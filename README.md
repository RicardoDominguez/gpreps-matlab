# GPREPS for motor velocity control

Practical implementation of GP Relative Entropy Policy Search for motor velocity control.

- [The details](#the-details)
- [To be improved](#to-be-improved)
- [Relevant papers](#relevant-papers)

# The details

GPREPS implementation in MATLAB used to train an open loop velocity controller for a BLDC motor. Check out [this video](https://www.youtube.com/watch?v=OJgzYbGpAFg) to see it at working on a real system! A similar approach will be used to minimize the energy consumption of the electric vehicle being built by [Sheffield Eco Motorsports](https://github.com/SheffieldEcoMotorsports). Please note that this implementation of GPREPS is suboptimal and I have since improved it in my [PyCREPS](https://github.com/RicardoDominguez/PyCREPS) repository (albeit in Python).

The results achieved in the real system are promising, as the algorithm can achieve reasonable accuracy in only a few samples which is impressive given the low control frequency, the high measurement noise and the very inconsistent motor dynamics.

The motor is controlled by a [STM32F4 discovery board](https://www.st.com/en/microcontrollers/stm32f4-series.html) which outputs PWM signals into the motor with duty cycle given by an open loop policy. The weights of the open loop policy are outputted by MATLAB and fed into the STM through a ``.c`` and a ``.h`` file. The GPREPS algorithm finds the policy weights which minimize the difference between the desired velocity profile and the observed motor velocity profile.

The policy iteration procedure can be abstracted as:
1. Initialize the policy arbitrarily.
2. Perform a single rollout on the physical system, acquiring real world data.
3. Train a GP dynamics forward model from all real world data acquired so far.
4. Generate M simulated rollouts using the GP forward dynamics model and different policy weights.
5. Update the high level policy according to the returns and policy weights of the simulated
   rollouts.
6. Go to step 2 (K times).

# To be improved

 * REPS implementation can be improved (mainly for stability purposes, refer to [PyCREPS](https://github.com/RicardoDominguez/PyCREPS)).
 * Currently if a rollout is missed on the real system (for example because there is no power to the motor) the program has to be stopped and restarted manually. Safeguard to automatically detect this (for instance, by checking that velocities greater than 0 have been measured)

 All feedback is welcome. Feel free to give suggestions or raise issues.

# Relevant papers
* Kupcsik, A. G., Deisenroth, M. P., Peters, J., & Neumann, G. (2013, July). Data-efficient generalization of robot skills with contextual policy search. In Proceedings of the 27th AAAI Conference on Artificial Intelligence, AAAI 2013 (pp. 1401-1407). [[pdf]](https://www.aaai.org/ocs/index.php/AAAI/AAAI13/paper/viewFile/6322/6842)
* Peters, J., Mülling, K., & Altun, Y. (2010, July). Relative Entropy Policy Search. In AAAI (pp. 1607-1612).[[pdf]](http://www.aaai.org/ocs/index.php/AAAI/AAAI10/paper/viewFile/1851/2264)
* Daniel, C., Neumann, G., & Peters, J. (2012, March). Hierarchical relative entropy policy search. In Artificial Intelligence and Statistics (pp. 273-281). [[pdf]](http://www.jmlr.org/proceedings/papers/v22/daniel12/daniel12.pdf)
* Daniel, C., Neumann, G., Kroemer, O., & Peters, J. (2016). Hierarchical relative entropy policy search. The Journal of Machine Learning Research, 17(1), 3190-3239. [[pdf]](http://www.jmlr.org/papers/volume17/15-188/15-188.pdf)
* Kupcsik, A., Deisenroth, M. P., Peters, J., Loh, A. P., Vadakkepat, P., & Neumann, G. (2017). Model-based contextual policy search for data-efficient generalization of robot skills. Artificial Intelligence, 247, 415-439. [[pdf]](http://eprints.lincoln.ac.uk/25774/1/Kupcsik_AIJ_2015.pdf)
