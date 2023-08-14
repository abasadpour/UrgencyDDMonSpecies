function RT = get_data_RT(raw_data_table, in_coherence, column_names_in_table, condition, RT_range)
%get_data_RT returns reaction times in each coherence per condition (i.e.,
%"correct", "error")
%   Detailed explanation goes here
%   column_names_in_table: {name of coherence, reaction
%   time, response, and subject ID}. "correct" == 1, "error" == 0
table_column_name = raw_data_table.Properties.VariableNames;

coherence_column = contains(cellstr(table_column_name),column_names_in_table{1});
RT_column = contains(cellstr(table_column_name),column_names_in_table{2});
response_column = contains(cellstr(table_column_name),column_names_in_table{3});


coherence_index = table2array(raw_data_table(:,coherence_column)) == in_coherence;
response_in_coherence = table2array(raw_data_table(coherence_index,response_column));
RT_in_coherence = table2array(raw_data_table(coherence_index,RT_column));

switch lower(condition)
    case "correct"
        response = 1;
    case "error"
        response = 0;
end

response_in_coherence_index = response_in_coherence == response;

RT = RT_in_coherence(response_in_coherence_index);
RT = RT(RT < RT_range(2));
RT = RT(RT > RT_range(1));
end