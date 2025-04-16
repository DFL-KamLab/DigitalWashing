function morph_out = Morph_Image_Sauvola(input_image)
%% morph_image_sauvola: Morphological Processing for Sauvola Thresholded Images
%
%  This function refines a binary image obtained through Sauvola thresholding.
%  It applies a series of morphological operations to improve segmentation by
%  closing small gaps, eroding to remove minor artifacts, and then dilating to 
%  restore important structural features.
%
%  Input:
%    input_image - A binary image (logical or numeric) resulting from Sauvola thresholding.
%
%  Output:
%    morph_out   - The refined binary image after applying morphological closing, 
%                  erosion, and dilation.
%


% Initialize working variable with the input binary image.
bw2 = input_image;

% Optional: Uncomment the following line to clear border-touching objects if needed.
% bw2 = imclearborder(bw2);

% Apply morphological closing using a disk-shaped structuring element with radius 8.
% This operation fills small holes and gaps in the binary image.
bw2 = imclose(bw2, strel('disk', 8));

% Apply erosion using a disk-shaped structuring element with radius 6 to remove small, spurious objects.
bw3 = imerode(bw2, strel('disk', 6));

% Apply dilation using a disk-shaped structuring element with radius 1 to restore the size of significant objects.
bw3 = imdilate(bw3, strel('disk', 1));

% Set the output to the final morphologically processed image.
morph_out = bw3;
end
