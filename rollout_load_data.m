%% rollout_load_data.m
% *Summary:* Load data from a text file corresponding to the data logged
% during the rollout of the policy in the physical system.
%   
% By Ricardo Dominguez Olmedo
%
% Last modified: 2018-02
%

data_file_name = 'lastRolloutData.txt';
rollout_data = csvread(data_file_name);

% Divide data for training inputs and outputs
x = rollout_data(1:end-1); y = rollout_data(2:end-1);

% Append to previous data extracted from rollouts
X = [X; x]; Y = [Y; x];