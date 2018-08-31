function filterraw(folder, filterOrd, ripple, freqRange)
%                  filterraw( folder, 
%                             filterOrd, 
%                             ripple,
%                             freqRange=[highPass lowPass] )
%
% Uses Butterworth (edit for Cheby2)
% looks in 'folder' for a set of *.raw.## files which contain per-channel 
% data, filters and combines those into a giant filtered output file
% 'folder.bandpass'.
%
% The raw.## files must be in range 0-nn, where nn is the last channel.
% If you want to skip a channel, add the '.dead' extension.
% 
% from Vlad's GetThetaPhase:
% FreqRange, FilterOrd, Ripple defautls [4 10], 4, 20.
% good values for gamma are [40 100], 8, 20.
%

%if nargin<2, FreqRange = [400 5000]; end
%if nargin<3, FilterOrd = 10; end;		
%if nargin<4, Ripple = 20; end;
if (nargin ~= 4), error('Please use "doc filterraw" for usage');end;
[pathstr basename ext]=fileparts(folder);basename=[basename ext];


nChannels = 16;
channels =  0:15;
sampleFreq = 30000;

% [nChannels channels] = getNumChannels(folder);
% sampleFreq = getSampleRate(folder);
% fprintf('there are %d input channels\n', length(channels));
% if any(channels==false)
%     fprintf('    but .dead channels will be excluded\n');
% end
% fprintf('sampleFreq is %dHz\n', sampleFreq);

% [bblow aalow] = cheby2(filterOrd, ripple, freqRange(2)*2/sampleFreq,'low');
% [bbhigh aahigh] = cheby2(filterOrd, ripple, freqRange(1)*2/sampleFreq,'high');
[bblow aalow] = butter(filterOrd, freqRange(2)*2/sampleFreq,'low');
[bbhigh aahigh] = butter(filterOrd, freqRange(1)*2/sampleFreq,'high');
%BUGBUG this didn't work??  [bb aa] = butter(filterOrd, freqRange*2/sampleFreq);

f=fopen([folder filesep basename '.bandpass'],'w','ieee-le');

lastSample=-1;
for ii=0:length(channels)-1
    if ~channels(ii+1), continue;end  % skip '.dead' channels
    inFile=[folder filesep basename '.raw.' int2str(ii)];
    fprintf('Loading \"%s\"', inFile);
    fi=fopen(inFile,'r','ieee-le');
    x=fread(fi,'float32','ieee-le');
    fclose(fi);
    if lastSample==-1, lastSample=length(x);end
    if lastSample~=length(x), error('Input files are different sizes');end
    lastSample=length(x);
    
    % 
    % Apply filters
    % No need to do lowpass separately if we aren't displaying
    %
    fprintf('.  Filtering');
    % lowpass=filtfilt(bblow,aalow,x);
    highpass=filtfilt(bbhigh,aahigh,x);
    clear x;
    filteredData=filtfilt(bblow,aalow,highpass);
%    filteredData=filtfilt(bb,aa,x);
    
    % write out the channel, but skips all the other channels
    fprintf('.  Writing');
    % this technique writes all samples for one channel, then next channel, etc
    fwrite(f,filteredData,'float32','ieee-le');
    fprintf('.\n');
    
    clear highpass;
    
    % BUGBUG check to make sure they are all same size?
    % exit early if there was bogus data
    % if (lastSample<size(x,1)), break; end

end

fclose(f);
if any(channels==false)
    fprintf('.bandpass has %d channels\n', nChannels);
end


fLog=fopen([folder filesep basename '.bandpass.log'],'wt');
fprintf(fLog,'there are %d input channels\n', length(channels));
if any(channels==false)
    fprintf(fLog,'    but .dead channels were excluded\n');
    fprintf(fLog,'    and .bandpass has %d channels\n', nChannels);
end
fprintf(fLog,'there are %d samples per channel\n', lastSample);
fprintf(fLog,'sampleFreq is %dHz\n', sampleFreq);
fprintf(fLog,'freqRange %dHz-%dHz is passed\n', freqRange(1), freqRange(2));
fprintf(fLog,'filterOrder is %d (Butterworth: two-pass)\n', filterOrd);
fclose(fLog);
