function logLikelihood = computeLogLikelihood(theta)
% Compute the log-likelihood for given parameter values
    v = theta(1);
    a = theta(2);
    z = theta(3);
    Sy = theta(4);
    Sx = theta(5);
    d = theta(6);
    sigma0 = theta(7);

    % Reaction time data and stimulus information
    RT = [100, 150, 120, 180, 200]; % Example reaction time data
    stimulus = [1, -1, 1, -1, 1]; % Example stimulus values (+1 or -1) for each trial
    nTrials = numel(RT);
    
    % Compute the drift rate (drift function)
    drift = v .* stimulus;
    
    % Compute the gain function (time-varying gain)
    t = 1:nTrials;
    
    
    % Run simulation for each trial
    logLikelihood = 0;
    for i = 1:nTrials
        RT_pred = simulateDDM(drift(i), a, z, Sy, Sx, d, sigma0);
        logLikelihood = logLikelihood + (RT(i)- RT_pred)^2; %log(normpdf(RT(i), RT_pred, 1)); % Assuming Gaussian noise with unit variance
    end
    
    % Negative log-likelihood for maximization
    % logLikelihood = -logLikelihood;
end