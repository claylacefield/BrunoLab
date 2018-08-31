function cluster = RotatePolarData(cluster, rotation)

% ROTATEPOLARDATA(CLUSTER, ROTATION) rotates polar data in CLUSTER by
% ROTATION degrees. ROTATION may be - or + but must be a multiple of 45.
%
% Can be used to permanently correct a cluster file. Be sure to mark the
% file as such!
% 
% To correct for a stimulator rotated CW, ROTATION should be -.
% To correct for a stimulator rotated CCW, ROTATION should be +.

if (mod(rotation, 45) ~= 0)
    error('invalid rotation parameter');
end

stimulus = StimCodeToDegrees(cluster(:,3));
stimulus = stimulus + rotation;
stimulus = mod(stimulus, 360);
cluster(:,3) = DegreesToStimCode(stimulus);
