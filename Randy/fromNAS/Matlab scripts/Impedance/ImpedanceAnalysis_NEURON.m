function[Imp, delta_z, p_delta_z] = ImpedanceAnalysis_NEURON(wn_params, params)

PLOT = false;

SCALINGFACTOR = 100;
SAMPLERATE = params.Fs;

disp(wn_params.filepath_v);
disp(wn_params.filepath_i);

stim_on = SAMPLERATE*((wn_params.stim_on)/1000);
stim_off = SAMPLERATE*((wn_params.stim_end)/1000);
stim_window = stim_off - stim_on;


New_v = importdata(wn_params.filepath_v);
V_data = New_v.data;
data_v = V_data(stim_on:stim_off, 2);
time = V_data(stim_on:stim_off, 1);

% PSP_v = importdata('C:/Elaine/080404_model_cell/data/sin_wave_data/sustained_psp_distal.dat');
% PSP_v = importdata('C:/Elaine/080404_model_cell/data/IMP with NMDA/prox_psp.dat');
% PSP = PSP_v.data;
% data_psp = PSP(stim_on:stim_off, 2);
% data_v = data_v - data_psp;

New_i = importdata(wn_params.filepath_i);
I_data = New_i.data;
data_i = I_data(stim_on:stim_off, 2);



P_v = POWERSPEC(data_v);
P_i = POWERSPEC(data_i);
P_vi = CROSSSPEC(data_v, data_i);
Z = abs(P_vi)./P_i;
freq = 16000*linspace(0, 1, length(P_v));

figure;
plot(time, data_v./data_i);
ylabel('voltage(mV)');
xlabel('time(ms)');
set(gcf, 'Name', 'V during stim window');
plotedit('ON'); 

figure;
subplot(2,1,1);
plot(freq, P_v);
ylabel('Power');
xlabel('freq (Hz)');
xlim([0 wn_params.Fmax]);
set(gcf, 'Name', 'Power Spectrum of V');
plotedit('ON'); 

subplot(2,1,2);
plot(freq, P_i);
ylabel('Power');
xlabel('freq (Hz)');
xlim([0 wn_params.Fmax]);
set(gcf, 'Name', 'Power Spectrum of I');
plotedit('ON'); 
 
figure; 
plot(freq, Z);
% 
% [C_stim,phi_stim,S12_stim,S1_stim,S2_stim,f]= coherencyc(data_i,data_v,params);
% CS = S12_stim; 
% S_I = S1_stim;
% S_V = S2_stim;
% freq = f;
% 
% Coh = C_stim;
% Z = abs(S12_stim./S1_stim);
% 
% 
% figure;
% plot(freq, Z);
ylabel('impedence');
xlabel('freq (Hz)');
xlim([0 wn_params.Fmax]);
% ylim([0 150]);
set(gcf, 'Name', 'Impedance');
plotedit('ON'); 