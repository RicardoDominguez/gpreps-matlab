%% cost_fcn.m
% *Summary:* Returns the cost of T rollouts. It is equivalent to a baseline 
% minus the energy consumed, scaled by a factor k.
%
%   C = cost_fcn(X)
%
% *Input arguments:*
%
%   y                 simulation end states                      (T x H)
%   simroll             `                                        
%
% *Output arguments:*
%
%   C                 cost associated with the rollout           (T x 1)
% 
% By Ricardo Dominguez Olmedo
%
% Last modified: 2018-02
%
function C = cost_max_var(y, simroll)
    iEndVar = simroll.iMaxVar;
    valEndVar = simroll.maxVar;
    iCost = simroll.iCost;
    
    baseline = 6e+4; % Baseline (higher than any expected energy consumption)
    k = 2000; % Scale factor
    k2 = 1;
    C = sum(abs(baseline - y(:, iCost)), 2); % Difference between baseline
    C = exp(-C / k)*k2;
    C(y(:, iEndVar) < valEndVar * 0.95) = 1; % Low reward for rollout that did
                                             % not complete the task
end