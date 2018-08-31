% Make columns of imported spreadsheet data (via xlsreadastext.m) into
% variables.
%
% Assumes spreadsheet has been read into 'data'
%
% Randy Bruno, October 2003

% preserve x which is used as a variable here
if exist('x', 'var')
    PreservedVariable = x;
else
    PreservedVariable = 0;
end

data = FindCellsAndReplace(data, 'TBA', 'NA');

for (i = 1:ncols(data))
    disp(data{1, i});
    % determine column type (numeric or string)
%    val = data{2, i};
%    if (isempty(val))
%        numeric=false;
%    else
%        if (isstr(val))
%            disp('is string');
%            if (strcmp(upper(val), 'NAN'))
%                disp('has NAN');
%                numeric = true;
%            else
%                numeric = false;
%                for (j = 2:nrows(data))
%                    disp(j);
%                    if (~isempty(data{j, i}) & ~isstr(data{j, i}))
%                        numeric = true;
%                        break;
%                    end
%                end
%            end
%        else
%            disp(i);
%            disp('numeric');
%            numeric = true;
%        end
%    end

    % check that column name has no "%" chars
    if ~isempty(find(data{1, i} == '%'))
        continue
    end

    numeric = true;
    for (j = 2:nrows(data))
        if (isstr(data{j,i}) & ~strcmp(upper(data{j,i}), 'NAN') & ~strcmp(upper(data{j,i}), 'NA'))
            numeric = false;
            break;
        end
    end

    % convert to numeric or string
    if (numeric)
        eval([data{1, i} ' = cell2num(data(2:end, i));']);
    else
        eval([data{1, i} ' = data(2:end, i);']);

        % check if array of strings is really an encoding of logicals
        islog = true;
        for j = 2:nrows(data)
            x = data(j, i);
            if ~strcmp(x, 'F') & ~strcmp(x, 'NA') & ~strcmp(x, 'T')
                islog = false;
            end
        end
        % if so, convert
        if islog
            %disp('is logical');
            eval([data{1, i} ' = cell2logical(data(2:end, i));']);
        end
    end
    
    % organize by rows if necessary
    eval([data{1, i} ' = as1col(' data{1, i} ');']);
end

if exist('x', 'var')
    x = PreservedVariable;
end
clear i j val numeric PreservedVariable;
