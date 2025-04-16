function [Output] = Remove_Foreground(Foreground, Frame)
%% Remove_Foreground: Remove Foreground Regions from a Frame
%
%  This function subtracts the foreground objects from an entire frame.
%  It labels the connected components of both the given foreground mask and
%  the frame and then removes (sets to 0) the pixels in the frame that
%  overlap with any of the detected foreground regions.
%
%  Inputs:
%    Foreground - Binary image where foreground regions are marked as non-zero.
%    Frame      - The original frame (grayscale or binary) from which the 
%                 foreground should be removed.
%
%  Output:
%    Output     - The frame with foreground regions removed (pixel values set to 0).
%


% Initialize the output as a copy of the input frame.
Output = Frame;

% Label the connected components in the foreground mask using 8-connectivity.
[labelMatrix1, ~] = bwlabel(Foreground, 8);
% Obtain the pixel coordinates for each connected component in the foreground.
d1 = regionprops(Foreground, 'PixelList');

% Label the connected components in the frame.
[labelMatrix2, ~] = bwlabel(Frame, 8);
% Obtain the pixel coordinates for each connected component in the frame.
d2 = regionprops(Frame, 'PixelList');

% Loop through each connected component in the foreground mask.
for i = 1 : length(d1)
    % Get the list of pixel coordinates for the i-th foreground region.
    PiX_LoC = d1(i).PixelList;
    
    % Loop through each connected component in the frame.
    for j = 1 : length(d2)
        % Check if the current frame region (d2) intersects with the 
        % foreground region (d1) in both x and y coordinates.
        if ~isempty(intersect(PiX_LoC(:,1), d2(j).PixelList(:,1))) && ...
           ~isempty(intersect(PiX_LoC(:,2), d2(j).PixelList(:,2)))
       
            % For every pixel in the overlapping region, set the pixel value to 0.
            for p = 1 : size(d2(j).PixelList, 1)
                Output(d2(j).PixelList(p,2), d2(j).PixelList(p,1)) = 0;
            end
        end
    end
end

end
