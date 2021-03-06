function varargout = segDendCaPlotHistAll_061114b(varargin)
% SEGDENDCAPLOTHISTALL_061114B MATLAB code for segDendCaPlotHistAll_061114b.fig
%      SEGDENDCAPLOTHISTALL_061114B, by itself, creates a new SEGDENDCAPLOTHISTALL_061114B or raises the existing
%      singleton*.
%
%      H = SEGDENDCAPLOTHISTALL_061114B returns the handle to a new SEGDENDCAPLOTHISTALL_061114B or the handle to
%      the existing singleton*.
%
%      SEGDENDCAPLOTHISTALL_061114B('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEGDENDCAPLOTHISTALL_061114B.M with the given input arguments.
%
%      SEGDENDCAPLOTHISTALL_061114B('Property','Value',...) creates a new SEGDENDCAPLOTHISTALL_061114B or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before segDendCaPlotHistAll_061114b_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to segDendCaPlotHistAll_061114b_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help segDendCaPlotHistAll_061114b

% Last Modified by GUIDE v2.5 11-Jun-2014 17:28:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @segDendCaPlotHistAll_061114b_OpeningFcn, ...
                   'gui_OutputFcn',  @segDendCaPlotHistAll_061114b_OutputFcn, ...
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


% --- Executes just before segDendCaPlotHistAll_061114b is made visible.
function segDendCaPlotHistAll_061114b_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to segDendCaPlotHistAll_061114b (see VARARGIN)

% Choose default command line output for segDendCaPlotHistAll_061114b
handles.output = hObject;


handles.checkbox1state = 0;
handles.checkbox2state = 0;


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes segDendCaPlotHistAll_061114b wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = segDendCaPlotHistAll_061114b_OutputFcn(hObject, eventdata, handles) 
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
handles.caData1 = caData1;
handles.caData2 = caData2;

% now also extract out RoiPkHist, if present

field1Base = thisField1(1:(strfind(thisField1, 'Ca')-1));
field1roiHistName = [field1Base 'RoiHist'];
handles.roiHist1 = dataStruc.(field1roiHistName);
handles.field1Base = field1Base;

field2Base = thisField2(1:(strfind(thisField2, 'Ca')-1));
field2roiHistName = [field2Base 'RoiHist'];
handles.roiHist2 = dataStruc.(field2roiHistName);
handles.field2Base = field2Base;



% Update handles structure
guidata(hObject, handles);

%
plotCaData(hObject, handles);

% 
plotRoiHist(hObject, handles);

%
plotEventHist(hObject, handles);

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

handles.K = caDataStruc.K;
handles.A = caDataStruc.A;
handles.C = caDataStruc.C;
handles.d1 = caDataStruc.d1;
handles.d2 = caDataStruc.d2;


% and make them "string" properties in listbox1
set(handles.listbox1,'String',fieldNames);
% set(handles.listbox1,'Value',1:length(fieldNames));

set(handles.text3, 'String', filename);

% also get the eventHist information

currDir = dir;
firstFile = 0; 
%firstFile2 = 0; 

for numFile = 1:length(currDir)
   if ~isempty(strfind(currDir(numFile).name, 'eventHist')) && firstFile == 0
       load(currDir(numFile).name);
       firstFile = 1;
   end
   
   if ~isempty(strfind(currDir(numFile).name, 'dendriteBehavStruc')) %&& firstFile2 == 0
       load(currDir(numFile).name);
       %firstFile2 = 1;
   end
    
end

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

try
handles.eventHistBehavStruc = eventHistBehavStruc;
catch
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on slider movement.
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

% 
plotCaData(hObject, handles);

%
plotFactorTemporal(hObject, handles);

% roiHist
plotRoiHist(hObject, handles);

% Update handles structure
guidata(hObject, handles);


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


%% plotting functions
function plotRoiHist(hObject, handles)

% roiHist
roiHist1 = handles.roiHist1;
roiHist2 = handles.roiHist2;

segNum = handles.segNum;

x = -8:24;
%x = x(2:end);
width1 = 1;
width2 = 2*width1/3;

axes(handles.axes4);
bar(x, roiHist1(:,segNum), width1, 'FaceColor', 'b'); xlim([-8.5 24.5]);
hold on; 
bar(x, roiHist2(:,segNum), width2, 'FaceColor', 'r');
hold off;

%%
function plotFactorTemporal(hObject, handles)

segNum = handles.segNum;

A = handles.A;
C = handles.C;
d1 = handles.d1;
d2 = handles.d2;

axes(handles.factorTemporal);
plot(handles.factorTemporal, C(:,segNum), 'b');
%axes(handles.factorTemporal);
xlim([1 size(C,1)]);
whitebg;

A2 = reshape(A(segNum,:),d1,d2);
axes(handles.factorSpatial);
imagesc(A2); %axis equal; axis tight;

%%
function plotCaData(hObject, handles)

segNum = handles.segNum;
caData1 = handles.caData1;
caData2 = handles.caData2;

caData1b = squeeze(caData1(:,segNum, :));
caData2b = squeeze(caData2(:,segNum, :));

try
sem1 = std(caData1b,0,2)/sqrt(size(caData1b,2));
catch
end

try
sem2 = std(caData2b,0,2)/sqrt(size(caData2b,2));
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
    try
        errorbar(handles.behavCaPlot, xAx, 5*mean(caData1b,2), 5*sem1, 'c');
        hold on;
    catch
    end
    try
        errorbar(handles.behavCaPlot, xAx, 5*mean(caData2b,2), 5*sem2, 'y');
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
function plotEventHist(hObject, handles)

% and extract event histograms for these fields
try
eventHistBehavStruc = handles.eventHistBehavStruc;

eventFieldName1 = [field1Base 'EventHist'];
eventFieldName2 = [field2Base 'EventHist'];

eventHist1 = eventHistBehavStruc.(eventFieldName1);
eventHist2 = eventHistBehavStruc.(eventFieldName2);

axes(handles.axes5);
bar(eventHist1);hold on;
bar(eventHist2, 'r');
catch
end
