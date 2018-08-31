function [M, mcParams] = eftyMC(method, toSave, toPlotMetrics)



ch = 2; endFr = 0;  % to read all frames from Ch2 (GCaMP)
[Y, Ysiz, filename] = h5readClay(ch, endFr, 0);

Y = squeeze(Y);


% Y = downsampleStack(Y);


% start Eftychios's motion correction code (from demo.m)

%tic; Y = read_file(name); toc; % read the file (optional, you can also pass the path in the function instead of Y)
%Y = double(Y);      % convert to double precision 
T = size(Y,ndims(Y));
%Y = Y - min(Y(:));



%% Motion correct


if strcmp(method, 'rigid')
%% set parameters (first try out rigid motion correction)

options = NoRMCorreSetParms('d1',size(Y,1),'d2',size(Y,2),'bin_width',50,'max_shift',15,'us_fac',50);

%% perform motion correction
tic; [M,shifts,template] = normcorre(Y,options); toc;

else
%% now try non-rigid motion correction (also in parallel)
options = NoRMCorreSetParms('d1',size(Y,1),'d2',size(Y,2),'grid_size',[32,32],'mot_uf',4,'bin_width',50,'max_shift',15,'max_dev',3,'us_fac',50);
tic; [M,shifts,template] = normcorre_batch(Y,options); toc
end


%% compute metrics
disp('Computing metrics'); tic;
nnY = quantile(Y(:),0.005);
mmY = quantile(Y(:),0.995);

% [cY,mY,vY] = motion_metrics(Y,10); 
clear Y;
[cM,mM,vM] = motion_metrics(M,10);
toc;
%T = length(cY);


%% (clay) save metrics, params
mcParams.filename = filename;
mcParams.date = date;
mcParams.method = method;

mcParams.options = options;
mcParams.shifts = shifts;
mcParams.template = template;
mcParams.cM = cM;
mcParams.mM = mM;
mcParams.vM = vM;

% mcParams.nnY = nnY;
% mcParams.mmY = mmY;
% mcParams.cY = cY;
% mcParams.mY = mY;
% mcParams.vY = vY;
mcParams.T = T;

%save(['mcParams_' date], 'mcParams');

[M] = eftyTruncStack(M);

if toSave
    disp('Saving output'); tic;
    basename = filename(1:strfind(filename, '_Cycle')-1);
    save([basename '_eMC'], 'M', 'mcParams', '-v7.3');
    toc;
end


%% plot metrics

if toPlotMetrics
    
figure;
    ax1 = subplot(2,3,1); imagesc(mY,[nnY,mmY]);  axis equal; axis tight; axis off; title('mean raw data','fontsize',14,'fontweight','bold')
    ax2 = subplot(2,3,2); imagesc(mM,[nnY,mmY]);  axis equal; axis tight; axis off; title('mean rigid corrected','fontsize',14,'fontweight','bold')
    subplot(2,3,4); plot(1:T,cY,1:T,cM1); legend('raw data','rigid'); title('correlation coefficients','fontsize',14,'fontweight','bold')
    subplot(2,3,5); scatter(cY,cM); hold on; plot([0.9*min(cY),1.05*max(cM)],[0.9*min(cY),1.05*max(cM)],'--r'); axis square;
        xlabel('raw data','fontsize',14,'fontweight','bold'); ylabel('rigid corrected','fontsize',14,'fontweight','bold');
    linkaxes([ax1,ax2],'xy')
%% plot shifts        

% shifts_r = horzcat(shifts1(:).shifts)';
% shifts_nr = cat(ndims(shifts2(1).shifts)+1,shifts2(:).shifts);
% shifts_nr = reshape(shifts_nr,[],ndims(Y)-1,T);
% shifts_x = squeeze(shifts_nr(:,1,:))';
% shifts_y = squeeze(shifts_nr(:,2,:))';
% 
% patch_id = 1:size(shifts_x,2);
% str = strtrim(cellstr(int2str(patch_id.')));
% str = cellfun(@(x) ['patch # ',x],str,'un',0);
% 
% figure;
%     ax1 = subplot(311); plot(1:T,cY,1:T,cM1); legend('raw data','rigid'); title('correlation coefficients','fontsize',14,'fontweight','bold')
%             set(gca,'Xtick',[])
%     ax2 = subplot(312); plot(shifts_x); hold on; plot(shifts_r(:,1),'--k','linewidth',2); title('displacements along x','fontsize',14,'fontweight','bold')
%             set(gca,'Xtick',[])
%     ax3 = subplot(313); plot(shifts_y); hold on; plot(shifts_r(:,2),'--k','linewidth',2); title('displacements along y','fontsize',14,'fontweight','bold')
%             xlabel('timestep','fontsize',14,'fontweight','bold')
%     linkaxes([ax1,ax2,ax3],'x')
    
end

%% plot a movie with the results

% figure;
% for t = 1:1:T
%     subplot(121);imagesc(Y(:,:,t),[nnY,mmY]); xlabel('raw data','fontsize',14,'fontweight','bold'); axis equal; axis tight;
%     title(sprintf('Frame %i out of %i',t,T),'fontweight','bold','fontsize',14); colormap('bone')
%     subplot(122);imagesc(M2(:,:,t),[nnY,mmY]); xlabel('non-rigid corrected','fontsize',14,'fontweight','bold'); axis equal; axis tight;
%     title(sprintf('Frame %i out of %i',t,T),'fontweight','bold','fontsize',14); colormap('bone')
%     set(gca,'XTick',[],'YTick',[]);
%     drawnow;
%     pause(0.02);
% end