function seg_out = Otsu_Threshold(input_image)
%% otsu_threshold: Global Image Thresholding Using Otsu's Method
%
%  This function applies Otsu's method to compute a global threshold for the
%  input image. It converts the image to a binary (black and white) image
%  using the computed threshold and then inverts the binary image.
%
%  Input:
%    input_image - A grayscale image (in uint8 or double format) to be thresholded.
%
%  Output:
%    seg_out     - A binary image resulting from applying Otsu's threshold and inversion.
%


% Compute the global threshold using Otsu's method.
thresh = graythresh(input_image);

% Convert the image to a binary image using the computed threshold.
bw = im2bw(input_image, thresh);

% Invert the binary image so that the foreground becomes white.
seg_out = imcomplement(bw);

end
