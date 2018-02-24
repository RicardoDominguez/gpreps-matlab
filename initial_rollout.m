%% Policies to be used
% X = []; Y = [];
% 
% %% Simulate policies and store data
% for n = 1:Ninitial
%     fprintf('Rollout %d of %d.\n', n, Ninitial)
%     
%     % Sample lower policy weights
%     pol.W = hipol.sample(hipol);
%     
%     % Simulate rollout
%     out = sim(model_name);
%     
%     latent = out.simulation_results;
%     x = latent(1:end-1, :);
%     y = latent(2:end, :);
%     X = [X; x]; Y = [Y; y];
% end
load('init20.mat')
%% Train GP models
train_forward_model;
    
%save('GPmodel_rand_proper.mat', 'GPmodels', 'X', 'Y')