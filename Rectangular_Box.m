function [x, y] = Rectangular_Box(Width, Height, Center)
%% Rectangular_Box: Compute the Vertex Coordinates of a Rectangular Box
%
%  This function calculates the coordinates of a rectangular bounding box
%  given its width, height, and center location. The output vectors (x, y)
%  represent the vertices of the rectangle in a closed polygon format, where
%  the first vertex is repeated at the end to complete the box.
%
%  Inputs:
%    Width   - The width of the rectangle.
%    Height  - The height of the rectangle.
%    Center  - A 1x2 vector [x_center, y_center] specifying the center of the rectangle.
%
%  Outputs:
%    x       - A vector of x-coordinates for the rectangle vertices.
%    y       - A vector of y-coordinates for the rectangle vertices.
%
%  Example:
%    [x, y] = Rectangular_Box(100, 50, [200, 150]);
%    plot(x, y, '-o'); % Plots the rectangular box.
%
%  Author: [Your Name]
%  Date: [Today's Date]
%

% Compute the left (x1) and right (x2) boundaries of the rectangle.
x1 = Center(1) - Width/2;
x2 = Center(1) + Width/2;

% Compute the top (y1) and bottom (y2) boundaries of the rectangle.
y1 = Center(2) - Height/2;
y2 = Center(2) + Height/2;

% Create the vertex coordinate vectors. The rectangle is represented
% as a closed polygon by repeating the first vertex at the end.
x = [x1, x2, x2, x1, x1];
y = [y1, y1, y2, y2, y1];

end
