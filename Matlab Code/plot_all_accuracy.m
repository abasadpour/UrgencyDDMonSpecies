function [outputArg1,outputArg2] = plot_all_accuracy(model, real_data)
%plot_all_accuracy plots accuracy of model and real data
%   each row of the structures belongs to a different model or species
model = order_struct(model, 'estimated_model');     % order the structure based on the estimated case
real_data = order_struct(real_data, 'estimated_model');


%%%%%%% load plot variable
plotvariables
legend_location = 'northeast';
%% assign variables

conditions = {'correct', 'error'};
num_of_models = length(model);
num_of_trial_types = length(conditions);
species_array = string(extractfield(model, 'species'));
type = model(1).model_type;
%% plot RT distributions and PDF
if all(species_array == species_array(1))
    species = model(1).species;
    fig = figure('Name',[species ' ' type ' all accuracy'], 'units','normalized','outerposition',accuracy_RT_figure_size);
else
    fig = figure('Name',[type 'All accuracy'], 'units','normalized','outerposition',accuracy_RT_figure_size);
end

subplot_num = 0;

subplot_names = cellstr(('a':char('a'+(num_of_models-1)))');
row_numbers = 1; %ceil(num_of_models / 2);
column_numbers = num_of_models; %ceil(num_of_models / 2);
tiled_figure = tiledlayout(row_numbers,column_numbers, 'TileSpacing','loose');
han=tiled_figure; 
han.Title.Visible= 'off';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
xlh = xlabel(han, 'Motion strength (% coh)','FontSize',label_fontsize,'FontWeight','bold');
ylh = ylabel(han, ['Accuracy'],'FontSize',label_fontsize,'FontWeight','bold');


for model_case = 1 : num_of_models
    case_number = model(model_case).estimated_model;
    species = model(model_case).species;
    coherences = model(model_case).coherence * 100;
    
    model_names = model(model_case).model_names;
        subplot_num = subplot_num + 1;
        sub_fig(subplot_num) = nexttile(tiled_figure); %subplot(row_numbers, column_numbers, subplot_num);

        model_accuracy = model(model_case).accuracy;
        data_accuracy = real_data.accuracy;
        MSE_accuracy(model_case, :) = abs(model_accuracy - data_accuracy);
        sub_plot(model_case) = plot(coherences, model_accuracy, markers{model_case}, 'DisplayName', model_names{case_number}, 'MarkerSize',marker_size, 'linewidth', marker_linewidth, 'MarkerEdgeColor', marker_colors{model_case});
        hold on
        if model_case == num_of_models
            sub_plot(model_case + 1) = plot(coherences, data_accuracy, 'p', 'DisplayName',[species ' data'], 'MarkerSize',marker_size, 'linewidth', marker_linewidth, 'MarkerEdgeColor', data_marker_color);
        else
            plot(coherences, data_accuracy, 'p', 'DisplayName',[species ' data'], 'MarkerSize',marker_size, 'linewidth', marker_linewidth, 'MarkerEdgeColor', data_marker_color)
        end
        box off

        
        if subplot_num <= (row_numbers - 1) * column_numbers
            set(sub_fig(subplot_num),'FontSize',tick_fontsize,'LineWidth',axis_linewidth,'TickDir','out',...
                'TickLength',ticklength, 'Xticklabel',[]);
        else
            set(sub_fig(subplot_num),'FontSize',tick_fontsize,'LineWidth',axis_linewidth,'TickDir','out',...
                'TickLength',ticklength);
        end

        ylim(accuracy_limits)

        pos = {get(sub_fig(subplot_num), 'position')};
        dim = cellfun(@(x) x.*[1 1 1 1], pos, 'uni',0);
        axes_size = [(dim{1}(1:2) + [0.075 0.12]) 0.1 0.4];
        if strcmpi(species, 'rat')
            axes_size = [(dim{1}(1:2) + [0.077 0.09]) 0.1 0.23];
            legend_location = 'northwest';
        end
        if model_case == num_of_models
            handaxes2 = axes('Position', axes_size);
            for i = 1 : size(MSE_accuracy, 1)
                plot(coherences, MSE_accuracy(i, :), markers{i}, 'DisplayName', model_names{i}, 'MarkerSize',marker_size - 4, 'linewidth', marker_linewidth, 'MarkerEdgeColor', marker_colors{i});
                hold on
            end
            set(handaxes2, 'Box', 'off')
            set(handaxes2,'FontSize',tick_fontsize / 2, 'FontWeight','bold', 'LineWidth',axis_linewidth / 1.5,'TickDir','out',...
                'TickLength',ticklength);
            xlabel('Motion strength (% coh)','FontWeight','bold','FontSize', label_fontsize - 12)
            ylabel('Abs. diff.', 'FontWeight','bold','FontSize', label_fontsize - 12)
        end
        if subplot_num == column_numbers
            lg  = legend(sub_fig(subplot_num), sub_plot(:),'FontSize',legend_fontsize, 'Location',legend_location);
        end

end



% lg.Layout.Tile = 'east';

% for subplot_num = 1 : tiles
%         % create textbox 
%     pos = {get(sub_fig(subplot_num), 'position')};
%     dim = cellfun(@(x) x.*[1 1 1 1], pos, 'uni',0);
%     annotation(fig, 'textbox', dim{1} + [-0.04 0.07 0 0], 'String', ['(' subplot_names{subplot_num} ')'], 'vert', 'top',...
%         'FontWeight','bold',...
%         'FontSize', label_fontsize - 2,...
%         'FitBoxToText','off',...
%          'EdgeColor','none');
% end



end