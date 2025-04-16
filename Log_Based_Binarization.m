function [erodedBW] = Log_Based_Binarization(I0)
%% log_based_binarization: Custom Segmentation and Morphological Processing
%
%  This function applies a custom segmentation method to an input image using 
%  a combination of Laplacian-of-Gaussian filtering, hole filling, Otsu thresholding,
%  and subsequent morphological operations. The resulting binary image is refined 
%  further using erosion, dilation, and border clearing to remove artifacts.
%
%  Steps:
%    1. Apply a Laplacian-of-Gaussian (LoG) filter to enhance edges and textures.
%    2. Fill holes in the LoG-filtered image.
%    3. Convert the image to a binary image using Otsu's method.
%    4. Fill holes again in the binary image.
%    5. Perform erosion followed by dilation to smooth the segmented objects.
%    6. Remove border-touching objects.
%
%  Input:
%    I0 - Input grayscale image to be segmented.
%
%  Output:
%    erodedBW - The final binary image after segmentation and morphological processing.
%


% Create a Laplacian-of-Gaussian (LoG) filter with a kernel size of 10 and sigma of 0.40.
h2 = fspecial('log', 10, 0.40);

% Apply the LoG filter to the input image to enhance edges and detail.
I = imfilter(I0, h2);

% Fill holes in the filtered image to smooth the segmentation.
I = imfill(I, 'holes');

% Convert the filled image to a binary image using Otsu's thresholding.
bw = im2bw(I, graythresh(I));

% (Optional) Complement the binary image if required for your application.
% bw = imcomplement(bw);

% Fill holes in the binary image to ensure solid segmented regions.
bw1 = imfill(bw, 'holes');

% Apply erosion with a disk-shaped structuring element of radius 2 to remove small artifacts.
se1 = strel('disk', 2);
erodedBW = imerode(bw1, se1);

% Apply dilation with a disk-shaped structuring element of radius 2 to restore object shape.
se2 = strel('disk', 2);
erodedBW = imdilate(erodedBW, se2);

% Clear objects that touch the image border to reduce boundary artifacts.
erodedBW = imclearborder(erodedBW);

end
