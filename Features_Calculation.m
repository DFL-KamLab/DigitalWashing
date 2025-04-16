function [Locations_and_Features] = Features_Calculation(Video_Orig, Video_Bin, Initial_Frame, Final_Frame, Nbr_Training_Frames, Fore_Back)
%% Features_Calculation: Extracts Geometric Features from Video Frames
%
%  This function computes a set of geometric features from a series of video
%  frames. It processes two input video matrices (original and binary), extracts
%  features from each frame using the function Features_and_Detections_V08, and 
%  aggregates these features into one output matrix.
%
%  Inputs:
%    Video_Orig          - 3D matrix of the original video (each slice is a frame)
%    Video_Bin           - 3D matrix of the binary (segmented) video
%    Initial_Frame       - Index of the first frame to process
%    Final_Frame         - Index of the last frame to process
%    Nbr_Training_Frames - Number of training frames used for initialization
%    Fore_Back           - Flag indicating whether to process foreground (1) or background (0)
%
%  Output:
%    Locations_and_Features - Matrix containing the extracted features for each processed frame
%
%  Notes:
%    - This version uses Features_and_Detections_V08 (instead of V07) for feature extraction.
%


% Determine the starting index for processing after the training frames.
INX = length(Initial_Frame : (Initial_Frame + Nbr_Training_Frames));

% Initialize the output variable that will hold all features.
Locations_and_Features = [];

% (Optional) Initialize variables for specific features if needed later.
HU_FEATURE_ForeGround = [];
ZERNIKE_FEATURE_ForeGround = [];
MINOR_MAJOR_RATIO_AXIS_ForeGround = [];
MINOR_AXIS_ForeGround = [];
MAJOR_AXIS_ForeGround = [];
XCORR_PEAKS_ForeGround = [];

% Determine the text label based on processing type: Foreground or Background.
if Fore_Back == 1
    TeXt = 'Foreground';
elseif Fore_Back == 0
    TeXt = 'Background';
end

% Create a waitbar to show progress during feature extraction.
Wait_Bar1 = waitbar((Nbr_Training_Frames - Initial_Frame) / (Final_Frame - Initial_Frame),...
    'Features Calculation');

% Loop over all frames starting after the training frames.
for k = Initial_Frame + Nbr_Training_Frames : Final_Frame
    
    % Extract the corresponding original and binary frames using the index INX.
    Orig = Video_Orig(:, :, INX);
    Bin = Video_Bin(:, :, INX);
    
    % Calculate features for the current frame using the updated version of the feature
    % extraction function. The output 'OutPut' holds the features for the current frame.
    [OutPut, ~] = Features_and_Detections(Orig, Bin, k, 0); 
    % Append the newly computed features to the aggregated matrix.
    Locations_and_Features = [Locations_and_Features; OutPut];
    
    % Update the waitbar with the current progress and display a message.
    progress_percent = round(((k - Initial_Frame) / (Final_Frame - Initial_Frame)) * 100, 1);
    waitbar((k - Initial_Frame) / (Final_Frame - Initial_Frame), Wait_Bar1, ...
        ['Features Calculation for ', TeXt, ' (', num2str(progress_percent), '%)']);
    
    % Increment the frame index used for the video matrices.
    INX = INX + 1;
end

% Close the waitbar after processing is completed.
close(Wait_Bar1)

end
