%% predict_reward.m
% *Summary:* Compute expected rewards by sampling trayectories using the
% GP forward models.
%
% By Ricardo Dominguez Olmedo
%
% Last modified: 2017-10
%
disp 'Computing predicted rewards...'

nout = size(dyno, 2);
ns = length(initialS);
Ntraj = M; % M trajectories

% Sample low level policy weights from high level policy
polWs = hipol.sample(hipol, Ntraj); % W x T

% Initialize state
x0 = initialS; x = ones(Ntraj, 1)*x0; % T x nS
y = zeros(Ntraj, size(dyno, 2));
u = zeros(Ntraj, 1); % T x 1
in = zeros(Ntraj, size(dyni, 2));
for t = 1:H
    tic
    % Trajectories finished
    notdone = (x(:,1) < run_values.end_distance); % T x 1
   
    % Sample from low level policy
    u(notdone) = policyvec(pol, polWs(:, notdone), x(notdone,1)); % T x 1
    
    % Predict next step
    in(notdone, 1) = x(notdone, 2);
    in(notdone, 2) = getRoadAngle(x(notdone, 1), track_profile) * 1000;
    in(notdone, 3) = u(notdone) / 100;
    for i = 1:nout
        y(notdone, i) = predict(GPmodels{i}, in(notdone, :));
    end
    %y(notdone, :) = gpm.sample(gpm, in(notdone, :));

    % Update variables by differences
    y(notdone, difi) = y(notdone, difi) + x(notdone, difi);
    x(notdone, :) = y(notdone, :);
    fprintf("Step %d out of %d. Elapsed: %d\n", t, H, toc);
end

% Reward associated with the episode
last_E = x(:, 3); x_end = x(:, 1);
cost = cost_fcn_gp(x_end, run_values, last_E); % T x 1

Wdataset = polWs'; % T x W
Rdataset = cost; % T x 1
Fdataset = zeros(M, ns); % T x ns

dataset = {Wdataset, Rdataset, Fdataset, eps};