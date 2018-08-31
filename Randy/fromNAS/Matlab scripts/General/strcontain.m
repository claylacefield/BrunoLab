function [bool] = strcontain(C, str)

% Returns a boolean array indicating whether or not each element in
% string (or cell array) C contains the substring str

if iscell(C)
    bool = ~cellfun(@isempty, strfind(C, str));
else
    bool = ~isempty(strfind(C, str));
end
