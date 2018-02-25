%% predict_reward.m
% *Summary:* Compute expected rewards by sampling trayectories using the
% GP forward models.
%
% By Ricardo Dominguez Olmedo
%
% Last modified: 2017-10
%

nout = size(dyno, 2); ns = length(simroll.initX); Ntraj = M;

% Sample low level policy weights from high level policy
polWs = hipol.sample(hipol, Ntraj); % W x T

% Initialize state
x0 = simroll.initX; x = ones(Ntraj, 1) * x0; % Current state (T x nS)
u = zeros(Ntraj, 1); % Control action, (T x 1)
in = zeros(Ntraj, size(dyni, 2)); % GP input
y = zeros(Ntraj, size(dyno, 2)); % Next state, GP output

for t = 1:simroll.H  % Each step within horizon
    tic
    
    % Trajectories finished
    notdone = (x(:,1) < simroll.start_dist); % T x 1
   
    % Sample from low level policy
    u(notdone) = policyvec(pol, polWs(:, notdone), x(notdone,1)); % T x 1
    
    % Predict next step
    in(notdone, 1) = x(notdone, dyni(1:end-1));
    in(notdone, end) = u(notdone);
    in = in .* scal; % Scale input
    for i = 1:nout
        y(notdone, i) = predict(GPmodels{i}, in(notdone, :));
    end

    % Update variables by differences
    y(notdone, difi) = y(notdone, difi) + x(notdone, difi);
    x(notdone, :) = y(notdone, :);
    fprintf("Step %d out of %d. Elapsed: %d\n", t, simroll.H, toc);
end

% Reward associated with the episode
last_E = x(:, 3); x_end = x(:, 1);
cost = cost_fcn_gp(x_end, simroll, last_E); % T x 1

Wdataset = polWs'; % T x W
Rdataset = cost; % T x 1
Fdataset = zeros(M, ns); % T x ns

dataset = {Wdataset, Rdataset, Fdataset, eps};