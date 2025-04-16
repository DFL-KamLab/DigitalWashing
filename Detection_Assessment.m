function [tp, fp, fn] = Detection_Assessment(X, Y, c)
%% detection_assessment: Evaluate Detection Performance Using the Hungarian Algorithm
%
%  This function compares the detected object locations (Y) with the 
%  ground truth locations (X) by computing a cost matrix based on Euclidean 
%  distances and then finds an optimal assignment using the Hungarian algorithm.
%
%  A detection is considered correct (true positive) if its distance from the
%  corresponding ground truth is less than the threshold 'c'. Discrepancies in 
%  the number of detections versus ground truth points are adjusted via additional 
%  false positives or false negatives.
%
%  Inputs:
%    X - 2xN matrix of ground truth coordinates, where each column represents [x; y].
%    Y - 2xM matrix of detected coordinates, where each column represents [x; y].
%    c - Scalar threshold distance for a valid detection.
%
%  Outputs:
%    tp - The number of true positive detections.
%    fp - The number of false positive detections.
%    fn - The number of false negative detections.


% Initialize counts for true positives, false positives, and false negatives.
tp = 0; 
fp = 0; 
fn = 0;

% Determine the number of ground truth points (n) and detected points (m).
n = size(X, 2);
m = size(Y, 2);

% If the number of ground truth points and detections differ, adjust the counts.
if n > m        % More ground truth than detections implies some false negatives.
    fn = fn + (n - m);
elseif n < m    % More detections than ground truth implies extra false positives.
    fp = fp + (m - n);
end

% Proceed only if there are detected points.
if ~isempty(Y)
    % Compute the pairwise Euclidean distance matrix between X and Y.
    % - XX is formed by replicating X, and YY is formed by replicating Y.
    % - The distance matrix D is computed element-wise.
    XX = repmat(X, [1, m]);  % Replicate ground truth points m times.
    YY = reshape(repmat(Y, [n, 1]), [size(Y, 1), n * m]);  % Replicate detection points.
    D = reshape(sqrt(sum((XX - YY).^2)), [n, m]);  % Compute Euclidean distances.
    
    % Use the Hungarian algorithm to obtain an optimal assignment.
    [assignment, ~] = Hungarian(D);
    
    % Extract the distances corresponding to the optimal assignments.
    match = D(find(assignment));
    
    % Evaluate each assignment based on the threshold.
    for i = 1:length(match)
        if match(i) < c
            tp = tp + 1;  % Valid detection
        else
            % A detection that exceeds the threshold is counted as both
            % a false positive (extra detection) and a false negative (missed true detection).
            fp = fp + 1;
            fn = fn + 1;
        end
    end
end
end
