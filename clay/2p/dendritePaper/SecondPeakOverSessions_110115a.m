



crsi = dendriteBehavStruc.correctRewStimIndCa;
crsiav = dendriteBehavStruc.correctRewStimIndCaAvg;

% crsi = crsi2;
% crsiav = crsi2av;

figure; 
line([10 10], [-0.2 0.6], 'Color', [0.5 0.5 0.5]); 
hold on;
plot(crsi, 'b');
plot(crsiav, 'r');
%title(dendriteBehavStruc.filename);


secPks = max(crsi(15:22, :));

a = mean(secPksCell{1,:});

for i = 1:size(secPksCell6, 2)
    pks = secPksCell6{1,i}; %1,i};
    pkAv(i) = mean(pks);
    pkSem(i) = std(pks)/sqrt(length(pks));
end

figure;
%plot(pkAv);
errorbar(pkAv, pkSem);

% compile events for three animals
for i = 1:5
    secPksCell4{1,i} = [secPksCell1{1,i} secPksCell2{1,i} secPksCell3{1,i}];
end


for i = 6:7
    secPksCell6{1,i} = [mean(secPksCell1{1,1}) mean(secPksCell2{1,i})];
end



