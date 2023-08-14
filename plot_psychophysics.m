function plot_psychophysics(model, real_data, coherence, t)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
species = model.species;
coherences = model.coherence;
type = model.model_type;
model_names = model.model_names;
case_number = model.estimated_model;

%%%%%%% load plot variable
plotvariables
 maximum_PDF_lim = max_PDF(2);
%% plot accuracy
figure('Name',[species ' ' type ' accuracy']);
model_accuracy = model.accuracy;
data_accuracy = real_data.accuracy;
plot(coherences, model_accuracy, 'b*', 'DisplayName', model_names{case_number}, 'MarkerSize',marker_size, 'linewidth', marker_linewidth)
hold on
plot(coherences, data_accuracy, 'rx', 'DisplayName','data', 'MarkerSize',marker_size, 'linewidth', marker_linewidth)
box off
ylim(accuracy_limits)
legend('Location','southeast')
xlabel('coh. level','FontSize',label_fontsize,'FontWeight','bold')
ylabel('accuracy','FontSize',label_fontsize,'FontWeight','bold')
set(gca,'FontSize',tick_fontsize,'LineWidth',axis_linewidth,'TickDir','out',...
                    'TickLength',ticklength);
% title([species ' ' type], 'FontSize',title_font_size, 'FontWeight',title_fontweight)
%% plot mean RTs
figure('Name',[species ' ' type ' mean RT'], 'units','normalized','outerposition',[0 0 0.6 0.6]);
model_mean_correct_RT = model.meanRT_correct;
model_mean_error_RT = model.meanRT_error;
data_mean_correct_RT = real_data.meanRT_correct;
data_std_correct_RT = real_data.stdRT_correct;
data_mean_error_RT = real_data.meanRT_error;
data_std_error_RT = real_data.stdRT_error;

meanRT_limit = meanRT_limits(2,:);

switch lower(species)
    case 'monkey'
        meanRT_limit = meanRT_limits(1,:);
    case 'rat'
        meanRT_limit = meanRT_limits(3,:);
end

plot(coherences, model_mean_correct_RT, 'bo', 'DisplayName',[model_names{case_number} ' corr.'], 'MarkerSize',marker_size, 'linewidth', marker_linewidth)
hold on
plot(coherences, data_mean_correct_RT, 'r+', 'DisplayName','data corr.', 'MarkerSize', marker_size, 'linewidth', marker_linewidth)
% errorbar(coherences, data_mean_correct_RT, data_std_correct_RT, 'r+', 'DisplayName','data corr.', 'MarkerSize',marker_size, 'linewidth', marker_linewidth)

plot(coherences, model_mean_error_RT, 'b*', 'DisplayName',[model_names{case_number} ' err.'], 'MarkerSize',marker_size, 'linewidth', marker_linewidth)
plot(coherences, data_mean_error_RT, 'mx', 'DisplayName','data err.', 'MarkerSize', marker_size, 'linewidth', marker_linewidth)
% errorbar(coherences, data_mean_error_RT, data_std_error_RT, 'kx', 'DisplayName','data err.', 'MarkerSize',marker_size, 'linewidth', marker_linewidth)
box off
ylim(meanRT_limit)
% hPlots = flip(findall(gcf,'Type','Line')); % flipped, because the lines our found in reverse order of appearance.
% leg = legend(hPlots([6 4]),'Orientation', 'Vertical','FontSize', legend_fontsize, 'Location','southeast');
legend
xlabel('coh. level','FontSize',label_fontsize,'FontWeight','bold')
ylabel('mean RT (s)','FontSize',label_fontsize,'FontWeight','bold')
set(gca,'FontSize',tick_fontsize,'LineWidth',axis_linewidth,'TickDir','out',...
                    'TickLength',ticklength);
% title([species ' ' type], 'FontSize',title_font_size, 'FontWeight',title_fontweight)

%% plot correct PDF
conditions = {'correct', 'error'};

for coh = coherence
    coherece_index = model.coherence == coh;
    num_of_correct_trials = length(real_data.correct_RT{coherece_index});
    num_of_error_trials = length(real_data.error_RT{coherece_index});
    fig = figure('Name',[species ' ' type ' ' num2str(100 * coh) '%' ' RT PDF'], 'units','normalized','outerposition',[0 0 0.8 0.3]);
    for condition = 1 : length(conditions)
        switch condition
            case 1
                RT_PDF = model.PDF_correct{coherece_index} * (num_of_correct_trials + num_of_error_trials) / num_of_correct_trials;
                RT_data = real_data.correct_RT{coherece_index};
            case 2
                RT_PDF = model.PDF_error{coherece_index} * (num_of_correct_trials + num_of_error_trials) / num_of_error_trials;
                RT_data = real_data.error_RT{coherece_index};
        end
        sub_fig = subplot(1, 2, condition);
        histogram(RT_data,"Normalization","pdf","DisplayName",'RT data');
        xlim([0 t(end)])
        switch lower(species)
            case 'monkey'
                maximum_PDF_lim = max_PDF(1);
            case 'rat'
                maximum_PDF_lim = max_PDF(3);
        end
        ylim([0 maximum_PDF_lim])
        box off
        hold on
        plot(t, RT_PDF(1: length(t)), 'k',"LineWidth",plot_linewidth, "DisplayName",model_names{case_number});
        switch condition
            case 1
                set(sub_fig,'FontSize',tick_fontsize,'LineWidth',axis_linewidth,'TickDir','out',...
            'TickLength',ticklength, 'Xticklabel',[]);
                
            case 2
                set(sub_fig,'FontSize',tick_fontsize,'LineWidth',axis_linewidth,'TickDir','out',...
                            'TickLength',ticklength);
        end

        if condition == 1 && coh == coherence(end)
            legend('Location','northeast')
        end
        
        ylabel(['PDF ' conditions{condition}],'FontSize',label_fontsize,'FontWeight','bold')
        han=axes(fig,'visible','off'); 
        han.Title.Visible='on';
        han.XLabel.Visible='on';
        xlabel(han,'RT (s)','FontSize',label_fontsize,'FontWeight','bold');
        title(han,[num2str(100 * coh) '% coh.'], 'FontSize',title_font_size, 'FontWeight',title_fontweight);
    end
end


end