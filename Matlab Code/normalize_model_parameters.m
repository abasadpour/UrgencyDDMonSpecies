function models = normalize_model_parameters(models, desired_species)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
new_models = models;
desired_species = lower(desired_species);
species_numbers = length(models);

for i = 1 : species_numbers
    species{i} = lower(models(i).species);
end
desired_index = strcmpi(cellstr(species), desired_species);
desired_parametrs = models(desired_index).best_squared_model_parameters;

for i = 1 : species_numbers
    models(i).normalized_model_parameters = models(i).best_squared_model_parameters ./ desired_parametrs;
end
end