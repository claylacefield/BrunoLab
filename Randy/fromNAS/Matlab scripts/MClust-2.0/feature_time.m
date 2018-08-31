function [timeData, timeNames] = feature_time(V, ttChannelValidity)

% MClust
% [timeData, timeNames] = feature_time(V, ttChannelValidity)
% Calculate time feature 
%
% INPUTS
%    V = TT tsd
%    ttChannelValidity = nCh x 1 of booleans
%
% OUTPUTS
%    Data - nSpikes times 
%    Names - "Time"
%
% ADR April 1998
% version M1.0
% RELEASED as part of MClust 2.0
% See standard disclaimer in Contents.m

timeData = Range(V, 'ts');
timeNames = {'time (ts)'};
