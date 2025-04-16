function morph_out = Morph_Image(input_image)
%% morph_image: Morphological Processing for Binary Image Cleaning
%
%  This function applies a sequence of morphological operations to a binary image 
%  to improve its segmentation. The operations include morphological closing 
%  (to fill small holes) followed by an erosion and dilation sequence using diamond-
%  shaped structuring elements to smooth object boundaries.
%
%  Input:
%    input_image - A binary image (logical or numeric) representing the initial segmentation.
%
%  Output:
%    morph_out   - A binary image after applying the morphological cleaning operations.
%


% Initialize the working image with the input.
bw2 = input_image;

% (Optional) Remove border artifacts by clearing connected components touching the image border.
% Uncomment the following line if border cleanup is desired.
% bw2 = imclearborder(bw2);

% Apply morphological closing with a disk-shaped structuring element of radius 1.
% This operation fills small holes or gaps in the binary image.
bw2 = imclose(bw2, strel('disk', 1));

% Perform an erosion followed by a dilation using diamond-shaped structuring elements.
% Erosion (with a diamond of size 2) shrinks object boundaries slightly, 
% and subsequent dilation (with a diamond of size 1) helps recover the object size while
% smoothing out small irregularities.
bw3 = imdilate(imerode(bw2, strel('diamond', 2)), strel('diamond', 1)); 

% Set the output to the result of the morphological processing.
morph_out = bw3;
end
