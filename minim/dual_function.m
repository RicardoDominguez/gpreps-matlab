%% dual_function.m
% *Summary:* Implementation of the GPREPS dual function. 
%
%   [fval, grad] = dual_function(x)
%
% *Input arguments:*
%
%   x                 vector containing (eta, theta)        (1 x 1+S)
%
% *Output arguments:*
%
%   fval              value of the dual function at x       (1 x 1)
%   grad              gradient of the dual function at x    (1 x 1+S)
% 
% By Ricardo Dominguez Olmedo
%
% Last modified: 2017-10
%
function [fval, grad] = dual_function(x)

    eta = x(1); theta = x(2:end)';
    
    % Extract additional arguments
    global min_fnc_args;
    dataset = min_fnc_args;
    Wdataset = dataset{1}; % (N x W)
    Rdataset = dataset{2}; % (N x 1)
    Fdataset = dataset{3}; % (N x S)
    eps      = dataset{4}; % (1 x 1)
    
    % Evaluate dual function at x
    N = size(Wdataset, 1);
    mean_f = mean(Fdataset, 1)';                            % (S x 1)
    err = Rdataset - sum(theta'.* Fdataset, 2);             % (N x 1)
    zeta = exp(err / eta);                                  % (N x 1)
    s_zeta = sum(zeta);                                     % (1 x 1)
    summa = s_zeta / N;                                     % (1 x 1)
    fval = eta * log(summa) + eta * eps + theta' * mean_f;  % (1 x 1)
    
    % Evaluate gradient
    if nargout > 1
        % Evaluate gradient w.r.t. eta
        base = sum(zeta.*err) / (eta * sum(zeta));          % (1 x 1)
        d_eta = eps + log(summa) - base;                    % (1 x 1)
        
        % Evaluate gradient w.r.t. theta
        d_theta = mean_f - (sum(zeta.*Fdataset, 1)' / s_zeta); % (S x 1)
        
        grad = [d_eta, d_theta'];                           % (1 x 1+S)
    end
end
