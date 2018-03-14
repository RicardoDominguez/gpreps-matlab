%% export_policy.m
% *Summary:* Export policy into a file depending of the format used by the 
% physical system controller.
%   
% By Ricardo Dominguez Olmedo
%
% Last modified: 2018-02
%

% Export look upo table into a C file formats
lookupTable2arrayFile(pol.nX, pol.deltaX*1000, hipol.muW);
movefile('lookupTable.c', [policy_folder, 'lookupTable.c'])
movefile('lookupTable.h', [policy_folder, 'lookupTable.h'])
rollout_STM;