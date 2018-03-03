%% rollout_load_data.m
% *Summary:* Load data from a text file corresponding to the data logged
% during the rollout of the policy in the physical system.
%   
% By Ricardo Dominguez Olmedo
%
% Last modified: 2018-03
%

data_file_name = 'log.txt';

[x, y] = load_data_fcn(data_file_name, simroll.H);

% Append to previous data extracted from rollouts
X = [X; x]; Y = [Y; y];