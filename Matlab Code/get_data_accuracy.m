function accuracy = get_data_accuracy(raw_data_table, in_coherence, column_names_in_table)
%get_data_accuracy calculates data accuracy in the coherence level using
%the response column in raw_data_table
%   returns 0 if there is no correct trials in the coherence level.
%   column_names_in_table: {name of coherence, reaction
%   time, response, and subject ID}. "correct" == 1, "error" == 0
accuracy = nan(1);
table_column_name = raw_data_table.Properties.VariableNames;

coherence_column = contains(cellstr(table_column_name),column_names_in_table{1});
response_column = contains(cellstr(table_column_name),column_names_in_table{3});


coherence_index = table2array(raw_data_table(:,coherence_column)) == in_coherence;
response_in_coherence = table2array(raw_data_table(coherence_index,response_column));

correct_response_in_coherence_index = response_in_coherence == 1;

correct_response_num = sum(correct_response_in_coherence_index);

accuracy = correct_response_num / length(response_in_coherence);

 
end