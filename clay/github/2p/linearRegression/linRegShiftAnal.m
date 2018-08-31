



for numSeg = 1:37
    
    
    for numShift = 1:10
        
        Rsqr = seg(numSeg).shift(numShift).Rsqr.Ordinary;
        
        r2arr(numSeg, numShift) = Rsqr;
        
        
    end
    
end


figure;
plot(-2:7,r2arr');

figure; plot(mean(r2arr,1));
