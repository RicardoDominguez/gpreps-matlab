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
all_y = zeros(Ntraj, simroll.H); % Concatenation of all states outputed
notdone = ones(Ntraj, 1); % If 0 the episode has finished (T x 1)

% If the policy depends on the time, this vector is required
eps_time = 0.01*ones(Ntraj, 1);

for t = 1:simroll.H  % Each step within horizon
    tic
    
    % Trajectories finished
    if useMaxVar
        notdone = x(:, iMaxVar) < simroll.maxVar; % T x 1
    end
    
    % Sample from low level policy
    if simroll.timeInPol, xPol = [eps_time, x(:, ipol)]; % Add time to policy
    else, xPol = x(:, ipol);
    end
    u(notdone) = policyvec(pol, polWs(:, notdone), xPol(notdone, :)); % T x 1
    
    % Predict next step
    xU = [x(notdone, :), u(notdone)]; % N x (nS + 1)
    in(notdone) = xU(:, dyni) .* scal; % Inputs do dynamic model, scaled
    for i = 1:nout
        y(notdone, i) = predict(GPmodels{i}, in(notdone, :));
    end

    % Update variables by differences
    y(notdone, difi) = y(notdone, difi) + x(notdone, difi);
    all_y(:, t) = y(:, 1);
    x(notdone, :) = y(notdone, :);
    
    % Update simulation time
    eps_time = eps_time + simroll.dt;
    
    % Print out
    fprintf("Step %d out of %d. Elapsed: %d\n", t, simroll.H, toc);
end

% Reward associated with the episode
cost = cost_fcn(y, simroll); % T x 1

Wdataset = polWs'; % T x W
Rdataset = cost; % T x 1
Fdataset = zeros(M, ns); % T x ns

dataset = {Wdataset, Rdataset, Fdataset, eps};