function OK = WriteCluster(filepath, cluster)
% WRITECLUSTER Write a cluster file.
% Randy Bruno, October 2003

if (nargin ~= 2)
   error('WriteCluster takes 2 arguments');
end

OK = 1;
fid = fopen(filepath, 'w');
if fid == -1
    OK = 0;
end
    
for i = 1:nrows(cluster)
    record = [i-1 cluster(i, 2) cluster(i, 3) round(cluster(i, 4)*10)];
    nc = fprintf(fid, '%d\t%d\t%d\t%d\r\n', record);
    if nc < 1
        OK = 0;
    end
end

st = fclose(fid);
if st == -1
    OK = 0;
end
