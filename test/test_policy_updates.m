init_param;
init_arbitrary_pol;
og = hipol.muW;
load('d2RolloutData.mat')
train_forward_model
predict_reward
update_policy
differences = (og - hipol.muW)
sum(abs(og-hipol.muW))

% eps 1 - 157
