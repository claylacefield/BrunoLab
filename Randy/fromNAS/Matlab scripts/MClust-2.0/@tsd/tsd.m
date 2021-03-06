function tsa = tsd(t, Data)
%
% tsa = tsd(t,data)
%
% tsd is a class of "timestamped arrays"
% 	It includes a list of timestamps
% 	and data (possibly an array).  
%    The first dimension of Data correspond to the
%    timestamps given.  The timestamps must be sequential,
% 	but do not have to be continuous.
%
% Methods
%    tsd/Range     - Timestamps used
%    tsd/Data      - Returns the data component
%    tsd/DT        - Returns the DT value (mean diff(timestamps))
%    tsd/StartTime - First timestamp
%    tsd/EndTime   - Last timestamp
%    tsd/Restrict  - Keep data within a certain range
%    tsd/CheckTS   - Makes sure that a set of tsd & ctsd objects have identical start and end times
%    tsd/cat       - Concatenate ctsd and tsd objects
%    tsd/Mask      - Make all non-mask values NaN
%
% 	It is completely compatible with ctsd.
%  Note: data can be 2-dimensional, then time is the second axis.
%
% ADR 1998
% version L4.0
% RELEASED as part of MClust 2.0
% See standard disclaimer in ../Contents.m

if nargin == 0
 tsa.t = NaN;
 tsa.data = NaN;
 tsa = class(tsa, 'tsd');
 return
end 

if nargin < 2
  error('tsd constructor must be called with T, Data');
end

tsa.t = t;
tsa.data = Data;

tsa = class(tsa, 'tsd');
