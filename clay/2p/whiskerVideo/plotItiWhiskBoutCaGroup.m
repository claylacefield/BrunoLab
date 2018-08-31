function plotItiWhiskBoutCaGroup(inStruc)

% Clay 121416

% sessionName = inStruc.sessionName;
% txtName = inStruc.txtName;

itiWhiskBoutCa = inStruc.itiWhiskBoutCa;
itiWhiskBoutAngle = inStruc.itiWhiskBoutAngle;
itiWhiskBoutVar = inStruc.itiWhiskBoutVar;

%mouseName = txtName(strfind(txtName, 'mouse')+5:strfind(txtName, '.txt')-1);

% itiWhiskBoutVar = itiWhiskBoutVar(1:1700, :);
% itiWhiskBoutAngle = itiWhiskBoutAngle(1:1700, :);

whLength = size(itiWhiskBoutVar,1);

xCa = -2:0.25:6;
xWh = linspace(-2,6, whLength);

semCa = std(itiWhiskBoutCa,0,2)/sqrt(size(itiWhiskBoutCa,2));
semWh = std(itiWhiskBoutVar,0,2)/sqrt(size(itiWhiskBoutVar,2));
semWh2 = std(itiWhiskBoutAngle,0,2)/sqrt(size(itiWhiskBoutAngle,2));

figure; 
subplot(3,1,3);
errorbar(xWh, mean(itiWhiskBoutVar,2), semWh, 'r');
ylabel('itiWhiskBoutVar');
xlabel('sec');
xlim([-2 6]);
ylim([min(mean(itiWhiskBoutVar,2))-10 max(mean(itiWhiskBoutVar,2))+ 10]);
subplot(3,1,2);
errorbar(xWh, mean(itiWhiskBoutAngle,2), semWh2);
ylabel('itiWhiskBoutAngle');
xlabel('sec');
xlim([-2 6]);
ylim([min(mean(itiWhiskBoutAngle,2))-1 max(mean(itiWhiskBoutAngle,2))+ 1]);
subplot(3,1,1);
errorbar(xCa, mean(itiWhiskBoutCa,2), semCa, 'g');
%title([sessionName ' ' txtName ' itiWhiskBoutCa']);
ylabel('dF/F');
xlabel('sec');
ylim([min(mean(itiWhiskBoutCa,2))-0.005 max(mean(itiWhiskBoutCa,2))+0.005]);
xlim([-2 6]);