%% rollout_load_all_data.m
% *Summary:* Load data from a the text files corresponding to the data 
% logged during the rollouts of the policy in the physical system.
%   
% By Ricardo Dominguez Olmedo
%
% Last modified: 2018-02
%

NrollOuts = 5;
base_name = 'log';
file_ext = '.txt'; % File extension
X = []; Y = [];

for i = 1:NrollOuts
    data_file_name = [base_name, num2str(i), file_ext];
    
    [x, y] = load_data_fcn(data_file_name);
    
    % Append to previous data extracted from rollouts
    X = [X; x]; Y = [Y; y];

    fclose(y(:, icos), simroll.target);
end

