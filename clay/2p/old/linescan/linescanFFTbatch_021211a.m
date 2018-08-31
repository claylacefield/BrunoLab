function [Y, powspec, f, maxGamFrameInd, gamSum, delF, yMat, spatMeanMat, filepath] = linescanFFT(day);

% clay 082610
% script for assessing gamma power from ANNINE VSD linescans (during
% whisker stimulation)

%%

% user interface to select TIF stack of linescans for processing
% [filename pathname OK] = uigetfile('*.tif', 'Select image file');
%
% if (~OK)
%     return; end
% filepath = [pathname, filename];

%%

folder = ['\\10.112.43.36\Public\clay\imaging\2p\' day];

cd(folder);

currDir = dir;

numRec=0;

%%
for j = 3:length(currDir);
    if currDir(j).bytes > 1e7;
        filepath = [folder '\' currDir(j)];
        for i=1:400
            frame = imread(filepath, 'tif', i);

            % take mean of frame over time (for this trial)
            %    y = mean(frame,1);
            % take mean of frame over space (for all space in this linescan region)
            spatMean = mean(frame,2);

            % deltaF/F
            meanPixVal = mean(spatMean);
            delF = (spatMean - meanPixVal) / meanPixVal;

            % Calculate the power spectrum of the linescans in this frame
            % (most taken from FFT help file in MATLAB)

            L= 256;  % 256 lines in frame
            Fs = 500; % linescan every 2ms in scanImage

            NFFT = 2^nextpow2(L); % Next power of 2 from length of y
            Y = fft(delF,NFFT)/L;   % FFT on spatial average
            %f = Fs/2*linspace(0,1,NFFT/2);
            %psFrame = pwelch(frame);


            ampl = 2*abs(Y(1:NFFT/2));
            yMat(:,i) = ampl; % compile power spectra for all frames
            gam = ampl(11:32);  % find gamma range of these spectra (ind based upon frequencies)
            gamSum(i) = sum(gam);   % find sum power in gamma range

            spatMeanMat(:,i) = spatMean;    % compile the spatial mean of each frame to see overall whisker response

        end  % end FOR loop for all frames in stack

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

        % deltaF/F
        meanPixVal = mean(spatMean(1:40));  % take baseline for delF/F from section before stim
        delF = (spatMean - meanPixVal) / meanPixVal;

        % do FFT on this frame avg again
        Y = fft(delF,NFFT)/L;
%%
        % find average power spectrum over all frames
        yAvg = mean(yMat, 2);

        %%

        % plot the frame with maximum gamma power
        figure;
        subplot(2,2,1); imagesc(maxGamFrame); colormap(gray); xlabel('space'); ylabel('time (2ms)'); title(['frame with maximum gamma power = frame # ' num2str(maxGamFrameInd)]);
        subplot(2,2,2); plot(delF, 2:2:512); set(gca,'YDir','reverse'); ylim([0 512]); xlabel('delF/F'); ylabel('time (ms)'); title('spatial average, delF/F');
        subplot(2,2,3); plot(tempMean); xlim([0 256]); xlabel('space'); ylabel('pixel lum.');title('temporal avg of frame');

        % Plot single-sided amplitude spectrum.
        f = Fs/2*linspace(0,1,NFFT/2);
        
        % plot powspec of frame with highest gamma power
        subplot(2,2,4);
        plot(f,2*abs(Y(1:NFFT/2)))
        title('Single-Sided Amplitude Spectrum of y(t)');
        xlabel('Frequency (Hz)');
        xlim([2 100]);
        ylabel('|Y(f)|');

        [ax,h3]=suplabel(['filename = ' filename] ,'t'); %NOTE: need 'suplabel' from MATLAB Exchange
        set(h3,'FontSize',12);

        % and plot average PS for all linescan frames

        powspec = yAvg;

        figure;
        plot(f,powspec)
        title([filename 'Single-Sided Amplitude Spectrum of y(t)']);
        xlabel('Frequency (Hz)');
        xlim([2 100]);
        ylabel('|Y(f)|');

        figure;
        plot(mean(spatMeanMat,2)); title(filename);
        %%
    end  % end IF for TIFs big enough to be linescans

end   % END loop through 2p directory of recording days

% What I generally want to output for group analysis:
% avg whisker response: (delF/F),
% average luminosity:
% max stim onset (70-120) and offset (175-225) response amplitudes
% avg power spectrum: 2*abs(yAvg(1:NFFT/2))
%
% note that time values are 2ms/line, thus 512ms/frame, and each index is
% 2ms
