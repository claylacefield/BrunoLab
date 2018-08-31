function bool = iselement(a, X)

% Returns true if a is an element of X

bool = ~isempty(X(X==a));
