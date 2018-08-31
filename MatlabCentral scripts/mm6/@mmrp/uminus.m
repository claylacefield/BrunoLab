function r=uminus(a)
%UPLUS Unary Minus for Rational Polynomial Objects. (MM)

% D.C. Hanselman, University of Maine, Orono ME 04469
% 3/27/98
% Mastering MATLAB 6, Prentice Hall, ISBN 0-13-019468-9

r=mmrp(-a.n,a.d,a.v);
