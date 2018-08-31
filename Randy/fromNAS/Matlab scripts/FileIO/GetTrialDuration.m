function [duration] = GetTrialDuration(filepath, method)

% Determine the trial duration
%
% Randy & Kate, November 2013

if (nargin == 0)
    [filename pathname OK] = uigetfile('*.dat', 'Select continuous signal file');
    if (~OK) 
        return; end
    filepath = [pathname, filename];
end

if nargin < 2
    method = 'header';
end

fid = fopen(filepath, 'r', 'b');
if (fid == -1) error('could not open file for reading'); end

switch method
    case 'header'
        d = ReadHeaderField(fid, 'duration');
        if isempty(d)
            warning('GetTrialDuration trying stimcode search method');
            duration = GetTrialDuration(filepath, 'stimcode');
        else
            duration = str2num(d);
        end
    case 'stimcode'        
        headerSize = SkipHeader(fid);
        
        % read the first 60 seconds of data starting at trial 0
        [stimcode, data] = GetRecord(fid, headerSize, 60000, 0);
        
        % data acquisition system cannot code outside +/-10V, so < -10 is a
        % stimcode, not trace data
        x = find(data < -10, 1, 'first');
        duration = (x-1) / 32; %convert scan# to milliseconds
    otherwise
        warning('method not recognized')
end

fclose(fid);