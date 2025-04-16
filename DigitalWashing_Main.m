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
close all;              % Close all open figure windows
clear;                  % Clear workspace variables
clc;                    % Clear command window

global C;               % Declare global constant for detection assessment
C = 20;

% File paths for subject data
Video_Tensor_Path = 'Path to the video tensor file';
GT_File           = 'Path to the ground truth def_loc file';

% Subject-specific parameters
Frame_Range      = [501, 700];
Frame_Range_Str  = sprintf('%d-%d', Frame_Range(1), Frame_Range(2));
K_Val            = 1.7;

fprintf('Processing video using frames %s and k value %.1f...\n', Frame_Range_Str, K_Val);


%% ------------------------------------------------------------------------
%  1. LOAD VIDEO TENSOR DATA
%  ------------------------------------------------------------------------
if ~exist(Video_Tensor_Path, 'file')
    error('Video tensor file not found: %s', Video_Tensor_Path);
end

Data_Struct   = load(Video_Tensor_Path);
Vars          = fieldnames(Data_Struct);
Video_Tensor  = Data_Struct.(Vars{1});
Tensor_Size   = size(Video_Tensor);

% Convert to grayscale if necessary
if numel(Tensor_Size) == 4 && Tensor_Size(4) == 3
    Num_Frames = Tensor_Size(3);
    X_Dim      = Tensor_Size(1);
    Y_Dim      = Tensor_Size(2);
    Video_Array = zeros(X_Dim, Y_Dim, Num_Frames);
    for Frame_Index = 1:Num_Frames
        RGB_Frame         = squeeze(uint8(Video_Tensor(:, :, Frame_Index, :)));
        Grayscale_Frame   = rgb2gray(RGB_Frame);
        Video_Array(:, :, Frame_Index) = double(Grayscale_Frame);
    end
else
    Video_Array = double(Video_Tensor);
end


%% ------------------------------------------------------------------------
%  2. LOAD GROUND TRUTH DATA (Def_Loc)
%  ------------------------------------------------------------------------
if ~exist(GT_File, 'file')
    error('Ground truth file not found: %s', GT_File);
end

GT_Data = load(GT_File);
if isfield(GT_Data, 'def_loc')
    Def_Loc = GT_Data.def_loc;
else
    error('Variable "def_loc" not found in ground truth file.');
end


%% ------------------------------------------------------------------------
%  2.1 CROP VIDEO AND RE-INDEX GROUND TRUTH FRAMES
%  ------------------------------------------------------------------------
Video_Array = Video_Array(:, :, Frame_Range(1):Frame_Range(2));
Def_Loc(:,3) = Def_Loc(:,3) - (Frame_Range(1) - 1);

Initial_Frame = 1;
Final_Frame   = size(Video_Array, 3);


%% ------------------------------------------------------------------------
%  3. PREPROCESSING AND FEATURE EXTRACTION
%  ------------------------------------------------------------------------
Nbr_Training_Frames = 20;

[Precision_MD, Recall_MD, Assessment_MD, Detections_MD, Foreground_Video] = ...
    MotionDetection_GaussianMixture(Video_Array, Def_Loc, Initial_Frame, Final_Frame, Nbr_Training_Frames, 0);

Locations_And_Features_Foreground = ...
    Features_Calculation(Video_Array, Foreground_Video, Initial_Frame, Final_Frame, Nbr_Training_Frames, 1);

Binarized_Video = ...
    Binarization_Method(0, Initial_Frame, Final_Frame, Video_Array);

Background_Video = ...
    Foreground_Background_Separation(logical(Foreground_Video), logical(Binarized_Video), Initial_Frame, Final_Frame, Nbr_Training_Frames);

Locations_And_Features_Background = ...
    Features_Calculation(Video_Array, Background_Video, Initial_Frame, Final_Frame, Nbr_Training_Frames, 0);


%% ------------------------------------------------------------------------
%  4. LOCAL DETECTION AND PERFORMANCE ASSESSMENT
%  ------------------------------------------------------------------------
Local_Detectors_Decisions_Binary = ...
    Local_Detectors_Decisions( ...
        Locations_And_Features_Foreground, ...
        Locations_And_Features_Background, ...
        Initial_Frame, Final_Frame, Nbr_Training_Frames, K_Val);

X_Check = size(Video_Array, 2);
Y_Check = size(Video_Array, 1);

Local_Detectors_Decisions_Binary_Reduced = Local_Detectors_Decisions_Binary( ...
    (Local_Detectors_Decisions_Binary(:,1) >= 21 & Local_Detectors_Decisions_Binary(:,1) <= X_Check-20) & ...
    (Local_Detectors_Decisions_Binary(:,2) >= 21 & Local_Detectors_Decisions_Binary(:,2) <= Y_Check-20), :);

Def_Loc_Reduced = Def_Loc( ...
    (Def_Loc(:,1) >= 21 & Def_Loc(:,1) <= X_Check-20) & ...
    (Def_Loc(:,2) >= 21 & Def_Loc(:,2) <= Y_Check-20), :);

Assessment  = [];
Detections  = [];

for Frame_Index = Initial_Frame + Nbr_Training_Frames : Final_Frame
    Y_Est = Local_Detectors_Decisions_Binary_Reduced( ...
        Local_Detectors_Decisions_Binary_Reduced(:,3) == Frame_Index, 1:2);
    X_GT  = Def_Loc_Reduced(Def_Loc_Reduced(:,3) == Frame_Index, 1:2);

    [TP, FP, FN] = Detection_Assessment(X_GT', Y_Est', C);
    Assessment = [Assessment; TP, FP, FN, Frame_Index];
    Detections = [Detections; Y_Est, ones(size(Y_Est,1),1)*Frame_Index];
end

Precision_Val = sum(Assessment(:,1)) / (sum(Assessment(:,1)) + sum(Assessment(:,2)));
Recall_Val    = sum(Assessment(:,1)) / (sum(Assessment(:,1)) + sum(Assessment(:,3)));
F1_Val        = F_Beta_Score(Precision_Val, Recall_Val, 1);
F05_Val       = F_Beta_Score(Precision_Val, Recall_Val, 0.5);
F2_Val        = F_Beta_Score(Precision_Val, Recall_Val, 2);


%% ------------------------------------------------------------------------
%  5. DISPLAY RESULTS
%  ------------------------------------------------------------------------
fprintf('Results for Subject %d (frames %s) with k = %.1f:\n', ...
    Subject_ID, Frame_Range_Str, K_Val);
fprintf('Precision: %.4f | Recall: %.4f | F1: %.4f | F0.5: %.4f | F2: %.4f\n', ...
    Precision_Val, Recall_Val, F1_Val, F05_Val, F2_Val);

disp('Processing complete.');
