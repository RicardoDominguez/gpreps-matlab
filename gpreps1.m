%% gpreps1.m
% *Summary:* Main script for the implementation of GPREPS (from 
% initialization up until the first system rollout)
%   
% By Ricardo Dominguez Olmedo
%
% Last modified: 2018-03
%

% Initialize scenario
disp 'Initializing algorithm...'; init_param;

% Next step
k = 1;

% System rollout
disp 'Exporting policy into files...'; system_rollout;
