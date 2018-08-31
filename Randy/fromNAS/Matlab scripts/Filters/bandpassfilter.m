function y = bandpassfilter(x, fc1, fc2)

Fpass1 = fc1 / (32000/2);  % First Passband Frequency
Fstop1 = Fpass1 / 2;  % First Stopband Frequency
Fpass2 = fc2 / (32000/2);  % Second Passband Frequency
Fstop2 = mean([1 Fpass2]);  % Second Stopband Frequency
Astop1 = 60;    % First Stopband Attenuation (dB)
Apass  = 1;     % Passband Ripple (dB)
Astop2 = 60;    % Second Stopband Attenuation (dB)

h = fdesign.bandpass('fst1,fp1,fp2,fst2,ast1,ap,ast2', Fstop1, Fpass1, ...
                     Fpass2, Fstop2, Astop1, Apass, Astop2);

Hd = design(h, 'butter', ...
    'MatchExactly', 'stopband');

fvtool(Hd)

y = filter(Hd, x-mean(x));
