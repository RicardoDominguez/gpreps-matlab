%% cost_fcn.m
% *Summary:* Returns the cost of a rollout. It is equivalent to a baseline 
% minus the energy consumed, scaled by a factor k.
%
%   C = cost_fcn(X)
%
% *Input arguments:*
%
%   all_y             all velocities                             (T x H)
%   target            target velocity                            (1 x 1)
%
% *Output arguments:*
%
%   C                 cost associated with the rollout           (T x 1)
% 
% By Ricardo Dominguez Olmedo
%
% Last modified: 2018-02
%
function C = cost_fcn(all_y, target)
    k = 1000; % Scale factor
    k2 = 1e8;
    C = sum(abs(all_y - target), 2);
    %C = sum(exp(-abs(all_y - target) / k), 2); % T x 1
    C = exp(-C / k)*k2;
end