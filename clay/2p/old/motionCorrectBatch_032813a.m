% function [] = motionCorrectBatch()

% motion correction batch file
% USAGE: 
% 
% DESCRIPTION:
% Wrapper for batch motion correction of 2p framescan data from 
% mouse behavior. 
%
% Reads through a spreadsheet of data files (.tif stacks) and 
% motion corrects them using Patrick's Vitterbi/Markov 
% algorithm correction
%
%
%
%
%



% invoke Patrick's motion correction: motion_correction(numStates,
% linesExcluded);

motion_correction2(30, 0);

