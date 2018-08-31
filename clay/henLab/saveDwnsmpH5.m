function saveDwnsmpH5() %,outfile)

outfile = 'eftyM1.h5';


ch = 2; endFr = 0;
[Y, Ysiz, filename] = h5readClay(ch, endFr, 0);
Ysiz = size(Y);

Y = squeeze(Y);

Y = downsampleStack(Y);
Ysiz2 = size(Y);

Y = reshape(Y, [1,Ysiz2(1), Ysiz2(2), 1, Ysiz2(3)]);

disp(['Writing H5 file ' outfile]); 
h5create(outfile, '/imaging', size(Y), 'ChunkSize', [1, Ysiz2(1), Ysiz2(2),1,1]);
tic;
h5write(outfile, '/imaging', Y);
toc;