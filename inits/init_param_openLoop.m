%% init_param.m
% *Summary:* Script to initialize the scenario in which to apply GPREPS.
%
% By Ricardo Dominguez Olmedo
%
% Last modified: 2018-03
%

% Clear workspace and add relevant subfolders
clear; addpath('pol', 'minim', 'cost', 'rollout', 'archiving');

%% Indexes for GP training [v, U]
dyni = [1, 2];      % Inputs
dyno = [1];         % Outputs
difi = [1];         % Trained by differences
scal = [1];         % Scale on inputs
icos = [1];         % Index for cost function

%% Parameters of the simulated rollout
simroll.max_sim_time = 10;          % (in seconds)
simroll.dt = 0.5;                     % (in seconds)
simroll.initX = zeros(size(dyno));  % Initial system state
simroll.H = simroll.max_sim_time / simroll.dt; % Horizon of sim rollout
simroll.target = 2000;
%simroll.target = [2500, 2500, 2400, 2400, 2300, 2300, 2200, 2200, 2100, 2100, 2000, 2000, 2100, 2100, 2200, 2200, 2300, 2300, 2400, 2400]; % Target angular speed in RPM

%% Parameters for interacting with real system
load_data_fcn = @readDataSTMstudio;
policy_folder = 'Controller/Src/';
log_folder = 'Controller/Log/';
UV_folder = 'Controller\MDK-ARM\MainPWM_CTS.uvprojx';
STMstudioLogExe = 'Controller\Rec\STMStudioRollout.exe';
archive_folder = 'archive/';
base_file_name = 'd1';

%% Parameters of the low level policy
pol.minU = 0;           % Minimum control action
pol.maxU = 4200;        % Maximum control action
pol.sample = @policy; 
pol.nX = simroll.H;            % Numer of data points in the X-axis lookup table
pol.lookupX = linspace(0, simroll.max_sim_time, pol.nX + 1);        
pol.deltaX = pol.lookupX(2) - pol.lookupX(1); % Even spacing in look-up 
                                              % table X axis
pol.lookupX = pol.lookupX(2:end); % Look-up table X axis data points
pol.controllerDeltaX = 500; % Value of deltaX exported to controller 
    %(different than pol.deltaX if diffent units are needed, 
    % for instance s vs ms)

%% Higher level policy
hipol.sample = @highpol;
deviation = 200; % Allows to tune the high level policy covariance matrix. 
                 % Higher, more exploration
% Check if distribution is satisfacotry using
% distribution using histogram(normrnd(muW_mean, muW_dev, 1000));
muW_mean = 3000;
muW_dev  = muW_mean / 10;
% Initial high policy mean equal to low level policy mean
hipol.muW = normrnd(muW_mean, muW_dev, pol.nX, 1);
hipol.sigmaW = eye(pol.nX) .* (deviation^2); % High level policy cov matrix
store_pols{1, 1} = hipol.muW; % Log initial policy

%% Relative entropy bound
eps = 3; % Relative entropy bound
         % Lower results in more exploration
dual_fcn = @dual_function;

%% Number of iterations
K = 10;             % Number of policy iterations
M = 10000;          % Number of simulated rollouts
X = []; Y = [];
InitRoll = 5;