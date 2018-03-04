%% rollout_load_data.m
% *Summary:* Load data from a text file corresponding to the data logged
% during the rollout of the policy in the physical system.
%   
% By Ricardo Dominguez Olmedo
%
% Last modified: 2018-03
%

% Move last log file to current directory
movefile([log_folder, 'log.txt'], 'log.txt');
data_file_name = 'log.txt';

% Extract x and y data
[x, y] = load_data_fcn(data_file_name, simroll.H);

% Evaluate cost of train data
rollout_costs(k) = cost_fcn(y(:, icos)', simroll.target);


% Append to previous data extracted from rollouts
X = [X; x]; Y = [Y; y];
save([archive_folder, base_file_name, 'RolloutData.mat'], 'X', 'Y')

% Send log file to archive
if exist('log.txt', 'file') == 2 % If file exists
    new_name = [base_file_name, 'Log', num2str(k), '.txt'];
    movefile('log.txt', [archive_folder, new_name]);
end