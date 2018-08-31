function pca_spkClay(folder,spikeWidth)
% pca_spk( folder, spikeWidth )
%
% create .fet file from spike data
%
% spikeWidth is in msecs (same as calcThresholds' clipWindow)
%
% DEFAULT is 1.625msec
%
if (nargin == 1), spikeWidth=1.625;
elseif (nargin ~= 2), error('Please use "doc pca_spk" for usage');end
[pathstr basename ext]=fileparts(folder);basename=[basename ext];

nChannels = 16;
sampleFreq = 30000;

% nChannels = getNumChannels(folder);
% sampleFreq = getSampleRate(folder);
spikeWidth=round(sampleFreq*spikeWidth/1000);

fprintf('there are %d channels\n', nChannels);
fprintf('sampleFreq is %dHz\n', sampleFreq);
fprintf('spikeWidth is %d samples\n', spikeWidth);


%
% get spiketimes
%
fi = fopen([folder filesep basename '.spktimes.1'],'r','ieee-le');
troughs=fread(fi,'int32','ieee-le');
fprintf('there are %d spikes\n', length(troughs));
fclose(fi);


%
% do PCA
%
coeff = zeros(nChannels*3+1,length(troughs));
fprintf('PCA:');
fi=fopen([folder filesep basename '.spk.1'],'r','ieee-le');
fseek(fi,0,'eof')

% klusters will puke on large coeff, so don't overscale
scaleFactor = 100;

formatter='';
for ii=1:nChannels
    fprintf(' Ch%02d', ii-1);
    fprintf('test1');
    fseek(fi,(ii-1)*2,'bof');
    x=fread(fi,[spikeWidth length(troughs)],'int16',(nChannels-1)*2,'ieee-le');
    if length(troughs) ~= size(x,2), error('bad .spk file');end
    
    fprintf('about to PCA');
    
    [m B U] = pca_decompose(x);
    % take first 3 dimensions
    coeff((ii-1)*3+1:(ii-1)*3+3,:)=U(1:3,:);
    % spread values to min/max
    for jj=1:3
        % older code to scale out the coeff to the full int32 range
        % scaleFactor = floor(intmax('int32')/max(abs(coeff((ii-1)*3+jj,:))));
        % fprintf(' %d',scaleFactor);
        coeff((ii-1)*3+jj,:) = round(coeff((ii-1)*3+jj,:).*double(scaleFactor));
    end
    formatter=[formatter '%d\t%d\t%d\t'];
end
formatter=[formatter '%d\n'];    % for the timestamp
fprintf('.\n');

coeff(ii*3+1,:)=troughs;  % for the timestamps
fo = fopen([folder filesep basename '.fet.1'],'wt');
fprintf(fo,'%d\n',nChannels*3+1);
fprintf(fo,formatter,int32(coeff));
fclose(fo); % .fet

fclose(fi); % .spk


% scriptname = [folder filesep basename '.1.KK.'];
scriptname = [folder filesep 'KK.1.'];
if isunix
    scriptname=[scriptname 'sh'];
else 
    scriptname=[scriptname 'cmd'];
end
fo = fopen(scriptname,'wt');
s = ['KlustaKwik ' basename ' 1 -UseFeatures '];for ii=1:nChannels;s=[s '111'];end
s = [s '0'];
if isunix, s=[s ' > /dev/null &'];end
fprintf(fo,'%s\n',s);
fclose(fo);
if isunix, system(['chmod +x ' scriptname]);end

