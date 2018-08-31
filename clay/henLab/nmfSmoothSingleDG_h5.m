function [segStruc] = nmfSmoothSingleDG_h5(K,beta, toDownsample) %plotSeg, toSmooth, toSave)

% USAGE: [segStruc] = nmfSmoothSingle(K,beta, toDownsample);
% Taking eftychios's clay_demo_nmf.m script and allowing GUI file selection
% of motion-corrected TIF stack and saves output to "segStruc" along with
% segmentation parameters.
%
% K = # of factors (putative single units) to separate
%   > make this something like twice the number of units you expect,
%   roughly (try 50 or 100)
% beta = sparseness penalty (=0:1) - this affects how spatially sparse the factors
%   are (?), i.e. is the variance shared by all pixels, or just a subset
%   NOTE: that high values may separate a single unit into multiple units
%   (try beta = 0.5 or 0.7 for DG data, right now)
% toDownsample = 1; % to downsample stack spatially and temporally by 2x
% each


segStruc.notes = 'using nmfSmoothSingleDG'; %, without mean subtraction before smoothing';

%% Select file to segment (w. GUI)

% cd('/home/clay/Documents/Data/2p mouse behavior');
% [filename, pathname] = uigetfile('*.mat', 'Select an .MAT imaging file to read');
% cd(pathname);  % must be in file's directory for Eftychios's script to work
% nam = filename; % just to use Eftychios's var name
% load(nam);

ch = 2; endFr = 0;  % to read all frames from Ch2 (GCaMP)
[Y, Ysiz, filename] = h5readClay(ch, endFr, 0);

Y = squeeze(Y);

% 022415: playing around to improve segmentation

%Yav = mean(Y,3);
%Y2 = Y-Yav;

% 122316: changed downsampling method
if toDownsample
    Y = downsampleStack(Y);
    
end

segStruc.avCh2 = mean(Y,3);

% normalize and reshape tif stack
[d1,d2,T] = size(Y);  
d = d1*d2;
nn = min(Y(:));              % normalize
mm = max(Y(:)); 
Y = (Y-nn)/(mm-nn);
Yr = reshape(Y,d,T);

clear Y;

%% Sparse non-negative matrix factorization
disp(['Segmenting: K=' num2str(K) ', beta =' num2str(beta)]); tic;
%K = 50;                            % number of components
opt.beta = beta;                   % sparsity penalty (larger values lead to sparser components)
[C,A] = sparsenmfnnls(Yr',K,opt);  % perform sparse NMF
toc;

clear Yr;

%% Save output into structure
%basename = nam(1:(strfind(nam, '.tif')-1));
segStruc.filename = filename; % nam;
segStruc.segDate = date;
segStruc.C = C; segStruc.A = A; 
segStruc.d1 = d1; segStruc.d2=d2; segStruc.T=T; 
segStruc.K = K; segStruc.opt=opt; 
segStruc.beta = beta;
% segStruc.smoothed = toDownsample;
segStruc.toDownsample = toDownsample;

%% Find goodSegs
disp('Isolating goodSegs'); tic;
[goodSeg, goodSegParams] = findGoodSegsDG(segStruc);
segStruc.goodSeg = goodSeg;
segStruc.goodSegParams = goodSegParams;
toc;


basename = filename(1:strfind(filename, '.h5')-1);


disp('Saving red channel average'); tic;
ch = 1; endFr = 1000;  % to read all frames from Ch1 (tdTomato)
[Y, Ysiz, filename] = h5readClay(ch, endFr, filename); toc;
if toDownsample
    Y = downsampleStack(Y);
end
segStruc.avCh1 = squeeze(mean(Y,3));
clear Y;

try
%if toSave ~= 0

save([basename '_segStruc_1_' date], 'segStruc');
    
%end
catch
end

% %% Plot if desired
% try
% if plotSeg
%     
% plotSegmentedFactor(segStruc);

plotGoodSegs(segStruc, goodSeg);

%     
% end
% catch
% end