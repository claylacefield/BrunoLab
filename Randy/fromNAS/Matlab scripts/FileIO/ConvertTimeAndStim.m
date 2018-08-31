function cluster = ConvertTimeAndStim(filepath, cluster)

% Deduce from filename if recorded in Pittsburgh. If so, check that
% timestamps and stimulus codes are OK.
% Randy Bruno, January 2004

[filepath, fname] = fileparts(filepath);
[filepath, fname] = fileparts(filepath);
[filepath, fname] = fileparts(filepath);
expdate = str2num(fname);

% convert timestamps
if (expdate < 010125)
    % FOR DATAFILES BEFORE 010125 (PDP STIMULATION)
	% Timestamps must be adjusted by 6.7 msec. Five msec of data is acquired prior
	% to the end of the control signal, which is SUPPOSE TO indicate time zero.
	% Timing tests on the PDP computer that controls stimulation showed, however,
	% that stimulation is actually delayed by an additional 1.7 msec (due to
	% various processing events on the PDP).
    disp('stimulus control: PDP');
    cluster(:,4) = cluster(:,4) / 10 - 6.7;
    if iselement(expdate, [000223, 000524, 000607, 000717, 000921, 000927, 001011, 001018, 001121])
        cluster(:,4) = cluster(:,4) - 10;
    end
else
    disp('stimulus control: Labview');
    cluster(:,4) = cluster(:,4) / 10;
end

% convert stimulus codes
V = cluster(:,3);
if (max(V) > 1.2)
    V = V / 2.0;
    V = -(floor((V - .05) / .1) + 21);
    cluster(:, 3) = V;
end
