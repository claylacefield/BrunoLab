function dlmappend(filename, m, dlm)

fid = fopen(filename, 'a');

for i = 1:nrows(m)
    fprintf(fid, ['%d' dlm], m(i, :));
    fprintf(fid, '\n', 0);
end

fclose(fid);
