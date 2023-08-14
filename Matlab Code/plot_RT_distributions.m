function plot_RT_distributions(model, real_data, coherence_to_plot, t)
%plot_Rt_distributions plot all PDF and Rt distributions in model and real
%data structure
%   each row of the structures belongs to a different model or species
model = order_struct(model, 'estimated_model');     % order the structure based on the estimated case
real_data = order_struct(real_data, 'estimated_model');

%%%%%%% load plot variable
plotvariables
label_fontsize = 24;
%% assign variables

conditions = {'correct', 'error'};
num_of_models = length(model);
num_of_coherences_to_plot = length(coherence_to_plot{1});
num_of_trial_types = length(conditions);
figure_size = [0 0 1 .8];
maximum_PDF_lim = max_PDF(2);
%% plot RT distributions and PDF
if length(coherence_to_plot) == num_of_models
    species = model(1).species;
    fig = figure('Name',[species ' All RT PDF'], 'units','normalized','outerposition', figure_size);
else
    fig = figure('Name',['All RT PDF'], 'units','normalized','outerposition', figure_size);
end


subplot_names = cellstr(('a':char('a'+(num_of_models-1)))');
row_numbers = num_of_models;
column_numbers = num_of_coherences_to_plot * num_of_trial_types;
axgrid = [row_numbers, column_numbers];  % [#rows, #cols]
tclMain = tiledlayout(axgrid(1), 1 , 'TileSpacing','tight'); % main tiled layout
han=tclMain; 
han.Title.Visible= 'off';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
xlh = xlabel(han,'RT (s)','FontSize',label_fontsize,'FontWeight','bold');
ylh = ylabel(han, ['PDF'],'FontSize',label_fontsize,'FontWeight','bold');



% creating tiles with titles in each row

tcl = gobjects(1,axgrid(1));
ax = gobjects(axgrid); 

for model_case = 1 : num_of_models
    subplot_num = 0;
    case_number = model(model_case).estimated_model;
    species = model(model_case).species;
    model_names = model(model_case).model_names;
    titles = model_names;
    if length(coherence_to_plot) == num_of_models
        coherence = coherence_to_plot{model_case};
    else
        coherence = coherence_to_plot{1};
    end
    tcl(model_case) = tiledlayout(tclMain,1,axgrid(2));
    tcl(model_case).Layout.Tile = model_case;
    for coh = coherence
        coherece_index = model(model_case).coherence == coh;
        num_of_correct_trials = length(real_data(model_case).correct_RT{coherece_index});
        num_of_error_trials = length(real_data(model_case).error_RT{coherece_index});
        for condition = 1 : length(conditions)
            subplot_num = subplot_num + 1;
            
            switch condition
                case 1
                    RT_PDF = model(model_case).PDF_correct{coherece_index} * (num_of_correct_trials + num_of_error_trials) / num_of_correct_trials;
                    RT_data = real_data(model_case).correct_RT{coherece_index};
                case 2
                    RT_PDF = model(model_case).PDF_error{coherece_index} * (num_of_correct_trials + num_of_error_trials) / num_of_error_trials;
                    RT_data = real_data(model_case).error_RT{coherece_index};
            end
            ax(model_case,subplot_num) = nexttile(tcl(model_case));
            sub_plot(1) = histogram(RT_data,"Normalization","pdf","DisplayName",species ,'NumBins',num_of_bins_histogram, 'BinLimits',[t(1), t(end)], 'FaceColor', histogram_color);
            xlim([0 t(end)])
            switch lower(species)
                case 'monkey'
                    maximum_PDF_lim = max_PDF(1);
                case 'rat'
                    maximum_PDF_lim = max_PDF(3);
            end
            ylim([0 maximum_PDF_lim])
            yticks([0 maximum_PDF_lim/2 maximum_PDF_lim])
            box off
            hold on
            sub_plot(2) = plot(t, RT_PDF(1: length(t)), 'k',"LineWidth",plot_linewidth, "DisplayName", 'Model');
            if model_case ~= num_of_models
                set(ax(model_case,subplot_num),'FontSize',tick_fontsize,'LineWidth',axis_linewidth,'TickDir','out',...
                    'TickLength',ticklength, 'Xticklabel',[]);
            else
                set(ax(model_case,subplot_num),'FontSize',tick_fontsize,'LineWidth',axis_linewidth,'TickDir','out',...
                    'TickLength',ticklength);
            end
    
            % if condition == 2 && coh == coherence(end)
            %     legend('Location','northeast')
            % end
            if model_case == 1 && subplot_num == column_numbers
                lg  = legend(ax(1, column_numbers), sub_plot(:)); 
            end         

            if model_case == 1
                % create textbox 
                % pos = {get(ax(model_case,subplot_num), 'position')};
                % dim = cellfun(@(x) x.*[1 1 1 1], pos, 'uni',0);
                % column_title_location = [0.02 0.07 0 0];
                hLF1 = ax(model_case,subplot_num);
                text_vertical_shift = max(hLF1.YLim) * 1.1;
                text((max(hLF1.XLim)-min(hLF1.XLim))/2+min(hLF1.XLim), text_vertical_shift ,[num2str(100 * coh) '% coh. ' conditions{condition}],'EdgeColor','none',...
                    'FontSize', title_font_size + 2,'HorizontalAlignment', 'center','VerticalAlignment','Bottom', 'FontWeight','bold')
                % annotation(fig, 'textbox', dim{1} + column_title_location, 'String', [num2str(100 * coh) '% coh. ' conditions{condition}], 'vert', 'top',...
                %     'FontWeight','bold',...
                %     'FontSize', label_fontsize - 2,...
                %     'FitBoxToText','off',...
                %      'EdgeColor','none');
            end


            % if mod(subplot_num, num_of_coherences_to_plot * num_of_trial_types) == 1
            %     % create textbox 
            %     pos = {get(sub_fig(subplot_num), 'position')};
            %     dim = cellfun(@(x) x.*[1 1 1 1], pos, 'uni',0);
            %     annotation(fig, 'textbox', dim{1} + [-0.03 0.04 0 0], 'String', ['(' subplot_names{model_case} ')'], 'vert', 'top',...
            %         'FontWeight','bold',...
            %         'FontSize', label_fontsize - 2,...
            %         'FitBoxToText','off',...
            %          'EdgeColor','none');
            % end
        end
    end
    title(tcl(model_case),titles{case_number},'FontSize',title_font_size, 'FontWeight',title_fontweight)
end