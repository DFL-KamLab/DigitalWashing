function [precision, recall, assessment, detections, output_seg_image] = MotionDetection_GaussianMixture(VIDEO, def_loc, Initial_Frame, Final_Frame, numTrain, DataType)
%% MD_GM: Motion Detection and Segmentation for Digital Washing
%
%  Inputs:
%    VIDEO         - Input video tensor
%    def_loc       - Ground truth object locations (matrix with coordinates and frame indices)
%    Initial_Frame - Index of the first frame to process
%    Final_Frame   - Index of the last frame to process
%    numTrain      - Number of frames used for background training (e.g., 20)
%    DataType      - Data type flag: 1 for raw video, 0 for pre-converted data
%
%  Outputs:
%    precision         - Overall precision of detection
%    recall            - Overall recall of detection
%    assessment        - Matrix with per-frame true positives, false positives, false negatives, and frame index
%    detections        - Matrix with detected coordinates and corresponding frame indices
%    output_seg_image  - Segmented foreground image for each processed frame
%


PixelSize = 20;
z = 3;

if DataType == 1
    detected_image = Motion_filter_JC_v2(VIDEO, Initial_Frame, Final_Frame, numTrain, z);
else
    detected_image = Motion_filter_JC_v2_DAT(VIDEO, Initial_Frame, Final_Frame, numTrain, z);
end

X_Check = size(detected_image, 2);
Y_Check = size(detected_image, 1);
c = 20;

assessment = [];
detections = [];
output_seg_image = zeros(Y_Check, X_Check, numTrain);

for i = Initial_Frame+numTrain : Final_Frame
    j = i - numTrain - Initial_Frame + 1;
    seg_out = imdilate(detected_image(:, :, j), strel('disk', 7));
    seg_out = imerode(seg_out, strel('disk', 7));
    morph = imclearborder(seg_out);
    
    [Y, Fore] = Localization_Sim(morph, PixelSize);
    
    X_x = def_loc(def_loc(:,3) == i, 1);
    X_y = def_loc(def_loc(:,3) == i, 2);
    X = [X_x, X_y];
    
    [tp, fp, fn] = Detection_Assessment(X', Y', c);
    assessment = [assessment; tp fp fn i];
    detections = [detections; Y, ones(size(Y,1), 1) * i];
    output_seg_image(:, :, j+numTrain) = Fore;
    
    % (Progress indicator; remove if not required)
    disp(j / (Final_Frame - (Initial_Frame + numTrain)));
end

precision = sum(assessment(:,1)) / (sum(assessment(:,1)) + sum(assessment(:,2)));
recall = sum(assessment(:,1)) / (sum(assessment(:,1)) + sum(assessment(:,3)));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function detected_image = Motion_filter_JC_v2_DAT(VIDEO, start_F, end_F, train_N, threshold)
%% Motion_filter_JC_v2_DAT: Motion Detection for Pre-converted Data
%
%  Inputs:
%    VIDEO     - Input video tensor (data file format)
%    start_F   - Starting frame index
%    end_F     - Ending frame index
%    train_N   - Number of training frames for background initialization
%    threshold - Threshold multiplier for motion detection
%
%  Output:
%    detected_image - Binary tensor with detected motion regions
%


med_filter_size = 3;
for i = start_F:end_F
    j = i - start_F + 1;
    Image_data(:, :, j) = VIDEO(:, :, j) / 255;
    Filter_G(:, :, j) = medfilt2(Image_data(:, :, j), [med_filter_size med_filter_size]);
    
    clc;
    disp(strcat('Importing: ', num2str(round(j/(end_F - start_F + 1)*100,1)), ' %'));
end

mean_init = mean(Image_data(:, :, 1:train_N), 3);
var_init = var(Image_data(:, :, 1:train_N), 0, 3);
mean_F_G_init = mean(Filter_G(:, :, 1:train_N), 3);
var_F_G_init = var(Filter_G(:, :, 1:train_N), 0, 3);

mean_t = mean_init;
var_t = var_init;
mean_F_G_t = mean_F_G_init;
var_F_G_t = var_F_G_init;

for j = (start_F + train_N):end_F
    k = j - start_F + 1;
    if any(var_t > 1/255, 'all')
        var_t(var_t < 1/255) = 1 / (255*3);
    end
    if any(var_F_G_t > 1/255, 'all')
        var_F_G_t(var_F_G_t < 1/255) = 1 / (255*3);
    end
    Above_T = Image_data(:, :, k) > (mean_t + threshold * sqrt(var_t));
    Below_T = Image_data(:, :, k) < (mean_t - threshold * sqrt(var_t));
    detected_particles(:, :, k - train_N) = Above_T + Below_T;
    
    Above_F_G_T = Filter_G(:, :, k) > (mean_F_G_t + threshold * sqrt(var_F_G_t));
    Below_F_G_T = Filter_G(:, :, k) < (mean_F_G_t - threshold * sqrt(var_F_G_t));
    detected_particles_F_G(:, :, k - train_N) = Above_F_G_T + Below_F_G_T;
    
    Mix_image = and(detected_particles(:, :, k - train_N), detected_particles_F_G(:, :, k - train_N));
    [mean_t, var_t] = update_m_v(mean_t, var_t, Image_data(:, :, k - train_N), Image_data(:, :, k), train_N);
    [mean_F_G_t, var_F_G_t] = update_m_v(mean_F_G_t, var_F_G_t, Filter_G(:, :, k - train_N), Filter_G(:, :, k), train_N);
    
    detected_image(:, :, j - start_F - train_N + 1) = Mix_image;
    clc;
    disp(['Pending... ', num2str(round(k/end_F*100,2)), ' %']);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function detected_image = Motion_filter_JC_v2(video, start_F, end_F, train_N, threshold)
%% Motion_filter_JC_v2: Motion Detection for Video Input
%
%  Inputs:
%    video     - Input video file or object
%    start_F   - Starting frame index for processing
%    end_F     - Ending frame index for processing
%    train_N   - Number of training frames for background initialization
%    threshold - Threshold multiplier for motion detection
%
%  Output:
%    detected_image - Binary tensor with detected motion regions


med_filter_size = 3;
for i = start_F:end_F
    j = i - start_F + 1;
    Image_data(:, :, j) = double(rgb2gray(read(video, i))) / 255;
    Filter_G(:, :, j) = medfilt2(Image_data(:, :, j), [med_filter_size med_filter_size]);
    
    clc;
    disp(strcat('Importing: ', num2str(round(j/(end_F - start_F + 1)*100,1)), ' %'));
end

mean_init = mean(Image_data(:, :, 1:train_N), 3);
var_init = var(Image_data(:, :, 1:train_N), 0, 3);
mean_F_G_init = mean(Filter_G(:, :, 1:train_N), 3);
var_F_G_init = var(Filter_G(:, :, 1:train_N), 0, 3);

mean_t = mean_init;
var_t = var_init;
mean_F_G_t = mean_F_G_init;
var_F_G_t = var_F_G_init;

for k = (start_F + train_N):end_F
    if any(var_t > 1/255, 'all')
        var_t(var_t < 1/255) = 1 / (255*3);
    end
    if any(var_F_G_t > 1/255, 'all')
        var_F_G_t(var_F_G_t < 1/255) = 1 / (255*3);
    end
    Above_T = Image_data(:, :, k) > (mean_t + threshold * sqrt(var_t));
    Below_T = Image_data(:, :, k) < (mean_t - threshold * sqrt(var_t));
    detected_particles(:, :, k - train_N) = Above_T + Below_T;
    
    Above_F_G_T = Filter_G(:, :, k) > (mean_F_G_t + threshold * sqrt(var_F_G_t));
    Below_F_G_T = Filter_G(:, :, k) < (mean_F_G_t - threshold * sqrt(var_F_G_t));
    detected_particles_F_G(:, :, k - train_N) = Above_F_G_T + Below_F_G_T;
    
    Mix_image = and(detected_particles(:, :, k - train_N), detected_particles_F_G(:, :, k - train_N));
    [mean_t, var_t] = update_m_v(mean_t, var_t, Image_data(:, :, k - train_N), Image_data(:, :, k), train_N);
    [mean_F_G_t, var_F_G_t] = update_m_v(mean_F_G_t, var_F_G_t, Filter_G(:, :, k - train_N), Filter_G(:, :, k), train_N);
    
    detected_image(:, :, k - start_F - train_N + 1) = Mix_image;
    disp(['Pending... ', num2str(round(k/end_F*100,2)), ' %']);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [mean, variance] = update_m_v(mean, variance, old_point, new_point, train_N)
%% update_m_v: Online Update of Mean and Variance (Welford's Algorithm)
%
%  Inputs:
%    mean      - Current mean image (background model)
%    variance  - Current variance image (background model)
%    old_point - Oldest frame to be removed from the model
%    new_point - New frame to be added to the model
%    train_N   - Number of training frames
%
%  Outputs:
%    mean      - Updated mean image
%    variance  - Updated variance image
%


M_n1 = old_point - mean;
mean = mean - M_n1 / train_N;
variance = variance - M_n1.^2 / train_N + variance / (train_N - 1);

M_1 = new_point - mean;
mean = mean + M_1 / train_N;
variance = variance + M_1.^2 / train_N - variance / (train_N - 1);
end




