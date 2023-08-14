function [model_pycophysics] = get_model_pychopysics(model_filename, models)
%get_model_pychopysics returns model pychopysics that stores in
%model_filename including model accuracy, model mean correct RTs
%   The python file includes several variables. The variable type is stored
%   in the last column of pycophysics variable.
species = models.species;
pychopysics = import_model(model_filename);
variable_name_column = length(pychopysics);

coherence_index = find(contains(cellstr(pychopysics{variable_name_column}),'coherence'));
accuracy_index = contains(cellstr(pychopysics{variable_name_column}),'accuracy');
meanRT_correct_index = contains(cellstr(pychopysics{variable_name_column}),'model mean correct RT');
meanRT_error_index = contains(cellstr(pychopysics{variable_name_column}),'model mean error RT');
correct_PDF_index = contains(cellstr(pychopysics{variable_name_column}),'PDF correct');
error_PDF_index = contains(cellstr(pychopysics{variable_name_column}),'PDF error');

coherence = nan(1, length(pychopysics{coherence_index}));

for i = 1 : length(pychopysics{coherence_index})
    coherence(i) = pychopysics{coherence_index}{i}{1}{2};
end

[coherence, sort_index] = sort(coherence);


model_accuracy = cell2mat(pychopysics{accuracy_index});
meanRT_correct = cell2mat(pychopysics{meanRT_correct_index});
meanRT_error = cell2mat(pychopysics{meanRT_error_index});
PDF_correct = pychopysics{correct_PDF_index};
PDF_error = pychopysics{error_PDF_index};

model_pycophysics.coherence = coherence;
model_pycophysics.accuracy = model_accuracy(sort_index);
model_pycophysics.meanRT_correct = meanRT_correct(sort_index);
model_pycophysics.meanRT_error = meanRT_error(sort_index);
model_pycophysics.PDF_correct = PDF_correct(sort_index);
model_pycophysics.PDF_error = PDF_error(sort_index);
model_pycophysics.model_type = models.model_type;
model_pycophysics.model_names = models.model_names;
model_pycophysics.loss_function = models.loss_function;
model_pycophysics.estimated_model = models.estimated_model;
model_pycophysics.species = species;
end