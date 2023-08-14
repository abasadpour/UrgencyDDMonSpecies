function [outputArg1,outputArg2] = plot_all_meanRTs(model, real_data)
%plot_all_accuracy plots mean reaction times of model and real data
%   each row of the structures belongs to a different model or species
model = order_struct(model, 'estimated_model');     % order the structure based on the estimated case
real_data = order_struct(real_data, 'estimated_model');


%%%%%%% load plot variable
plotvariables
inplot_relative_location = [0.018 0.09 0.1 0.15];
legend_location = 'northeast';

%% assign variables

conditions = {'correct', 'error'};
num_of_models = length(model);
num_of_trial_types = length(conditions);
species_array = string(extractfield(model, 'species'));
type = model(1).model_type;
meanRT_limit = meanRT_limits(2,:);
%% plot RT distributions and PDF
if all(species_array == species_array(1))
    species = model(1).species;
    fig = figure('Name',[species ' ' type ' all mean RTs'], 'units','normalized','outerposition',accuracy_RT_figure_size);
    switch lower(species)
        case 'monkey'
            inplot_relative_location = [0.072 0.55 0.09 0.15];       % change in-plot location based on species
            meanRT_limit = meanRT_limits(1,:);
        case 'rat'
            inplot_relative_location = [0.123 0.585 0.055 0.15];
            legend_location = 'southeast';
            meanRT_limit = meanRT_limits(3,:);
    end
else
    fig = figure('Name',[type ' all mean RTs'], 'units','normalized','outerposition',accuracy_RT_figure_size);
end

subplot_num = 0;

subplot_names = cellstr(('a':char('a'+(num_of_models-1)))');
row_numbers = 1 * 3; %ceil(num_of_models / 2);
column_numbers = num_of_models; %ceil(num_of_models / 2);
tiled_figure = tiledlayout(row_numbers,column_numbers, 'TileSpacing','compact');
han=tiled_figure; 
han.Title.Visible= 'off';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
xlh = xlabel(han, 'Motion strength (% coh)','FontSize',label_fontsize,'FontWeight','bold');
% ylh = ylabel(han, ['mean RT (s)'],'FontSize',label_fontsize,'FontWeight','bold');

for model_case = 1 : num_of_models
    case_number = model(model_case).estimated_model;
    species = model(model_case).species;
    coherences = model(model_case).coherence * 100;
    
    model_names = model(model_case).model_names;
    subplot_num = subplot_num + 1;
    sub_fig(subplot_num) = nexttile(tiled_figure, subplot_num, [2 1]); %subplot(row_numbers, column_numbers, subplot_num);

    model_mean_correct_RT = model(model_case).meanRT_correct;
    model_mean_error_RT = model(model_case).meanRT_error;
    data_mean_correct_RT = real_data(model_case).meanRT_correct;
    data_std_correct_RT = real_data(model_case).stdRT_correct;
    data_mean_error_RT = real_data(model_case).meanRT_error;
    data_std_error_RT = real_data(model_case).stdRT_error;
    error_correctRT(model_case, :) = abs(model_mean_correct_RT - data_mean_correct_RT);
    error_errorRT(model_case, :) = abs(model_mean_error_RT - data_mean_error_RT);
    
    sub_plot(1) = plot(coherences, model_mean_correct_RT, 'v', 'DisplayName', ['Model, correct'], 'MarkerSize',marker_size, 'linewidth', marker_linewidth, 'MarkerEdgeColor', model_marker_color);
    hold on
    sub_plot(2) = plot(coherences, model_mean_error_RT,  'diamond', 'DisplayName', ['Model, error'], 'MarkerSize',marker_size, 'linewidth', marker_linewidth, 'MarkerEdgeColor', model_marker_color);
    
    sub_plot(3) = plot(coherences, data_mean_correct_RT, 'p', 'DisplayName', [species ', correct'], 'MarkerSize',marker_size, 'linewidth', marker_linewidth, 'MarkerEdgeColor', data_marker_color);
    hold on
    sub_plot(4) = plot(coherences, data_mean_error_RT,  's', 'DisplayName', [species ', error'], 'MarkerSize',marker_size, 'linewidth', marker_linewidth, 'MarkerEdgeColor', data_marker_color);

    box off

    if subplot_num == 1
        ylabel(['Mean RT (s)'],'FontSize',label_fontsize,'FontWeight','bold');
    end

    if subplot_num == column_numbers
        lg  = legend(sub_plot(:),'FontSize',legend_fontsize, 'Location',legend_location);
    end

    if subplot_num <= (row_numbers - 1) * column_numbers
        set(sub_fig(subplot_num),'FontSize',tick_fontsize,'LineWidth',axis_linewidth,'TickDir','out',...
            'TickLength',ticklength, 'Xticklabel',[]);
    else
        set(sub_fig(subplot_num),'FontSize',tick_fontsize,'LineWidth',axis_linewidth,'TickDir','out',...
            'TickLength',ticklength);
    end
    
    ylim(meanRT_limit)
    title([model_names{case_number}], 'FontSize',title_font_size, 'FontWeight',title_fontweight);


    % create textbox 
    % pos = {get(sub_fig(subplot_num), 'position')};
    % dim = cellfun(@(x) x.*[1 1 1 1], pos, 'uni',0);
    % annotation(fig, 'textbox', dim{1} + [-0.047 0.08 0 0], 'String', ['(' subplot_names{model_case} ')'], 'vert', 'top',...
    %     'FontWeight','bold',...
    %     'FontSize', label_fontsize - 2,...
    %     'FitBoxToText','off',...
    %      'EdgeColor','none');
end
% lg  = legend(sub_plot(:)); 
% lg.Layout.Tile = 'east';
number_of_subplots = subplot_num;
subplot_numbers = ((row_numbers - 1) * column_numbers + 1) : ((row_numbers - 1) * column_numbers + number_of_subplots);
model_case = 0;
% plot the in-plot error
for subplot_num = subplot_numbers
    model_case = model_case + 1;
    % pos = {get(sub_fig(subplot_num), 'position')};
    % dim = cellfun(@(x) x.*[1 1 1 1], pos, 'uni',0);

    % handaxes2 = axes('Position', [(dim{1}(1:2) + inplot_relative_location(1:2)) inplot_relative_location(3:4)]);
    sub_fig(subplot_num) = nexttile(tiled_figure, subplot_num, [1 1]); %subplot(row_numbers, column_numbers, subplot_num);
    error_plot(1) = plot(coherences, error_correctRT(model_case, :), 'k.--', 'DisplayName', 'correct', 'MarkerSize', marker_size * 2, 'linewidth', marker_linewidth * 1.5, 'MarkerFaceColor','black', 'MarkerEdgeColor', 'black');
    hold on
    error_plot(2) = plot(coherences, error_errorRT(model_case, :), 'k.:', 'DisplayName', 'error', 'MarkerSize', marker_size * 2, 'linewidth', marker_linewidth * 1.5, 'MarkerFaceColor','black', 'MarkerEdgeColor', 'black');
    box off


    % legend('Location','northwest','FontSize', legend_fontsize / 2,'FontWeight','bold')
    ylim(RT_in_plot_ylim)
    yticks([0 RT_in_plot_ylim(end)/2 RT_in_plot_ylim(end)])
    % xticklabels(Model_names)

    if subplot_num == subplot_numbers(1)
        ylabel(['Abs. RT diff. (s)'],'FontSize',label_fontsize,'FontWeight','bold');
    end

    if subplot_num == subplot_numbers(end)
        lg  = legend(error_plot(:),'FontSize',legend_fontsize, 'Location','northwest');
    end

    if subplot_num <= (row_numbers - 1) * column_numbers
        set(sub_fig(subplot_num),'FontSize',tick_fontsize,'LineWidth',axis_linewidth,'TickDir','out',...
            'TickLength',ticklength, 'Xticklabel',[]);
    else
        set(sub_fig(subplot_num),'FontSize',tick_fontsize,'LineWidth',axis_linewidth,'TickDir','out',...
            'TickLength',ticklength);
    end
end
% lg  = legend(sub_plot(:)); 
% lg.Layout.Tile = 'east';

end