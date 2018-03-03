%% compare_cost_rolls.m
% *Summary:* Compare the rewards associated with different physical
% rollouts, stored in data files.
%
% By Ricardo Dominguez Olmedo
%
% Last modified: 2018-03
%

NrollOuts = 5;
base_name = 'log';
file_ext = '.txt'; % File extension
X = []; Y = [];
costs = zeros(1, NrollOuts);

for i = 1:NrollOuts
    data_file_name = [base_name, num2str(i), file_ext];
    
    [x, y] = load_data_fcn(data_file_name, simroll.H);
    
    costs(i) = cost_fcn(y(:, icos)', simroll.target);
end