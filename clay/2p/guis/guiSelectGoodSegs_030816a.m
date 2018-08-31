function varargout = guiSelectGoodSegs_030816a(varargin)
% GUISELECTGOODSEGS_030816A MATLAB code for guiSelectGoodSegs_030816a.fig
%      GUISELECTGOODSEGS_030816A, by itself, creates a new GUISELECTGOODSEGS_030816A or raises the existing
%      singleton*.
%
%      H = GUISELECTGOODSEGS_030816A returns the handle to a new GUISELECTGOODSEGS_030816A or the handle to
%      the existing singleton*.
%
%      GUISELECTGOODSEGS_030816A('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUISELECTGOODSEGS_030816A.M with the given input arguments.
%
%      GUISELECTGOODSEGS_030816A('Property','Value',...) creates a new GUISELECTGOODSEGS_030816A or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guiSelectGoodSegs_030816a_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guiSelectGoodSegs_030816a_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guiSelectGoodSegs_030816a

% Last Modified by GUIDE v2.5 09-Mar-2016 02:21:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @guiSelectGoodSegs_030816a_OpeningFcn, ...
    'gui_OutputFcn',  @guiSelectGoodSegs_030816a_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before guiSelectGoodSegs_030816a is made visible.
function guiSelectGoodSegs_030816a_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guiSelectGoodSegs_030816a (see VARARGIN)

% Choose default command line output for guiSelectGoodSegs_030816a
handles.output = hObject;

% initialize some variables in handles struc
handles.checkbox1state = 0;
handles.checkbox2state = 0;
handles.trialNumCheckboxState = 0;

handles.segNum = 1;

handles.greatSeg = [];
handles.goodSeg = [];
handles.okSeg = [];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes guiSelectGoodSegs_030816a wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = guiSelectGoodSegs_030816a_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




%% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile('.mat');
cd(pathname);
inStruc = load(filename);
fieldNames = fieldnames(inStruc);
caDataStruc = inStruc.(fieldNames{1});
handles.typeStruc = fieldNames{1};
handles.caDataStruc = caDataStruc;
handles.filename = filename;
handles.segDate = caDataStruc.segDate;

handles.segStruc = caDataStruc;

% need to find fields in calcium data structure
fieldNames = fieldnames(caDataStruc);
% fieldNames = fieldNames(2:length(fieldNames));  % cut out eventStruc

caFields = strfind(fieldNames, 'Ca');
caFieldInd = find(not(cellfun('isempty', caFields)));
fieldNames = fieldNames(caFieldInd);

handles.fieldNames = fieldNames;

% handles.K = caDataStruc.K;
% handles.A = caDataStruc.A;
handles.C = caDataStruc.C;
% handles.d1 = caDataStruc.d1;
% handles.d2 = caDataStruc.d2;

% built this 080314 for hand segmented files
try
    handles.A = caDataStruc.A;
    handles.K = caDataStruc.K;
    handles.d1 = caDataStruc.d1;
    handles.d2 = caDataStruc.d2;
    handles.roiPkIndCell = caDataStruc.roiPkIndCell;
    
    handSeg = 0;
    
catch
    cd('corrected');
    
    corrDir = dir;
    
    handSeg = 1;
    
    for corrDirNum = 1:length(corrDir)
        if ~isempty(strfind(corrDir(corrDirNum).name, '.tif')) && isempty(strfind(corrDir(corrDirNum).name, 'final'))
            
            tifFilename = corrDir(corrDirNum).name;
            
            %tifpath = [dayPath dayDir(b).name '/' filename]; %[dayDir(b).name '.tif']];
            % NOTE: build the tifpath different because of the extra
            % folder layer for motion correction
            
            disp(['Processing image stack for ' filename]);
            tic;
            
            % see how big the image stack is
            stackInfo = imfinfo(tifFilename);  % create structure of info for TIFF stack
            sizeStack = length(stackInfo);  % no. frames in stack
            width = stackInfo(1).Width; % width of the first frame (and all others)
            height = stackInfo(1).Height;  % height of the first frame (and all others)
            
            clear stackInfo;
            
            frameNum = 0;
            
            % now load all tifs in stack into 3D matrix
            for i=1:sizeStack
                frame = imread(tifFilename, 'tif', i); % open the TIF frame
                frameNum = frameNum + 1;
                tifStack(:,:,frameNum)= frame;  % make into a TIF stack
                %imwrite(frame*10, 'outfile.tif')
                
            end
            
            handles.tifAvg = uint16(mean(tifStack, 3));
            
            clear tifStack;
            
        end
    end
    cd ..;
end

handles.handSeg = handSeg;

% and make them "string" properties in listbox1
set(handles.listbox1,'String',fieldNames);
% set(handles.listbox1,'Value',1:length(fieldNames));

set(handles.text3, 'String', filename);

% also get the eventHist information

currDir = dir;
firstFile = 0;
%firstFile2 = 0;

eventStrucArr = [];
eventStrucDatenums = [];
dendBehavStrucArr = [];
dendBehavDatenums = [];

for numFile = 1:length(currDir)
    if ~isempty(strfind(currDir(numFile).name, 'eventHist'))
        eventStrucArr = [eventStrucArr numFile];
        eventStrucDatenums = [eventStrucDatenums currDir(numFile).datenum];
        %load(currDir(numFile).name);
    elseif ~isempty(strfind(currDir(numFile).name, 'dendriteBehavStruc')) %&& firstFile2 == 0
        dendBehavStrucArr = [dendBehavStrucArr numFile];
        dendBehavDatenums = [dendBehavDatenums currDir(numFile).datenum];
        %load(currDir(numFile).name);
        %firstFile2 = 1;
    elseif ~isempty(strfind(currDir(numFile).name, 'whiskDataStruc'))  % now also load whisker data if present
        load(currDir(numFile).name);
        display(['Loading ' currDir(numFile).name]);
    elseif ~isempty(strfind(currDir(numFile).name, '.bin'))  % now also load whisker data if present
        binFileName = currDir(numFile).name;
        x2 = binRead2pSingleName(binFileName);
        display(['Loading ' binFileName]);
    end
    
end

handles.whiskSig = x2(5,:);
handles.lickSig = x2(6,:)/4;
handles.levSig = x2(2,:)/4;
handles.rewSig = x2(3,:)/4;

try
handles.whiskFrTimes = whiskDataStruc.frTimes;
handles.whiskAngle = whiskDataStruc.meanAngle(1:length(whiskDataStruc.frTimes));
handles.whiskDataStruc = whiskDataStruc;
catch
    disp('No whiskerDataStruc');
end

% find the latest of each relevant structure
[maxDBSdatenum, maxDendBehavStrucNum] = max(dendBehavDatenums);
load(currDir(dendBehavStrucArr(maxDendBehavStrucNum)).name);
handles.dendriteBehavStruc = dendriteBehavStruc;

try
    [maxESdatenum, maxEventStrucNum] = max(eventStrucDatenums);
    load(currDir(eventStrucArr(maxEventStrucNum)).name);
    handles.eventHistBehavStruc = eventHistBehavStruc;
catch
end

% and calculate discrimination index
correctRespStruc = dendriteBehavStruc.eventStruc.correctRespStruc;
corrRespArr = correctRespStruc.corrRespArr;

minBin = 1;
[binFracCorrect] = binErrorRates(correctRespStruc);

cla(handles.axes6);
axes(handles.axes6);
bar(binFracCorrect);
xlim([0.5 length(binFracCorrect)+0.5]);
ylim([0 1]); hold on;
line([0.5 length(binFracCorrect)+0.5], [0.5 0.5], 'Color', 'r');
hold off;

% Update handles structure
guidata(hObject, handles);

%% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dataStruc = handles.caDataStruc;

contents = cellstr(get(hObject,'String'));
field = get(hObject,'Value');     % index of fieldNames
fieldNames = handles.fieldNames;
thisField1 = fieldNames{field(1)};
thisField2 = fieldNames{field(2)};
handles.field1 = thisField1;
handles.field2 = thisField2;
%disp(thisField);

caData1 = dataStruc.(thisField1);
caData2 = dataStruc.(thisField2);
handles.caData1 = caData1;  % caData is frame epoch for all segments and events
handles.caData2 = caData2;

% now also extract out RoiPkHist, if present
field1Base = thisField1(1:(strfind(thisField1, 'Ca')-1));
field2Base = thisField2(1:(strfind(thisField2, 'Ca')-1));
handles.field1Base = field1Base;
handles.field2Base = field2Base;

% try
%     field1roiHistName = [field1Base 'RoiHist'];
%     handles.roiHist1 = dataStruc.(field1roiHistName);
%     
%     field2roiHistName = [field2Base 'RoiHist'];
%     handles.roiHist2 = dataStruc.(field2roiHistName);
% catch
% end

% 072214

dendriteBehavStruc = handles.dendriteBehavStruc;
handles.frDataField1 = dendriteBehavStruc.(thisField1);
handles.frDataField2 = dendriteBehavStruc.(thisField2);


% Update handles structure
guidata(hObject, handles);

%
plotCaData(hObject, handles);

%
try
    plotRoiHist(hObject, handles);
catch
end

%
%try
    plotWhiskData(hObject, handles);
%catch
    %display('Cannot plot whisking data');
%end

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% --- Executes on slider movement.
function segNumSlider_Callback(hObject, eventdata, handles)
% hObject    handle to segNumSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

segNum = get(hObject, 'Value');
segNum = round(segNum);
handles.segNum = segNum;

set(handles.text4, 'String', segNum);

caData1 = handles.caData1;
caData2 = handles.caData2;

% Update handles structure
guidata(hObject, handles);



plotFactorTemporal(hObject, handles);

% roiHist
try
    plotRoiHist(hObject, handles);
catch
end

%
try
    plotWhiskData(hObject, handles);
catch
end

% try 
    plotWhiskXcorr(hObject, handles);
% catch
%     disp('Cant plot whiskXcorr data');
% end

%
plotCaData(hObject, handles);


% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function segNumSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to segNumSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


%% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1

% for plotting averages

checkbox1state = get(hObject,'Value');

if isempty(checkbox1state)
    checkbox1state = 0;
end

handles.checkbox1state = checkbox1state;

% Update handles structure
guidata(hObject, handles);

plotCaData(hObject, handles);


%% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2

% for plotting all traces

checkbox2state = get(hObject,'Value');

if isempty(checkbox2state)
    checkbox2state = 0;
end

handles.checkbox2state = checkbox2state;

% Update handles structure
guidata(hObject, handles);

plotCaData(hObject, handles);


%% --- Executes on slider movement.
function trialSlider_Callback(hObject, eventdata, handles)
% hObject    handle to trialSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

trialNumCheckboxState = handles.trialNumCheckboxState;

trialSliderVal = 1;

if trialNumCheckboxState == 1
    
    trialSliderVal = get(hObject, 'Value');
    
    caData1 = handles.caData1;
    caData2 = handles.caData2;
    segNum = handles.segNum;
    %eventHistBehavStruc = handles.eventHistBehavStruc;
    field1Base = handles.field1Base;
    field2Base = handles.field2Base;
    
%     eventFieldName1 = [field1Base 'EventBin'];
%     eventFieldName2 = [field2Base 'EventBin'];
%     
%     event1 = eventHistBehavStruc.(eventFieldName1);
%     event2 = eventHistBehavStruc.(eventFieldName2);
%     
%     trialEvent1 = event1(:,trialSliderVal);
%     binSize = 100;
%     numBins = floor(length(trialEvent1)/binSize);
%     for bin = 1:numBins
%         trialEvent1av(bin) = sum(trialEvent1(((bin-1)*binSize+1):(bin*binSize)));
%         
%     end
%     
%     axes(handles.axes5);
%     %bar(trialEvent1);
%     plot(trialEvent1av); ylabel('whisker contacts');
    
    trialCaData1 = caData1(:,segNum,trialSliderVal);
    
    axes(handles.axes4);
    plot(trialCaData1, 'b'); xlim([1 33]); ylim([-0.1 0.5]); hold on;
    plot(handles.frDataField1(:,trialSliderVal), 'g');
    
    try
        %trialEvent2 = event2(:,trialSliderVal);
        trialCaData2 = caData2(:,segNum,trialSliderVal);
        plot(trialCaData2, 'r');
        plot(handles.frDataField2(:,trialSliderVal), 'm');
        hold off;
    catch
        hold off;
    end
    
    handles.trialSliderVal = trialSliderVal;

plotWhiskData(hObject, handles);
    
end

set(handles.text6, 'String', trialSliderVal);

% handles.trialSliderVal = trialSliderVal;
% 
% plotWhiskData(hObject, handles);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function trialSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trialSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


%% --- Executes on button press in trialNumCheckbox.
function trialNumCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to trialNumCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

trialNumCheckboxState = get(hObject, 'Value');

handles.trialNumCheckboxState = trialNumCheckboxState;

if trialNumCheckboxState == 0
    %
    try
        plotWhiskData(hObject, handles);
    catch
    end
    
    % roiHist
    try
        plotRoiHist(hObject, handles);
    catch
    end
    
end

guidata(hObject, handles);


%% plotting functions
function plotRoiHist(hObject, handles)

trialNumCheckboxState = handles.trialNumCheckboxState;

if trialNumCheckboxState == 0
    
    % roiHist
    roiHist1 = handles.roiHist1;
    roiHist2 = handles.roiHist2;
    
    segNum = handles.segNum;
    
    C = handles.C;
    roiPkIndCell = handles.roiPkIndCell;
    caData1 = handles.caData1;
    caData2 = handles.caData2;
    
    numTrials1 = size(caData1,3);
    numTrials2 = size(caData2,3);
    
    avRate = length(roiPkIndCell{segNum})/length(C(:,segNum));
    
    x = -8:24;
    %x = x(2:end);
    width1 = 1;
    width2 = 2*width1/3;
    
    axes(handles.axes4);
    bar(x, roiHist1(:,segNum)/numTrials1, width1, 'FaceColor', 'b'); xlim([-8.5 24.5]);
    hold on;
    bar(x, roiHist2(:,segNum)/numTrials2, width2, 'FaceColor', 'r');
    line([-8 24], [avRate avRate], 'Color', 'y');
    ylabel('ca events/frame/trial');
    hold off;
    
    %     axes(handles.axes4);
    %     bar(x, roiHist1(:,segNum), width1, 'FaceColor', 'b'); xlim([-8.5 24.5]);
    %     hold on;
    %     bar(x, roiHist2(:,segNum), width2, 'FaceColor', 'r');
    %     ylabel('ca events/frame/trial');
    %     hold off;
    
end

%%
function plotFactorTemporal(hObject, handles)

segNum = handles.segNum;

C = handles.C;

t = 1:size(C,1);

Cseg = C(:,segNum);


axes(handles.factorTemporal);
plot(handles.factorTemporal, Cseg, 'b');

try
    roiPkIndCell = handles.roiPkIndCell;
    roiPkInd = roiPkIndCell{segNum};
    hold on; plot(t(roiPkInd), Cseg(roiPkInd), 'r.'); hold off;
catch
end

set(handles.factorTemporal, 'Color', [1,1,1]); %hold off;
%axes(handles.factorTemporal);
xlim([1 size(C,1)]);
%whitebg;

handSeg = handles.handSeg;

if handSeg == 0
    A = handles.A;
    d1 = handles.d1;
    d2 = handles.d2;
    
    A2 = reshape(A(segNum,:),d1,d2);
    axes(handles.factorSpatial);
    imagesc(A2); %axis equal; axis tight;
else
    tifAvg = handles.tifAvg;
    axes(handles.factorSpatial);
    imagesc(tifAvg);
end

%%
function plotCaData(hObject, handles)

segNum = handles.segNum;
caData1 = handles.caData1;
caData2 = handles.caData2;

caData1b = squeeze(caData1(:,segNum, :));
caData2b = squeeze(caData2(:,segNum, :));

% 072214 also for frame avg
frDataField1 = handles.frDataField1;
frDataField2 = handles.frDataField2;

try
    sem1 = std(caData1b,0,2)/sqrt(size(caData1b,2));
    semf1 = std(frDataField1,0,2)/sqrt(size(frDataField1,2));
catch
end

try
    sem2 = std(caData2b,0,2)/sqrt(size(caData2b,2));
    semf2 = std(frDataField2,0,2)/sqrt(size(frDataField2,2));
catch
end

set(hObject,'BackgroundColor','white');

%set(handles.behavCaPlot,'BackgroundColor','black');

% %figure;
% plot(handles.behavCaPlot, caData1(:,segNum), 'b'); % ylim([-0.05 0.3]);
% hold(handles.behavCaPlot);
% plot(handles.behavCaPlot, caData2(:,segNum), 'r');

% hz = 4;
if size(caData1b,1) == 33
    hz = 4;
elseif size(caData1b, 1) == 65
    hz = 8;
elseif size(caData1b, 1) == 17
    hz = 2;
end

xAx = linspace(-2,6,8*hz+1);

% try
checkbox1state = handles.checkbox1state;
% catch
%     checkbox1state = 0;
% end
%
% try
checkbox2state = handles.checkbox2state;
% catch
%     checkbox2state = 0;
% end

% and plot Ca signals (with SEM)
axes(handles.behavCaPlot);
if checkbox2state == 1
    plot(handles.behavCaPlot, xAx, caData1b, 'b'); % xlim([-2 6]);
    %hold on;
    hold(handles.behavCaPlot);
    plot(handles.behavCaPlot, xAx, caData2b, 'r');
    
end

xlim([-2 6]);
xlabel(handles.behavCaPlot,'sec (from event)');
ylabel(handles.behavCaPlot,'dF/F');


if checkbox1state == 1
    scale = 2;
    try
        errorbar(handles.behavCaPlot, xAx, scale*mean(caData1b,2), scale*sem1, 'c');
        hold on;
        errorbar(handles.behavCaPlot, xAx, scale*mean(frDataField1,2), scale*semf1, 'g');
    catch
    end
    try
        errorbar(handles.behavCaPlot, xAx, scale*mean(caData2b,2), scale*sem2, 'y');
        errorbar(handles.behavCaPlot, xAx, scale*mean(frDataField2,2), scale*semf2, 'm');
    catch
    end
    hold off;
end

% and put lines on for start/stop of event epoch (3s window)
axes(handles.behavCaPlot); %hold on;
line([0 0],[-0.05 0.2], 'Color', 'g');
line([3 3],[-0.05 0.2], 'Color', 'r');
xlim([-2 6]);

% legend(handles.behavCaPlot, thisField1, thisField2);

%%
function plotWhiskData(hObject, handles)

% try
trialNumCheckboxState = handles.trialNumCheckboxState;
whiskCheckboxState = handles.whiskCheckboxState;
field1Base = handles.field1Base;
field2Base = handles.field2Base;
dendriteBehavStruc = handles.dendriteBehavStruc;
whiskSig = handles.whiskSig;
frTimes = handles.whiskFrTimes;
whiskAngle = handles.whiskAngle;

lickSig = handles.lickSig;
levSig = handles.levSig;
rewSig = handles.rewSig;

frameTrig = dendriteBehavStruc.eventStruc.frameTrig;

% so I think these are zeroFrames for the events
field1FrInds = dendriteBehavStruc.([field1Base 'FrInds']);
field2FrInds = dendriteBehavStruc.([field2Base 'FrInds']);

% and just find the times (in ms) for the zero frames for these events
field1ZeroTimes = frameTrig(field1FrInds);
field2ZeroTimes = frameTrig(field2FrInds);


for i = 1:length(field1ZeroTimes)
field1StartWhiskFrames(i) = find(frTimes>=(frameTrig(field1FrInds(i)-8)), 1);
field1EndWhiskFrames(i) = find(frTimes<=(frameTrig(field1FrInds(i)+24)), 1, 'last');
end

for i = 1:length(field2ZeroTimes)
field2StartWhiskFrames(i) = find(frTimes>(frameTrig(field1FrInds(i)-8)), 1);
field2EndWhiskFrames(i) = find(frTimes<(frameTrig(field1FrInds(i)+24)), 1, 'last');
end


%if trialNumCheckboxState == 0    
    % now extract appropriate whisker signals for these events
    % (BUT must first go back and load in whole dendBehavStruc for ca
    % frInds/times)
    
    if whiskCheckboxState == 1
        eventStart = field1StartWhiskFrames;
        eventEnd = field1EndWhiskFrames;
    else
        eventStart = field2StartWhiskFrames;
        eventEnd = field2EndWhiskFrames;
    end
    
    for i = 1:length(eventStart)
        eventWhiskAngleTrial = -whiskAngle(eventStart(i):eventEnd(i));
        eventWhiskAngle(:,i) = interp1(frTimes(eventStart(i):eventEnd(i)), eventWhiskAngleTrial, round(linspace(frTimes(eventStart(i)),frTimes(eventEnd(i)), 8000)));
    end
    
    %eventWhiskAngle = eventWhiskAngle -mean(eventWhiskAngle,1);
    
    %display(dim(eventWhiskAngle));
    meanWhiskAngle = mean(eventWhiskAngle,2);
    %meanWhiskAngle = meanWhiskAngle - mean(meanWhiskAngle,0,1);
    
    if trialNumCheckboxState == 0
    axes(handles.axes5);
    %ylim([-100 100]);
    plot(handles.axes5, 1:8000, meanWhiskAngle);

    elseif trialNumCheckboxState == 1
        trialSliderVal = handles.trialSliderVal;
        preTrialMs = field1ZeroTimes(trialSliderVal)-2000;
        postTrialMs = field1ZeroTimes(trialSliderVal)+5999;
        whiskSigTrial = whiskSig(preTrialMs:postTrialMs);
        whiskSigTrialEpoch = whiskSig((field1ZeroTimes(trialSliderVal)+500:field1ZeroTimes(trialSliderVal)+3000));
        %whiskSigTrial = whiskAngle(eventStart(trialSliderVal):eventEnd(trialSliderVal));
        whiskSigTrial = (whiskSigTrial-mean(whiskSigTrialEpoch))/max(whiskSigTrialEpoch);
        lickSigTrial = lickSig(preTrialMs:postTrialMs);
        levSigTrial = levSig(preTrialMs:postTrialMs);
        rewSigTrial = rewSig(preTrialMs:postTrialMs);
        axes(handles.axes5);
        plot(handles.axes5, preTrialMs:postTrialMs, whiskSigTrial, 'r');
        hold(handles.axes5); 
        plot(handles.axes5, preTrialMs:postTrialMs, lickSigTrial, 'm');
        plot(handles.axes5, preTrialMs:postTrialMs, levSigTrial, 'c');
        plot(handles.axes5, preTrialMs:postTrialMs, rewSigTrial, 'g');
        
        whiskAngleTrial = whiskAngle(eventStart(trialSliderVal):eventEnd(trialSliderVal));
        whiskAngleTrial = (whiskAngleTrial-mean(whiskAngleTrial))/max(whiskAngleTrial);
        plot(handles.axes5, frTimes(field1StartWhiskFrames(trialSliderVal):field1EndWhiskFrames(trialSliderVal)), whiskAngleTrial);
        ylim([-0.5 1.5]);
        xlim([preTrialMs postTrialMs]);
        hold off; 
        display('Plotting trial whisker angle data');
        

        
    end
        ylabel('meanWhiskerAngle');
    display('Plotting whisker data');
    
%end
% catch
%     disp('No whiskerDataStruc');
% end


% --- Executes on button press in loadGoodSegButton.
function loadGoodSegButton_Callback(hObject, eventdata, handles)

[filename, pathname] = uigetfile('.mat', 'Select a goodSeg file');
cd(pathname);
load(filename);

tifBasename = handles.filename(1:14);
segNameInd = strfind(filename, 'Seg');
middleGoodSegTag = filename((segNameInd+4):(end-16));
goodSegFileDateTag = filename((end-14):(end-4));

% load in okSeg/greatSeg if they exist
try
    load([tifBasename '_okSeg_' middleGoodSegTag '_' goodSegFileDateTag '.mat']);
catch
    okSeg = [];
end

try
    load([tifBasename '_greatSeg_' middleGoodSegTag '_' goodSegFileDateTag '.mat']);
catch
    greatSeg = [];
end

set(handles.goodSegNameTxt, 'String', filename);
set(handles.goodSegTxt, 'String', num2str(goodSeg));
set(handles.okSegTxt, 'String', num2str(okSeg));
set(handles.greatSegTxt, 'String', num2str(greatSeg));

handles.goodSeg = goodSeg;
handles.okSeg = okSeg;
handles.greatSeg = greatSeg;

segStruc = handles.segStruc;

try
    ca2 = sortUnitsByTime(segStruc, goodSeg, 0,0,1,0); %sortEvent, plotEvent, toNorm)
    disp('Plotting heatmap');
    axes(handles.goodSegHeatmap);
    imagesc(ca2);
catch
    disp('Cant plot units by time');
end

try
    disp('Plotting unitScatter');
    event = 'rewStimStimIndCa';
    axes(handles.goodSegScatter);
    plotGoodSegEpochScatter(segStruc, goodSeg, event, 0);
    xlim([0 0.2]);
    ylim([0 0.2]);
catch
    disp('Cant plot unit scatter');
end

guidata(hObject, handles);


% --- Executes on button press in saveGoodSegButton.
function saveGoodSegButton_Callback(hObject, eventdata, handles)

okSeg = handles.okSeg;
goodSeg = handles.goodSeg;
greatSeg = handles.greatSeg;
filename = handles.filename;

segDate = handles.segDate;
goodSegTag = handles.goodSegTag;

save([filename(1:14) '_okSeg_' goodSegTag '_' segDate], 'okSeg');
save([filename(1:14) '_goodSeg_' goodSegTag '_' segDate], 'goodSeg');
save([filename(1:14) '_greatSeg_' goodSegTag '_' segDate], 'greatSeg');

handles.okSeg = [];
handles.goodSeg = [];
handles.greatSeg = [];

set(handles.okSegTxt, 'String', num2str(handles.okSeg));
set(handles.goodSegTxt, 'String', num2str(handles.goodSeg));
set(handles.greatSegTxt, 'String', num2str(handles.greatSeg));

guidata(hObject, handles);



%% add tag to good/greatSeg filenames to save
function goodSegTagTxt_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of goodSegTagTxt as text
%        str2double(get(hObject,'String')) returns contents of goodSegTagTxt as a double

handles.goodSegTag = get(hObject, 'String');

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function goodSegTagTxt_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% ADD/REMOVE current factor to GOODSEG/GREATSEG

% --- Executes on button press in addGoodSegButton.
function addGoodSegButton_Callback(hObject, eventdata, handles)

goodSeg = handles.goodSeg;
okSeg = handles.okSeg;
segNum = handles.segNum;

goodSeg = sort(unique([segNum goodSeg]));
set(handles.goodSegTxt, 'String', num2str(goodSeg));
handles.goodSeg = goodSeg;

% add this to greatSeg
okSeg = sort(unique([segNum okSeg]));
set(handles.okSegTxt, 'String', num2str(okSeg));
handles.okSeg = okSeg;


segStruc = handles.segStruc;

try
    ca2 = sortUnitsByTime(segStruc, goodSeg, 0,0,1,0); %sortEvent, plotEvent, toNorm)
    disp('Plotting heatmap');
    axes(handles.goodSegHeatmap);
    imagesc(ca2);
catch
    disp('Cant plot units by time');
end

try
    disp('Plotting unitScatter');
    event = 'rewStimStimIndCa';
    axes(handles.goodSegScatter);
    plotGoodSegEpochScatter(segStruc, goodSeg, event, 0);
    xlim([0 0.2]);
    ylim([0 0.2]);
catch
    disp('Cant plot unit scatter');
end

guidata(hObject, handles);

% --- Executes on button press in remGoodSegButton.
function remGoodSegButton_Callback(hObject, eventdata, handles)

goodSeg = handles.goodSeg;
greatSeg = handles.greatSeg;
segNum = handles.segNum;

% remove this segNum from goodSeg
goodSeg = goodSeg(goodSeg~=segNum);
set(handles.goodSegTxt, 'String', num2str(goodSeg));
handles.goodSeg = goodSeg;

% and also remove this from greatSeg array
greatSeg = greatSeg(greatSeg~=segNum);
set(handles.greatSegTxt, 'String', num2str(greatSeg));
handles.greatSeg = greatSeg;

guidata(hObject, handles);

% --- Executes on button press in addGreatSegButton.
function addGreatSegButton_Callback(hObject, eventdata, handles)


greatSeg = handles.greatSeg;
goodSeg = handles.goodSeg;
okSeg = handles.okSeg;
segNum = handles.segNum;

% add this to greatSeg
greatSeg = sort(unique([segNum greatSeg]));
set(handles.greatSegTxt, 'String', num2str(greatSeg));
handles.greatSeg = greatSeg;

% also add to goodSeg (if it's not already there)
goodSeg = sort(unique([segNum goodSeg]));
set(handles.goodSegTxt, 'String', num2str(goodSeg));
handles.goodSeg = goodSeg;

% add this to greatSeg
okSeg = sort(unique([segNum okSeg]));
set(handles.okSegTxt, 'String', num2str(okSeg));
handles.okSeg = okSeg;

guidata(hObject, handles);


% --- Executes on button press in remGreatSegButton.
function remGreatSegButton_Callback(hObject, eventdata, handles)

greatSeg = handles.greatSeg;
segNum = handles.segNum;

% remove this from greatSeg array
greatSeg = greatSeg(greatSeg~=segNum);
set(handles.greatSegTxt, 'String', num2str(greatSeg));
handles.greatSeg = greatSeg;

guidata(hObject, handles);


% Clear goodSeg/greatSeg button
% --- Executes on button press in clearGoodSegButton.
function clearGoodSegButton_Callback(hObject, eventdata, handles)

handles.okSeg = [];
handles.goodSeg = [];
handles.greatSeg = [];

set(handles.okSegTxt, 'String', num2str(handles.okSeg));
set(handles.goodSegTxt, 'String', num2str(handles.goodSeg));
set(handles.greatSegTxt, 'String', num2str(handles.greatSeg));

guidata(hObject, handles);


% --- Executes on button press in addOkSegButton.
function addOkSegButton_Callback(hObject, eventdata, handles)

okSeg = handles.okSeg;
segNum = handles.segNum;

% add this to greatSeg
okSeg = sort(unique([segNum okSeg]));
set(handles.okSegTxt, 'String', num2str(okSeg));
handles.okSeg = okSeg;

guidata(hObject, handles);


% --- Executes on button press in remOkSegButton.
function remOkSegButton_Callback(hObject, eventdata, handles)

okSeg = handles.okSeg;
goodSeg = handles.goodSeg;
greatSeg = handles.greatSeg;
segNum = handles.segNum;

% remove this segNum from goodSeg
okSeg = okSeg(okSeg~=segNum);
set(handles.okSegTxt, 'String', num2str(okSeg));
handles.okSeg = okSeg;

% remove this segNum from goodSeg
goodSeg = goodSeg(goodSeg~=segNum);
set(handles.goodSegTxt, 'String', num2str(goodSeg));
handles.goodSeg = goodSeg;

% and also remove this from greatSeg array
greatSeg = greatSeg(greatSeg~=segNum);
set(handles.greatSegTxt, 'String', num2str(greatSeg));
handles.greatSeg = greatSeg;

guidata(hObject, handles);


% --- Executes on button press in whiskDataCheckbox.
function whiskDataCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to whiskDataCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.whiskCheckboxState = get(hObject,'Value');

try
plotWhiskData(hObject, handles);
catch
    disp('Problem plotting whisking data');
end

guidata(hObject, handles);


%%

function plotWhiskXcorr(hObject, handles)

try        
dendriteBehavStruc = handles.dendriteBehavStruc;
whiskDataStruc = handles.whiskDataStruc;
segNum = handles.segNum;

frameAvgDf = dendriteBehavStruc.frameAvgDf;
segCa = handles.segStruc.C(:,segNum);

frameTrig = dendriteBehavStruc.eventStruc.frameTrig;


whiskerData = -whiskDataStruc.meanAngle(1:end-1); % = whiskDataStruc.medianAngle;
% NOTE: inverting this because protractions are negative-going from these
% PS3eye movies
frTimes = whiskDataStruc.frTimes;

% only take whisking var from same period as frameAvgDf
whiskerData = whiskerData(find(frTimes>=frameTrig(1) & frTimes <= frameTrig(end)));
frTimes = frTimes(find(frTimes>=frameTrig(1) & frTimes <= frameTrig(end)));

% interp frameAvgDf to whisker imaging frame times
cax = interp1(frameTrig, frameAvgDf, frTimes);
frCaXc = xcorr(cax, whiskerData', 1000, 'coeff');

% interp segCa to whisker imaging frame times
cax = interp1(frameTrig, segCa, frTimes);
segCaXc = xcorr(cax, whiskerData', 1000, 'coeff');

axes(handles.unitWhiskXcorr);
plot((frCaXc-mean(frCaXc))/mean(frCaXc)); hold on; 
plot(100*(segCaXc-mean(segCaXc))/mean(segCaXc), 'g'); hold off;

catch
    disp('Cant plot whiskUnitXcorr');
end
