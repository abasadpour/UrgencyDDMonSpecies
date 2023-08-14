close all; clear;

species = {'Monkey', 'Human', 'Rat'};
coherence_to_plot = {[0.032, 0.128], [0.02, 0.12], [0.1, 0.5]};
RT_range = {[0.1 1.65], [0.1 2.5], [0.1 2.5]};
T_dur = 2.5;  % seconds
dt = 0.01;  % seconds in model
t = (0:dt:T_dur);
mention_species = 1;
between_species_flag = 1;
initial_condition = {'fixed', 'uniform'};
model_type = {'full', 'restricted'};
method = {'absolute', 'normalized'};
forced_best_case = 0;
[current_path, fName, fExt] = fileparts(which("model_comparisons.m"));
% current_path = cd; 
base_folder = fullfile(current_path, '..');  % C:\Users\se16008969\OneDrive - Ulster University\Research projects\Hui''s paper\Real data fit or
                                                                                                                % C:\Users\assad\OneDrive - Ulster University\Research projects\Hui''s paper\Real data fit

loss_function = 'LossRobustLikelihood';    % 'LossSquaredError' or 'LossRobustLikelihood' or 'LossByMeans'

for i = 1 : length(species)
    model_comparison(i) = get_model_statistics(species{i}, base_folder, model_type{1},initial_condition{1}, loss_function);
    model_comparison(i) = choose_best_model_parameters(model_comparison(i), forced_best_case, 'squared error');
    [model_pychopysics(i), real_data_pychopysics(i)] = get_psychophysics(model_comparison(i), 'squared error', RT_range{i});
    plot_psychophysics(model_pychopysics(i), real_data_pychopysics(i), coherence_to_plot{i}, t)
    figure("Name", [species{i} ' model gain'])
    model_comparison(i) = plot_gain(model_comparison(i), t, i,mention_species);
end


figure("Name", [model_type{1} ' model gain'], 'units','normalized','outerposition',[0 0 0.5 0.5])
for i = 1 : length(species)
    plot_gain(model_comparison(i), t, i, mention_species);
    hold on
end
model_comparison = normalize_model_parameters(model_comparison, 'Monkey');


for method_num = 1 : length(method)
    figure("Name", [model_type{1} ' ' method{method_num} ' model parameters'], 'units','normalized','outerposition',[0 0 0.5 0.5])
    for i = 1 : length(species)
        plot_parameters(model_comparison(i), method{method_num}, i, between_species_flag, mention_species);
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