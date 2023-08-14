function model = plot_gain(model, t, case_number, mention_species)
%plot_gain plots tme-variant gain in the model
%   Detailed explanaton goes here

%%%%%%% load plot variable
plotvariables
label_font_increase = 1.5;
%% calculate gain
model_parameters = model.best_squared_model_parameters;
parameter_names = model.parameter_names;

Sy=model_parameters(strcmp(cellstr(parameter_names),'Sy'));
Sx=model_parameters(strcmp(cellstr(parameter_names),'Sx'));
d=model_parameters(strcmp(cellstr(parameter_names),'d'));
G=Sy.*exp(Sx*(t-d))./(1+exp(Sx*(t-d)))+(1+(1-Sy)*exp(-Sx*d))/(1+exp(-Sx*d));
model.best_squared_model_gain = G;
%% plot gain
% figure('Name',[model.species ' model gain'])
switch mention_species
    case 1
        plot(t, G, 'Color', marker_colors{case_number}, 'LineWidth', plot_linewidth, 'DisplayName', [model.species ' ' model.model_names{model.estimated_model}])
        label_font_increase = 1;
    case 0
        plot(t, G, 'Color', marker_colors{case_number}, 'LineWidth', plot_linewidth, 'DisplayName', [model.model_names{model.estimated_model}])
end
box off
legend('Location','northwest')
xlabel('Time (s)','FontSize',label_fontsize * label_font_increase,'FontWeight','bold')
ylabel('Gain','FontSize',label_fontsize * label_font_increase,'FontWeight','bold')
set(gca,'FontSize',tick_fontsize * label_font_increase,'LineWidth',axis_linewidth,'TickDir','out',...
                    'TickLength',ticklength);
% title(model.model_type, 'FontSize',title_font_size, 'FontWeight',title_fontweight)
end