%% minimize_dual_func.m
% *Summary:* Minimize dual function with constrain eta > 0, using the 
% interior point algorithm.
%
%   X = minimize_dual_func(fcn, args)
%
% *Input arguments:*
%
%   fcn               function handle to the dual function
%   args              cell - additional arguments for the dual function
%       args{1}             Weight  dataset matrix  (N x W)
%       args{2}             Return  dataset vector  (N x 1)
%       args{3}             Feature dataset matrix  (N x S)
%       args{4}             Epsilon                 (1 x 1)
%
% *Output arguments:*
%
%   X                 minimization solution (1 x 1+n_theta)
% 
% By Ricardo Dominguez Olmedo
%
% Last modified: 2017-10
%
function X = minimize_dual_func(fcn, args)

    global min_fnc_args; % Additional arguments to pass to 'fun' other than
    min_fnc_args = args; % eta and theta.
    
    n_theta = size(args{3}, 2);
    
    % Make sure initial point is defined
    eta_undefined = 1; eta0 = 1; theta0 = zeros(1, n_theta);
    while(eta_undefined)
        eta0 = 10 * eta0;
        x0 = [eta0, theta0]; % Initial x value
        [val, grad] = fcn(x0);
        eta_undefined = isinf(val)|isnan(val)|isinf(grad(1))|isnan(grad(1));
    end
    
    A = []; b = []; Aeq = []; beq = []; nonlcon = []; ub = []; % Constrains
    lb = [0, ones(1, n_theta) * (-Inf)]; % Constrain eta > 0
    
    % 'fcn' also evaluates the gradient of dual function
    % Minimize using the interior point algorithm
    options = optimoptions('fmincon', 'SpecifyObjectiveGradient', true, ...
        'Algorithm', 'interior-point');
    
    X = fmincon(fcn, x0, A, b, Aeq, beq, lb, ub, nonlcon, options);
end