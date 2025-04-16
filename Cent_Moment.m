function n_pq = Cent_Moment(p, q, A)
%% cent_moment: Compute the Normalized Central Moment of an Image
%
%  This function computes the normalized central moment of order (p, q) for an 
%  image matrix A. The normalized central moment provides a scale-invariant 
%  measure of the shape of the intensity distribution.
%
%  Processing Steps:
%    1. Compute the zeroth-order raw moment (moo) of the image.
%    2. Calculate the first-order moments to determine the centroid (xx, yy) 
%       of the image.
%    3. Compute the central moment (mu_pq) about the centroid.
%    4. Normalize the central moment using a factor based on p and q.
%
%  Inputs:
%    p - Order of the moment in the x-dimension.
%    q - Order of the moment in the y-dimension.
%    A - Input image matrix (e.g., grayscale image).
%
%  Output:
%    n_pq - The normalized central moment of order (p, q).
%
%  The normalization factor is defined as: gamma = 0.5*(p+q) + 1.
%


% Get the size of the input image.
[m, n] = size(A);

% Compute the zeroth-order moment (sum of all pixel intensities).
moo = sum(sum(A));

% Initialize first order moments for x and y.
m1o = 0;
mo1 = 0;

% Calculate the first order moments over the entire image.
% Note: x and y indices in MATLAB start at 1, so we use (x+1) and (y+1).
for x = 0:m-1
    for y = 0:n-1
        m1o = m1o + x * A(x+1, y+1);
        mo1 = mo1 + y * A(x+1, y+1);
    end
end

% Compute the centroid coordinates (xx, yy) of the image intensity distribution.
xx = m1o / moo;
yy = mo1 / moo;

% The zeroth central moment (mu_00) is the same as the raw moment.
mu_oo = moo;

% Initialize the central moment mu_pq.
mu_pq = 0;

% Compute the central moment of order (p, q):
% This involves summing (x-xx)^p*(y-yy)^q over all pixels.
for ii = 0:m-1
    x_diff = ii - xx;
    for jj = 0:n-1
        y_diff = jj - yy;
        mu_pq = mu_pq + (x_diff)^p * (y_diff)^q * A(ii+1, jj+1);
    end
end

% Calculate the normalization exponent gamma.
gamma = 0.5*(p + q) + 1;

% Compute the normalized central moment.
n_pq = mu_pq / moo^(gamma);

end
