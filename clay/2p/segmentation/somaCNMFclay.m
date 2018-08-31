function [segStruc] = somaCNMFclay()


currDir = dir;
currDirNames = {currDir.name};

currPath = pwd;
slashInds = strfind(currPath, '/');
currDirName = currPath(slashInds(end)+1:end);

try
Y = readTifStackSimple([currPath '/' currDirName '.sima/' currDirName 'b.tif']);
catch
    try
        Y = readTifStackSimple([currPath '/' currDirName '.sima/' currDirName '.tif']);
    catch
    Y = readTifStackSimple([currPath '/corrected/' currDirName '.tif']);
    
    end
end

Y = Y - min(Y(:)); 

[d1,d2,T] = size(Y);                                % dimensions of dataset
d = d1*d2;                                          % total number of pixels


%% Set parameters

K = 20;                                           % number of components to be found
tau = 6; %[];                                         % std of gaussian kernel (size of neuron - not needed for dendritic data) 
p = 0;                                            % No AR dynamics for dendritic data (2 for somatic?)
merge_thr = 0.8;                                  % merging threshold

options = CNMFSetParms(...                      
    'd1',d1,'d2',d2,...                         % dimensions of datasets
    'search_method','ellipse','dist',3,...       % search locations when updating spatial components
    'deconv_method','constrained_foopsi',...    % activity deconvolution method
    'temporal_iter',2,...                       % number of block-coordinate descent steps 
    'fudge_factor',0.98,...                     % bias correction for AR coefficients
    'merge_thr',merge_thr,...                    % merging threshold
    'gSig',tau...
    );
%% Data pre-processing
tic;
[P,Y] = preprocess_data(Y,p);
toc;

%% fast initialization of spatial components using greedyROI and HALS
tic;
[Ain,Cin,bin,fin,center] = initialize_components(Y,K,tau,options,P);  % initialize
toc;


Yr = reshape(Y,d,T);
% plot_dend_components_GUI(Yr,Ain,Cin,bin,fin,options);  % view the components

    
%% update spatial components
tic;
[A,b,Cin] = update_spatial_components(Yr,Cin,fin,[Ain,bin],P,options);
toc;

%% update temporal components
tic;
[C,f,P,S] = update_temporal_components(Yr,A,b,Cin,fin,P,options);
toc;

%% merge found components
[Am,Cm,K_m,merged_ROIs,P,Sm] = merge_components(Yr,A,b,C,f,P,S,options);

% display_merging = 1; % flag for displaying merging example
% if and(display_merging, ~isempty(merged_ROIs))
%     i = 1; %randi(length(merged_ROIs));
%     ln = length(merged_ROIs{i});
%     figure;
%         set(gcf,'Position',[300,300,(ln+2)*300,300]);
%         for j = 1:ln
%             subplot(1,ln+2,j); imagesc(reshape(A(:,merged_ROIs{i}(j)),d1,d2)); 
%                 title(sprintf('Component %i',j),'fontsize',16,'fontweight','bold'); axis equal; axis tight;
%         end
%         subplot(1,ln+2,ln+1); imagesc(reshape(Am(:,K_m-length(merged_ROIs)+i),d1,d2));
%                 title('Merged Component','fontsize',16,'fontweight','bold');axis equal; axis tight; 
%         subplot(1,ln+2,ln+2);
%             plot(1:T,(diag(max(C(merged_ROIs{i},:),[],2))\C(merged_ROIs{i},:))'); 
%             hold all; plot(1:T,Cm(K_m-length(merged_ROIs)+i,:)/max(Cm(K_m-length(merged_ROIs)+i,:)),'--k')
%             title('Temporal Components','fontsize',16,'fontweight','bold')
%         drawnow;
% else
%     fprintf('No components were merged. \n')
% end

%% order and extract DF/F

[A_or,C_or,S_or,P] = order_ROIs(A,C,S,P); % order components
K_m = size(C_or,1);
[C_df,~] = extract_DF_F(Yr,[A_or,b],[C_or;f],K_m+1); % extract DF/F values (optional)

% %% display components
% 
% plot_dend_components_GUI(Yr,A_or,C_or,b,f,options)
% 
% %% make movie
% 
% make_dendritic_video(A_or,C_or,b,f,Yr,d1,d2)


%% save to segStruc

segStruc.filename = [currDirName '.tif'];
segStruc.segDate = date;
segStruc.options = options;
segStruc.d1 = d1; segStruc.d2 = d2; segStruc.T = T;
segStruc.C = C_or'; %C_df(1:K,:)';  % temporal components
segStruc.A = A_or'; % spatial components
segStruc.K = K_m;
segStruc.opt.beta = 0;

save([currDirName '_seg2c_' date], 'segStruc');



