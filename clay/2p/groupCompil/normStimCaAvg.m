function [normGroupCa, zGroupCa] = normStimCaAvg(inStruc)

%ca = b;

%inStruc = unitGroupStrucD;
groupCa = inStruc.rewStimCaAvg;

for i = 1:size(groupCa,2)
    ca = groupCa(:,i);
    minSub = ca-min(ca);
    normCa = minSub/max(minSub);

    zscored = ca/std(ca);

    normGroupCa(:,i) = normCa;
    zGroupCa(:,i) = zscored;
end

figure; 
subplot(3,1,1);
plot(mean(groupCa,2));

subplot(3,1,2);
plot(mean(zGroupCa,2));

subplot(3,1,3);
plot(mean(normGroupCa,2));


