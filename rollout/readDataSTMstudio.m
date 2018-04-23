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

function [x, y] = readDataSTMstudio(data_file_name, simroll) % [x v E U]
    H = simroll.H; 
        
    fid = fopen(data_file_name);
    
    lines_out = 8; % Ignore first lines_out lines in text file
    for i = 1:lines_out, fgetl(fid); end

    raw_data = fscanf(fid, "D:\t%f\t%d\t%d\t%d\t%d\n", [5 Inf])'; % 4 columns
                                                              % [t, v, U, e, flag]
    dt = (raw_data(2, 1) - raw_data(1, 1)) / 1000;
    
    iU = 3; % index in raw_data of control action U (sample when U changes)
    nOut = 4; % number of variables being sampled
    sample = [2, 3]; % Index of raw_data being sampled normally
    integrate = [2, 4]; % Index of raw_data being sampled and integrated
    iSample = [2, 4]; % Index of latent containing 'sample' variables
    iInt = [1, 3]; % Index of latent containing 'integrate' variables
    latent = zeros(H+1, nOut); % All samples stored here
    
    startU = raw_data(1, iU);
    ifind = 1; % Last data sample index
    latent(1, iSample) = raw_data(1, sample); % First sample
    latent(1, iInt) = zeros(1, length(integrate)); % Integral with 0 initial condition
    for j = 2:(H+1)
        lastifind = ifind;
        ifind = find(raw_data(ifind:end, iU) ~= startU, 1) + ifind - 1;
        startU = raw_data(ifind, iU);
        latent(j, iSample) = raw_data(ifind, sample);
        latent(j, iInt) = latent(j-1, iInt) ...
            + sum(raw_data(lastifind:ifind-1, integrate));
    end
    latent(:, iInt) = latent(:, iInt) * dt;

    x = latent(1:end-1, :); y = latent(2:end, :);

    fclose(fid);
end