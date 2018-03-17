# GPREPSmotorTest
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

To improve:
 * Add velocity feedback