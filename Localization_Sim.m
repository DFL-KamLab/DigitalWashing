function [detection, ImG] = Localization_Sim(seg_out, PixelSize)
%% localization_sim: Localize Objects in a Segmented Image with Size Filtering
%
%  This function processes a binary segmented image to extract the centroids of 
%  connected components (objects) using 8-connected region labeling. It excludes 
%  objects smaller than a specified PixelSize by filtering based on their area, and 
%  removes these small objects from the output image.
%
%  Inputs:
%    seg_out   - Binary segmented image (logical or binary image) resulting 
%                from a thresholding or segmentation process.
%    PixelSize - Minimum object area (in pixels) for an object to be considered.
%
%  Outputs:
%    detection - Nx2 matrix containing the [x, y] coordinates of detected objects 
%                that meet the minimum size criterion.
%    ImG       - Processed binary image after removing objects smaller than PixelSize.
%


% Label connected components using 8-connectivity.
[labelMatrix, ~] = bwlabel(seg_out, 8);

% Compute region properties for labeled objects; extract centroids.
d = regionprops(labelMatrix, 'Centroid');
g = cat(1, d.Centroid);

% Initialize the output image as a copy of the segmented input.
ImG = seg_out;

if isempty(g)
    % No objects detected: return empty coordinates.
    xdata = [];
    ydata = [];
else
    % Extract x and y coordinates from the centroids.
    x = g(:, 1);
    y = g(:, 2);

    % Recompute region properties to obtain areas and PixelList for size filtering.
    d = regionprops(labelMatrix, 'Area', 'PixelList');
    % Extract areas of each region.
    areas = cat(1, d.Area);
    % Identify regions with area greater than or equal to PixelSize.
    idx = (areas >= PixelSize);
    
    % Select centroids corresponding to valid regions.
    xdata = x(idx)';
    ydata = y(idx)'; 
    
    % Loop through all regions to remove small objects from the image.
    for i = 1:length(d)
        if d(i).Area < PixelSize
            % For objects smaller than PixelSize, obtain their pixel list.
            PiX = d(i).PixelList;
            % Set these pixel values to 0 in the output image to remove the object.
            ImG(PiX(:,2), PiX(:,1)) = 0;
        end
    end
end

% Construct the output detection matrix as [x, y] coordinates.
detection = [xdata' ydata'];
end
