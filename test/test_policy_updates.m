init_param;
init_arbitrary_pol;
og = hipol.muW;
load('d4RolloutData.mat')
eps = 4;
kn = 10;
policies = zeros(kn+1, length(hipol.muW));
policies(1, :) = hipol.muW';
for kiii = 1:kn
    train_forward_model
    predict_reward
    update_policy
    differences = (hipol.muW - og);
    sum(abs(og-hipol.muW))
    policies(kiii+1, :) = hipol.muW';
    %hipol.muW
    %pause;
end

%plot(policies')
%num2cell('123456')
%legend(ans)