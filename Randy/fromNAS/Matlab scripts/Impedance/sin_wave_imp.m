
[filename_prox pathname_prox OK] = uigetfile('C:/Elaine/080404_model_cell/data/sin_wave_data/*.dat', 'proximal-synapse voltage file');
if (~OK) return; end
filepath_prox = [pathname_prox, filename_prox];


[filename_distal pathname_distal OK] = uigetfile('C:/Elaine/080404_model_cell/data/sin_wave_data/*.dat', 'distal-synapse voltage file');
if (~OK) return; end
filepath_distal = [pathname_distal, filename_distal];

[filename_passive pathname_passive OK] = uigetfile('C:/Elaine/080404_model_cell/data/sin_wave_data/*.dat', 'passive voltage file');
if (~OK) return; end
filepath_passive = [pathname_passive, filename_passive];


prox_v = importdata(filepath_prox);
prox = prox_v.data(:, 2);
time = prox_v.data(:,1);

prox_psp = importdata('C:\Elaine\080404_model_cell\data\sin_wave_data\prox_psp.dat');
ppsp = prox_psp.data(:, 2);

distal_v = importdata(filepath_distal);
distal = distal_v.data(:, 2);

distal_psp = importdata('C:\Elaine\080404_model_cell\data\sin_wave_data\distal_psp.dat')
dpsp = distal_psp.data(:, 2);

New_passive = importdata(filepath_passive);
passive = New_passive.data(:, 2);
%
%P_prox = POWERSPEC(prox);
%freq = 16000/2*linspace(0, 1, ceil(3200/2));
%
figure;
plot(time, prox-ppsp, 'r');
hold on;
plot(time, distal-dpsp, 'k');
plot(time, passive+70);

figure;
plot(time, prox./passive, 'r');
hold on;
plot(time, distal./passive, 'k');
plot(time, prox./distal);
xlim=([150 200]);
xlabel('time, ms')

figure;
plot(time, prox-passive, 'r');
hold on;
plot(time, distal- passive, 'k');

xlim=([150 200]);
xlabel('time, ms')