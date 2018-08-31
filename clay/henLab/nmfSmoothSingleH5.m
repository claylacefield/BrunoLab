function [segStruc] = nmfSmoothSingleH5(K,beta, toSmooth) %plotSeg, toSmooth, toSave)

% USAGE: [segStruc] = nmfSmoothSingle(K,beta, plotSeg, toSmooth);
% Taking eftychios's clay_demo_nmf.m script and allowing GUI file selection
% of motion-corrected TIF stack and saves output to "segStruc" along with
% segmentation parameters.
%
% K = # of factors (putative single units) to separate
%   > make this something like twice the number of units you expect,
%   roughly
% beta = sparseness penalty (=0:1) - this affects how spatially sparse the factors
%   are (?), i.e. is the variance shared by all pixels, or just a subset
%   NOTE: that high values may separate a single unit into multiple units
% plotSeg = 0 to not plot resulting factor spatial profiles, 1 to plot
% toSmooth = 0 to not spatially smooth, 1 to smooth (smoothing can help
%   with files where motion correction is imperfect, and thus cell features
%   may not occupy exactly the same pixels
% toSave = 0 to not save output segStruc, 1 to save in current directory



segStruc.notes = 'using nmfSmoothSingleH5, without mean subtraction before smoothing';

%% Select file to segment (w. GUI)

% cd('/home/clay/Documents/Data/2p mouse behavior');
[filename, pathname] = uigetfile('*.h5', 'Select an HDF5 imaging file to read');
cd(pathname);  % must be in file's directory for Eftychios's script to work
nam = filename; % just to use Eftychios's var name

%% Import and trim TIF stack

% try     % try eftychios's trimming but catch to old one if it fails
%     
%     Y = tiff_reader_new(nam,1); % read in tif stack and don't show
%     
% catch
    % addpath nmfv1_4; % clay: just added path to linux matlab
    
    
disp(['Importing HDF5 for ' filename]); tic;
Y = h5read(filename, '/imaging');
toc;

Y = squeeze(Y);

% 022415: playing around to improve segmentation

%Yav = mean(Y,3);
%Y2 = Y-Yav;

% 081614: added smoothing to improve segmentation
if toSmooth
    disp(['Smoothing by ' num2str(toSmooth), 'x', num2str(toSmooth)]); tic;
    for frame = 1:size(Y,3)
        %Y2 = Y(:,:,frame) - Yav;
        Y(:,:,frame) = filter2(fspecial('average', toSmooth), Y(:,:,frame));  % Y2);
        
    end
    toc;
    
end

% normalize and reshape tif stack
[d1,d2,T] = size(Y);  
d = d1*d2;
nn = min(Y(:));              % normalize
mm = max(Y(:)); 
Y = (Y-nn)/(mm-nn);
Yr = reshape(Y,d,T);

%% Sparse non-negative matrix factorization
disp(['Segmenting: K=' num2str(K) ', beta =' num2str(beta)]); tic;
%K = 50;                            % number of components
opt.beta = beta;                   % sparsity penalty (larger values lead to sparser components)
[C,A] = sparsenmfnnls(Yr',K,opt);  % perform sparse NMF
toc;

%% Save output into structure
%basename = nam(1:(strfind(nam, '.tif')-1));
segStruc.filename = nam;
segStruc.segDate = date;
segStruc.C = C; segStruc.A = A; 
segStruc.d1 = d1; segStruc.d2=d2; segStruc.T=T; 
segStruc.K = K; segStruc.opt=opt; 
segStruc.beta = beta;
segStruc.smoothed = toSmooth;

% cd ..;  % go up one level to day folder (i.e. out of .sima folder) to save
% 
% % and save segmentation structure to day folder
% % save([basename '_seg_' date '.mat'], 'segStruc');
% 
% 
% %% Plot if desired
% try
% if plotSeg
%     
% plotSegmentedFactor(segStruc);
%     
% end
% catch
% end


try
%if toSave ~= 0

save(['gergoTest_seg_1_' date], 'segStruc');
    
%end
catch
end