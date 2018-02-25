%% cost_fcn_gp.m
% *Summary:* Returns the cost of a simulated rollout. It is equivalent to a
% baseline minus the energy consumed, scaled by a factor k.
%
%   C = cost_fcn(X)
%
% *Input arguments:*
%
%   endX              final rollout distance from initial point  (T x 1)
%   simroll
%       .end_dist     maximum distance achivable                 (1 x 1)
%   total_E           total energy consumed during rollout       (T x 1)
%
% *Output arguments:*
%
%   C                 cost associated with the rollout           (T x 1)
% 
% By Ricardo Dominguez Olmedo
%
% Last modified: 2018-02
%
function C = cost_fcn_gp(endX, simroll, total_E)
    baseline = 6e+4; % Baseline (higher than any expected energy consumption)
    k = 2000; % Scale factor
    C = exp((baseline - total_E) / k); % T x 1
    C(endX < simroll.end_dist) = 1; % Low reward for rollout that did not 
                                    % complete the task
end