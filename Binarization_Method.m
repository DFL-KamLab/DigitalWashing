function [Video_Out] = Binarization_Method(Method, Initial_Frame, Final_Frame, VIDEO)
%% Binarization_Method: Frame Binarization Using Multiple Thresholding Techniques
%
%  This function processes video frames by applying a specified binarization
%  method. Depending on the provided method code, a different thresholding
%  algorithm is applied to each frame. The resulting binary image is then post-
%  processed using morphological operations to clean the segmentation.
%
%  Inputs:
%    Method       - Numeric code for the binarization method:
%                   1: Otsu thresholding
%                   2: Adaptive thresholding
%                   3: Urbano segmentation
%                   4: Abbiramy segmentation
%                   5: Sauvola thresholding
%                   Otherwise: Fixed method as proposed in the paper
%    Initial_Frame - Starting frame index for processing
%    Final_Frame   - Ending frame index for processing
%    VIDEO         - 3D video tensor (rows x columns x frames)
%
%  Output:
%    Video_Out     - 3D matrix containing binarized output frames after morphological filtering


% Initialize the output video matrix.
Video_Out = [];

% Create a waitbar to indicate frame processing progress.
Wait_Bar1 = waitbar(0, 'Frame Binarization');

% Define the minimum area (in pixels) that a blob must have to be retained.
PixelSize = 20;

if Method == 1
    % Method 1: Otsu Thresholding
    for k = 1:length(Initial_Frame:Final_Frame)
        I = uint8(VIDEO(:,:,k));  % Extract current frame and convert to uint8.
        
        % Apply Otsu thresholding to obtain an initial segmentation.
        seg_out = Otsu_Threshold(I);
        % Clean the segmented output with morphological operations.
        morph_out = Morph_Image(seg_out);
        % Invert the image if needed, then remove small objects.
        morph_out = imcomplement(morph_out);
        morph_out = bwareaopen(morph_out, PixelSize);
        
        % Store the processed frame.
        Video_Out(:,:,k) = morph_out;
        % Update progress.
        waitbar((k - Initial_Frame) / (Final_Frame - Initial_Frame), Wait_Bar1, 'Frame Binarization using Otsu');
    end

elseif Method == 3
    % Method 3: Urbano Segmentation
    for k = 1:length(Initial_Frame:Final_Frame)
        I = uint8(VIDEO(:,:,k));
        
        % Apply Urbano segmentation algorithm (version 2).
        seg_out = Urbano_Seg(I);
        % Clear objects touching the image border.
        seg_out = imclearborder(seg_out);
        % Perform additional morphological filtering (version 4).
        morph_out = Morph_Image_Urbano(seg_out);
        % Remove small objects.
        morph_out = bwareaopen(morph_out, PixelSize);
        
        % Store the processed frame.
        Video_Out(:,:,k) = morph_out;
        % Update progress indicator.
        waitbar((k - Initial_Frame) / (Final_Frame - Initial_Frame), Wait_Bar1, 'Frame Binarization using Urbano');
    end

elseif Method == 5
    % Method 5: Sauvola Thresholding
    for k = 1:length(Initial_Frame:Final_Frame)
        I = uint8(VIDEO(:,:,k));
        
        % Apply Sauvola thresholding with a window size of [20 20] and k factor of 0.15.
        seg_out = Sauvola_Threshold(I, [20 20], 0.15);
        % Invert and clear border artifacts.
        seg_out = imclearborder(imcomplement(seg_out));
        % Process segmentation with morphological operations (version 4).
        morph_out = Morph_Image_Sauvola(seg_out);
        % Remove objects smaller than the PixelSize.
        morph_out = bwareaopen(morph_out, PixelSize);
        
        % Save the processed binary frame.
        Video_Out(:,:,k) = morph_out;
        % Update progress.
        waitbar((k - Initial_Frame) / (Final_Frame - Initial_Frame), Wait_Bar1, 'Frame Binarization using Sauvola');
    end

else
    % Default Method: Fixed method as proposed in the paper.
    for k = 1:length(Initial_Frame:Final_Frame)
        I = uint8(VIDEO(:,:,k));
        
        % Apply the custom binarization method MyMethod_V01.
        morph_out = Log_Based_Binarization(I);
        
        % Save the resulting binary frame.
        Video_Out(:,:,k) = morph_out;
        % Update the waitbar with progress information.
        waitbar((k - Initial_Frame) / (Final_Frame - Initial_Frame), Wait_Bar1, 'Frame Binarization using Log Based Binarization');
    end
end

% Close the waitbar when processing is complete.
close(Wait_Bar1)
end
