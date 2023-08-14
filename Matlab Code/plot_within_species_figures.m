close all; clear;
plot_time = 2.5;    % duration of trials in seconds
DDM_monkey = calculate_model_comparison('Monkey', plot_time);

pause

DDM_human = calculate_model_comparison('Human', plot_time);

pause

DDM_rat = calculate_model_comparison('Rat', plot_time);