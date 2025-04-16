function seg_out = Urbano_Seg(input_image)
%% Urbano_Seg_V02: Segmentation Using Combined Gaussian and LoG Filtering
%
%  This function applies a hybrid image segmentation approach by combining Gaussian
%  smoothing and Laplacian-of-Gaussian (LoG) filtering. The image is first smoothed
%  with a Gaussian filter to reduce noise, then enhanced with an LoG filter to highlight
%  edges. Finally, the image is thresholded using an adjusted Otsu method to obtain a binary
%  segmentation.
%
%  Input:
%    input_image - Grayscale image (uint8 or double) to be segmented.
%
%  Output:
%    seg_out     - Binary image resulting from segmentation.

%

% Create a Gaussian filter with scaled kernel size and standard deviation.
h1 = fspecial('gaussian', 11*3, 1*3);

% Create a Laplacian-of-Gaussian (LoG) filter with scaled parameters.
h2 = fspecial('log', 9*3, 0.3*3);

% Initialize the working image.
I = input_image;

% Apply the Gaussian filter to smooth the image. The loop iterates once and can be modified for additional smoothing.
for jj = 1:1
    I = imfilter(I, h1);
end

% Apply the LoG filter to enhance edges.
I = imfilter(I, h2);

% Compute a global threshold using Otsu's method and scale it by a factor of 1.1.
% Then, convert the filtered image to a binary image using the computed threshold.
bw = im2bw(I, 1.1 * graythresh(I));

% Return the binary segmentation output.
seg_out = bw;
end
