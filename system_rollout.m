%% system_rollout.m
% *Summary:* Script to perform rollouts in the system in order to obtain
% real world data.
%
% By Ricardo Dominguez Olmedo
%
% Last modified: 2017-10
%
for j = 1:NdataRolls
    % Sample lower policy weights
    pol.W = hipol.muW; %hipol.sample(hipol);
    
    % Simulate rollout
    tic; out = sim(model_name); toc
    
    latent = out.simulation_results;
    x = latent(1:end-1, :);
    y = latent(2:end, :);
    X = [X; x]; Y = [Y; y];

    last_E = latent(end, 3);
    x_end = latent(end, 1);
    cost = cost_fcn(x_end, run_values, last_E);
    
    disp 'Performance'
    performance(k) = last_E
    all_costs(k) = cost
end