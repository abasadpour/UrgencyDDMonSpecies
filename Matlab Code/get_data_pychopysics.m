function [data_pychopysics] = get_data_pychopysics(data_filename, model_pychopysics, RT_range)
%get_data_pychopysics returns real data pychopysics based on the coherence
%in the model
%   Detailed explanation goes here
raw_data_table = readtable(data_filename);
column_names_in_table = {'coh', 'rt', 'response', 'subjectID'}; % include the name of coherence, reaction time, response, and subject ID in the table header respectively
if contains(lower(model_pychopysics.species), 'monkey')
    column_names_in_table = {'coh', 'rt', 'correct', 'monkey'}; % include the name of coherence, reaction time, response, and subject ID in the table header respectively
end
coherences = model_pychopysics.coherence;

table_column_name = raw_data_table.Properties.VariableNames;

coherence_column = contains(cellstr(table_column_name),column_names_in_table{1});

data_coherence = table2array(unique(raw_data_table(:,coherence_column)))';

coherences = coherences(ismember(coherences, data_coherence));     % only analyse for common coherences between model and real data

accuracy = nan(1, length(coherences));
correct_RT = cell(1, length(coherences));
error_RT = cell(1, length(coherences));
index = 1;

for coherence = coherences
    
    accuracy(index) = get_data_accuracy(raw_data_table, coherence, column_names_in_table);
    correct_RT{index} = get_data_RT(raw_data_table, coherence, column_names_in_table, "correct", RT_range);
    meanRT_correct(index) = mean(correct_RT{index});
    stdRT_correct(index) = std(correct_RT{index});
    error_RT{index} = get_data_RT(raw_data_table, coherence, column_names_in_table, "error", RT_range);
    meanRT_error(index) = mean(error_RT{index});
    stdRT_error(index) = std(error_RT{index});
    index = index + 1;
end

data_pychopysics.coherences = coherences;
data_pychopysics.accuracy = accuracy;
data_pychopysics.meanRT_correct = meanRT_correct;
data_pychopysics.meanRT_error = meanRT_error;
data_pychopysics.stdRT_correct = stdRT_correct;
data_pychopysics.stdRT_error = stdRT_error;
data_pychopysics.correct_RT = correct_RT;
data_pychopysics.error_RT = error_RT;
data_pychopysics.estimated_model = model_pychopysics.estimated_model;
data_pychopysics.trial_num = size(raw_data_table,1);
data_pychopysics.species = model_pychopysics.species;

end