%% gpreps2.m
% *Summary:* Main script for the implementation of GPREPS (after the first
% rollout on the physical system)
%   
% By Ricardo Dominguez Olmedo
%
% Last modified: 2018-02
%
%
fprintf('Policy iteration %d of %d.\n', k, K)

% Load data from the rollout on the physical system
disp 'Load data from rollout'; rollout_load_data;

% Train forward model
disp 'Train models'; train_forward_model;

% Predict M simulated rollouts
disp 'Predict rewards'; predict_reward;

% Update high level policy
disp 'Updating policy'; update_policy; 
store_pols{k, 1} = hipol.muW;
k = k + 1; % For next policy iteration

disp '---------------------------------------------------'
disp 'Time to rollout the policy into the physical system'
disp 'When done run gpreps2'
disp '---------------------------------------------------'