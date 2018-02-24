%% train_forward_model.m
% *Summary:* Script to train GP forward models of the dynimics of the
% system.
%
% By Ricardo Dominguez Olmedo
% 'BasisFunction', 'linear'
% Last modified: 2017-10
%
%Xa = [X(:, 1:3), getAppropkxRoadAngle(X(:,1), Y(:,1), track_profile), X(:, 4)];
Xt = X(:, dyni); % Inputs, [v theta u]
Xt(:,2) = Xt(:,2)*1000; Xt(:,3) = Xt(:,3) / 100; % Same order of magnitude for inputs
Yd = Y(:, diffi) - X(:, diffi);
Yt = Yd(:, dyno);

nout = size(dyno, 2); GPmodels = cell(nout, 1);
for i = 1:nout
    fprintf('Model %d out of %d. ', i, nout);
    % Extract train data
    Yi = Yt(:, i);
    
    % Train model
%     if size(Xt, 1) < 3000 % Exact
    worked = 0;
    siglow = 1e-2*std(Yi);
    while(~worked)
        try
%             if size(Xt, 1) < 2900
                tic; GPmodels{i} = fitrgp(Xt, Yi, 'FitMethod', 'exact', 'KernelFunction', ...
                    'squaredExponential', 'SigmaLowerBound', siglow); toc
%             else
%                 tic; GPmodels{i} = fitrgp(Xt, Yi, 'FitMethod', 'fic', 'KernelFunction', ...
%                     'squaredExponential', 'ActiveSetMethod', 'likelihood', 'ActiveSetSize', ...
%                     2900); toc
%             end
            worked = 1;
        catch
            worked = 0;
            disp 'The was a problem with the GP regression'
            siglow = siglow*10;
        end
    end
%     else % Sparse
%         tic; GPmodels{i} = fitrgp(Xt, Yi, 'FitMethod', 'fic', 'KernelFunction', ...
%             'squaredExponential', 'ActiveSetMethod', 'likelihood', 'ActiveSetSize', ...
%             500); toc
end

