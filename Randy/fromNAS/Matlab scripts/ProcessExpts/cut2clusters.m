% This script reads an MClust output file (.cut) and writes multiple
% ASCII files containing the individual clusters described in .cut.
% The ASCII files have the same general name as the .cut file with
% the extension format .clusterx, where x is the cluster #.
%
% Assumes the presence of a matching .lv file of the same general name.
% Requires my function left(s, n), which returns the substring of s after
% deletion of the n-rightmost characters.
%
% Randy Bruno, June 2000

[fname, pname] = uigetfile('*.cut', 'Select a .cut file to convert');
cd(pname);
lvname = strcat(left(fname, 4), '.lv');
cut2clustern(fname, lvname);

