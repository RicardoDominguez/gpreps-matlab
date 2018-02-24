%% cost_fcn.m
% *Summary:* Returns the cost of an input system state. It is equivalent to
% a baseline minus the energy consumed, scaled by a factor k.
%
%   C = cost_fcn(X)
%
% *Input arguments:*
%
%   X                 vector containing the system state      (1 x N)
%
% *Output arguments:*
%
%   C                 cost of input state X                   (1 x 1)
% 
% By Ricardo Dominguez Olmedo
%
% Last modified: 2017-10
%
% endX T x 1
% total_E T X 1
% C T x 1
function C = cost_fcn_gp(endX, run_values, total_E)
    baseline = 6e+4; % Baseline (higher than any expected energy consumption)
    k = 2000; % Scale factor
    C = exp((baseline - total_E) / k); % T x 1
    C(endX < run_values.end_distance) = 1; % Not completed track
end