%% train_forward_model.m
% *Summary:* Script to train GP forward models of the dynimics of the
% system from the data extracted from physical interaction with the system
%
% By Ricardo Dominguez Olmedo
%
% Last modified: 2018-02
%

Xt = X(:, dyni); % Inputs of the model
Yd = Y(:, difi) - X(:, difi); % Targets trained by differences
Yt = Yd(:, dyno); % Outputs of the model

% Scale the data so that it has simar orders of magnitude and the GP is
% trained properly
Xt = Xt .* scal;

nout = size(dyno, 2); GPmodels = cell(nout, 1);
for i = 1:nout % One model trained for each output
    fprintf('Model %d out of %d. ', i, nout);
    
    % Extract train data
    Yi = Yt(:, i);
    
    % Train model
    worked = 0;
    siglow = 1e-2*std(Yi);
    while(~worked)
        try
            % Try to fit GP
            tic; GPmodels{i} = fitrgp(Xt, Yi, 'FitMethod', 'exact', 'KernelFunction', ...
                'squaredExponential', 'SigmaLowerBound', siglow); toc         
            worked = 1;
        catch
            worked = 0;
            disp 'The was a problem with the GP regression'
            siglow = siglow*10; % Increase sigma lower bound if training did
                                % not converge
        end
    end
end


% If datasets are too large sparse methods can be used
% GPmodels{i} = fitrgp(Xt, Yi, 'FitMethod', 'fic', 'KernelFunction', ...
%   'squaredExponential', 'ActiveSetMethod', 'likelihood', 'ActiveSetSize', 2900)
