

corrFirstContactTimes = corrFirstContactTimes(find(corrFirstContactTimes));

beginInd = corrFirstContactTimes - preFrame;
endInd = corrFirstContactTimes + postFrame;

for k = 1:length(endInd)
    
   %corrFirstContactLfp(:,:,k) = x(beginInd(k):endInd(k),:);
    corrFirstContactWhisk(:,k) = filtWhiskSig(beginInd(k):endInd(k));

%         for chNum = 1:size(x,2)
%             chDf = chStruc(:,chNum);
%             corrFirstContactLfp (:,chNum,k)= x(beginInd(k):endInd(k));
%             
%         end

    
end


    corrFirstContactLfpAvg = mean(corrFirstContactLfp,3);

for j=50:60
 figure; hold on; 
 for i = 1:16 
     plot(corrFirstContactLfp(:,i,j)*3+i); 
 end
 
 plot(corrFirstContactWhisk(:,j)*2-2, 'm');
 
end

