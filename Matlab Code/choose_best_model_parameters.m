function [new_model] = choose_best_model_parameters(Model, forced_best_case, method)
%get_best_model_parameters choose a set of parameters for the best model in
%the Model structure based on the squared error
%   Forces the best case if forced_best_case is between 1 and number of cases.
models = Model.model;
if strcmpi(method, 'squared error')
    best_squared_model = Model.best_squared_model;
else
    best_squared_model = Model.best_model;
end
if forced_best_case > 0 && forced_best_case < length(Model.model_names) + 1
    best_squared_model = forced_best_case;
end

model_losses = Model.loss{best_squared_model};

[~, best_model_min_error] = min(model_losses(:, 1));
switch method
    case 'squared error'
        [~, best_model_min_error] = min(model_losses(:, 2));
    case 'LossRobustLikelihood'
        [~, best_model_min_error] = max(model_losses(:, 1));
end

[model_parameters, parameter_names] = get_model_parameters(models, best_squared_model);

% [~,idx] = sort(best_model_parameters(:,1)); % sort just the first column
% sortedmat = best_model_parameters(idx,:);   % sort the whole matrix using the sort indices

best_model_parametrs = model_parameters(best_model_min_error, :);
disp(['Best least squared error ' Model.model_type ' model for ' Model.species ' with ' Model.initial_condition ' IC is ' Model.model_names{Model.best_squared_model}])

new_model = Model;
new_model.best_squared_model_parameters = best_model_parametrs;
new_model.parameter_names = parameter_names;
new_model.all_best_model_parameters = model_parameters;
new_model.estimated_model = best_squared_model;

end