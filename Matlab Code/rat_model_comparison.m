close all; clear;

species = {'Rat'};
cases = {'case (i)',
    'case (ii)',
    'case (iii)',
    'case (iv)'};
coherence_to_plot = {[0.1, 0.5]};
T_dur = 3;  % seconds
dt = 0.01;  % seconds in model
t = (0:dt:T_dur);
initial_condition = {'fixed', 'uniform'};
parameter_comparison_method = {'absolute', 'normalized'};
model_type = {'full', 'restricted'};
num_of_cases = length(cases);
forced_best_case = 0;
[current_path, fName, fExt] = fileparts(which("model_comparisons.m"));
% current_path = cd; 
base_folder = fullfile(current_path, '..');  % C:\Users\se16008969\OneDrive - Ulster University\Research projects\Hui''s paper\Real data fit or
                                                                                                                % C:\Users\assad\OneDrive - Ulster University\Research projects\Hui''s paper\Real data fit

loss_function = 'LossRobustLikelihood';    % 'LossSquaredError' or 'LossRobustLikelihood' or 'LossByMeans'

for i = 1 : length(species)
    model_comparison(i) = get_model_statistics(species{i}, base_folder, model_type{1},initial_condition{1}, loss_function);
    model_comparison(i) = choose_best_model_parameters(model_comparison(i), forced_best_case, 'squared error');    
end

other_case_numbers = 1 : num_of_cases;
best_case = model_comparison(1).estimated_model;
other_case_numbers(other_case_numbers == best_case) = [];
sorted_case_numbers = [best_case other_case_numbers];

for i = 2 : num_of_cases
    model_comparison(i) = choose_best_model_parameters(model_comparison(1), other_case_numbers(i - 1), 'squared error');
end

for i = 1 : num_of_cases
    [model_pychopysics(i), real_data_pychopysics(i)] = get_psychophysics(model_comparison(i), 'squared error');
    plot_psychophysics(model_pychopysics(i), real_data_pychopysics(i), coherence_to_plot{1}, t)
    figure("Name", [species{1} ' ' cases{sorted_case_numbers(i)} ' model gain'])
    model_comparison(i) = plot_gain(model_comparison(i), t);
end

plot_RT_distributions(model_pychopysics, real_data_pychopysics, coherence_to_plot, t)

figure("Name", ['model gain comparison'], 'units','normalized','outerposition',[0 0 0.5 0.5])
for i = 1 : num_of_cases
    plot_gain(model_comparison(i), t);
    hold on
end
model_comparison = normalize_model_parameters(model_comparison, species{1});

for method_num = 1 : length(parameter_comparison_method)
    figure("Name", [model_type{1} ' ' parameter_comparison_method{method_num} ' model parameters'], 'units','normalized','outerposition',[0 0 0.6 0.6])
    for i = 1 : length(model_comparison)
        plot_parameters(model_comparison(i), parameter_comparison_method{method_num}, i);
        hold on
    end
end
%% run for restricted model
% for i = 1 : length(species)
%     restricted_model_comparison(i) = get_model_statistics(species{i}, base_folder, model_type{2});
%     restricted_model_comparison(i) = choose_best_model_parameters(restricted_model_comparison(i), forced_best_case);
%     [restricted_model_pychopysics(i), restricted_real_data_pychopysics(i)] = get_psychophysics(restricted_model_comparison(i), base_folder, loss_function);
%     plot_psychophysics(restricted_model_pychopysics(i), restricted_real_data_pychopysics(i), coherence_to_plot{i}, t)
%     figure("Name", [species{i} ' model gain'])
%     restricted_model_comparison(i) = plot_gain(restricted_model_comparison(i), t);
% end
% 
% figure("Name",[model_type{2} ' model gain'])
% for i = 1 : length(species)
%     plot_gain(restricted_model_comparison(i), t);
%     hold on
% end