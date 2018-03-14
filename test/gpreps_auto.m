% gpreps_auto

gpreps
% for iroll = 1:InitRoll
%     disp 'Initializing policy...'; init_arbitrary_pol;     % Initialize policy
%     disp 'Exporting policy into files...'; export_policy;  % Export policy into the 
%                                                        % format used by the 
%                                                        % physical system
%     disp 'Load data from rollout'; rollout_load_data;
% end
%load('initDat.mat')
%hipol.muW(:, 1) = ones(pol.nX, 1) * 3000;

while(k  < K)
    fprintf("Rollout %d out of %d...\n", k, K)
    gpreps2
end