function value = ReadHeaderField(fid, field)
% READHEADERFIELD Returns the value of a header field in .dat file from ntrode.vi
% READHEADERFIELD(FID, FIELD), where FID is a file identifier and FIELD
% is a string specifying the name of the field whose VALUE should be
% returned.
%
% Randy Bruno, December 2013

done = false;
while ~done
    line = fgetl(fid);
    if strcontain(line, field)
        value = line(strfind(line, ':')+1:end);
        done = true;
    else
        if strcmp(line, '%%ENDHEADER') || feof(fid)
            warning(['ReadHeaderField could not find field named ' field]);
            value = [];
            done = true;
        end
    end            
end
