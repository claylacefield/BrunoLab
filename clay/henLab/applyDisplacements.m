function applyDisplacements(filename)

% This is a function to load a displacements.mat file of motion correction
% data (saved from readSeqDispPkl.py) and apply these displacements to an
% image stack in MATLAB


load(filename);  % displacements is a 4D array dim= (frames,?,lines, yxDisp)

displ = squeeze(displacements);  % this removes 2nd dimension (ch?)

numFr = size(displ,1);


for frNum = 1:numFr
    frDisp = squeeze(displ(frNum,:, :));
    
    for line = 1:size(frDisp,1)
        yDisp = frDisp(line, 1);
        xDisp = frDisp(line, 2);
        
        outStack(frNum,line+yDisp,xxxx) = inStack(frNum, line, :);
    end

end





