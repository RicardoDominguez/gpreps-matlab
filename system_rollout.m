%% system_rollout.m
% *Summary:* Perform a policy rollout on the physical system. In order to 
% do, so first export policy into a file depending of the format used by 
% the physical system controller. Then, build and flash the controller.
% Finally, call a data acquisition script for STMstudio.
%   
% By Ricardo Dominguez Olmedo
%
% Last modified: 2018-03
%

% Export look upo table into a C file formats, move to controller folder
printLookupTableC(pol.nX, pol.controllerDeltaX, hipol.muW);
movefile('lookupTable.c', [policy_folder, 'lookupTable.c'])
movefile('lookupTable.h', [policy_folder, 'lookupTable.h'])

% Build and flash controller
system(['UV4 -b ', UV_folder]); % Build project
system(['UV4 -f ', UV_folder]); % Flash project

% Call data acquisition script
system(STMstudioLogExe);

% Load data from rollout
loadRolloutData;