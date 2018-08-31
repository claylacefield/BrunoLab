function output = left(s, n)
% LEFT Leftmost characters.
% LEFT(S, N) returns the portion of string S left after removing the
% N-rightmost characters

output = s(1:(size(s,2)-n));
