function plot_parameters(models, method, species_number, between_species, mention_species)
%plot_parameters plots the parameters of estimated_model in models
%   method: 'absolute' or 'normalized'
%   between_species: 0 or 1; shows if the comparison is within species

%%%%%%% load plot variable
plotvariables

%% plot parameters
species = models.species;
switch lower(method)
    case 'absolute'
        best_parameters = models.best_squared_model_parameters;
        ylabel_content = 'Absolute value';
        legend_location = 'northeast';
    case 'normalized'
        best_parameters = models.normalized_model_parameters;
        ylabel_content = 'Normalised value';
        legend_location = 'east';
        if strcmpi(species, 'rat') && ~between_species
            legend_location = 'southeast';
        end
        if between_species
            legend_location = 'northeast';
        end
end
% parameter_names = models.parameter_names;
parameter_names = {"k", "S_{y}", "S_{x}", "d", "\sigma_{0}", "t_{residual}", "\sigma_{residual}"};
switch mention_species
    case 1
        display_name = [species ' ' models.model_names{models.estimated_model}];
    case 0
        display_name = [models.model_names{models.estimated_model}];
end

t = 1 :length(parameter_names);
plot(t, best_parameters, markers{species_number}, "DisplayName", display_name,'MarkerSize',tick_fontsize, 'LineWidth', plot_linewidth - 1, 'MarkerEdgeColor', marker_colors{species_number})

box off
legend('Location',legend_location)
xlabel('Parameters','FontSize',label_fontsize,'FontWeight','bold')
xlim([0 (t(end) + 1)])
if strcmpi(species, 'rat') && ~mention_species && strcmpi(method, 'Normalised value')
    ylim([0.2 2])
end
xticks(t)
xticklabels(parameter_names)
ylabel(ylabel_content,'FontSize',label_fontsize,'FontWeight','bold')
set(gca,'FontSize',tick_fontsize,'LineWidth',axis_linewidth,'TickDir','out',...
                    'TickLength',ticklength);
% title(models.model_type, 'FontSize',title_font_size, 'FontWeight',title_fontweight)
end