%% highpol.m
% *Summary:* Sample from the high level policy using a multivariate normal
% distribution.
%
%   w = highpol(hipol)
%
% *Input arguments:*
%
%   hipol             high level policy struct
%       .muW                parameter mean                   % (W x 1)
%       .sigmaW             parameter covariance matrix      % (W x W)
%
% *Output arguments:*
%
%   w                 parameter vector sampled                 (W x 1)
% 
% By Ricardo Dominguez Olmedo
%
% Last modified: 2017-10
%
function w = highpol(hipol, N)
    % Sample from multivariate normal distribution
    if nargin < 2, N = 1; end
    w = mvnrnd(hipol.muW, hipol.sigmaW, N)';
 end