function [Image_out, x_line1, y_line1, x_line2, y_line2, x, y, x_rect, y_rect] = Image_Around_Detected_Cells(Image_In, xCenter, yCenter, xRadius, yRadius, Perimeter, Angle, Axis_Ext)
%% Image_Around_Detected_Cells: Extract a Localized Region Around a Detected Blob
%
%  This function extracts a rectangular region from the input image that surrounds
%  a detected cell or blob, based on its centroid, axes lengths, orientation,
%  perimeter, and an extension factor. In addition, it computes:
%       - The rotated ellipse representing the blob perimeter.
%       - Extended axis lines (minor and major) for further feature analysis.
%       - A rectangular box (x_rect, y_rect) that defines the region of interest.
%
%  Inputs:
%    Image_In  - The original grayscale image.
%    xCenter   - X-coordinate of the blob's centroid.
%    yCenter   - Y-coordinate of the blob's centroid.
%    xRadius   - Half of the blob's minor axis length.
%    yRadius   - Half of the blob's major axis length.
%    Perimeter - Perimeter of the blob, used to determine the number of ellipse points.
%    Angle     - Orientation of the blob (in degrees).
%    Axis_Ext  - Extension factor for the axis lines.
%
%  Outputs:
%    Image_out - The cropped image region around the detected cell.
%    x_line1, y_line1 - Coordinates of the extended line along the minor axis.
%    x_line2, y_line2 - Coordinates of the extended line along the major axis.
%    x, y           - Coordinates of the rotated ellipse perimeter.
%    x_rect, y_rect - Coordinates defining the rectangular region of interest.
%
%  Author: [Your Name]
%  Date: [Today's Date]
%

% Get the size of the input image.
[r, c] = size(Image_In);

% Generate theta values based on the blob's perimeter to create the ellipse.
theta = linspace(0, 2*pi, 10*ceil(Perimeter));
x = xRadius * cos(theta);  % Unrotated x-coordinates for the ellipse.
y = yRadius * sin(theta);  % Unrotated y-coordinates for the ellipse.

% Create extended lines for the minor and major axes.
x_line1 = -Axis_Ext * xRadius : Axis_Ext * xRadius;   % Minor axis: extend horizontally.
y_line1 = zeros(1, length(x_line1));                   % Minor axis: y remains 0.
y_line2 = -Axis_Ext * yRadius : Axis_Ext * yRadius;     % Major axis: extend vertically.
x_line2 = zeros(1, length(y_line2));                   % Major axis: x remains 0.

% Adjust the orientation by subtracting 90 degrees (to convert to MATLAB image coordinates).
angleInDegrees = Angle - 90;
rotationMatrix = [cosd(angleInDegrees), -sind(angleInDegrees); sind(angleInDegrees), cosd(angleInDegrees)];

% Combine the ellipse perimeter points and the axis lines into coordinate matrices.
xy = [x', y'];
xy_line1 = [x_line1', y_line1'];
xy_line2 = [x_line2', y_line2'];

% Rotate the ellipse and the extended axis lines using the computed rotation matrix.
xyRotated = xy * rotationMatrix;
xyRotated_line1 = xy_line1 * rotationMatrix;
xyRotated_line2 = xy_line2 * rotationMatrix;

% Translate the rotated coordinates so that they are centered at (xCenter, yCenter).
x = xyRotated(:, 1) + xCenter;
y = xyRotated(:, 2) + yCenter;
x_line1 = xyRotated_line1(:, 1) + xCenter;
y_line1 = xyRotated_line1(:, 2) + yCenter;
x_line2 = xyRotated_line2(:, 1) + xCenter;
y_line2 = xyRotated_line2(:, 2) + yCenter;

% Determine the rectangular bounds by finding the min and max coordinates of the rotated axes.
Max_X = ceil(max([x_line1; x_line2]));
Min_X = floor(min([x_line1; x_line2]));
Max_Y = ceil(max([y_line1; y_line2]));
Min_Y = floor(min([y_line1; y_line2]));

% Set a fixed size for the rectangular region (in this case, 60 by 60 pixels).
MaXx = 60;
% Compute the rectangular region using a helper function.
[x_rect, y_rect] = Rectangular_Box(MaXx, MaXx, [xCenter yCenter]);

% Determine the starting and ending indices for cropping the image.
x_st = min(floor(y_rect(2)), r);
x_en = max(ceil(y_rect(3)), 1);
y_st = max(floor(x_rect(1)), 1);
y_en = min(ceil(x_rect(2)), c);

% Ensure the indices are within the image bounds.
if x_st <= 0, x_st = 1; end
if y_st <= 0, y_st = 1; end
if x_en > r, x_en = r; end
if y_en > c, y_en = c; end

% Define the rectangular box coordinates (for plotting or further use).
y_rect = [x_st, x_st, x_en, x_en, x_st];
x_rect = [y_st, y_en, y_en, y_st, y_st];

% Crop the original image to obtain the localized region.
Image_out = Image_In(x_st:x_en, y_st:y_en);
end
