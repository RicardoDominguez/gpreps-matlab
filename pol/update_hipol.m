%% update_hipol.m
% *Summary:* Update high level policy pi(w) using weighted maximum
% likelihood (ML).
%
%   hipol = update_hipol(p, w, hipol)
%
% *Input arguments:*
%
%   p                 vector of weights for weighted ML      % (N x 1)
%   w                 vector of parameters from samples      % (N x W)
%   hipol             high level policy struct
%       .muW                parameter mean                   % (W x 1)
%       .sigmaW             parameter covariance matrix      % (W x W)
%
% *Output arguments:*
%
%   hipol             high level policy struct
% 
% By Ricardo Dominguez Olmedo
%
% Last modified: 2017-10
%
function hipol = update_hipol(p, w, hipol)
    N = size(p, 1);
    S = ones(N, 1); % Context matrix                (N x 1)
    B = w;          % Parameter matrix              (N x W)
    P = diag(p);    % Diagonal weighting matrix     (N x N)
    
    Amatrix = pinv(S' * P * S) * S' * P * B;      % (1 x W)
    mu = Amatrix(1, :)';                          % (W x 1)
    
    % Compute sigma
    W = size(mu, 1);                              % (1 x 1)
    sum_sigma = zeros(W);                         % (W x W)
    w_mu_diff = w' - mu;                          % (W x N)
    ps = p / sum(p);
    for i = 1:N
        nom = ps(i)  * w_mu_diff(:,i) * w_mu_diff(:,i)'; % (W x W)
        sum_sigma = sum_sigma + nom;                     % (W x W)
    end
    
    % Update policy
    hipol.muW = mu;
    hipol.sigmaW = sum_sigma;
end