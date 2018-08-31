function bool = inString(str1, str2)

% returns TRUE if str1 contains str2

bool = ~isempty(strfind(str1, str2));
