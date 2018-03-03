%% rollout_load_data.m
% *Summary:* Load data from a text file corresponding to the data logged
% during the rollout of the policy in the physical system.
%   
% By Ricardo Dominguez Olmedo
%
% Last modified: 2018-02
%

data_file_name = 'log.txt';
fid = fopen(data_file_name);

lines_out = 8;
for i = 1:lines_out, fgetl(fid); end

raw_data = fscanf(fid, "D:\t%f\t%d\t%d\t%d\n", [4 Inf])';
istrt = find(raw_data(:, 4) == 1, 1);
endstr = istrt + simroll.H;
rollout_data = raw_data(istrt:endstr, [2, 3]);

x = rollout_data(1:end-1, :); y = rollout_data(2:end, :);

% Append to previous data extracted from rollouts
X = [X; x]; Y = [Y; y];