% Time range
t = linspace(0, 5, 1000); % from 0 to 5 seconds

%%%%%%% load plot variable
plotvariables
label_font_increase = 1.5;

% Set of parameters
parameters = [1, 2, 0.5;  % d, s_x, s_y for first curve
              1.5, 1.5, 0.7;  % d, s_x, s_y for second curve
              0.5, 2.5, 0.3]; % d, s_x, s_y for third curve

% Line styles and markers for colorblind friendliness
styles = {'-', '--', '-.'};
% markers = {'o', '+', '*'};

% Plotting
figure;
hold on;
for i = 1:size(parameters, 1)
    d = parameters(i, 1);
    s_x = parameters(i, 2);
    s_y = parameters(i, 3);
    gain_values = time_variant_gain(t, d, s_x, s_y);
    plot(t, gain_values, 'k', 'LineWidth', plot_linewidth* 0.9, 'LineStyle', styles{i}, ...
         'DisplayName', sprintf('d=%.1f, s_x=%.1f, s_y=%.1f', d, s_x, s_y));
end

hold off;

box off
xlabel('Time (s)','FontSize',label_fontsize * label_font_increase,'FontWeight','bold');
ylabel('Gain \gamma(t)','FontSize',label_fontsize * label_font_increase,'FontWeight','bold');
set(gca,'FontSize',tick_fontsize * label_font_increase,'LineWidth',axis_linewidth,'TickDir','out',...
                    'TickLength',ticklength);
% title('Time-Variant Gain \gamma(t) for Different Parameters','FontSize',title_font_size * label_font_increase, 'FontWeight',title_fontweight);
legend('Location','northwest');
grid off;
