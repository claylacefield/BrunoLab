function B = xlsreadastext(filepath, sheetname)

% In Matlab v6.5, we did not have the third output of xlsread (raw),
% which is why the previous version of this function had to combined the
% numeric and text matrices of xlsread. With v7.1, this process is much
% simpler.
%
% Randy Bruno, February 2006

if (nargin == 0)
    [filename pathname OK] = uigetfile('*.xls', 'Select .xls file');
    if (~OK) return; end
    filepath = [pathname, filename];
end

if nargin == 2
    [A, C, B] = xlsread(filepath, sheetname);
else
    [A, C, B] = xlsread(filepath);
end
