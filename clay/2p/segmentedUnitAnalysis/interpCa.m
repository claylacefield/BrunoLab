function [ca2, x2] = interpCa(ca, interpFact)

% USAGE: [ca2] = interpCa(ca);
% Clay 2018
% interpolates (spline fit) calcium data

%interpFact = 10;

x1 = linspace(-2,6, size(ca,1));
x2 = linspace(-2,6, interpFact*size(ca,1));


ca2 = interp1(x1, ca, x2, 'spline');
ca2 = ca2';

%figure; plot(x2,ca2);

