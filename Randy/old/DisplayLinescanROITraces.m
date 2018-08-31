function DisplayLinescanROITraces(handles)

nl = handles.dy;
scandur = str2num(get(handles.FrameDurationBox, 'String'));
x = (scandur/nl):(scandur/nl):scandur;

% calculate neuron traces & plot all ROIs
nROI = handles.ROIn;
colors = ['rgbymcrgbymc'];
F = zeros(nROI, nl);
dF = zeros(nROI, nl);

cf = str2num(get(handles.currentFrame, 'String'));
for i = 1:nROI
    h = handles.ROIh(i);
    api = iptgetapi(h);
    p = api.getPosition();
    disp(p)
    handles.ROIpos{i} = p;

    if get(handles.AverageImageButton, 'Value')
        pixels = handles.AvgI(p(2):(p(2)+p(4)-1), p(1):(p(1)+p(3)-1));
    else
        pixels = handles.I(p(2):(p(2)+p(4)-1), p(1):(p(1)+p(3)-1), cf);
    end

    %average over x, so there's only a string of values along the y axis
    y = mean(pixels, 2);
    y=y';
%     baseline = mean(pixels(50:75));
    %calculate %dF/F
%     y = 100 * (pixels - baseline) / baseline;

% image = handles.AvgI;
% baseline = image(50:75, :);
% baseline = mean(baseline, 1);
% for i = 1:length(baseline)
%     image(:, i) = 100 * (image(:, i) - baseline(i)) / baseline(i);
% end
% figure;
% 

    if get(handles.DeltaFbutton, 'Value')
        baseline = mean(y(50:75));
        dF(i,:) = (y - baseline) / baseline * 100;
        y = dF(i, :);
    end

    if get(handles.ButterworthFilterCheckbox, 'Value')
        fl = str2num(get(handles.LowCutoff, 'String'));
        fh = str2num(get(handles.HighCutoff, 'String'));
        [b, a] = butter(5, fl / (scanfreq/2), 'high');
        [y, zf] = filter(b, a, y);
        if fh < floor(scanfreq / 2)
            [b, a] = butter(10, fh / (scanfreq/2), 'low');
            [y, zf] = filter(b, a, y);
        end
    end

    if get(handles.BoxcarCheckbox, 'Value')
        windowSize = str2num(get(handles.BoxcarSize, 'String'));
        y = filter(ones(1, windowSize) / windowSize, 1, y);
    end


        plot(x, y, 'Color', colors(i));
%         plot(x, y + i*20, 'Color', colors(i));
    hold on;

end

if ~isempty(handles.Npx) | handles.ROIn > 0
    if get(handles.Fbutton, 'Value')
        ylabel('F');
    else
        ylabel('relative % dF/F');
    end
    xlabel('ms');
    box off;
    hold off;
    ylim auto;
    set(gca, 'Color', 'k');
    drawnow;
end
hold off;

% if get(handles.ButterworthFilterCheckbox, 'Value')
%     figure;
%     subplot(2,1,1);
%     [P, freq] = pwelch(dF(i,:), [], [], [], scanfreq);
%     loglog(freq, P);
%     box off;
%     axis tight;
%     xlabel('Hz');
%     ylabel('Power dF/F');
%
%     subplot(2,1,2);
%     [P, freq] = pwelch(y, [], [], [], scanfreq);
%     loglog(freq, P);
%     box off;
%     axis tight;
%     xlabel('Hz');
%     ylabel('Power dF/F');
% end


