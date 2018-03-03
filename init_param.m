%% init_param.m
% *Summary:* Script to initialize the scenario in which to apply GPREPS.
%
% By Ricardo Dominguez Olmedo
%
% Last modified: 2018-02
%

% Clear workspace and add relevant subfolders
clear; addpath('pol', 'minim', 'cost', 'rollout');

%% Indexes for GP training [v, U]
dyni = [1, 2];      % Inputs
dyno = [1];         % Outputs
difi = [1];         % Trained by differences
scal = [1];      % Scale on inputs

%% Parameters of the simulated rollout
simroll.max_sim_time = 10;          % (in seconds)
simroll.dt = 0.5;                     % (in seconds)
simroll.initX = zeros(size(dyno));  % Initial system state
simroll.H = simroll.max_sim_time / simroll.dt; % Horizon of sim rollout
simroll.target = 2000; % Target angular speed in RPM

%% Parameters of the low level policy
pol.minU = 0;           % Minimum control action
pol.maxU = 4200;        % Maximum control action
pol.sample = @policy; 
pol.nX = simroll.H;            % Numer of data points in the X-axis lookup table
pol.lookupX = linspace(0, simroll.max_sim_time, pol.nX + 1);            
pol.lookupX = pol.lookupX(2:end); % Look-up table X axis data points
pol.deltaX = pol.lookupX(2) - pol.lookupX(1); % Even spacing in look-up 
                                              % table X axis

%% Higher level policy
deviation = 200; % Allows to tune the high level policy covariance matrix. 
                 % Higher, more exploration
hipol.sigmaW = eye(pol.nX) .* (deviation^2); % High level policy cov matrix
hipol.sample = @highpol;

%% Relative entropy bound
eps = 1; % Relative entropy bound
         % Lower results in more exploration
dual_fcn = @dual_function;

%% Number of iterations
K = 10;             % Number of policy iterations
M = 10000;          % Number of simulated rollouts
X = []; Y = [];