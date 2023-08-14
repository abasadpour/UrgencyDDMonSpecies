function sortedS = order_struct(struct, field_name)
%order_struct order a structure array based on the field name
% suppose struct is the struct array. field_name is the field that contains date and time.

T = struct2table(struct); % convert the struct array to a table
sortedT = sortrows(T, field_name); % sort the table by 'DOB'
sortedS = table2struct(sortedT); % change it back to struct array if necessary
end