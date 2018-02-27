%% predict_reward.m
% *Summary:* Compute expected rewards by sampling trayectories using the
% GP forward models.
%
% By Ricardo Dominguez Olmedo
%
% Last modified: 2018-02
%

nout = size(dyno, 2); ns = length(simroll.initX); Ntraj = M;

% Sample low level policy weights from high level policy
polWs = hipol.sample(hipol, Ntraj); % W x T

% Initialize state
x0 = simroll.initX; x = ones(Ntraj, 1) * x0; % Current state (T x nS)
u = zeros(Ntraj, 1); % Control action, (T x 1)
in = zeros(Ntraj, size(dyni, 2)); % GP input
y = zeros(Ntraj, size(dyno, 2)); % Next state, GP output
all_y = zeros(Ntraj, H); % Concatenation of all states outputed

for t = 1:simroll.H  % Each step within horizon
    tic
    
    % Trajectories finished   
    % Sample from low level policy
    u = policyvec(pol, polWs, x(:, 1)); % T x 1
    
    % Predict next step
    in(:, 1) = x(:, dyni(1:end-1));
    in(:, end) = u;
    in = in .* scal; % Scale input
    for i = 1:nout
        y(:, i) = predict(GPmodels{i}, in(:, :));
    end

    % Update variables by differences
    y(:, difi) = y(:, difi) + x(:, difi);
    all_y(:, t) = y(:, 1);
    x(:, :) = y(:, :);
    fprintf("Step %d out of %d. Elapsed: %d\n", t, simroll.H, toc);
end

% Reward associated with the episode
cost = cost_fcn(all_y); % T x 1

Wdataset = polWs'; % T x W
Rdataset = cost; % T x 1
Fdataset = zeros(M, ns); % T x ns

dataset = {Wdataset, Rdataset, Fdataset, eps};