

frameShiftArr = -2:7;

for numSeg = 1:length(goodSeg)
    
    frameAvgDf = C(:,numSeg);
    
    for numShift = 1:10
        
        
        %% perform linear regression using randy's
        % script
        
        mdl = RegressClayCalciumShift2(x2, frameAvgDf, frameShiftArr(numShift));
        
        %clear frameAvgDf;
        
        % get tif file name
        %fn = filename(1:(strfind(filename, '.tif')-1));
        
        % save stuff to output struc (need to increment
        % numSessions)
        
        %disp(['saving to struc mouse# ' num2str(numMouse) ' Session ' num2str(numSessions) ' SegNum= ' num2str(goodSeg(numSeg))]);
        
        seg(numSeg).shift(numShift).segNum = goodSeg(numSeg);
        seg(numSeg).shift(numShift).coeffNames = mdl.CoefficientNames;
        seg(numSeg).shift(numShift).coeff = mdl.Coefficients;
        seg(numSeg).shift(numShift).Rsqr = mdl.Rsquared;
        
    end
    
    clear frameAvgDf;
    
end



