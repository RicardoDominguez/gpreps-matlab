# GPREPS
This GPREPS implmentation is designed to interact with a physical system,
where policy rollouts are conducted on said system and the GP forward
models are trained with the resulting data.

The general data flow can be represented as:
1. Policy arbitrarily initialized.
2. Rollout of the policy on the physcial system, real world data
   acquired.
3. GP forward model trained from all acquired real world data.
4. GP model and policy used to generate M simulated rollouts.
5. Update high level policy according to the result of the simulated
   rollouts.
6. Go to step 2 (K times)

Design for energy optimization TODO:
1. Main.c add option update only at sample rate when PID and automatic control
2. Policy input speed/whatnot should be given by matlab
3. There is a better way to handle not done rollouts
4. Sample without changing input

Procedure for the lab testing:
6. Tune cost function accordingly so that policy changes sufficiently.
7. Rollout normally

