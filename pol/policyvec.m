%% policy.m
% *Summary:* Return an action given the system state. The policy hereby
% is implemented by tiling the state space, having each tile an associated 
% weight which refelct the action before applying saturation.
%
%   hipol = update_hipol(p, w, hipol)
%
% *Input arguments:*
%
%   pol               struct containing several policy parameters
%       .nX                 number of datapoint in look-up table X axis  (1 x 1)
%       .deltaX             spacing between each datapoint in X axis     (1 x 1)
%       .minU               minimum action                               (1 x 1)
%       .maxU               maximum action                               (1 x 1)
%   W                 policy weights for each trajectory                 (nW x T)
%   X                 system state                                       (T x 1)
%
% *Output arguments:*
%
%   u             	  control output to the system                       (T x 1)
% 
% By Ricardo Dominguez Olmedo
%
% Last modified: 2018-02
%
function u = policyvec(pol, W, X)
    nX = pol.nX; spacing = pol.deltaX; min = pol.minU; max = pol.maxU;

    T = size(X, 1);
    u = zeros(T, 1);
    
    % Values out of range of thr
    ilX = X <= 0; imX = X >= nX * spacing;
    u(ilX) = W(1, ilX); u(imX) = W(end, imX);
    
    aoX = ~(ilX|imX); % all other X
    is = ceil(X(aoX) / spacing); % index of W used
    u(aoX) = diag(W(is, aoX)); % pairs of is and aoX
    
    % Saturation
    u(u>max) = max; u(u<min) = min;
end