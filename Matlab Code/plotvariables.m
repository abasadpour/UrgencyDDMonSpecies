%%%%%%% Plot variable for DDM models

title_font_size = 18;
title_fontweight = 'bold';
legend_fontsize = 16 / 1.15;
tick_fontsize = 18;
label_fontsize = 24;

plot_linewidth = 4;
ticklength = [0.02 0.025];
axis_linewidth = 2;

% box bplot
boxplot_color = 'k';
outlier_shape_color = 'k+';
non_box_marker_shape_color = 'k<';


max_mean_RT = 1.5;

squared_error_limits = [0.02 0.05];

accuracy_limits = [0.4 1];
meanRT_limits = [0.3    1;      % Monkey
                 0.3    1.2;    % Human
                 0.3    1.2];   % Rat
accuracy_RT_figure_size = [0 0 1 0.6];
RT_in_plot_ylim = [-0.05 0.5];


% marker shape and colour
marker_linewidth = 2;
marker_size = 12;
markers = {'o', 'x', '+', '^'};
marker_colors = {'r', 'b', 'k', "#B42DFF"};
line_marker_shape_without_color = {'o-', 'x-', '+-', '^-'};
data_marker_color = "#14A295";
model_marker_color = "#DEA53F";

% histogram variables
max_PDF = [3 
           5 
           3];
num_of_bins_histogram = 50;
histogram_color = [.7 .7 .7];
