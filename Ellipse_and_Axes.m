function [x_line1_2, y_line1_2, x_line2_2, y_line2_2, x, y] = Ellipse_and_Axes(xCenter1, yCenter1, xRadius1, yRadius1, IM_Orientation, IM_Perimeter, Axis_Ext)
%% Ellipse_and_Axes: Compute Ellipse Perimeter and Extended Axes for a Blob
%
%  This function calculates the ellipse representing a detected blob using its
%  centroid, axes lengths, orientation, and perimeter. In addition, it computes two
%  extended lines along the minor and major axes of the ellipse, which are useful
%  for further analysis.
%
%  Inputs:
%    xCenter1      - X-coordinate of the blob's centroid.
%    yCenter1      - Y-coordinate of the blob's centroid.
%    xRadius1      - Radius along the minor axis (half of the minor axis length).
%    yRadius1      - Radius along the major axis (half of the major axis length).
%    IM_Orientation- Orientation of the blob (in degrees).
%    IM_Perimeter  - Perimeter of the blob (used to determine the number of points on the ellipse).
%    Axis_Ext      - Extension factor to extend the axes lines beyond the ellipse.
%
%  Outputs:
%    x_line1_2, y_line1_2 - Coordinates of the first extended line (aligned with the minor axis).
%    x_line2_2, y_line2_2 - Coordinates of the second extended line (aligned with the major axis).
%    x, y               - Coordinates of the ellipse perimeter after rotation and translation.
%
%  The function uses a rotation matrix to align the ellipse and axes lines with the blob's orientation.
%
%  Author: [Your Name]
%  Date: [Today's Date]
%

% Generate coordinate vectors for the extended axis lines.
% For the minor axis: x varies from -Axis_Ext*xRadius1 to Axis_Ext*xRadius1; y remains zero.
x_line1_2 = -Axis_Ext * xRadius1 : Axis_Ext * xRadius1;
y_line1_2 = zeros(1, length(x_line1_2));

% For the major axis: y varies from -Axis_Ext*yRadius1 to Axis_Ext*yRadius1; x remains zero.
y_line2_2 = -Axis_Ext * yRadius1 : Axis_Ext * yRadius1;
x_line2_2 = zeros(1, length(y_line2_2));

% Create ellipse perimeter points using the parametric form.
theta1 = linspace(0, 2*pi, ceil(IM_Perimeter)); % Determine number of points based on perimeter.
x1 = xRadius1 * cos(theta1);  % Unrotated x-coordinates.
y1 = yRadius1 * sin(theta1);  % Unrotated y-coordinates.

% Compute the rotation matrix.
% The rotation angle is given by IM_Orientation - 90 to account for coordinate system differences.
angleInDegrees1 = IM_Orientation - 90;
rotationMatrix1 = [cosd(angleInDegrees1), -sind(angleInDegrees1); sind(angleInDegrees1), cosd(angleInDegrees1)];

% Apply the rotation to the ellipse perimeter points.
xy1 = [x1', y1'];  % Combine x and y into a coordinate matrix.
xyRotated1 = xy1 * rotationMatrix1;
% Translate the rotated ellipse to the blob's centroid.
x = xyRotated1(:,1) + xCenter1;
y = xyRotated1(:,2) + yCenter1;

% Prepare extended axis lines (before rotation).
xy_line1_2 = [x_line1_2', y_line1_2'];  % Minor axis line.
xy_line2_2 = [x_line2_2', y_line2_2'];  % Major axis line.

% Rotate the extended lines using the same rotation matrix.
xyRotated_line1_2 = xy_line1_2 * rotationMatrix1;
xyRotated_line2_2 = xy_line2_2 * rotationMatrix1;

% Translate the rotated lines to the blob's centroid.
x_line1_2 = xyRotated_line1_2(:,1) + xCenter1;
y_line1_2 = xyRotated_line1_2(:,2) + yCenter1;
x_line2_2 = xyRotated_line2_2(:,1) + xCenter1;
y_line2_2 = xyRotated_line2_2(:,2) + yCenter1;

end
