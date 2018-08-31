function plotItiWhiskBoutCa(inStruc)

% Clay 121416

% sessionName = inStruc.sessionName;
% txtName = inStruc.txtName;

itiWhiskBoutCa = inStruc.itiWhiskBoutCa;
itiWhiskBoutAngle = inStruc.itiWhiskBoutAngle;
itiWhiskBoutVar = inStruc.itiWhiskBoutVar;

%mouseName = txtName(strfind(txtName, 'mouse')+5:strfind(txtName, '.txt')-1);

itiWhiskBoutVar = itiWhiskBoutVar(1:1700, :);
itiWhiskBoutAngle = itiWhiskBoutAngle(1:1700, :);

whLength = size(itiWhiskBoutVar,1);

xCa = -2:0.25:6;
xWh = linspace(-2,6, whLength);

figure; 
subplot(3,1,1);
plot(xCa, mean(itiWhiskBoutCa,2));
%title([sessionName ' ' txtName ' itiWhiskBoutCa']);
ylabel('dF/F');
xlabel('sec');
%ylim([-0.1 0.3]);
xlim([-2 6]);
subplot(3,1,2);
plot(xWh, mean(itiWhiskBoutVar,2));
ylabel('itiWhiskBoutVar');
xlabel('sec');
subplot(3,1,3);
plot(xWh, mean(itiWhiskBoutAngle,2));
ylabel('itiWhiskBoutVar');
xlabel('sec');

