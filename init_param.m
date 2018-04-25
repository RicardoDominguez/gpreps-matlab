%% init_param.m
% *Summary:* Script to initialize the scenario in which to apply GPREPS.
%
% By Ricardo Dominguez Olmedo
%
% Last modified: 2018-03
%

% Clear workspace and add relevant subfolders
clear; addpath('pol', 'minim', 'cost', 'rollout', 'archiving');

%% Indexes for GP training [x v E U]
dyni = [2, 4];      % Inputs
dyno = [1, 2, 3];   % Outputs
difi = [1, 2, 3];   % Trained by differences
scal = [1 1];       % Scale on inputs
icos = [3];         % Index for cost function
ipol = [1];         % Index for policy

%% Parameters of the simulated rollout
simroll.max_sim_time = 20; % (in seconds)
simroll.dt = 0.5; % (in seconds)
simroll.initX = zeros(size(dyno));  % Initial system state
simroll.H = simroll.max_sim_time / simroll.dt; % Horizon of sim rollout
simroll.target = 0; % Lowest amount of energy possible
simroll.timeInPol = 0; % 1 if the first input for the rollout policy is the
                       % simulation time
% Terminate simulation if iMaxVar variable is > than maxVar
simroll.useMaxVar = 1; % 1 to activate the option
simroll.iMaxVar = 1; % In this case x
simroll.maxVar = 5e4;
simroll.iCost = icos;

%% Parameters for interacting with real system
load_data_fcn = @readDataSTMstudio;
policy_folder = 'Controller/Src/';
log_folder = 'Controller/Log/';
UV_folder = 'Controller\MDK-ARM\MainPWM_CTS.uvprojx';
STMstudioLogExe = 'Controller\Rec\STMStudioRollout.exe';
archive_folder = 'archive/';
base_file_name = 'd1';
polSampleT = simroll.dt * 1000; % In ms
controllerMaxRollTime = simroll.max_sim_time * 1000; % Duration of rollout

%% Previous dynamics knowledge
prev_data = 'dyndata/';
use_prev_dyn_data = 0;
dyndata_file = 'dynamics0.mat';
if use_prev_dyn_data
    load([prev_data, dyndata_file])
else
    X = []; Y = [];
end

%% Cost function
if simroll.useMaxVar
    cost_fcn = @cost_max_var;
else
    cost_fcn = @cost_no_max_var;
end

%% Parameters of the low level policy
pol.minU = 0;           % Minimum control action
pol.maxU = 4200;        % Maximum control action
pol.sample = @policy; 
pol.nX = simroll.H; % Numer of data points in the X-axis lookup table
pol.lookupX = linspace(0, simroll.max_sim_time, pol.nX + 1);
pol.lookupX = pol.lookupX(2:end); % Look-up table X axis data points
pol.deltaX = pol.lookupX(2) - pol.lookupX(1); % Even spacing in look-up 
                                              % table X axis
pol.controllerDeltaX = pol.deltaX * 1000; % Value of deltaX exported to controller 
    %(different than pol.deltaX if diffent units are needed, 
    % for instance s vs ms)

%% Higher level policy
hipol.sample = @highpol;
deviation = 200; % Allows to tune the high level policy covariance matrix. 
                 % Higher, more exploration
% Check if distribution is satisfacotry using
% distribution using histogram(normrnd(muW_mean, muW_dev, 1000));
muW_mean = 2700;
muW_dev  = muW_mean / 3;
% Initial high policy mean equal to low level policy mean
hipol.muW = normrnd(muW_mean, muW_dev, pol.nX, 1);
hipol.sigmaW = eye(pol.nX) .* (deviation^2); % High level policy cov matrix
store_pols{1, 1} = hipol.muW; % Log initial policy

%% Relative entropy bound
eps = 3; % Relative entropy bound
         % Lower results in more exploration
dual_fcn = @dual_function;

%% Number of iterations
K = 3;              % Number of policy iterations
M = 10000;          % Number of simulated rollouts
NinitRolls = 20;     % Number of initial rollouts