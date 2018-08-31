function [vsdResponse, vsdOnsetPk, vsdOffsetPk, pkOffset, pkOnset, pkGam, meanPixVal, powspec, f, gamSum, delF, yMat, spatMeanMat, filepath] = linescanFFT2(filepath, filename);

% clay 021211
% script for assessing gamma power from ANNINE VSD linescans (during
% whisker stimulation)
%
% USAGE: for use with linescanFFTbatch script
%
% NOTE: this particular instance takes TIF stacks containing both green and
% red channels but only analyzes VSD responses from the red channel

%%

frameNum = 0;

% see how big the image stack is
stackInfo = imfinfo(filepath);
sizeStack = length(stackInfo);
clear stackInfo;
%%

for i=2:2:sizeStack
    frame = imread(filepath, 'tif', i); % open the TIF frame
    frameNum = frameNum + 1;

    % take mean of frame over time (for this trial)
    %    y = mean(frame,1);
    
    % take mean of frame over space (for all space in this linescan region)
    spatMean = mean(frame,2);
    
    % calculate deltaF/F
    meanPixVal = mean(spatMean(30:60));
    delF = (spatMean - meanPixVal) / meanPixVal;
    
    % find peak onset and offset response amplitudes (negative-going):
    % NOTE: this now produces pk size rel to variance of baseline epoch
    pkOnset(frameNum) = min(delF(70:120))/std(spatMean(30:60));
    pkOffset(frameNum) = min(delF(175:225))/std(spatMean(30:60));

    % Calculate the power spectrum of the linescans in this frame
    % (most taken from FFT help file in MATLAB)

    L= 256;  % 256 lines in frame
    Fs = 500; % linescan every 2ms in scanImage

    NFFT = 2^nextpow2(L); % Next power of 2 from length of y
    Y = fft(delF,NFFT)/L;   % FFT on spatial average
    %f = Fs/2*linspace(0,1,NFFT/2);
    %psFrame = pwelch(frame);
    

    ampl = 2*abs(Y(1:NFFT/2));
    yMat(:,frameNum) = ampl; % compile power spectra for all frames
    gam = ampl(11:32);  % find gamma range of these spectra (ind based upon frequencies)
    gamSum(frameNum) = sum(gam);   % find sum power in gamma range
    pkGam(frameNum) = max(gam);  % find pk gam power
    
    spatMeanMat(:,frameNum) = spatMean;    % compile the spatial mean of each frame to see overall whisker response

end


%% ANALYSIS ON FRAME WITH MAX GAMMA POWER
% Find the frame with the maximum gamma power
maxGam = max(gamSum);
maxGamFrameInd = find(gamSum == maxGam);

% and reload this frame
maxGamFrame = imread(filepath, 'tif', maxGamFrameInd);

% take mean of frame over space (for all space in this linescan region)
spatMean = mean(maxGamFrame,2);
% take mean of frame over time (for this trial)
tempMean = mean(maxGamFrame,1);

% deltaF/F for frame with max gam power
meanPixVal = mean(spatMean(30:60));  % take baseline for delF/F from section before stim
delF = (spatMean - meanPixVal) / meanPixVal;

% do FFT on this frame avg again
Y = fft(delF,NFFT)/L;

% find average power spectrum over all frames
yAvg = mean(yMat, 2);

%% PLOT STUFF

% plot the frame with maximum gamma power
% figure;
% subplot(2,2,1); imagesc(maxGamFrame); colormap(gray); xlabel('space'); ylabel('time (2ms)'); title(['frame with maximum gamma power = frame # ' num2str(maxGamFrameInd)]);
% subplot(2,2,2); plot(delF, 2:2:512); set(gca,'YDir','reverse'); ylim([0 512]); xlabel('delF/F'); ylabel('time (ms)'); title('spatial average, delF/F');
% subplot(2,2,3); plot(tempMean); xlim([0 256]); xlabel('space'); ylabel('pixel lum.');title('temporal avg of frame');

% Plot single-sided amplitude spectrum for this frame.
f = Fs/2*linspace(0,1,NFFT/2);

% subplot(2,2,4);
% plot(f,2*abs(Y(1:NFFT/2)))
% title('Single-Sided Amplitude Spectrum of y(t)');
% xlabel('Frequency (Hz)');
% xlim([2 100]);
% ylabel('|Y(f)|');
% 
% [ax,h3]=suplabel(['filename = ' filename] ,'t'); %NOTE: need 'suplabel' from MATLAB Exchange
% set(h3,'FontSize',12);

% and plot average PS for all linescan frames

powspec = yAvg;

% figure;
% plot(f,powspec)
% title([filename 'Single-Sided Amplitude Spectrum of y(t)']);
% xlabel('Frequency (Hz)');
% xlim([2 100]);
% ylabel('|Y(f)|');

avgVSDresp = mean(spatMeanMat,2);
meanPixVal = mean(avgVSDresp(30:60));  % take baseline for delF/F from section before stim
vsdResponse = (avgVSDresp - meanPixVal) / meanPixVal;
vsdOnsetPk = min(vsdResponse(70:120));
vsdOffsetPk = min(vsdResponse(175:225));

% figure; 
% plot(vsdResponse); title(filename);
%%

% What I generally want to output for group analysis:
% avg whisker response: (delF/F), 
% average luminosity:
% max stim onset (70-120) and offset (175-225) response amplitudes
% avg power spectrum: 2*abs(yAvg(1:NFFT/2))
% 
% note that time values are 2ms/line, thus 512ms/frame, and each index is
% 2ms
