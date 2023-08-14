function [pylist] = list2cell(list)
%list2cell convert any python list in the pylist cell to cell
%   Detailed explanation goes here
pylist = cell(list);
list_element = numel(pylist);

for el_num = 1 : list_element
    switch class(pylist{el_num})
        case 'py.list'
            pylist{el_num} = list2cell(pylist{el_num});
        case 'py.numpy.ndarray'
            pylist{el_num} = double(pylist{el_num});
        case 'py.tuple'
            pylist{el_num} = list2cell(pylist{el_num});
        case 'py.str'
            pylist{el_num} = string(pylist{el_num});
        case 'py.int'
            pylist{el_num} = double(pylist{el_num});
    end
end

end