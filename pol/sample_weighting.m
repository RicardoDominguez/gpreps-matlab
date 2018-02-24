%% sample_weighting.m
% *Summary:* Compute the sample weighting for weighted ML update.
%
%   p = sample_weight(eta, theta, dataset)
%
% *Input arguments:*
%
%   eta                                                (1 x 1)
%   theta                                              (S x 1)
%   dataset           cell with sample data
%       dataset{1}             Weight  dataset matrix  (N x W)
%       dataset{2}             Return  dataset vector  (N x 1)
%       dataset{3}             Feature dataset matrix  (N x S)
%
% *Output arguments:*
%
%   p                 sample weighting                 (N x 1)
% 
% By Ricardo Dominguez Olmedo
%
% Last modified: 2017-10
%
function p = sample_weighting(eta, theta, dataset)
    err = dataset{2} - sum(theta'.*dataset{3}, 2);
    p = exp(err / eta);
end