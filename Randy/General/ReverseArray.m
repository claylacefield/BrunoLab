function out = ReverseArray(in)

% REVERSEARRAY(IN) Returns an array containing the reversed ordering of elements in vector IN
%
% Randy Bruno, June 2003

n = length(in);
out = zeros(size(in));
for i = 1:n
    out(i) = in(n-i+1);
end

    