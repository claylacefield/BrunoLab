function [M1, M2, mcParams] = eftyMC(toSave, toPlotMetrics)



ch = 2; endFr = 0;  % to read all frames from Ch2 (GCaMP)
[Y, Ysiz, filename] = h5readClay(ch, endFr, 0);

Y = squeeze(Y);


% Y = downsampleStack(Y);


% start Eftychios's motion correction code (from demo.m)

%tic; Y = read_file(name); toc; % read the file (optional, you can also pass the path in the function instead of Y)
%Y = double(Y);      % convert to double precision 
T = size(Y,ndims(Y));
%Y = Y - min(Y(:));

%% set parameters (first try out rigid motion correction)

options_rigid = NoRMCorreSetParms('d1',size(Y,1),'d2',size(Y,2),'bin_width',50,'max_shift',15,'us_fac',50);

%% perform motion correction
tic; [M1,shifts1,template1] = normcorre(Y,options_rigid); toc

%% now try non-rigid motion correction (also in parallel)
options_nonrigid = NoRMCorreSetParms('d1',size(Y,1),'d2',size(Y,2),'grid_size',[32,32],'mot_uf',4,'bin_width',50,'max_shift',15,'max_dev',3,'us_fac',50);
tic; [M2,shifts2,template2] = normcorre_batch(Y,options_nonrigid); toc



%% compute metrics
disp('Computing metrics'); tic;
nnY = quantile(Y(:),0.005);
mmY = quantile(Y(:),0.995);

[cY,mY,vY] = motion_metrics(Y,10); 
clear Y;
[cM1,mM1,vM1] = motion_metrics(M1,10);
[cM2,mM2,vM2] = motion_metrics(M2,10);
toc;
T = length(cY);


%% (clay) save metrics, params
mcParams.filename = filename;
mcParams.date = date;

mcParams.nnY = nnY;
mcParams.mmY = mmY;
mcParams.cY = cY;
mcParams.mY = mY;
mcParams.vY = vY;
mcParams.T = T;

mcParams.options_rigid = options_rigid;
mcParams.shifts1 = shifts1;
mcParams.template1 = template1;
mcParams.cM1 = cM1;
mcParams.mM1 = mM1;
mcParams.vM1 = vM1;

mcParams.options_nonrigid = options_nonrigid;
mcParams.shifts2 = shifts2;
mcParams.template2 = template2;
mcParams.cM2 = cM2;
mcParams.mM2 = mM2;
mcParams.vM2 = vM2;

%save(['mcParams_' date], 'mcParams');

if toSave
    disp('Saving output'); tic;
    basename = filename(1:strfind(filename, '_Cycle')-1);
    save([basename '_eMC'], 'M1', 'M2', 'mcParams', '-v7.3');
    toc;
end


%% plot metrics

if toPlotMetrics
    
figure;
    ax1 = subplot(2,3,1); imagesc(mY,[nnY,mmY]);  axis equal; axis tight; axis off; title('mean raw data','fontsize',14,'fontweight','bold')
    ax2 = subplot(2,3,2); imagesc(mM1,[nnY,mmY]);  axis equal; axis tight; axis off; title('mean rigid corrected','fontsize',14,'fontweight','bold')
    ax3 = subplot(2,3,3); imagesc(mM2,[nnY,mmY]); axis equal; axis tight; axis off; title('mean non-rigid corrected','fontsize',14,'fontweight','bold')
    subplot(2,3,4); plot(1:T,cY,1:T,cM1,1:T,cM2); legend('raw data','rigid','non-rigid'); title('correlation coefficients','fontsize',14,'fontweight','bold')
    subplot(2,3,5); scatter(cY,cM1); hold on; plot([0.9*min(cY),1.05*max(cM1)],[0.9*min(cY),1.05*max(cM1)],'--r'); axis square;
        xlabel('raw data','fontsize',14,'fontweight','bold'); ylabel('rigid corrected','fontsize',14,'fontweight','bold');
    subplot(2,3,6); scatter(cM1,cM2); hold on; plot([0.9*min(cY),1.05*max(cM1)],[0.9*min(cY),1.05*max(cM1)],'--r'); axis square;
        xlabel('rigid corrected','fontsize',14,'fontweight','bold'); ylabel('non-rigid corrected','fontsize',14,'fontweight','bold');
    linkaxes([ax1,ax2,ax3],'xy')
%% plot shifts        

shifts_r = horzcat(shifts1(:).shifts)';
shifts_nr = cat(ndims(shifts2(1).shifts)+1,shifts2(:).shifts);
shifts_nr = reshape(shifts_nr,[],ndims(Y)-1,T);
shifts_x = squeeze(shifts_nr(:,1,:))';
shifts_y = squeeze(shifts_nr(:,2,:))';

patch_id = 1:size(shifts_x,2);
str = strtrim(cellstr(int2str(patch_id.')));
str = cellfun(@(x) ['patch # ',x],str,'un',0);

figure;
    ax1 = subplot(311); plot(1:T,cY,1:T,cM1,1:T,cM2); legend('raw data','rigid','non-rigid'); title('correlation coefficients','fontsize',14,'fontweight','bold')
            set(gca,'Xtick',[])
    ax2 = subplot(312); plot(shifts_x); hold on; plot(shifts_r(:,1),'--k','linewidth',2); title('displacements along x','fontsize',14,'fontweight','bold')
            set(gca,'Xtick',[])
    ax3 = subplot(313); plot(shifts_y); hold on; plot(shifts_r(:,2),'--k','linewidth',2); title('displacements along y','fontsize',14,'fontweight','bold')
            xlabel('timestep','fontsize',14,'fontweight','bold')
    linkaxes([ax1,ax2,ax3],'x')
    
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