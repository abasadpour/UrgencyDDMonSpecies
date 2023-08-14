function [model_parameters, parameter_names] = get_model_parameters(models, model_number)
%get_model_parameters returns two variables with model parameters and their names for all runs
%and their names based on the model number
%   Detailed explanation goes here

model = models{model_number};

parameter_names = model{1}{1};
for i = 1 : length(parameter_names)
    parameter_names{i} = string(parameter_names{i});
end

model_parameters = nan(length(model), length(parameter_names));
for i = 1 : length(model)
    model_parameters(i, :) = cell2mat(model{i}{2});
end

end