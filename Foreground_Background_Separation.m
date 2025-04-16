function [Background] = Foreground_Background_Separation(Foreground, Entire, Initial_Frame, Final_Frame, Nbr_Training_Frames)
%% Foreground_Background_Separation: Separates Background from Foreground in Video Frames
%
%  This function computes the background of video frames by removing the
%  detected foreground regions from the entire frame. The first set of frames
%  (as defined by Nbr_Training_Frames) are used for background initialization 
%  (set as zeros), and the subsequent frames are processed using the Remove_Foreground
%  function to extract the background components.
%
%  Inputs:
%    Foreground          - 3D matrix containing the foreground detections for each frame.
%    Entire              - 3D matrix containing the complete video frames.
%    Initial_Frame       - Index of the first frame to process.
%    Final_Frame         - Index of the last frame to process.
%    Nbr_Training_Frames - Number of frames used for background model initialization.
%
%  Output:
%    Background - 3D matrix where each slice is the computed background for the corresponding frame.


% Initialize the output background matrix.
Background = [];
INX = 1;

% Create a waitbar to indicate progress of the background computation.
Wait_Bar1 = waitbar(0, 'Background Computation');

% For the initial training frames, set the background as zeros.
for i = Initial_Frame : (Initial_Frame + Nbr_Training_Frames - 1)
    Background(:, :, INX) = zeros(size(Entire, 1), size(Entire, 2));
    INX = INX + 1;
    % Update progress in the waitbar.
    waitbar((i - Initial_Frame) / (Final_Frame - Initial_Frame), Wait_Bar1, 'Background Computation');
end

% For the remaining frames, compute the background by removing the detected foreground.
for k = Initial_Frame + Nbr_Training_Frames : Final_Frame
    % Remove the foreground from the entire frame using the Remove_Foreground function.
    Background(:, :, INX) = Remove_Foreground(Foreground(:, :, INX), Entire(:, :, INX));
    INX = INX + 1;
    % Update the progress indicator.
    waitbar((k - Initial_Frame) / (Final_Frame - Initial_Frame), Wait_Bar1, 'Background Computation');
end

% Close the waitbar once the processing is complete.
close(Wait_Bar1)

end
