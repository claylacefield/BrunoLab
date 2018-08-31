function data = FindCellsAndReplace(data, oldstr, newstr)

for i = 1:nrows(data)
    for j = 1:ncols(data)
        if strcmp(data{i, j}, oldstr)
            data{i, j} = newstr;
        end
    end
end
