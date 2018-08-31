function y = cell2logical(x)

for i = 1:nrows(x)
    switch x{i}
        case 'T'
            y(i) = 1;
        case 'F'
            y(i) = 0;
        case 'NA'
            y(i) = NaN;
        otherwise
            disp('array input to cell2logical contains something other than boolean or NaN');
    end
end
        