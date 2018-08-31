% Make columns of imported spreadsheet data (via xlsreadastext.m) into
% variables.
%
% Assumes spreadsheet has been read into 'data'
%
% Randy Bruno, October 2003

for (i = 1:ncols(data))
    eval(['clear ' data{1, i}]);
end

clear i;
