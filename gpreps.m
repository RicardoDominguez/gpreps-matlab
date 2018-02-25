%% gpreps.m
% *Summary:* Main script for the implementation of GPREPS (from
% initializing the scenario up until the first policy export)
%   
% By Ricardo Dominguez Olmedo
%
% Last modified: 2018-02
%

disp 'Initializing algorithm...'; init_param;          % Initialize scenario
disp 'Initializing policy...'; init_arbitrary_pol;     % Initialize policy
disp 'Exporting policy into files...'; export_policy;  % Export policy into the 
                                                       % format used by the 
                                                       % physical system
                        
disp '---------------------------------------------------'
disp 'Time to rollout the policy into the physical system'
disp 'When done run gpreps2'
disp '---------------------------------------------------'
k = 1; % First policy iteration comes now