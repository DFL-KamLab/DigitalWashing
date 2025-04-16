function [OutPut, props] = Features_and_Detections(Gray_Image, Bin_Image, FraMe, flag)
%% Features_and_Detections: Extract Geometric Features and Local Detections from Cell Images
%
%  This function extracts features and detections from an input grayscale image,
%  using an initial binary segmentation. It computes various geometric properties
%  for each blob detected in the binary image and then refines the analysis by
%  processing a localized region around each detected blob. The function calculates:
%       - Minor and major axis lengths of the blob (and their ratio)
%       - Hu features and Zernike moments (as measures of shape complexity)
%       - Cross-correlation peaks from second-derivative analysis along extended axes
%
%  The processed features are compiled into a matrix, with additional display options 
%  controlled by the 'flag' parameter.
%
%  Inputs:
%    Gray_Image - The original grayscale image.
%    Bin_Image  - The binary segmented image.
%    FraMe      - A scaling factor used to mark the frame number in the output.
%    flag       - Display flag: if 1, additional figures with processing details are shown.
%
%  Outputs:
%    OutPut - A matrix where each row contains the following features:
%             [x_center, y_center, MINOR_AXIS, MAJOR_AXIS, MINOR_MAJOR_RATIO_AXIS,
%              HU_FEATURE, ZERNIKE_FEATURE, XCORR_PEAKS, FraMe]
%    props  - The region properties computed on the binary image (using regionprops),
%             including MajorAxisLength, MinorAxisLength, Orientation, Centroid,
%             Perimeter, Area, and BoundingBox.
%


% Compute region properties on the binary image (ensuring the image is logical).
props = regionprops(logical(Bin_Image), 'MajorAxisLength', 'MinorAxisLength', 'Orientation', 'Centroid', 'Perimeter', 'Area', 'BoundingBox');

% Define parameters for processing.
Axis_Ext = 5;   % Extension factor for axis calculation.
F = 3;          % Resize factor for the localized region.
[r, c] = size(Gray_Image);

% Preallocate arrays for storing extracted features.
MINOR_AXIS = [];
MAJOR_AXIS = [];
MINOR_MAJOR_RATIO_AXIS = [];
HU_FEATURE = [];
ZERNIKE_FEATURE = [];
XCORR_PEAKS = [];
x_center = [];
y_center = [];

% Process each blob detected in the binary image.
for i = 1:length(props)
    % Retrieve key properties of the current blob.
    xCenter = props(i).Centroid(1);
    yCenter = props(i).Centroid(2);
    xRadius = props(i).MinorAxisLength / 2;
    yRadius = props(i).MajorAxisLength / 2;
    Angle = props(i).Orientation;
    Perim = props(i).Perimeter;
    
    % Calculate ellipse axes and extended lines for the blob using a helper function.
    % (x_line1_1, y_line1_1, etc.) are computed for visualization and reference.
    [x_line1_1, y_line1_1, x_line2_1, y_line2_1, x, y] = Ellipse_and_Axes(xCenter, ...
        yCenter, xRadius, yRadius, Angle, Perim, 1);
    
    % Extract a localized region (approximately 30x30 pixels) around the blob.
    [IMM_Orig, x_line1, y_line1, x_line2, y_line2, x_ori, y_ori, x_rect, y_rect] = Image_Around_Detected_Cells(Gray_Image, xCenter, yCenter, xRadius, yRadius, Perim, Angle, Axis_Ext);
    
    % Enhance the localized region:
    %   - Resize it by a factor F.
    %   - Sharpen the image for clearer feature extraction.
    IMM = imresize(IMM_Orig, F);
    IMM = imsharpen(IMM, 'Radius', 30, 'Amount', 2);
    
    % Apply Sauvola thresholding to binarize the enhanced image.
    IMM_BS = imcomplement(Sauvola_Threshold(IMM, [20 20], 0.15)); 
    % Post-process the binary image with morphological operations.
    IMM_BS = imdilate(IMM_BS, strel('disk', 3));
    IMM_BS = imfill(IMM_BS, 'holes');  
    IMM_BS = imerode(IMM_BS, strel('disk', 9));
    IMM_BS = bwareaopen(IMM_BS, 50);
    
    % Obtain region properties from the processed localized region.
    props1 = regionprops(IMM_BS, 'PixelList', 'MajorAxisLength', 'MinorAxisLength', 'Orientation', 'Centroid', 'Perimeter', 'Area', 'BoundingBox');
    
    % Proceed if the localized region contains detectable features.
    if ~isempty(props1)
        % If multiple regions are detected, select the one closest to the center of the box.
        if length(props1) > 1
            DiSt = zeros(1, length(props1));
            for kkk = 1:length(props1)
                A = props1(kkk).Centroid(1);
                B = props1(kkk).Centroid(2);
                % Compute distance from the assumed center of the region (assumed at half of [150 150]).
                DiSt(kkk) = sum(([A B] - [150 150] / 2) .^ 2);
            end
            [~, Inx] = min(DiSt);
        else
            Inx = 1;
        end
        
        % Extract the properties of the chosen region.
        IM_PixelList = props1(Inx).PixelList;
        IM_MajorAxisLength = props1(Inx).MajorAxisLength;
        IM_MinorAxisLength = props1(Inx).MinorAxisLength;
        xRadius1 = IM_MinorAxisLength / 2;
        yRadius1 = IM_MajorAxisLength / 2;
        IM_Orientation = props1(Inx).Orientation;
        IM_Centroid = props1(Inx).Centroid;
        IM_Perimeter = props1(Inx).Perimeter;
        IM_Area = props1(Inx).Area;
        
        xCenter1 = IM_Centroid(1);
        yCenter1 = IM_Centroid(2);
        
        % Compute ellipse parameters for the localized region.
        [x_line1_2, y_line1_2, x_line2_2, y_line2_2, x1, y1] = Ellipse_and_Axes(xCenter1, ...
            yCenter1, xRadius1, yRadius1, IM_Orientation, IM_Perimeter, Axis_Ext);
        
        
        % Compute additional shape descriptors:
        %   Hu features from the processed image.
        IMmM = double(IMM);
        M = Feature_Vector(IMmM);
        M = -sign(M) .* log10(abs(M));
        Hu_FeaTureS = sum(abs(M));
       
        
        % Append computed features to the output vectors.
        MINOR_AXIS = [MINOR_AXIS xRadius1];
        MAJOR_AXIS = [MAJOR_AXIS yRadius1];
        MINOR_MAJOR_RATIO_AXIS = [MINOR_MAJOR_RATIO_AXIS (xRadius1 / yRadius1)];
        HU_FEATURE = [HU_FEATURE Hu_FeaTureS];
        x_center = [x_center xCenter];
        y_center = [y_center yCenter];
        
        % If the display flag is set, plot intermediate results for debugging.
        if flag == 1
            figure
            subplot(2,2,1)
            imshow(uint8(Gray_Image))
            hold on
            plot(x_line1_1, y_line1_1, 'g')
            plot(x_line2_1, y_line2_1, 'g')
            plot(x, y, 'g')
            hold off
            
            subplot(2,2,2)
            imshow(uint8(IMM))
            hold on
            plot(xCenter1, yCenter1, 'sqr')
            plot(x_line1_2, y_line1_2, 'r')
            plot(x_line2_2, y_line2_2, 'r')
            plot(x1, y1, 'r')
            hold off
            
            subplot(2,2,3)
            imshow(Bin_Image)
            hold on
            plot(x_line1_1, y_line1_1, 'g')
            plot(x_line2_1, y_line2_1, 'g')
            plot(x, y, 'g')
            hold off
            
            subplot(2,2,4)
            imshow(IMM_BS)
            hold on
            plot(xCenter1, yCenter1, 'sqr')
            plot(x_line1_2, y_line1_2, 'r')
            plot(x_line2_2, y_line2_2, 'r')
            plot(x1, y1, 'r')
            hold off
            
            figure
            subplot(4,2,[1,3])
            imshow(uint8(IMM))
            hold on
            plot(xCenter1, yCenter1, 'sqr')
            plot(x_line1_2, y_line1_2, 'r')
            plot(x_line2_2, y_line2_2, 'r')
            plot(x1, y1, 'r')
            hold off
            
            subplot(4,2,2)
            plot(X_Range, Int_X_Axis, 'r')
            ylabel('Pixel Intensity')
            xlabel('Pixel Number')
            title('Extended minor axis intensity')
            xlim([-200 200])
            
            subplot(4,2,4)
            plot(Y_Range, Int_Y_Axis, 'r')
            ylabel('Pixel Intensity')
            xlabel('Pixel Number')
            title('Extended major axis intensity')
            xlim([-200 200])
            
            subplot(4,2,[5,6,7,8])
            plot(x_fnc, y_fnc, 'b')
            xlabel('Lag')
            ylabel('2^{nd} derivative of XCorr')
        end
    end
end

% Compile all extracted features and center coordinates into the output matrix.
% Each row corresponds to a detected blob and contains:
% [x_center, y_center, MINOR_AXIS, MAJOR_AXIS, MINOR_MAJOR_RATIO_AXIS, HU_FEATURE, ZERNIKE_FEATURE, XCORR_PEAKS, FraMe]
OutPut = [x_center' y_center' MINOR_AXIS' MAJOR_AXIS' MINOR_MAJOR_RATIO_AXIS' HU_FEATURE' FraMe * ones(length(HU_FEATURE), 1)];

end
