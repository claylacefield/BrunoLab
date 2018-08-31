function [linescanFFTstruc] = linescanFFTbatchAll();

% clay 021211
% script for assessing gamma power from ANNINE VSD linescans (during
% whisker stimulation)

%%

% batch processes VSD imaging TIF stacks using the linescanFFT2 function


%%

% go to main data folder
folder = '\\10.112.43.36\Public\clay\imaging\2p\';
cd(folder);
parDir = dir;

numRec = 0;  % index for all data files analyzed

% and loop through all days in the main 2p imaging directory
for dayInd = 3:length(parDir);

    % check to see if this is a folder
    if parDir(dayInd).isdir;

        cd([folder parDir(dayInd).name]);
        currDir = dir;

%% analyze linescan imaging file
        for i = 3:length(currDir);  % for all data files from this day
            if currDir(i).bytes > 5e7 && currDir(i).bytes < 12e7;  % i.e. if this file is big enough to probably be a linescan TIF stack
                numRec = numRec + 1;
                filename = currDir(i).name;
                filepath = [folder parDir(dayInd).name '\' currDir(i).name];

                if currDir(i).bytes > 1e8;
                    % if file is too big, probably both green and red channels, so
                    % use special linescanFFT2b to only analyze red channel
                    [vsdResponse, vsdOnsetPk, vsdOffsetPk, pkOffset, pkOnset, pkGam, meanPixVal, powspec, f, gamSum, delF, yMat, spatMeanMat, filepath] = linescanFFT2b(filepath, filename);
                else
                    % otherwise, use linescanFFT2 function to analyze this file
                    [vsdResponse, vsdOnsetPk, vsdOffsetPk, pkOffset, pkOnset, pkGam, meanPixVal, powspec, f, gamSum, delF, yMat, spatMeanMat, filepath] = linescanFFT2(filepath, filename);
                end

                % and save the important variables to a data structure
                linescanFFTstruc(numRec).name = filename;
                linescanFFTstruc(numRec).pkOffset = pkOffset;
                linescanFFTstruc(numRec).pkOnset = pkOnset;
                linescanFFTstruc(numRec).pkGam = pkGam;
                linescanFFTstruc(numRec).meanPixVal = meanPixVal;
                linescanFFTstruc(numRec).powspec = powspec;
                linescanFFTstruc(numRec).f = f;
                linescanFFTstruc(numRec).gamSum = gamSum;
                linescanFFTstruc(numRec).vsdResponse = vsdResponse;
                linescanFFTstruc(numRec).vsdOnsetPk = vsdOnsetPk;
                linescanFFTstruc(numRec).vsdOffsetPk = vsdOffsetPk;
                %linescanFFTstruc(numRec). = ;
                %linescanFFTstruc(numRec). = ;

            end  % end IF for TIFs big enough to be linescans

        end   % END loop through day directory of imaging files

    end % end IF for whether item is a folder of data to analyze

end % END loop through 2p directory of recording days

% What I generally want to output for group analysis:
% avg whisker response: (delF/F),
% average luminosity:
% max stim onset (70-120) and offset (175-225) response amplitudes
% avg power spectrum: 2*abs(yAvg(1:NFFT/2))
%
% note that time values are 2ms/line, thus 512ms/frame, and each index is
% 2ms

%% and save output structure into a file
save(['\\10.112.43.36\Public\clay\imaging\2p\linescanFFTall_' date], 'linescanFFTstruc');