function varargout = dendCaWhiskPlotFieldsPeaksTimecourse_091616a(varargin)
% DENDCAWHISKPLOTFIELDSPEAKSTIMECOURSE_091616A MATLAB code for dendCaWhiskPlotFieldsPeaksTimecourse_091616a.fig
%      DENDCAWHISKPLOTFIELDSPEAKSTIMECOURSE_091616A, by itself, creates a new DENDCAWHISKPLOTFIELDSPEAKSTIMECOURSE_091616A or raises the existing
%      singleton*.
%
%      H = DENDCAWHISKPLOTFIELDSPEAKSTIMECOURSE_091616A returns the handle to a new DENDCAWHISKPLOTFIELDSPEAKSTIMECOURSE_091616A or the handle to
%      the existing singleton*.
%
%      DENDCAWHISKPLOTFIELDSPEAKSTIMECOURSE_091616A('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DENDCAWHISKPLOTFIELDSPEAKSTIMECOURSE_091616A.M with the given input arguments.
%
%      DENDCAWHISKPLOTFIELDSPEAKSTIMECOURSE_091616A('Property','Value',...) creates a new DENDCAWHISKPLOTFIELDSPEAKSTIMECOURSE_091616A or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dendCaWhiskPlotFieldsPeaksTimecourse_091616a_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dendCaWhiskPlotFieldsPeaksTimecourse_091616a_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dendCaWhiskPlotFieldsPeaksTimecourse_091616a

% Last Modified by GUIDE v2.5 18-Sep-2016 21:09:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dendCaWhiskPlotFieldsPeaksTimecourse_091616a_OpeningFcn, ...
                   'gui_OutputFcn',  @dendCaWhiskPlotFieldsPeaksTimecourse_091616a_OutputFcn, ...
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


%% --- Executes just before dendCaWhiskPlotFieldsPeaksTimecourse_091616a is made visible.
function dendCaWhiskPlotFieldsPeaksTimecourse_091616a_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dendCaWhiskPlotFieldsPeaksTimecourse_091616a (see VARARGIN)

% Choose default command line output for dendCaWhiskPlotFieldsPeaksTimecourse_091616a
handles.output = hObject;


handles.tracePlot = 0;


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dendCaWhiskPlotFieldsPeaksTimecourse_091616a wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = dendCaWhiskPlotFieldsPeaksTimecourse_091616a_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%% --- Executes on button press in loadDataButton.
% In this case, this loads in a structure (usually a cageBatch or animal
% struc) and records the fieldNames and Ca data

function loadDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile('.mat');   % select data struc with GUI
cd(pathname);
inStruc = load(filename);   % load in data structure (NOTE: will be one field deep, due to "load" func)
fieldNames = fieldnames(inStruc);   % get the fieldNames (which will be equal to the name/type of target data structure)
caDataStruc = inStruc.(fieldNames{1});  % so now extract bottom level data structure
handles.typeStruc = fieldNames{1};  % and save the type of struc
handles.caDataStruc = caDataStruc;  % and the caData into handles struc
handles.filename = filename;

% find fields in calcium data structure
fieldNames = fieldnames(caDataStruc);
% fieldNames = fieldNames(2:length(fieldNames));  % cut out eventStruc

% and only save fieldNames for Ca data
caFields = strfind(fieldNames, 'Ca');   % this give some # for each field with "Ca" in title, zeros if none
caFieldInd = find(not(cellfun('isempty', caFields)));   % finds indices of Ca fields
fieldNames = fieldNames(caFieldInd);    % and only use these fieldNames

handles.fieldNames = fieldNames;    % and save back into handles struc

% so now, take the fieldNames of Ca data
% and make them "string" properties to select from in listbox1
set(handles.listbox1,'String',fieldNames);
% set(handles.listbox1,'Value',1:length(fieldNames));

% now find peaks in Ca data for each field

try
for field = 1:length(fieldNames)
   caDataField = caDataStruc.(fieldNames{field}); 
   caDataFieldAvg = nanmean(caDataField, 2);
   [C, I] = nanmax(caDataFieldAvg);
   caAvgPeakVal(field) = C;
   caAvgPeakInd(field) = I;
end

[maxPkFieldVal, maxPkFieldInd] = nanmax(caAvgPeakVal);

set(handles.maxFieldTxt, 'String', fieldNames{maxPkFieldInd});

set(handles.filenameTxt, 'String', ['Filename = ' filename]);

catch
end

% Update handles structure
guidata(hObject, handles);




%% --- Executes on selection change in listbox1.
% In this case, this allows selection of multiple event-triggered
% calcium signals and plots (after data and event fieldNames are 
% loaded from desired structure via loaddatabutton)

function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load in calcium data structure (or other struc) from handles struc
dataStruc = handles.caDataStruc;

contents = cellstr(get(hObject,'String'));  % get selected listbox1 fieldNames
field = get(hObject,'Value');     % index of fieldNames
fieldNames = handles.fieldNames; % get all fieldNames from handles struc

thisField1 = fieldNames{field(1)};  % name of first selected field
handles.field1 = thisField1;    % and save these back into handles

handles.field = field;

%disp(thisField);



% calculate SEM of the calcium data for these fields
caData1 = dataStruc.(thisField1);
%caData1 = caData1(:,1:fileLim);
handles.caData1 = caData1;

if length(field) == 2
    thisField2 = fieldNames{field(2)};  % and second
    handles.field2 = thisField2;
    caData2 = dataStruc.(thisField2);
    handles.caData2 = caData2;
end

plotData(handles);

% Update handles structure
guidata(hObject, handles);


% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


%% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load in relevant variables from handles struc and save 
field1 = handles.field1;
field2 = handles.field2;

caData1 = handles.caData1;
caData2 = handles.caData2;

caPeakVal1 = handles.caPeakVal1;
caPeakInd1 = handles.caPeakInd1;
caPeakVal2 = handles.caPeakVal2;
caPeakInd2 = handles.caPeakInd2;

typeStruc = handles.typeStruc;
strucFileName = handles.filename; 

[FileName, PathName] = uiputfile('.mat');
save(FileName, 'field1', 'field2', 'caData1', 'caData2', 'caPeakVal1', 'caPeakInd1', 'caPeakVal2', 'caPeakInd2', 'typeStruc', 'strucFileName');



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1

handles.tracePlot = get(hObject, 'Value');

plotData(handles);

% Update handles structure
guidata(hObject, handles);



%% Plotting function
function plotData(handles)

try
fileLimStr = get(handles.edit3, 'String');
%set(handles.text6, 'String', fileLimStr);
fileLim = str2num(fileLimStr);
catch
   fileLim = 1; 
end

set(handles.text6, 'String', num2str(handles.tracePlot));

field = handles.field;
caData1 = handles.caData1;
thisField1 = handles.field1;

sem1 = nanstd(caData1,0,2)/sqrt(size(caData1,2));

if size(caData1,1) == 33
hz = 4;
elseif size(caData1,1) == 17
    hz = 2;
elseif size(caData1,1) == 65
    hz = 8;
end

xAx = linspace(-2,6,8*hz+1); 

axes(handles.behavCaPlot); cla;

% and plot Ca signals (with SEM)
if length(field) == 1
    %plot(handles.behavCaPlot, xAx, nanmean(caData1,2), 'b');  xlim([-2 6]);
    
    if handles.tracePlot == 1
        
        plot(handles.behavCaPlot, xAx, caData1, 'c');
    end
    
    hold(handles.behavCaPlot);
    
    errorbar(handles.behavCaPlot, xAx, nanmean(caData1,2), sem1, 'b');
    xlabel(handles.behavCaPlot,'sec (from event)'); ylabel(handles.behavCaPlot,'dF/F');
    legend(handles.behavCaPlot, thisField1);
    %hold on;
    
end

if length(field) == 2
    
    %     if fileLim > 1
    %         caData2 = caData2(:,1:fileLim);
    %     end
    
    caData2 = handles.caData2;
    thisField2 = handles.field2;
    
    hold(handles.behavCaPlot);
    if handles.tracePlot == 1
        plot(handles.behavCaPlot, xAx, caData1, 'c');
        plot(handles.behavCaPlot, xAx, caData2, 'm');
    end
    
    
    

    sem2 = nanstd(caData2,0,2)/sqrt(size(caData2,2));
    
    %errorbar(handles.behavCaPlot, xAx, nanmean(caData1,2), sem1, 'b');
    xlabel(handles.behavCaPlot,'sec (from event)'); ylabel(handles.behavCaPlot,'dF/F');
    
    errorbar(handles.behavCaPlot, xAx, nanmean(caData1,2), sem1, 'b');
    errorbar(handles.behavCaPlot, xAx, nanmean(caData2,2), sem2, 'r');
    legend(handles.behavCaPlot, thisField1, thisField2);
    
end


% and put lines on for start/stop of event epoch (3s window)
axes(handles.behavCaPlot); %hold on;
line([0 0],[-0.05 0.2], 'Color', 'g');
line([3 3],[-0.05 0.2], 'Color', 'r');
xlim([-2 6]);
hold off;

set(handles.behavCaPlot, 'Color', [1,1,1]);
% set(gca, 'TextColor', 'k');
%hold off;

% now plot peaks for these events
caPeakVal1 = [];
caPeakVal2 = [];

try
for animal = 1:size(caData1, 2)
   [C, I] = nanmax(caData1(8:16,animal));
   caPeakVal1(animal) = C-nanmean(caData1(4:6, animal));
   caPeakInd1(animal) = I+7;
end


handles.caPeakVal1 = caPeakVal1;
handles.caPeakInd1 = caPeakInd1;
catch
end

axes(handles.peakScatterPlot);% hold on;
plot(handles.peakScatterPlot, caPeakVal1, 'b.');
hold(handles.peakScatterPlot);

set(handles.peakScatterPlot, 'Color',[1,1,1]);

try
for animal = 1:size(caData2, 2)
   [C, I] = nanmax(caData2(8:16,animal));
   caPeakVal2(animal) = C-nanmean(caData2(4:6, animal));
   caPeakInd2(animal) = I+7;
end
handles.caPeakVal2 = caPeakVal2;
handles.caPeakInd2 = caPeakInd2;
plot(handles.peakScatterPlot, caPeakVal2, 'r.');
catch
end

hold off;


% hold(handles.peakScatterPlot);
% xlim([-0.05 0.3]); ylim([-0.05 0.3]);
% xlabel(thisField1); ylabel(thisField2);
% line([-0.05 0.3], [-0.05 0.3], 'Color', 'k');
%hold off;
