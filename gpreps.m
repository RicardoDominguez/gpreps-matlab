%% gpreps.m
% *Summary:* Main script for the implementation of GPREPS.
%   
% By Ricardo Dominguez Olmedo
%
% Last modified: 2017-10
%
clear

init_param; % Initialize the scenario in which to apply GPREPS

store_pols = cell(K, 1); % Stores the mean weight of the high level policy
initial_rollout;
for k = 1:K
    fprintf('Iteration %d of %d. ', k, K)
    disp 'Predict rewards'; predict_reward;
    disp 'Updating policy'; update_policy; store_pols{k, 1} = hipol.muW;
    disp 'Rollout'; system_rollout;
    disp 'Train models'; train_forward_model;
end