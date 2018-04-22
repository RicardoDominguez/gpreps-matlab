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

% Initial system rollouts
disp 'Initial rollouts...'; 
for k = 1:NinitRolls
    hipol.muW = normrnd(muW_mean, muW_dev, pol.nX, 1);
    system_rollout; 
end