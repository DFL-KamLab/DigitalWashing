function morph_out = Morph_Image_Urbano(input_image)
%% morph_image_V04: Advanced Morphological Filtering for Binary Image Refinement
%
%  This function applies a series of morphological operations to a binary image 
%  to refine and clean the segmentation results. It first performs a closing 
%  operation to fill small gaps and smooth boundaries, then applies an erosion 
%  to remove small artifacts and finally, a dilation to partially restore object 
%  sizes.
%
%  Input:
%    input_image - A binary image (logical or numeric) representing the segmentation result.
%
%  Output:
%    morph_out   - The morphologically processed binary image.
%

% Initialize the working variable with the input image.
bw2 = input_image;

% Optional: Clear border objects if needed.
% bw2 = imclearborder(bw);

% Apply morphological closing using a disk-shaped structuring element with radius 8.
% This step helps to fill small holes and smooth the object boundaries.
bw2 = imclose(bw2, strel('disk', 8));

% Apply erosion with a disk-shaped structuring element of radius 6 to remove small artifacts.
bw3 = imerode(bw2, strel('disk', 6));

% Follow with a dilation using a disk-shaped structuring element of radius 1 to restore the object size.
bw3 = imdilate(bw3, strel('disk', 1));

% Set the output to the final morphologically processed image.
morph_out = bw3;
end
