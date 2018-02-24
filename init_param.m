addpath('pol', 'minim', 'cost', 'model');

run_values.max_sim_time = 140; % in seconds
run_values.dt = 1;
run_values.start_distance = 0; % in meters
run_values.end_distance = 940; % in meters
model_name = 'v013a.slx';

load('new_track.mat')
track_profile.distance = distance;
track_profile.road_angle = road_profile;
track_profile.spacing = distance(2)-distance(1);

pol.minU = 0; % Minimum control action
pol.maxU = 1000; % Maximum control action
pol.sample = @policy; % Control action sample function
pol.n_tiles = 30; % Number of tiles
pol.thr = linspace(run_values.start_distance, run_values.end_distance, ...
    pol.n_tiles+1);
pol.thr = pol.thr(2:end); % Thereshold of each tile
pol.spacing = pol.thr(2) - pol.thr(1);
pol.W = ones(pol.n_tiles, 1) .* 700;

% Indexes [x, v, E, theta, U]
dyni = [2, 4, 5];      % Inputs
dyno = [1, 2, 3];   % Outputs
diffi = [1, 2, 3];  % Trained by differences
difi = diffi;

%% Higher level policy
hipol.muW = pol.W;
nW = size(hipol.muW, 1); % Parameter mean
deviation = 200; % Allows to tune the covariance matrix. Higher, more exploration
hipol.sigmaW = eye(nW) .* (deviation^2); % Parameter covariance matrix
hipol.sample = @highpol; % Policy weights sample function

%% Sampling trayectories variables
initialS = [0, 0, 0]; % Initial state
H = run_values.max_sim_time / run_values.dt; % Maximum number of steps

%% Relative entropy bound.
eps = 3; % Lower eps results in more exploration.
dual_fcn = @dual_function;

%% Number of iterations
K = 10;  % Policy iterations
M = 10000; % Reward prediction samples
NdataRolls = 1;
Ninitial = 3;

%% GP
%init_gp;
%train_forward_model;