%% ========================================================================
%  “DIGITAL WASHING” OF SEMEN TIME-LAPSE IMAGES
%
%  This script implements the "Digital Washing" algorithm presented in our paper.
%
%  Abstract:
%  We introduce a supervised learning method for sperm cell detection in time-lapse 
%  images collected from raw human semen samples. The method leverages a set of 
%  geometric features extracted from moving sperm cells (class SM) to identify 
%  immotile sperm cells (class SD), which typically share the same geometric features 
%  as moving sperm cells. This selective identification and separation process, 
%  termed "Digital Washing", is designed to distinguish immotile sperm cells from 
%  other non-sperm cells (class O) and debris. Tested on images from fourteen 
%  male volunteers, the method is benchmarked against Urbano et al.'s detection method 
%  (2017) and YOLOv5 VISEM-Tracking (2023), demonstrating performance metrics 
%  of precision 0.82±0.15, recall 0.92±0.03, F0.5-score 0.83±0.13, F1-score 0.86±0.09, 
%  and F2-score 0.89±0.05.
%
%  Description:
%  The script performs the following main tasks:
%    1. Loads a video tensor file containing time-lapse images for a specific subject 
%       and converts the data to grayscale if necessary.
%    2. Loads ground truth labels (Def_Loc) for the corresponding video.
%    3. Crops the video to a specified frame range and re-indexes the ground truth.
%    4. Executes preprocessing including motion detection, foreground/background 
%       segmentation, and feature extraction using custom functions.
%    5. Implements local detection based on a set threshold (K_Val) and assesses 
%       performance via precision, recall, and various F_beta scores.
%
%  Requirements:
%    - The video tensor file may contain either grayscale or RGB formatted data.
%    - The ground truth file must include a variable named 'def_loc'.
%    - Custom functions must be available and in the MATLAB path
%
%  Usage:
%    Adjust file paths and parameters as needed. Ensure all required custom functions 
%    are available in the MATLAB path before executing this script.
%
%  Date: April 15, 2025
%  ========================================================================

%% ------------------------------------------------------------------------
%  INITIALIZATION AND SETUP
%  ------------------------------------------------------------------------
close all;              % Close all open figure windows to reset visual state
clear;                  % Remove all variables from the workspace
clc;                    % Clear the command window display

global C;               % Declare a global constant for spatial tolerance in detection
C = 20;                 % Set the spatial tolerance (in pixels) for matching detections

% Path to the .mat file containing the video tensor:
%   - Dimensions: [width (pixels) × height (pixels) × number of frames]
Video_Tensor_Path = 'Path to the video tensor file';  

% Path to the ground truth file:
%   - Matrix with columns [x-coordinate, y-coordinate, frame index]
GT_File = 'Path to the ground truth file';  


% Subject-specific parameters
Frame_Range      = [1, 50];                         % Range of frames to process
Frame_Range_Str  = sprintf('%d-%d', Frame_Range(1), Frame_Range(2)); 
K_Val            = 1.7;                                % Decision parameter

fprintf('Processing video using frames %s and k value %.1f...\n', Frame_Range_Str, K_Val);


%% ------------------------------------------------------------------------
%  1. LOAD VIDEO TENSOR DATA
%  ------------------------------------------------------------------------
if ~exist(Video_Tensor_Path, 'file')
    error('Video tensor file not found: %s', Video_Tensor_Path);  % Abort if video file missing
end

Data_Struct   = load(Video_Tensor_Path);                  % Load the .mat file into a struct
Vars          = fieldnames(Data_Struct);                  % Get all variable names from the struct
Video_Tensor  = Data_Struct.(Vars{1});                     % Extract the first (and assumed only) variable
Tensor_Size   = size(Video_Tensor);                        % Determine dimensions of the tensor

% Convert to grayscale if tensor contains RGB frames
if numel(Tensor_Size) == 4 && Tensor_Size(4) == 3
    Num_Frames = Tensor_Size(3);                           % Number of time frames
    X_Dim      = Tensor_Size(1);                           % Width of frame (pixels)
    Y_Dim      = Tensor_Size(2);                           % Height of frame (pixels)
    Video_Array = zeros(X_Dim, Y_Dim, Num_Frames);         % Preallocate grayscale array

    for Frame_Index = 1:Num_Frames
        RGB_Frame       = squeeze(uint8(Video_Tensor(:, :, Frame_Index, :)));  % Extract RGB frame
        Grayscale_Frame = rgb2gray(RGB_Frame);             % Convert RGB to single-channel grayscale
        Video_Array(:, :, Frame_Index) = double(Grayscale_Frame);  % Store as double precision
    end
else
    Video_Array = double(Video_Tensor);                     % Already single-channel: cast to double
end


%% ------------------------------------------------------------------------
%  2. LOAD GROUND TRUTH DATA (Def_Loc)
%  ------------------------------------------------------------------------
if ~exist(GT_File, 'file')
    error('Ground truth file not found: %s', GT_File);     % Abort if GT file missing
end

% Load ground truth data from .mat file:
%   - def_loc: N×3 matrix with columns [x-coordinate, y-coordinate, frame index]
GT_Data = load(GT_File);
if isfield(GT_Data, 'def_loc')  % Ensure the variable 'def_loc' is present
    Def_Loc = GT_Data.def_loc;  % Extract the ground truth matrix
else
    error('Variable "def_loc" not found in ground truth file.');
end



%% ------------------------------------------------------------------------
%  2.1 CROP VIDEO AND RE-INDEX GROUND TRUTH FRAMES
%  ------------------------------------------------------------------------
Video_Array = Video_Array(:, :, Frame_Range(1):Frame_Range(2));  % Keep only desired frames
Def_Loc(:,3) = Def_Loc(:,3) - (Frame_Range(1) - 1);               % Shift GT frame indices

Initial_Frame = 1;                                               % First frame index after cropping
Final_Frame   = size(Video_Array, 3);                            % Last frame index in cropped video


%% ------------------------------------------------------------------------
%  3. PREPROCESSING AND FEATURE EXTRACTION
%  ------------------------------------------------------------------------
Nbr_Training_Frames = 20;                                        % Number of frames for background modeling

% Motion detection via Gaussian mixture modeling
[Precision_MD, Recall_MD, Assessment_MD, Detections_MD, Foreground_Video] = ...
    MotionDetection_GaussianMixture( ...
        Video_Array, Def_Loc, Initial_Frame, Final_Frame, Nbr_Training_Frames, 0);

% Extract features from the moving (foreground) regions
Locations_And_Features_Foreground = ...
    Features_Calculation( ...
        Video_Array, Foreground_Video, Initial_Frame, Final_Frame, Nbr_Training_Frames, 1);

% Binarize entire video
Binarized_Video = ...
    Binarization_Method(0, Initial_Frame, Final_Frame, Video_Array);

% Separate foreground and background
Background_Video = ...
    Foreground_Background_Separation( ...
        logical(Foreground_Video), logical(Binarized_Video), Initial_Frame, Final_Frame, Nbr_Training_Frames);

% Extract features from background
Locations_And_Features_Background = ...
    Features_Calculation( ...
        Video_Array, Background_Video, Initial_Frame, Final_Frame, Nbr_Training_Frames, 0);


%% ------------------------------------------------------------------------
%  4. LOCAL DETECTION AND PERFORMANCE ASSESSMENT
%  ------------------------------------------------------------------------
% Apply local decision rule with threshold K_Val
Local_Detectors_Decisions_Binary = ...
    Local_Detectors_Decisions( ...
        Locations_And_Features_Foreground, ...
        Locations_And_Features_Background, ...
        Initial_Frame, Final_Frame, Nbr_Training_Frames, K_Val);

% Determine valid spatial region to avoid border effects
X_Check = size(Video_Array, 2);  % Max x-coordinate
Y_Check = size(Video_Array, 1);  % Max y-coordinate

% Filter out detections too close to image borders
Local_Detectors_Decisions_Binary_Reduced = Local_Detectors_Decisions_Binary( ...
    (Local_Detectors_Decisions_Binary(:,1) >= 21 & Local_Detectors_Decisions_Binary(:,1) <= X_Check-20) & ...
    (Local_Detectors_Decisions_Binary(:,2) >= 21 & Local_Detectors_Decisions_Binary(:,2) <= Y_Check-20), :);

% Similarly restrict ground truth locations
Def_Loc_Reduced = Def_Loc( ...
    (Def_Loc(:,1) >= 21 & Def_Loc(:,1) <= X_Check-20) & ...
    (Def_Loc(:,2) >= 21 & Def_Loc(:,2) <= Y_Check-20), :);

Assessment  = [];  % Initialize array for TP, FP, FN per frame
Detections  = [];  % Initialize array to record all detections

% Loop through each frame beyond training period
for Frame_Index = Initial_Frame + Nbr_Training_Frames : Final_Frame
    % Get estimated detection positions for this frame
    Y_Est = Local_Detectors_Decisions_Binary_Reduced( ...
        Local_Detectors_Decisions_Binary_Reduced(:,3) == Frame_Index, 1:2);
    % Get ground truth positions for this frame
    X_GT  = Def_Loc_Reduced(Def_Loc_Reduced(:,3) == Frame_Index, 1:2);

    % Compute true positives, false positives, false negatives
    [TP, FP, FN] = Detection_Assessment(X_GT', Y_Est', C);
    % Append per-frame results
    Assessment = [Assessment; TP, FP, FN, Frame_Index];
    Detections = [Detections; Y_Est, ones(size(Y_Est,1),1)*Frame_Index];
end

% Compute overall precision and recall
Precision_Val = sum(Assessment(:,1)) / (sum(Assessment(:,1)) + sum(Assessment(:,2)));
Recall_Val    = sum(Assessment(:,1)) / (sum(Assessment(:,1)) + sum(Assessment(:,3)));

% Compute F‑scores for β = 1, 0.5, and 2
F1_Val  = F_Beta_Score(Precision_Val, Recall_Val, 1);
F05_Val = F_Beta_Score(Precision_Val, Recall_Val, 0.5);
F2_Val  = F_Beta_Score(Precision_Val, Recall_Val, 2);


%% ------------------------------------------------------------------------
%  5. DISPLAY RESULTS
%  ------------------------------------------------------------------------
fprintf('Results with k = %.1f:\n', ...
    Frame_Range_Str, K_Val);  % Print summary header
fprintf('Precision: %.4f | Recall: %.4f | F1: %.4f | F0.5: %.4f | F2: %.4f\n', ...
    Precision_Val, Recall_Val, F1_Val, F05_Val, F2_Val);  % Print metrics

disp('Processing complete.');  % Indicate script has finished
