function [model_pychopysics, real_data_pychopysics] = get_psychophysics(models, loss_function, RT_range)
%get_psychophysics returns and plots the mean RT and accuracy of the real
%data and the best-fitted model
%   loss_function:  [string] 'squared error' or 'log-likelihood'
species = models.species;
best_model = models.best_model;
loss_function_name = models.loss_function;

switch lower(loss_function)
    case 'squared error'
        best_model = models.estimated_model;
end

model_data_folder = models.data_folder;
base_model_file_name = 'solved_model_';

if strcmpi(models.model_type, 'restricted')
    base_model_file_name = [models.model_type '_' base_model_file_name];
end

%% import model pychophysics
model_filename = fullfile(model_data_folder,[base_model_file_name num2str(best_model) '_' loss_function_name '.pkl']);
model_pychopysics = get_model_pychopysics(model_filename, models);

%% import real data pychopysics
data_dir = dir([model_data_folder filesep '*.csv']);
if length(data_dir) == 1
    data_filename = fullfile(data_dir.folder, data_dir.name);
else
    error('zero or multiple csv file in the folder')
end
real_data_pychopysics = get_data_pychopysics(data_filename, model_pychopysics, RT_range);

end


