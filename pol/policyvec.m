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
%       .n_tiles            number of tiles
%       .thr                vector containing the thresholds of each tile (N x 1)
%       .W                  policy weights
%       .minU               minimum action
%       .maxU               maximum action
%   X                 system state
%
% *Output arguments:*
%
%   u             	  control output to the system
% 
% By Ricardo Dominguez Olmedo
%
% Last modified: 2017-10
%
% W (NW, T)
% X (T, 1)
% thr (NW, 1)
% u (T, 1)
function u = policyvec(pol, W, X)
    thr = pol.thr; spacing = pol.spacing; min = pol.minU; max = pol.maxU;

    T = size(X, 1);
    u = zeros(T, 1);
    
    % Values out of range of thr
    ilX = X <= thr(1); imX = X >= thr(end);
    u(ilX) = W(1, ilX); u(imX) = W(end, imX);
    
    aoX = ~(ilX|imX); % all other X
    is = ceil((X(aoX) - thr(1))/spacing); % index of W used
    u(aoX) = diag(W(is, aoX)); % pairs of is and aoX
    
    % Saturation
    u(u>max) = max; u(u<min) = min;
end