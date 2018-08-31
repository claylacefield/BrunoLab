function i = PositionInArray(array, x)
% POSITIONINARRAY(ARRAY, X) Finds the index of X in ARRAY.
% Returns 0 if not found.
%
% Randy Bruno, June 2003

n = length(array);
i = 1;
while (array(i) ~= x & i < n)
    i = i + 1;
end
if (array(i) ~= x)
    i = 0;
end
