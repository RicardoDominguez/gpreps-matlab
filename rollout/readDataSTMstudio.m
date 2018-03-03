%% rollout_load_all_data.m
% *Summary:* Load data from a text file outputted by STMstudio.
%   
% *Input arguments:*
%   -data_file_name     file name of the text file
%   -H                  number of samples extracted
%
% By Ricardo Dominguez Olmedo
%
% Last modified: 2018-02
%

function [x, y] = readDataSTMstudio(data_file_name, H)
    fid = fopen(data_file_name);
    
    lines_out = 8; % Ignore first lines_out lines in text file
    for i = 1:lines_out, fgetl(fid); end

    raw_data = fscanf(fid, "D:\t%f\t%d\t%d\t%d\n", [4 Inf])'; % 4 columns
                                                              % [t, v, U, flag]
    istrt = find(raw_data(:, 4) == 1, 1); % Start index when start flag is 1
    endstr = istrt + H; % simroll.H samples from start index
    rollout_data = raw_data(istrt:endstr, [2, 3]); % [v, U] extracted
    
    x = rollout_data(1:end-1, :); y = rollout_data(2:end, :);

    fclose(fid);
end