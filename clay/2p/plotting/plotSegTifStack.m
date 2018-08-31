function plotSegTifStack(segStruc, i)

filename = segStruc.filename;

% load in segmentation matrices
C = segStruc.C;     % temporal matrix
A = segStruc.A;     % spatial matrix
d1 = segStruc.d1;   % dimX?
d2 = segStruc.d2;   % dimY?
T = segStruc.T;     % time (num frames)

%% and to make a movie of a single component

% NOTE: not really working right now so just take saved movie and look at
% in imageJ

% i = 6;
% figure; 
% Ar = reshape(A(i,:),d1,d2);
% nn = min(Ar(:))*min(C(:,i));
% mm = max(Ar(:))*min(C(:,i));
% %T = size(C,1);
% for t = 1:T
%     imagesc(Ar*C(t,i), [nn,mm]); axis equal; axis tight;
%     title(sprintf('Timestep %i out of %i', t, T));
%     pause(0.01);
%     drawnow;
% end


%% and to save this movie as a .tif stack

outputFileName = [filename '_factor' i '_seg.tif'];
for t=1:T
    imwrite(Ar*C(t,i), outputFileName, 'WriteMode', 'append', 'Compression', 'None');
end
