


% plot timing and amplitude of first and second peaks

inStruc = group1Struc; % dendriteBehavStruc; 

field = 'rewStimStimIndCaAvg'; % 'correctRewStimIndCa';

eventCa = inStruc.(field);

pk1range = 10:14; %5:12;
pk2range = 15:25; %13:20;

thresh = 0.05;

numGoodSess = 0; goodSessInds = [];

figure; hold on;

for numSession = 1:size(eventCa,2)
    
    eventCaSess = eventCa(:,numSession);
    eventCaSess = eventCaSess - eventCaSess(5);
    
    try
        [pk1val, pk1ind] = max(eventCaSess(pk1range));
        
        [pk2val, pk2ind] = max(eventCaSess(pk2range));
        
        if pk1val> thresh %&& pk2ind >1
            
            numGoodSess = numGoodSess + 1;
            goodSessInds(numGoodSess) = numSession;
           
            plot(pk1ind+pk1range(1)-1, pk1val, 'b.');
            plot(pk2ind+pk2range(1)-1, pk2val, 'r.');

            %plot(pk2val, pk1val, 'b.');
            
        end
    catch
    end
    
    
end



%% NOW select out goodSessInds from group1Struc


fieldNames = fieldnames(inStruc);

for field = 1:length(fieldNames)
    
    try
   eventCa = inStruc.(fieldNames{field});
   
   goodEventCa = eventCa(:,goodSessInds);
   
   outStruc.(fieldNames{field}) = goodEventCa;
    
    catch
    end
    
    
    
end


baseFr = 4:8;
xFr = -2:0.25:6;

colorList = autumn(size(eventCa,2));

figure; hold on;

line([0 0], [-0.05 0.25], 'color','r');

for eventNum = 1:size(eventCa,2)
    
    eventNumCa = eventCa(:,eventNum);
    
    eventNumCa = eventNumCa - mean(eventNumCa(baseFr));
    
    plot(xFr-0.25, eventNumCa, 'b');
    % plot(xFr-0.25, eventNumCa, 'color', colorList(eventNum,:));
    
end
    




