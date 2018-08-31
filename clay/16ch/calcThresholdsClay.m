function calcThresholdsClay(folder, theta, clipWindow, assocWindow)
% calcThresholds( folder, theta, clipWindow, assocWindow )
%
% all windows are in milliseconds
% NOTE that assocWindow is a FORWARD value, ie half-window
% theta is threshold in standard deviations
%
% looks in 'folder' for 'folder.bandpass' file which contains per-channel 
% data, and calculate a threshold, theta
%
%

if (nargin ~= 4), error('Please use "doc calcThreshold" for usage');end;
[pathstr basename ext]=fileparts(folder);basename=[folder filesep basename ext];

nChannels = 16;
sampleFreq = 30000;

fprintf('there are %d channels\n', nChannels);
fprintf('sampleFreq is %dHz\n', sampleFreq);


fi=fopen([basename '.bandpass'],'r','ieee-le');
fseek(fi,0,'eof');
channelDataSize = ftell(fi)/nChannels;
nSamples=channelDataSize/4;
seconds=nSamples/sampleFreq;
clipWindow=round(sampleFreq*clipWindow/1000);
assocWindow=round(sampleFreq*assocWindow/1000);
% this is no longer settable (intra-channel extrema assoc window)
e2eWindow=assocWindow;

fprintf('there are %d samples per channel\n', nSamples);
fprintf('there are %d seconds of data\n', round(seconds));
fprintf('clip window is %d samples\n', clipWindow);
fprintf('channel-channel extrema association is %d samples\n', assocWindow);


%
% Write top of .log file
%
fLog=fopen([basename '.spikes.log'],'wt');
fprintf(fLog,'there are %d channels\n', nChannels);
fprintf(fLog,'sampleFreq is %dHz\n', sampleFreq);
fprintf(fLog,'there are %d samples per channel\n', nSamples);
fprintf(fLog,'there are %d seconds of data\n', round(seconds));
fprintf(fLog,'clip window is %d samples\n', clipWindow);
fprintf(fLog,'channel-channel extrema association is %d samples\n', assocWindow);
fprintf(fLog,'spike is defined as extrema beyond %2.2f std dev\n', theta);


%
% First pass: detect spikes within each channel
%
extremaSample=cell(nChannels,1);
extremaVal=cell(nChannels,1);
rms=zeros(1,nChannels);
for ii=1:nChannels
%if ii==11, keyboard;end
    % read all data for just this channel
    fseek(fi,channelDataSize*(ii-1),'bof');
    x=fread(fi,nSamples,'float32','ieee-le');
    if length(x)~=nSamples, error ('.bandpass problem');end
    % split up into 1-second slices, get sd (assuming mean==zero) for each slice
    for jj=1:seconds;m(jj)=sqrt(mean( x((jj-1)*sampleFreq+1:(jj-1)*sampleFreq+sampleFreq).^2 ));end
    m=sort(m);
    % get rid of 1% of outliers ~ 3sd
    m(ceil(seconds*0.99)+1:end)=[];
    rms(ii)=mean(m);
    % set threshold at theta*sd
    aboveThreshold=find(abs(x)>theta*rms(ii));   % array of extrema locations in original data
    grosspeakCount=length(find(x>theta*rms(ii)));
    troughCount=length(find(x<-theta*rms(ii)));
    consumedpeakCount=0;risingpeakCount=0;standalonepeakCount=0;disttonext=0;
    mixedExtrema=0;peak2troughSpikes=0;peak2troughSpread=0;
    peakSpikeIntros=0;troughSpikeIntros=0;
    
    % single channel culling
    %
    jj=1;
    while (jj<length(aboveThreshold))
        % first, if pos value starts the window, make the peak of this rise the windowBegin
        if x(aboveThreshold(jj))>0
            peakSpikeIntros=peakSpikeIntros+1;
            peakExtrema=true;
            inRise=false;
            for kk=jj+1:length(aboveThreshold)  % yes, could go forever, but it won't with any real data
                % is the next aboveThreshold actually the next sample?  is it also more positive?
                if (aboveThreshold(kk)==aboveThreshold(jj)+1) && (x(aboveThreshold(kk))>x(aboveThreshold(jj)))
                    aboveThreshold(jj)=aboveThreshold(kk);
                    aboveThreshold(kk)=0;
                    consumedpeakCount=consumedpeakCount+1;
                    inRise=true;
                else
                    break
                end
            end
            if inRise
                risingpeakCount=risingpeakCount+1;
            else
                standalonepeakCount=standalonepeakCount+1;
                if aboveThreshold(jj+1)<aboveThreshold(jj), keyboard;end
                disttonext=disttonext+(aboveThreshold(jj+1)-aboveThreshold(jj));
            end
            % jj = kk; Don't do this, I switched to swapping the peaks
        else
            troughSpikeIntros=troughSpikeIntros+1;
            peakExtrema=false;
        end

        windowBegin=aboveThreshold(jj);
        
        % are we at end of samples?  if so, lookahead is insufficient, end early
        if (windowBegin+e2eWindow-1)>nSamples
            fprintf(fLog,'Ch%02d skipping final extrema\n',ii-1);
            break;
        end

        [minInWindow minInWindowPos] = min(x(windowBegin:windowBegin+e2eWindow-1));

        if peakExtrema
            if minInWindow<-theta*rms(ii)
                mixedExtrema=mixedExtrema+1;
            end
            %BUGBUG document that we set peak2trough threshold at 1.5X the basic threshold
            if x(windowBegin)-minInWindow > (theta*rms(ii)*1.5)
                peak2troughSpikes=peak2troughSpikes+1;
                peak2troughSpread=peak2troughSpread+(x(windowBegin)-minInWindow)/rms(ii);
                bogusPeak = false;
            else
                bogusPeak = true;
            end
            
        end

        if peakExtrema && bogusPeak
            % note we will not clear out the window, we just don't like this
            % peak so we'll move to next extrema, which may or may not be within this window
            aboveThreshold(jj)=0;
        else
            % clear out any extrema in the pre-window (from intro extrema to trough) and window
            % then set threshold position to lowest point in window
            extremaInWindow = find( aboveThreshold(jj:min(jj+e2eWindow+minInWindowPos,end)) < windowBegin+(minInWindowPos-1)+(e2eWindow-1) );
            aboveThreshold(jj+extremaInWindow-1) = 0;
            aboveThreshold(jj) = windowBegin+minInWindowPos-1;
        end

        jj = jj+1;
        %if isnan(aboveThreshold(jj))
            % kk = find(isfinite(aboveThreshold(jj:min(jj+e2eWindow+minInWindowPos,end))),1);
            kk = find(aboveThreshold(jj:min(jj+e2eWindow+minInWindowPos,end)),1);
        %end
        if (kk), jj = jj+kk-1;
        else break
        end

    end % while

    extremaSample{ii}=aboveThreshold(aboveThreshold>0);
    extremaVal{ii}=x(extremaSample{ii})/rms(ii);  % store extremaVal in units of sd

    fprintf('Ch%02d  spikes %d\n', ii-1, length(extremaSample{ii}));
    fprintf(fLog,'Ch%02d  (sd %2.5f mean %2.5f)  \n', ii-1, rms(ii), mean(x));
    fprintf(fLog,'    spikes %d\n', length(extremaSample{ii}));
    fprintf(fLog,'    gross peaks %d, peak intros %d: rising %d (ignored during rise %d), standalone %d (avg next +%d)\n', ...
        grosspeakCount, peakSpikeIntros, risingpeakCount, consumedpeakCount, standalonepeakCount, round(disttonext/standalonepeakCount));
    fprintf(fLog,'    gross troughs %d, trough intros %d\n',...
        troughCount, troughSpikeIntros);
    fprintf(fLog,'    peak&trough extrema %d, peak2trough spikes %d (avg spread %.1fsd)\n',...
        mixedExtrema, peak2troughSpikes, peak2troughSpread/peak2troughSpikes);

end % for ii
clear aboveThreshold x;




% 
% Now we scan between channels for the "master" trough, and select that as the
% spike window
%

fprintf('clipping spikes');

% initial load
nextIndex=ones(nChannels,1);
nextSample=zeros(nChannels,1);
nextVal=zeros(nChannels,1);
possibleSpikes=0;
for ii=1:nChannels
    nextSample(ii) = extremaSample{ii}(1);
    nextVal(ii) = extremaVal{ii}(1);
    possibleSpikes = possibleSpikes+length(extremaSample{ii});
end
remainingChannels=ones(nChannels,1);
[windowBegin windowBeginCh] = min(nextSample);
% assocWindowOffsets=[round(-assocWindow/2)+1 fix(assocWindow/2)];

% assign these prior to loop so we aren't constantly recalcing
rmsAssocWindowDivisor=ones(assocWindow,1)*rms;
assocWindowPrecString = [int2str(assocWindow) '*float32'];   % ie '64*float' for 64 samples
troughs=zeros(possibleSpikes,1);  % wildly overallocate, avoid time cost in loop

% begin cross-channel window loop
t1=0;t2=0;t3=0;t4=0;t5=0;%ts=clock;
% this no longer useful, as I changed the per-channel handling to include minima only
% peakExtrema=0;
slidewindow=0;overlappedSpikes=0;
reslide=0;maxslide=0; %diagnostic
refuseslide=0;refuseselfslide=0;distalextrema=0; %diagnostic
pp=0;

groups=zeros(nChannels-1,1);
channelsInFullWindow(1:nChannels)=false;

while any(remainingChannels)

    channelsInWindow = find( nextSample<(windowBegin+assocWindow) );
    [minInWindow minInWindowChSubset] = min(nextVal( channelsInWindow ));
    [maxInWindow maxInWindowChSubset]= max(nextVal( channelsInWindow ));
    minInWindowCh=channelsInWindow(minInWindowChSubset);
    maxInWindowCh=channelsInWindow(maxInWindowChSubset);
% this no longer useful, as I changed the per-channel handling to include minima only
%     % if (maxInWindow>0 && minInWindow<0), mixedExtrema=mixedExtrema+1;end
%     if (maxInWindow>0 && minInWindow>0)
%         peakExtrema=peakExtrema+1;
%         onlyPeaks=true;
%     else
%         onlyPeaks=false;
%     end
    % keep track of all the channels seen if the full window
    % will be used later for assignment to groups[]
    channelsInFullWindow(channelsInWindow)=true;


    % should the window change?
    if minInWindowCh == windowBeginCh
        % nope, this is our window minimum
        % fprintf('%d (Ch%02d)\n',nextSample(windowBeginCh),windowBeginCh));


        if (fseek(fi,(windowBegin-1)*4,'bof')), error('input format error'); end
        x=fread(fi,[assocWindow nChannels],assocWindowPrecString,channelDataSize-assocWindow*4,'ieee-le');

        
        x=x./rmsAssocWindowDivisor;
        [row col] = find( x==min(min(x)) );
        if abs(col-windowBeginCh)>1, 
            distalextrema=distalextrema+1; % diagnostic
        end
        % must handle very rare event where multiple channels have exact same trough
        % voltage, or same channel has exact same trough voltage at different points in the window
        % ... we will just take the first one
        if length(col)>1
            col=col(1);
            row=row(1);
        end;
        % is the trough (the lowest) voltage on the same channel, but forward in the window?
        % if so, we will decline, as we presume that the single-channel spike
        % list is filtered properly; otherwise this is a double spike.
        % generally these refuseslide numbers should add up to < 5% of spikes
        if (col==windowBeginCh && row~=1)
            x(2:end,windowBeginCh)=0;   % but don't compare this channel with itself?
            [row col2] = find( x==min(min(x)) );
            if col2~=windowBeginCh
                refuseslide=refuseslide+1; % diagnostic
            else
                refuseselfslide=refuseselfslide+1;  % diagnostic
            end
            row=1;
        end
        windowBegin=windowBegin+row-1;
        windowBeginCh=col;
        
        pp=pp+1;
        troughs(pp) = windowBegin;

        % figure out the grouping
        % first add the centering channel to the window group, in case it wasn't
        % in extrema list
        channelsInFullWindow(windowBeginCh)=true;
        for ii=1:nChannels-1
            if channelsInFullWindow(ii) && channelsInFullWindow(ii+1)
                groups(ii)=groups(ii)+1;
            end
        end
        channelsInFullWindow(:)=false;


        % move to the next extrema
        nextIndex(channelsInWindow) = nextIndex(channelsInWindow)+1;
        for ii=1:length(channelsInWindow)
            ch=channelsInWindow(ii);
            % have we tapped out this channel?
            if nextIndex(ch)>length(extremaSample{ch})
                remainingChannels(ch) = NaN;
                nextSample(ch)=NaN;
                nextVal(ch)=NaN;
            else
                nextSample(ch) = extremaSample{ch}(nextIndex(ch));
                nextVal(ch) = extremaVal{ch}(nextIndex(ch));
            end
        end
        slidewindow=0;
        [windowBegin windowBeginCh] = min(nextSample);

    else
        % window must change: minInWindowCh ~= windowBeginCh
        if ~slidewindow
            thisslide=nextSample(minInWindowCh)-windowBegin;
        else
            thisslide=thisslide+nextSample(minInWindowCh)-windowBegin;
        end
        slidewindow=slidewindow+1;
        % HACK, if the window is sliding too much, let's just log this as a
        % spike and let the window logic move us forward to next spike
        % We will not look for lowest point in the window in these edge cases
        if thisslide>26
            pp=pp+1;
            troughs(pp)=windowBegin;
            overlappedSpikes=overlappedSpikes+1;
            % figure out the grouping
            for ii=1:nChannels-1
                if channelsInFullWindow(ii) && channelsInFullWindow(ii+1)
                    groups(ii)=groups(ii)+1;
                end
            end
            channelsInFullWindow(:)=false;
            slidewindow=0;
        elseif slidewindow>1
            reslide=reslide+1;maxslide=max(maxslide,thisslide); %diagnostic
        end
% this no longer useful, as I changed the per-channel handling to include minima only
%         % if there are only peak extrema in the window, then use the max peak as
%         % the start of window, rather than the lowest extrema
%         if (onlyPeaks)
%             windowBegin = nextSample(maxInWindowCh);
%             windowBeginCh = maxInWindowCh;
%             channelsInWindow(maxInWindowChSubset)=[];
%         else
            windowBegin = nextSample(minInWindowCh);
            windowBeginCh = minInWindowCh;
            channelsInWindow(minInWindowChSubset)=[];
%         end
        nextIndex(channelsInWindow) = nextIndex(channelsInWindow)+1;
        for ii=1:length(channelsInWindow)
            ch=channelsInWindow(ii);
            if nextIndex(ch)>length(extremaSample{ch})
                remainingChannels(ch) = NaN;
                nextSample(ch)=NaN;
                nextVal(ch)=NaN;
            else
                nextSample(ch) = extremaSample{ch}(nextIndex(ch));
                nextVal(ch) = extremaVal{ch}(nextIndex(ch));
            end
        end

    end

end % while
fprintf('.\n');

fprintf('there are %d spikes\n',pp);
fprintf(fLog,'there are %d spikes\n',pp);
fprintf('Groups:\n');
fprintf(fLog,'Groups:\n');
for ii=1:nChannels-1
    fprintf('  %02d+%02d  %5.4fHz\n', ii-1,ii,groups(ii)/seconds);
    fprintf(fLog,'  %02d+%02d  %5.4fHz\n', ii-1,ii,groups(ii)/seconds);
end

troughs(pp+1:end)=[];   % clear end of array




%
% Write out .spk file
%
fprintf('Writing .spk files');
fo = fopen([basename '.spk.1'],'w','ieee-le');

% assign these prior to loop so we aren't constantly recalcing
clipWindowOffsets=[round(-clipWindow/2)+1 fix(clipWindow/2)];
%BUGBUG broken  clipWindowScaler=(ones(assocWindow,1)/rms).*scaleFactor;
rmsClipWindowDivisor=ones(clipWindow,1)*rms;
clipWindowPrecString = [int2str(clipWindow) '*float32'];   % ie '96*float' for 96 samples

t1=0;t2=0;t3=0;t4=0;t5=0;%ts=clock;

% HACK to get a reasonable scaleFactor... just run thru loop once to get min-max
normMax=0;
for ii=1:pp
    % make sure not to overrun end
    if (troughs(ii)+clipWindowOffsets(1)-1) < 0
        continue;
    end

    if (fseek(fi,(troughs(ii)+clipWindowOffsets(1)-1)*4,'bof')), error('input format error'); end
    x=fread(fi,[clipWindow nChannels],clipWindowPrecString,channelDataSize-clipWindow*4,'ieee-le');

    x=x./rmsClipWindowDivisor;
    normMax=max(normMax,max(max(abs(x))));
end
scaleFactor=floor(double(intmax('int16'))/normMax);
% fprintf(' (scaleFactor %d)', scaleFactor);
fprintf(fLog,' .spk scaleFactor %d\n', scaleFactor);


scaleMax=0;scaleMin=0;
skippedSpikes=0;
for ii=1:pp
    % make sure not to overrun end
    if (troughs(ii)+clipWindowOffsets(1)-1) < 0
        fprintf(fLog,'Skipping spike at %d (too early for clipWindow)\n', troughs(ii));
        skippedSpikes=skippedSpikes+1;
        continue;
    end

    if (fseek(fi,(troughs(ii)+clipWindowOffsets(1)-1)*4,'bof')), error('input format error'); end
    x=fread(fi,[clipWindow nChannels],clipWindowPrecString,channelDataSize-clipWindow*4,'ieee-le');

    x=x./rmsClipWindowDivisor;
    x=(x.*scaleFactor)';
    %BUGBUG this isn't working!!
    scaleMax=int16(max(scaleMax,max(max(x))));scaleMin=int16(min(scaleMin,min(min(x))));
    if scaleMax==intmax('int16') || scaleMin==intmin('int16')
        fprintf('(min,max) = (%f,%f) at sample# %d\n', min(min(x)),max(max(x)),troughs(ii));
        error('scaleFactor too large for 16-bit signed integer');
    end
    
    if fwrite(fo,x,'int16','ieee-le')~=clipWindow*nChannels, error('output format error'); end
end


fclose(fo); % .spk

% Write out spiketimes
%
fo = fopen([basename '.spktimes.1'],'w','ieee-le');
fwrite(fo,troughs(skippedSpikes+1:end),'int32','ieee-le');
fclose(fo);

fprintf('.\n');
fprintf(fLog,'scaled (min,max) = (%d,%d)\n',int16(scaleMin),int16(scaleMax));


fclose(fi); % .bandpass

fclose(fLog);
