%% init_arbitrary_pol.m
% *Summary:* Arbitrary initialization of the weights for the low level/high
% level policy usign a normal distribution.
%
% By Ricardo Dominguez Olmedo
%
% Last modified: 2018-02
%

%% Change mean and deviation as desired. Currently, high deviation arround
% the mean to get sufficent information about the dynamics of the physical
% system.
sample_mean = (pol.maxU + pol.minU) / 2;
sample_dev = sample_mean / 3;
% Visiaully check if this values are satisfactory using:
%   >> pns = normrnd(sample_mean, sample_dev, 1000);
%   >> histogram(pns)

%% Initialize weights
% Weight of the policy, look-up table Y axis data points
pol.W = normrnd(sample_mean, sample_dev, pol.nX, 1);
% Initial high policy mean equal to low level policy mean
hipol.muW = pol.W;