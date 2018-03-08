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

function [x, y] = readDataSTMstudio(data_file_name, simroll)
    H = simroll.H; 
    dt = simroll.dt * 1000;  % in ms
    
    latent = zeros(H+1, 2);
    
    fid = fopen(data_file_name);
    
    lines_out = 8; % Ignore first lines_out lines in text file
    for i = 1:lines_out, fgetl(fid); end

    raw_data = fscanf(fid, "D:\t%f\t%d\t%d\t%d\n", [4 Inf])'; % 4 columns
                                                              % [t, v, U, flag]
                                                              
    startU = raw_data(1, 3);
    ifind = 1; % Last data sample index
    latent(1, :) = raw_data(1, [2, 3]);
    for j = 2:(H+1)
        ifind = find(raw_data(ifind:end, 3) ~= startU, 1) + ifind - 1;
        startU = raw_data(ifind, 3);
        latent(j, :) = raw_data(ifind, [2, 3]);
    end
    
%     % Sampling looking at time dt
%     raw_data(:, 1) = raw_data(:, 1) - raw_data(1, 1); % Time starts at 0                                                    
%     for j = 1:(H+1)
%         idata = find(raw_data(:,1) >= ((j-1)*dt), 1);
%         latent(j, :) = raw_data(idata, [2 ,3]); % [v, U] extracted 
%     end

    x = latent(1:end-1, :); y = latent(2:end, :);

    fclose(fid);
end