function DDM = calculate_model_comparison(species, plot_time)
close all;
species = {species};
species_num = 1;
between_species_flag = 0;
cases = {'Case (i)',
    'Case (ii)',
    'Case (iii)',
    'Case (iv)'};
switch lower(species{species_num})
    case 'human'
        coherence_to_plot = {[0.02, 0.12]};
        RT_range = [0.1 2.5];
    case 'monkey'
        coherence_to_plot = {[0.032, 0.128]};
        RT_range = [0.1 1.65];
    case 'rat'
        coherence_to_plot = {[0.1, 0.5]};
        RT_range = [0.1 2.5];
end
mention_species = 0;
T_dur = plot_time;  % seconds
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

sorted_case_numbers = model_comparison(1).sorted_squared_error_model;

for i = 2 : num_of_cases
    model_comparison(i) = choose_best_model_parameters(model_comparison(1), sorted_case_numbers(i), 'squared error');
end

for i = 1 : num_of_cases
    [model_pychopysics(i), real_data_pychopysics(i)] = get_psychophysics(model_comparison(i), 'squared error', RT_range);
end

plot_all_accuracy(model_pychopysics, real_data_pychopysics);
plot_all_meanRTs(model_pychopysics, real_data_pychopysics);

plot_RT_distributions(model_pychopysics, real_data_pychopysics, coherence_to_plot, t)

figure("Name", [species{species_num} ' model gain comparison'], 'units','normalized','outerposition',[0 0 0.5 0.5])
for i = 1 : num_of_cases
    model_comparison(i) = plot_gain(model_comparison(i), t, model_comparison(i).estimated_model, mention_species);
    hold on
end
model_comparison = normalize_model_parameters(model_comparison, species{1});

for method_num = 1 : length(parameter_comparison_method)
    figure("Name", [species{species_num} ' ' model_type{1} ' ' parameter_comparison_method{method_num} ' model parameters'], 'units','normalized','outerposition',[0 0 0.5 0.7])
    for i = 1 : length(model_comparison)
        plot_parameters(model_comparison(i), parameter_comparison_method{method_num}, model_comparison(i).estimated_model, between_species_flag, mention_species);
        hold on
    end
end
DDM.model_variables = model_comparison;
DDM.model_pychopysics = model_pychopysics;
DDM.real_data_pychopysics = real_data_pychopysics;
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