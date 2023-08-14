# Run this file for estimating model parameters for human dataset

import matplotlib.pyplot as plt
import logging

logging.disable(logging.CRITICAL)

from pyddm import Sample
import pandas

with open("BestUnbiasedPsychoEpochsHUMAN200502.csv", "r") as f:
    df_rt = pandas.read_csv(f)
# df_rt = df_rt[df_rt["subjectID"] == 459]  # Only Human #459

# Remove short and long RTs, as in 10.1523/JNEUROSCI.4684-04.2005.
# This is not strictly necessary, but is performed here for
# compatibility with this study.
df_rt = df_rt[df_rt["rt"] > .1]  # Remove trials less than 100ms
df_rt = df_rt[df_rt["rt"] < 2.5]  # Remove trials greater than 2500ms

# df_rt = df_rt[df_rt["response"] == 1]  # Remove error trials

# Create a sample object from our data.  This is the standard input
# format for fitting procedures.  Since RT and correct/error are
# both mandatory columns, their names are specified by command line
# arguments.
human_sample = Sample.from_pandas_dataframe(df_rt, rt_column_name="rt", choice_column_name="response")

import pyddm as ddm
import numpy as np


###gain function###
def urgency_gain(t, Sy, Sx, d):
    return Sy * np.exp(Sx * (t - d)) / (1 + np.exp(Sx * (t - d))) + \
        (1 + (1 - Sy) * np.exp(-Sx * d)) / (1 + np.exp(-Sx * d))


from pyddm import Drift


class DriftUrgencyGain(Drift):
    name = "Drift depends linearly on coherence with an urgency function"
    required_parameters = ["driftcoh", "Sy", "Sx", "d"]  # <-- Parameters we want to include in the model
    required_conditions = ["coh"]  # <-- Task parameters ("conditions"). Should be the same name as in the sample.

    def get_drift(self, t, conditions, **kwargs):
        return self.driftcoh * conditions['coh'] * urgency_gain(t, self.Sy, self.Sx, self.d)


class DriftGain(Drift):
    name = "Drift depends linearly on coherence with an urgency function"
    required_parameters = ["driftcoh"]  # <-- Parameters we want to include in the model
    required_conditions = ["coh"]  # <-- Task parameters ("conditions"). Should be the same name as in the sample.

    def get_drift(self, t, conditions, **kwargs):
        return self.driftcoh * conditions['coh']


from pyddm import Noise


class NoiseUrgencyGain(Noise):
    name = "Noise depends linearly on gain with an urgency function"
    required_parameters = ["Sy", "Sx", "d", "sigma0"]  # <-- Parameters we want to include in the model

    def get_noise(self, t, **kwargs):
        return urgency_gain(t, self.Sy, self.Sx, self.d) * self.sigma0


class NoiseUrgencyCoherenceGain(Noise):
    name = "Noise depends linearly on gain with an urgency function and coh"
    required_parameters = ["Sy", "Sx", "d", "sigma0"]  # <-- Parameters we want to include in the model
    required_conditions = ["coh"]  # <-- Task parameters ("conditions"). Should be the same name as in the sample.

    def get_noise(self, t, conditions, **kwargs):
        return urgency_gain(t, self.Sy, self.Sx, self.d) * self.sigma0 * np.sqrt(1 + conditions['coh'])


class NoiseGain(Noise):
    name = "Noise depends linearly on gain with an urgency function"
    required_parameters = ['sigma0']  # <-- Parameters we want to include in the model

    def get_noise(self, t, **kwargs):
        return self.sigma0


def mean_error_time(Solution):
    """The mean decision time in the correct trials (excluding undecided trials)."""
    if Solution.choice_names != ("correct", "error"):
        raise NotImplementedError("Choice names need to be set to \"correct\" and \"error\" to use this function.")
    if Solution.prob("error") > 0:
        return np.sum(Solution.err * Solution.t_domain) / Solution.prob("error")
    else:
        return 0


import numpy as np
from pyddm import LossFunction


class LossByMeans(LossFunction):
    name = "Mean RT and accuracy"

    def setup(self, dt, T_dur, **kwargs):
        self.dt = dt
        self.T_dur = T_dur

    def loss(self, model):
        sols = self.cache_by_conditions(model)
        MSE = 0
        for comb in self.sample.condition_combinations(required_conditions=self.required_conditions):
            c = frozenset(comb.items())
            s = self.sample.subset(**comb)
            # MSE += (sols[c].prob("correct") - s.prob("correct")) ** 2
            if sols[c].prob("correct") > 0:
                MSE += ((sols[c].mean_decision_time() - np.mean(list(s))) ** 2) * s.choice_upper.size + \
                       ((mean_error_time(sols[c]) - np.mean(s.choice_lower)) ** 2) * s.choice_lower.size
        return MSE


import numpy as np
import scipy
from pyddm import Overlay, Solution


class OverlayNonDecisionGaussian(Overlay):
    name = "Add a Gaussian-distributed non-decision time"
    required_parameters = ["nondectime", "ndsigma"]

    def apply(self, solution, **kwargs):
        # Make sure params are within range
        assert self.ndsigma > 0, "Invalid st parameter"
        # Extract components of the solution object for convenience
        choice_upper = solution.choice_upper
        choice_lower = solution.choice_lower
        dt = solution.dt
        # Create the weights for different timepoints
        times = np.asarray(list(range(-len(choice_upper), len(choice_upper)))) * dt
        weights = scipy.stats.norm(scale=self.ndsigma, loc=self.nondectime).pdf(times)
        if np.sum(weights) > 0:
            weights /= np.sum(weights)  # Ensure it integrates to 1
        newchoice_upper = np.convolve(weights, choice_upper, mode="full")[len(choice_upper):(2 * len(choice_upper))]
        newchoice_lower = np.convolve(weights, choice_lower, mode="full")[len(choice_upper):(2 * len(choice_upper))]
        return Solution(newchoice_upper, newchoice_lower, solution.model,
                        solution.conditions, solution.undec)


from pyddm import Model, Fittable
from pyddm.functions import fit_adjust_model, display_model, get_model_loss
from pyddm.models import NoiseConstant, BoundConstant, OverlayChain, OverlayNonDecision, OverlayPoissonMixture, \
    LossRobustBIC, LossRobustLikelihood, LossSquaredError, LossBIC, OverlayUniformMixture, OverlayNonDecisionGamma, \
    LossLikelihood, ICUniform

driftcoh = Fittable(minval=0, maxval=50)
Sy = Fittable(minval=0.01, maxval=30)
Sx = Fittable(minval=0, maxval=15)
d = Fittable(minval=0, maxval=2)
sigma0 = Fittable(minval=0, maxval=5)
B = 1
nondectime = Fittable(minval=0.25, maxval=.8)
ndsigma = Fittable(minval=0.02, maxval=.2)
initial_condition = ICUniform()
dx = .001
dt = .01
T_dur = 5

model_2 = Model(name='Human data, drift varies with coherence and urgency, noise with urgency',
                drift=DriftUrgencyGain(driftcoh=driftcoh,
                                       Sy=Sy,
                                       Sx=Sx,
                                       d=d),
                noise=NoiseUrgencyGain(Sy=Sy,
                                       Sx=Sx,
                                       d=d,
                                       sigma0=sigma0),
                bound=BoundConstant(B=B),
                # Since we can only have one overlay, we use
                # OverlayChain to string together multiple overlays.
                # They are applied sequentially in order.  OverlayNonDecision
                # implements a non-decision time by shifting the
                # resulting distribution of response times by
                # `nondectime` seconds.
                overlay=OverlayNonDecisionGaussian(nondectime=nondectime,
                                                   ndsigma=ndsigma),
                IC=initial_condition,
                dx=dx, dt=dt, T_dur=T_dur)

model_1 = Model(name='Human data, drift varies with urgency and coherence, noise with urgency and coherence',
                drift=DriftUrgencyGain(driftcoh=driftcoh,
                                       Sy=Sy,
                                       Sx=Sx,
                                       d=d),
                noise=NoiseUrgencyCoherenceGain(Sy=Sy,
                                                Sx=Sx,
                                                d=d,
                                                sigma0=sigma0),
                bound=BoundConstant(B=B),
                # Since we can only have one overlay, we use
                # OverlayChain to string together multiple overlays.
                # They are applied sequentially in order.  OverlayNonDecision
                # implements a non-decision time by shifting the
                # resulting distribution of response times by
                # `nondectime` seconds.
                overlay=OverlayNonDecisionGaussian(nondectime=nondectime,
                                                   ndsigma=ndsigma),
                IC=initial_condition,
                dx=dx, dt=dt, T_dur=T_dur)

model_3 = Model(name='Human data, drift varies with coherence, noise with urgency',
                drift=DriftGain(driftcoh=driftcoh),
                noise=NoiseUrgencyGain(Sy=Sy,
                                       Sx=Sx,
                                       d=d,
                                       sigma0=sigma0),
                bound=BoundConstant(B=B),
                # Since we can only have one overlay, we use
                # OverlayChain to string together multiple overlays.
                # They are applied sequentially in order.  OverlayNonDecision
                # implements a non-decision time by shifting the
                # resulting distribution of response times by
                # `nondectime` seconds.
                overlay=OverlayNonDecisionGaussian(nondectime=nondectime,
                                                   ndsigma=ndsigma),
                IC=initial_condition,
                dx=dx, dt=dt, T_dur=T_dur)

model_4 = Model(name='Human data, drift varies with coherence and urgency, noise',
                drift=DriftUrgencyGain(driftcoh=driftcoh,
                                       Sy=Sy,
                                       Sx=Sx,
                                       d=d),
                noise=NoiseGain(sigma0=sigma0),
                bound=BoundConstant(B=B),
                # Since we can only have one overlay, we use
                # OverlayChain to string together multiple overlays.
                # They are applied sequentially in order.  OverlayNonDecision
                # implements a non-decision time by shifting the
                # resulting distribution of response times by
                # `nondectime` seconds.
                overlay=OverlayNonDecisionGaussian(nondectime=nondectime,
                                                   ndsigma=ndsigma),
                IC=initial_condition,
                dx=dx, dt=dt, T_dur=T_dur)




def calc_fit_model(number_run, sample, model, loss_function):
    from pyddm.functions import fit_adjust_model, display_model, get_model_loss
    from pyddm.models import LossRobustLikelihood, LossSquaredError
    import warnings
    warnings.filterwarnings("ignore")

    fitted_model = fit_adjust_model(sample=sample, model=model,
                                    # fitting_method="simplex",
                                    lossfunction=loss_function,
                                    verbose=False)
    model_loss = get_model_loss(model=model, sample=sample,
                                lossfunction=LossSquaredError,
                                method=None)
    print('Model parameters for run', number_run)
    display_model(fitted_model)
    print("model's squared error is: ", model_loss)
    param_names = fitted_model.get_model_parameter_names()
    params = fitted_model.get_model_parameters()
    log_loss = fitted_model.get_fit_result().value()
    return [param_names, params, log_loss, model_loss]


# execute tasks in parallel in a for loop
from multiprocessing import Process, Manager, Pool, cpu_count

# protect the entry point
if __name__ == '__main__':
    cpu_nums = cpu_count()
    run_numbers = 40
    loss_function = LossRobustLikelihood
    print('Start fitting models')
    # create all tasks
    with Pool(processes=cpu_nums) as pool:


        args = [(i, human_sample, model_2, loss_function) for i in range(run_numbers)]
        all_models_2 = pool.starmap(calc_fit_model, args)

        args = [(i, human_sample, model_3, loss_function) for i in range(run_numbers)]
        all_models_3 = pool.starmap(calc_fit_model, args)

        args = [(i, human_sample, model_4, loss_function) for i in range(run_numbers)]
        all_models_4 = pool.starmap(calc_fit_model, args)

        args = [(i, human_sample, model_1, loss_function) for i in range(run_numbers)]
        all_models_1 = pool.starmap(calc_fit_model, args)
    # report that all tasks are completed
    print('Done', flush=True)
    #
    import pickle

    loss_function_name = 'LossRobustLikelihood'
    file_name = 'restricted_models_1_' + loss_function_name + '.pkl'
    with open(file_name, 'wb') as file:
        pickle.dump(all_models_1, file)
        print(f'Object successfully saved to "{file_name}"')

    file_name = 'restricted_models_2_' + loss_function_name + '.pkl'
    with open(file_name, 'wb') as file:
        pickle.dump(all_models_2, file)

        print(f'Object successfully saved to "{file_name}"')

    file_name = 'restricted_models_3_' + loss_function_name + '.pkl'
    with open(file_name, 'wb') as file:
        pickle.dump(all_models_3, file)

        print(f'Object successfully saved to "{file_name}"')

    file_name = 'restricted_models_4_' + loss_function_name + '.pkl'
    with open(file_name, 'wb') as file:
        pickle.dump(all_models_4, file)

        print(f'Object successfully saved to "{file_name}"')
#

