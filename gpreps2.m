%% gpreps2.m
% *Summary:* Main script for the implementation of GPREPS (after the first
% rollout on the physical system)
%   
% By Ricardo Dominguez Olmedo
%
% Last modified: 2018-03
%

fprintf('Policy iteration %d of %d.\n', k, K)

% Train forward model
disp 'Train models'; train_forward_model;

% Predict M simulated rollouts
disp 'Predict rewards'; predict_reward;

% Update high level policy
disp 'Updating policy'; update_policy;

% Next step
k = k + 1;

% System rollout
disp 'Exporting policy into files...'; system_rollout;