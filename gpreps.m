%% gpreps.m
% *Summary:* Main script for the implementation of GPREPS (from
% initializing the scenario up until the first policy export)
%   
% By Ricardo Dominguez Olmedo
%
% Last modified: 2018-02
%

init_param;             % Initialize scenario
init_arbitrary_pol;     % Initialize policy
export_policy;          % Export policy into the format used by the 
                        % physical system
                        
disp '---------------------------------------------------'
disp 'Time to rollout the policy into the physical system'
disp 'When done run gpreps2'
disp '---------------------------------------------------'
k = 1; % First policy iteration comes now