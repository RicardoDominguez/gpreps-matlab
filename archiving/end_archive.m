%% end_archive.m
% *Summary:* Saves various variables to the archive folder, so that the
% training process can be resumed afterwards.
%   
% By Ricardo Dominguez Olmedo
%
% Last modified: 2018-03
%

% Save policy and reward from previous rollout
store_pols{k, 1} = hipol.muW;
save([archive_folder, base_file_name, 'Info.mat'], 'store_pols', 'rollout_costs')

% Save all variables - except the GPmodels (it can lead to very large file
% sizes otherwise)
clear 'GPmodels'
save([archive_folder, base_file_name, 'All.mat'])