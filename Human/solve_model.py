# Run this file for calculating the psychometrics of the best-fitted model for human dataset


import matplotlib.pyplot as plt

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
            MSE += (sols[c].prob("correct") - s.prob("correct")) ** 2
            if sols[c].prob("correct") > 0:
                MSE += ((sols[c].mean_decision_time() - np.mean(list(s))) ** 2) * s.choice_upper.size

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
from pyddm.functions import fit_adjust_model, display_model, get_model_loss, solve_all_conditions
from pyddm.models import NoiseConstant, BoundConstant, OverlayChain, OverlayNonDecision, OverlayPoissonMixture, \
    LossRobustBIC, LossRobustLikelihood, LossSquaredError, LossBIC, OverlayUniformMixture, OverlayNonDecisionGamma, \
    LossLikelihood

# Enter model parameters for the best fitted model here

driftcoh = 20.319827469466713
Sy = 6.337198320209810
Sx = 4.880904845335600
d = 1.960289814566221
sigma0 = 1.475552429227408
B = 1
nondectime = 0.401589972650403
ndsigma = 0.035530995377349
dx = .001
dt = .01
T_dur = 5
run_numbers = 1
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
                dx=dx, dt=dt, T_dur=T_dur)



def calc_fit_model(number_run, sample, model, loss_function):
    from pyddm.functions import fit_adjust_model, display_model, get_model_loss
    from pyddm.models import LossRobustLikelihood, LossSquaredError
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


def mean_error_time(Solution):
    """The mean decision time in the correct trials (excluding undecided trials)."""
    if Solution.choice_names != ("correct", "error"):
        raise NotImplementedError("Choice names need to be set to \"correct\" and \"error\" to use this function.")
    return np.sum(Solution.err * Solution.t_domain) / Solution.prob("error")


# execute tasks in parallel in a for loop
model_pdfcorr = []
model_pdferr = []
model_accuracy = []
model_meanRT = []
model_coherence = []
model_meanRTerr = []
conditions = human_sample.condition_combinations()
solution = solve_all_conditions(model=model_2, sample=human_sample,
                                condition_combinations=None, method=None)
for simulated in solution:
    model_accuracy.append(solution[simulated].prob("correct"))
    model_pdfcorr.append(solution[simulated].pdf("correct"))
    model_pdferr.append(solution[simulated].pdf("error"))
    model_meanRT.append(solution[simulated].mean_decision_time())
    model_meanRTerr.append(mean_error_time(solution[simulated]))
    model_coherence.append(list(simulated))

for comb in human_sample.condition_combinations():
    subsamples = human_sample.subset(**comb)

sample_accuracy = human_sample.prob("correct")
sample_meanRT = human_sample.mean_decision_time()

#
import pickle

variable_names = ['accuracy', 'model mean correct RT', 'model mean error RT', 'PDF correct',
                  'PDF error', 'coherence', 'variable names']
model_RT_parameters = [model_accuracy, model_meanRT, model_meanRTerr, model_pdfcorr, model_pdferr, model_coherence,
                       variable_names]
file_name = 'solved_model_2_LossRobustLikelihood.pkl'
with open(file_name, 'wb') as file:
    pickle.dump(model_RT_parameters, file)

    print(f'Object successfully saved to "{file_name}"')
#

