function plotCaWhiskContacts(inStruc)


somaVals = inStruc.somaVals;
dendVals = inStruc.dendVals;
somaWhiskContacts = inStruc.somaWhiskContacts;
dendWhiskContacts = inStruc.dendWhiskContacts;

figure;
subplot(2,1,1);
try
plotMeanSEM(somaVals, 'r');
catch
    disp('No somaVals');
end
hold on; 
try
plotMeanSEM(dendVals, 'b');
catch
    disp('No dendVals');
end
legend('soma', 'dend');
%title([mouseSummCell{1,1} ' ' progNameTag ' ' eventName ' soma vs. dend (matched) on ' date]);
ylim([-0.04 0.2]);
xlabel('secs');
ylabel('dF/F');

subplot(2,1,2);
try
plotMeanSEM(somaWhiskContacts, 'r');
catch
    disp('No somaWhiskContacts');
end
hold on; 
try
plotMeanSEM(dendWhiskContacts, 'b');
catch
    disp('No dendWhiskContacts');
end

legend('soma', 'dend');
    %xlim([0 size(somaWhiskContacts,1)]);
    title('whisk contacts');
