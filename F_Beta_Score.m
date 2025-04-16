function [F_score] = F_Beta_Score(precision, recall, beta)
%% F_beta_Score: Compute the Weighted Harmonic Mean of Precision and Recall
%
%  This function calculates the F_beta score, a performance metric that combines 
%  precision and recall into a single value. The beta parameter specifies the weight
%  given to recall relative to precision. A beta > 1 favors recall, while beta < 1 favors 
%  precision.
%
%  Inputs:
%    precision - Numeric value representing the precision metric.
%    recall    - Numeric value representing the recall metric.
%    beta      - Weighting factor, where beta > 1 gives more importance to recall.
%
%  Output:
%    F_score   - The computed F_beta score.
%
%  Formula:
%       F_beta = (1 + beta^2) * (precision * recall) / (beta^2 * precision + recall)

%

% Compute the F_beta score using the weighted harmonic mean formula.
F_score = (1 + beta^2) .* ((precision .* recall) ./ (beta^2 .* precision + recall));

end
