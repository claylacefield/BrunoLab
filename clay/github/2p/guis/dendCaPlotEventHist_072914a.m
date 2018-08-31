function varargout = dendCaPlotEventHist_072914a(varargin)
% DENDCAPLOTEVENTHIST_072914A MATLAB code for dendCaPlotEventHist_072914a.fig
%      DENDCAPLOTEVENTHIST_072914A, by itself, creates a new DENDCAPLOTEVENTHIST_072914A or raises the existing
%      singleton*.
%
%      H = DENDCAPLOTEVENTHIST_072914A returns the handle to a new DENDCAPLOTEVENTHIST_072914A or the handle to
%      the existing singleton*.
%
%      DENDCAPLOTEVENTHIST_072914A('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DENDCAPLOTEVENTHIST_072914A.M with the given input arguments.
%
%      DENDCAPLOTEVENTHIST_072914A('Property','Value',...) creates a new DENDCAPLOTEVENTHIST_072914A or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dendCaPlotEventHist_072914a_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dendCaPlotEventHist_072914a_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dendCaPlotEventHist_072914a

% Last Modified by GUIDE v2.5 29-Jul-2014 21:59:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dendCaPlotEventHist_072914a_OpeningFcn, ...
                   'gui_OutputFcn',  @dendCaPlotEventHist_072914a_OutputFcn, ...
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


% --- Executes just before dendCaPlotEventHist_072914a is made visible.
function dendCaPlotEventHist_072914a_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dendCaPlotEventHist_072914a (see VARARGIN)

% Choose default command line output for dendCaPlotEventHist_072914a
handles.output = hObject;


handles.checkbox1state = 0;
handles.checkbox2state = 0;
handles.checkbox3state = 0;
handles.checkbox4state = 0;

handles.segNum = 1;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dendCaPlotEventHist_072914a wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = dendCaPlotEventHist_072914a_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
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

try
field1roiHistName = [field1Base 'RoiHist'];
handles.roiHist1 = dataStruc.(field1roiHistName);

field2roiHistName = [field2Base 'RoiHist'];
handles.roiHist2 = dataStruc.(field2roiHistName);
catch
end

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
try
plotEventHist(hObject, handles);
catch
end

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



% --- Executes on button press in pushbutton1.
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

% need to find fields in calcium data structure
fieldNames = fieldnames(caDataStruc);
% fieldNames = fieldNames(2:length(fieldNames));  % cut out eventStruc

caFields = strfind(fieldNames, 'Ca');
caFieldInd = find(not(cellfun('isempty', caFields)));
fieldNames = fieldNames(caFieldInd);

handles.fieldNames = fieldNames;


% and make them "string" properties in listbox1
set(handles.listbox1,'String',fieldNames);
% set(handles.listbox1,'Value',1:length(fieldNames));

set(handles.text3, 'String', filename);

% also get the eventHist information

currDir = dir;
evFileNum = 0;
dendStrucNum = 0;

for numFile = 1:length(currDir)
    
    % look for eventHist (may be caps or not) and make list of indices in currDir
   if ~isempty(strfind(currDir(numFile).name, 'ventHist'))
       evFileNum = evFileNum + 1;
       eventStrucNum(evFileNum) = numFile;
   end
   
   if ~isempty(strfind(currDir(numFile).name, 'dendriteBehavStruc')) %&& firstFile2 == 0
       dendStrucNum = dendStrucNum + 1;
       dendBehavStrucNum(dendStrucNum) = numFile;
   end
    
end

% 072414 now find most recent cognate eventHist files and load in
[newestEvDatenum, newestEvInd] = max([currDir(eventStrucNum).datenum]);

inStruc = load(currDir(eventStrucNum(newestEvInd)).name);
fieldNamesEvSt = fieldnames(inStruc);
eventHistBehavStruc = inStruc.(fieldNamesEvSt{1});

clear eventStrucNum newestEvInd fieldNamesEvSt inStruc;

try
[newestDendDatenum, newestDendInd] = max([currDir(dendBehavStrucNum).datenum]);

inStruc = load(currDir(dendBehavStrucNum(newestDendInd)).name);
fieldNamesEvSt = fieldnames(inStruc);
dendriteBehavStruc = inStruc.(fieldNamesEvSt{1});

clear dendBehavStrucNum newestDendInd fieldNamesEvSt inStruc;
catch
    disp('Problem getting dendriteBehavStruc for performance graph');
end

try
% and calculate discrimination index
correctRespStruc = dendriteBehavStruc.eventStruc.correctRespStruc;
corrRespArr = correctRespStruc.corrRespArr;

minBin = 1;
[binFracCorrect] = binErrorRates(correctRespStruc);

axes(handles.axes6);
bar(binFracCorrect); 
xlim([0.5 length(binFracCorrect)+0.5]);
ylim([0 1]); hold on; 
line([0.5 length(binFracCorrect)+0.5], [0.5 0.5], 'Color', 'r');
catch
end

try
handles.eventHistBehavStruc = eventHistBehavStruc;
catch
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in checkbox1.
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


% --- Executes on button press in checkbox2.
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


% --- Executes on slider movement.
function trialSlider_Callback(hObject, eventdata, handles)
% hObject    handle to trialSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

checkbox3state = handles.checkbox3state; 

trialSliderVal = 1;

if checkbox3state == 1
    
    trialSliderVal = get(hObject, 'Value');
    
    caData1 = handles.caData1;
    caData2 = handles.caData2;
    
    eventHistBehavStruc = handles.eventHistBehavStruc;
    field1Base = handles.field1Base;
    field2Base = handles.field2Base;
    
    eventFieldName1 = [field1Base 'EventBin'];
    eventFieldName2 = [field2Base 'EventBin'];
    
    event1 = eventHistBehavStruc.(eventFieldName1);
    event2 = eventHistBehavStruc.(eventFieldName2);
    
    try
    trialEvent1 = event1(:,trialSliderVal);
    trialCaData1 = caData1(:,trialSliderVal);
    catch
    end
    
    try
    trialEvent2 = event2(:,trialSliderVal);
    trialCaData2 = caData2(:,trialSliderVal);
    catch
    end
    
    axes(handles.axes5);
    bar(trialEvent1);
    
    axes(handles.axes4);
    plot(trialCaData1); xlim([1 33]); ylim([-0.1 max(caData1)]);
    
    
end

set(handles.text6, 'String', trialSliderVal);

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


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

checkbox3state = get(hObject, 'Value');

handles.checkbox3state = checkbox3state;

if checkbox3state == 0
    %
    try
        plotEventHist(hObject, handles);
    catch
    end
    
    % roiHist
%     try
%         plotRoiHist(hObject, handles);
%     catch
%     end
    
end

guidata(hObject, handles);


%% plotting functions
% function plotRoiHist(hObject, handles)
% 
% checkbox3state = handles.checkbox3state;
% 
% if checkbox3state == 0
%     
%     % roiHist
%     roiHist1 = handles.roiHist1;
%     roiHist2 = handles.roiHist2;
%    
%     
%     x = -8:24;
%     %x = x(2:end);
%     width1 = 1;
%     width2 = 2*width1/3;
%     
%     axes(handles.axes4);
%     bar(x, roiHist1(:,segNum), width1, 'FaceColor', 'b'); xlim([-8.5 24.5]);
%     hold on;
%     bar(x, roiHist2(:,segNum), width2, 'FaceColor', 'r');
%     hold off;
%     
% end


%%
function plotCaData(hObject, handles)

% segNum = handles.segNum;
caData1b = handles.caData1;
caData2b = handles.caData2;

% caData1b = squeeze(caData1(:,segNum, :));
% caData2b = squeeze(caData2(:,segNum, :));

try
sem1 = nanstd(caData1b,0,2)/sqrt(size(caData1b,2));
catch
end

try
sem2 = nanstd(caData2b,0,2)/sqrt(size(caData2b,2));
catch
end

set(hObject,'BackgroundColor','white');

% %figure;
% plot(handles.behavCaPlot, caData1(:,segNum), 'b'); % ylim([-0.05 0.3]);
% hold(handles.behavCaPlot);
% plot(handles.behavCaPlot, caData2(:,segNum), 'r');

hz = 4;
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
checkbox4state = handles.checkbox4state;

% and plot Ca signals (with SEM)
axes(handles.behavCaPlot);
if checkbox2state == 1
    plot(handles.behavCaPlot, xAx, caData1b, 'c'); % xlim([-2 6]);
    %hold on;
    hold(handles.behavCaPlot);
    plot(handles.behavCaPlot, xAx, caData2b, 'm');
end

xlim([-2 6]);
xlabel(handles.behavCaPlot,'sec (from event)'); 
ylabel(handles.behavCaPlot,'dF/F');

scaleAv = 1;


thisField1 = handles.field1;
thisField2 = handles.field2;

if checkbox1state == 1
    try
        errorbar(handles.behavCaPlot, xAx, scaleAv*nanmean(caData1b,2), scaleAv*sem1, 'b');
        hold on;
    catch
    end
    try
        errorbar(handles.behavCaPlot, xAx, scaleAv*nanmean(caData2b,2), scaleAv*sem2, 'r');
    catch
    end
    
    legend(thisField1, thisField2);
    
    hold off;
end

% and put lines on for start/stop of event epoch (3s window)
axes(handles.behavCaPlot); %hold on;
currYlim = get(gca, 'YLim');
line([0 0],currYlim, 'Color', 'g');
line([3 3],currYlim, 'Color', 'r'); % [currYlim(1) currYlim(2)]
xlim([-2 6]);
set(handles.behavCaPlot, 'Color', [1,1,1]); %hold off;
xlabel('sec'); ylabel('dF/F');

% legend(handles.behavCaPlot, thisField1, thisField2);

% now plot peaks for these events
caPeakVal1 = [];
caPeakVal2 = [];

for animal = 1:size(caData1b, 2)
   [C, I] = max(caData1b(8:16,animal));
   caPeakVal1(animal) = C-nanmean(caData1b(4:6, animal));
   caPeakInd1(animal) = I+7;
end

for animal = 1:size(caData2b, 2)
   [C, I] = max(caData2b(8:16,animal));
   caPeakVal2(animal) = C-nanmean(caData2b(4:6, animal));
   caPeakInd2(animal) = I+7;
end

handles.caPeakVal1 = caPeakVal1;
handles.caPeakInd1 = caPeakInd1;
handles.caPeakVal2 = caPeakVal2;
handles.caPeakInd2 = caPeakInd2;

if checkbox4state == 1
    axes(handles.axes4);
    plot(caPeakVal1, caPeakVal2, 'b.'); hold on;
    xlabel(thisField1); ylabel(thisField2);
    line([-0.05 0.3], [-0.05 0.3], 'Color', 'k');
    set(handles.axes4, 'Color', [1,1,1]); %hold off;
    hold off;
    
else
    axes(handles.axes4);
    plot(caPeakVal1, 'b.'); hold on;
    plot(caPeakVal2, 'r.');
    %legend(thisField1, thisField2);
    xlabel('animal OR session'); ylabel('peak dF/F');
    set(handles.axes4, 'Color', [1,1,1]); %hold off;
    hold off;
end

%%
function plotEventHist(hObject, handles)

checkbox3state = handles.checkbox3state;
field1Base = handles.field1Base;
field2Base = handles.field2Base;

if checkbox3state == 0
    
    % and extract event histograms for these fields
%     try
        eventHistBehavStruc = handles.eventHistBehavStruc;
        
        eventFieldName1 = [field1Base 'EventHist'];
        eventFieldName2 = [field2Base 'EventHist'];
        
        eventHist1 = eventHistBehavStruc.(eventFieldName1);
        eventHist2 = eventHistBehavStruc.(eventFieldName2);
        
        if size(eventHist1, 2)>1
            eventHist1 = nanmean(eventHist1, 2);
            eventHist2 = nanmean(eventHist2, 2);
        end
        
        binSize = 100;
        
        eventHist1 = histBin(eventHist1, binSize);
        eventHist2 = histBin(eventHist2, binSize);
        
        x = 1:80;
        width1 = 1;
        width2 = 1*width1/2;
        
        axes(handles.axes5);
        bar(x, eventHist1/max(eventHist1), width1, 'FaceColor', 'b'); xlim([1 80]); hold on;
        bar(x, eventHist2/max(eventHist2), width2, 'FaceColor', 'r');
        legend(eventFieldName1, eventFieldName2);
        ylabel('whisker contacts');
        hold off;
%     catch
%     end
    
end

set(handles.axes5, 'Color', [1,1,1]); %hold off;


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4
checkbox4state = get(hObject, 'Value');

handles.checkbox4state = checkbox4state;

guidata(hObject, handles);

plotCaData(hObject, handles);
