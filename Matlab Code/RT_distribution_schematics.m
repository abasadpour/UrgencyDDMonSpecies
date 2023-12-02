close all; clear;
axis_line_width = 6;
plot_line_width = 4;
% Parameters for the skewed distribution
mean = 0.6;
sigma = 1; % Standard deviation
skewness = 5; % Skewness parameter for transformation

% Range for plotting
x = linspace(0, 5, 1000);

% Normal distribution
pd = makedist('Normal', 'mu', mean, 'sigma', sigma);
y = pdf(pd, x);

% Applying a transformation to introduce skew
y_transformed = 2 * y .* normcdf(skewness * (x - mean));

% Ensuring density starts from zero at value 0
y_transformed(x < 0) = 0;

% Plotting
figure;
set(gcf, 'Units', 'Normalized', 'Position', [0.5, 0.5, 0.25, 1/6]); % Position format: [left, bottom, width, height]

plot(x, y_transformed, 'b-', 'LineWidth', plot_line_width);
box off;  % Turn off the box
grid off; % Turn off the grid
set(gca, 'XTick', [], 'YTick', [], 'LineWidth', axis_line_width); % Remove axis ticks but keep the axes

ax = gca;
ax.YColor = 'none'; % Make y-axis invisible

% Parameters for the normal distribution
mean = 1.25;
sigma = .3; % Standard deviation

% Range for plotting
x = linspace(0, 2.5, 1000);

% Normal distribution
pd = makedist('Normal', 'mu', mean, 'sigma', sigma);
y = pdf(pd, x);

% Inverting the plot to make it upside down
y_inverted = -y;


% Creating the figure and setting its size
figure;
set(gcf, 'Units', 'Normalized', 'Position', [0.5, 0.5, 0.25, 1/6]); % Position format: [left, bottom, width, height]

% Plotting
plot(x, y_inverted, 'r-', 'LineWidth', axis_line_width); % Red colored plot
box off;  % Turn off the box
grid off; % Turn off the grid
set(gca, 'XTick', [], 'YTick', [], 'LineWidth', axis_line_width); % Remove axis ticks but keep the axes

% Setting the axis line to zero and adjusting axis limits
ax = gca;
ax.YColor = 'none'; % Make y-axis invisible
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
ax.XLim = [0 2.5];
ax.YLim = [min(y_inverted) 0];
