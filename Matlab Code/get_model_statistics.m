function stat = get_model_statistics(species, base_folder, type, initial_condition, loss_function)
%get_model_statistics calculates non-parametric statistical comparison
%among different cases
%   type: model type 'full' or restricted

%%%%%%% load plot variable
plotvariables

Model_names = {'Case (i)',
    'Case (ii)',
    'Case (iii)',
    'Case (iv)'};
initial_condition_name = [initial_condition 'IC'];
model_data_folder = fullfile(base_folder, species, initial_condition_name);
switch type
    case 'full'
        base_model_file_name = 'all_models_';
    case 'restricted'
        base_model_file_name = 'restricted_models_';
end

num_of_models = length(Model_names);

for model_num = 1 : num_of_models
    model_filename = fullfile(model_data_folder,[base_model_file_name num2str(model_num) '_' loss_function '.pkl']);
    Model{model_num} = import_model(model_filename);
    [loss_tmp, loss_name] = get_loss_results(Model{model_num});
    loss{model_num} = loss_tmp;
    loss_main(:, model_num) = loss{model_num}(:,1);
    loss_squared(:, model_num) = loss{model_num}(:,2);
end

p_log = kruskalwallis(loss_main, Model_names, 'off');
figure('Name', [species ' ' loss_function],'units','normalized','outerposition',[0 0 0.5 0.7])
bp = boxplot(loss_main, Model_names, 'Colors', boxplot_color, 'Symbol', outlier_shape_color);
box off
set(bp,'LineWidth', axis_linewidth);
ylabel([loss_function],'FontSize',label_fontsize,'FontWeight','bold')
xlabel('Model','FontSize',label_fontsize,'FontWeight','bold')
% title(species,'FontSize',title_font_size,'FontWeight','bold')
set(gca,'FontSize',tick_fontsize,'LineWidth',axis_linewidth,'TickDir','out',...
                    'TickLength',ticklength);

% ylim(squared_error_limits);

[p_log,tbl_log,stats_log] = kruskalwallis(loss_main,[], 'off');
c = multcompare(stats_log, "CriticalValueType","tukey-kramer", "Display","off");
tbl = array2table(c,"VariableNames", ...
    ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);

p_squared = kruskalwallis(loss_squared, Model_names, 'off');
figure('Name', [species ' Squared Error'], 'units','normalized','outerposition',[0 0 0.5 0.7])

if strcmpi(species, 'rat') || strcmpi(species, 'monkey')
    bp = plot(mean(loss_squared), non_box_marker_shape_color, 'DisplayName', ['Squared err.'], 'LineWidth', plot_linewidth, 'MarkerSize', marker_size + 2);
    xlim([0 (length(Model_names) + 1)])
    xticks(1:length(Model_names))
    xticklabels(Model_names)
    if strcmp(loss_function,'LossRobustLikelihood')
        % Calculate the AIC for different models
        num_of_parameters = length(Model{1,1}{1,1}{1});
        AIC_values = 2 * num_of_parameters + 2 * loss_main;
    
        % Adding right-hand side axis for AIC values
        yyaxis right
        ax = gca;
        ax.YColor = [0, 0, 0.7];  % Color of Y-axis (dark blue)
        plot(mean(AIC_values), non_box_marker_shape_color, 'Color', [0, 0, 0.7], 'LineWidth', plot_linewidth, 'MarkerSize', marker_size + 2);
        ylabel('AIC', 'FontSize', label_fontsize, 'FontWeight', 'bold');
    
        box off
    
        % Reset to left Y-axis for further plotting if needed
        yyaxis left
    end

else
    bp = boxplot(loss_squared, Model_names, 'Colors', boxplot_color, 'Symbol', outlier_shape_color);
    set(bp,'LineWidth', axis_linewidth);
    if strcmp(loss_function,'LossRobustLikelihood')
        % Calculate the AIC for different models
        num_of_parameters = length(Model{1,1}{1,1}{1});
        AIC_values = 2 * num_of_parameters + 2 * loss_main;
    
        % Adding right-hand side axis for AIC values
        yyaxis right
        ax = gca;
        ax.YColor = [0, 0, 0.7];  % Color of Y-axis (dark blue)
        bp = boxplot(AIC_values, Model_names, 'Colors', [0, 0, 0.7], 'Symbol', outlier_shape_color);
        set(bp, {'LineWidth', 'linestyle'}, {2, '-'});
        set(findobj(gcf, 'tag', 'Outliers'), 'MarkerSize', marker_size + 2, 'LineWidth', 2);
        ylabel('AIC', 'FontSize', label_fontsize, 'FontWeight', 'bold');
    
        box off
    
        % Reset to left Y-axis for further plotting if needed
        yyaxis left
    end
end
box off

ylabel(['Squared error'],'FontSize',label_fontsize,'FontWeight','bold')
xlabel('Model','FontSize',label_fontsize,'FontWeight','bold')
% title(species,'FontSize',title_font_size,'FontWeight','bold')
set(gca,'FontSize',tick_fontsize,'LineWidth',axis_linewidth,'TickDir','out',...
                    'TickLength',ticklength);


% ylim(squared_error_limits);

[p_squared,tbl_squared,stats_squared] = kruskalwallis(loss_squared, [], 'off');
c_squared = multcompare(stats_squared, "CriticalValueType","tukey-kramer", "Display","off");
tbl_squared = array2table(c_squared,"VariableNames", ...
    ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);

if strcmpi(loss_function, 'LossRobustLikelihood')
    [best_log, best_model] = max(mean(loss_main, 1));
else
    [best_squared, best_model] = min(mean(loss_main, 1));
end
mean_squared_error = mean(loss_squared, 1);
[~, sorted_squared_error_model] = sort(mean_squared_error);
[best_squared, best_squared_model] = min(mean(loss_squared, 1));

stat.data_folder = model_data_folder;
stat.model = Model;
stat.loss = loss;

stat.p_log = p_log;
stat.stats_log = stats_log;
stat. tbl_log = tbl;

stat.p_squared = p_squared;
stat.stats_squared = stats_squared;
stat.tbl_squared = tbl_squared;

stat.mean_squared_error = mean_squared_error;
stat.sorted_squared_error_model = sorted_squared_error_model;
stat.best_model = best_model;
stat.best_squared_model = best_squared_model;
stat.estimated_model = [];

stat.model_names = Model_names;
stat.loss_function = loss_function;
stat.model_type = type;
stat.initial_condition = initial_condition;

stat.all_best_model_parameters = [];
stat.best_squared_model_parameters = [];
stat.normalized_model_parameters = [];
stat.parameter_names = [];
stat.best_squared_model_gain = [];
stat.species = species;


end