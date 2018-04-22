%% gpreps.m
% *Summary:* Main script for the implementation of GPREPS
%   
% By Ricardo Dominguez Olmedo
%
% Last modified: 2018-03
%

% Initialize scenario
disp 'Initializing algorithm...'; init_param;

% Initial rollouts
fprintf('Policy iteration %d of %d.\n', k, K)  
for k = 1:NinitRolls
    hipol.muW = normrnd(muW_mean, muW_dev, pol.nX, 1);
    system_rollout; 
end

for k = NinitRolls+1:K+NinitRolls % Policy iterations
    fprintf('Policy iteration %d of %d.\n', k, K)
                                               
    % Train forward model
    disp 'Train models...'; train_forward_model;
    
    % Predict M simulated rollouts
    disp 'Predict rewards...'; predict_reward;

    % Update high level policy
    disp 'Updating policy...'; update_policy; 
        
    % System rollout
    disp 'System rollout...'; system_rollout;
end
 
% Archive
end_archive;
