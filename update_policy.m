%% update_policy.m
% *Summary:* Updates the high level policy by optimizing the dual function,
% computing the sample weighting, and use weighted maximum likelihood 
% for the policy update.
%
% By Ricardo Dominguez Olmedo
%
% Last modified: 2017-10
%

minimi_out = minimize_dual_func(dual_fcn, dataset);
eta = minimi_out(1); theta = minimi_out(2:end)';
p = sample_weighting(eta, theta, dataset);
hipol = update_hipol(p, dataset{1}, hipol);
