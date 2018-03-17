%% gpreps.m
% *Summary:* Main script for the implementation of GPREPS
%   
% By Ricardo Dominguez Olmedo
%
% Last modified: 2018-03
%

% Initialize scenario
disp 'Initializing algorithm...'; init_param;

for k = 1:K % Policy iterations
    fprintf('Policy iteration %d of %d.\n', k, K)
    
    % System rollout
    disp 'System rollout...'; system_rollout;
                                               
    % Train forward model
    disp 'Train models...'; train_forward_model;
    
    % Predict M simulated rollouts
    disp 'Predict rewards...'; predict_reward;

    % Update high level policy
    disp 'Updating policy...'; update_policy;                                                           
end

% Evaluation of the final policy
disp 'Initiall rollout...'; system_rollout;
 
% Archive
end_archive;
