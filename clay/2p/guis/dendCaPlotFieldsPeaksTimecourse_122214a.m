function varargout = dendCaPlotFieldsPeaksTimecourse_122214a(varargin)
% DENDCAPLOTFIELDSPEAKSTIMECOURSE_122214A MATLAB code for dendCaPlotFieldsPeaksTimecourse_122214a.fig
%      DENDCAPLOTFIELDSPEAKSTIMECOURSE_122214A, by itself, creates a new DENDCAPLOTFIELDSPEAKSTIMECOURSE_122214A or raises the existing
%      singleton*.
%
%      H = DENDCAPLOTFIELDSPEAKSTIMECOURSE_122214A returns the handle to a new DENDCAPLOTFIELDSPEAKSTIMECOURSE_122214A or the handle to
%      the existing singleton*.
%
%      DENDCAPLOTFIELDSPEAKSTIMECOURSE_122214A('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DENDCAPLOTFIELDSPEAKSTIMECOURSE_122214A.M with the given input arguments.
%
%      DENDCAPLOTFIELDSPEAKSTIMECOURSE_122214A('Property','Value',...) creates a new DENDCAPLOTFIELDSPEAKSTIMECOURSE_122214A or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dendCaPlotFieldsPeaksTimecourse_122214a_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dendCaPlotFieldsPeaksTimecourse_122214a_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dendCaPlotFieldsPeaksTimecourse_122214a

% Last Modified by GUIDE v2.5 22-Dec-2014 16:12:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dendCaPlotFieldsPeaksTimecourse_122214a_OpeningFcn, ...
                   'gui_OutputFcn',  @dendCaPlotFieldsPeaksTimecourse_122214a_OutputFcn, ...
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


%% --- Executes just before dendCaPlotFieldsPeaksTimecourse_122214a is made visible.
function dendCaPlotFieldsPeaksTimecourse_122214a_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dendCaPlotFieldsPeaksTimecourse_122214a (see VARARGIN)

% Choose default command line output for dendCaPlotFieldsPeaksTimecourse_122214a
handles.output = hObject;

handles.checkbox1state = 0;
handles.checkbox2state = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dendCaPlotFieldsPeaksTimecourse_122214a wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = dendCaPlotFieldsPeaksTimecourse_122214a_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%% --- Executes on selection change in listbox1.
% In this case, this allows selection of multiple event-triggered
% calcium signals and plots (after data and event fieldNames are 
% loaded from desired structure via loaddatabutton)

function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load in calcium data structure (or other struc) from handles struc
% dataStruc = handles.caDataStruc;

contents = cellstr(get(hObject,'String'));  % get selected listbox1 fieldNames
field = get(hObject,'Value');     % index of fieldNames
fieldNames = handles.fieldNames; % get all fieldNames from handles struc
thisField1 = fieldNames{field(1)};  % name of first selected field
thisField2 = fieldNames{field(2)};  % and second
handles.field1 = thisField1;    % and save these back into handles
handles.field2 = thisField2;

% Update handles structure
guidata(hObject, handles);

plotAll(hObject, handles);


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

% for field = 1:length(fieldNames)
%    caDataField = caDataStruc.(fieldNames{field}); 
%    caDataFieldAvg = nanmean(caDataField, 2);
%    [C, I] = max(caDataFieldAvg);
%    caAvgPeakVal(field) = C;
%    caAvgPeakInd(field) = I;
% end
% 
% [maxPkFieldVal, maxPkFieldInd] = max(caAvgPeakVal);
% 
% set(handles.maxFieldTxt, 'String', fieldNames{maxPkFieldInd});

set(handles.filenameTxt, 'String', ['Filename = ' filename]);

% Update handles structure
guidata(hObject, handles);


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

checkbox1state = get(hObject, 'Value');

if isempty(checkbox1state)
    checkbox1state = 0;
end

handles.checkbox1state = checkbox1state;

guidata(hObject, handles);

plotAll(hObject, handles);


function plotAll(hObject, handles)



dataStruc = handles.caDataStruc;

thisField1 = handles.field1; 
thisField2 = handles.field2; 

% calculate SEM of the calcium data for these fields
caData1 = dataStruc.(thisField1);
caData2 = dataStruc.(thisField2);

fileLim = get(handles.edit3, 'String');
set(handles.text6, 'String', fileLim);


fileLim = str2num(fileLim);

if fileLim > 0
    
caData1b = caData1(:,1:min(fileLim, size(caData1, 2)));
caData2b = caData2(:,1:min(fileLim, size(caData2, 2)));

else 
    caData1b = caData1;
    caData2b = caData2;
end

handles.caData1 = caData1;
handles.caData2 = caData2;
sem1 = nanstd(caData1b,0,2)/sqrt(size(caData1b,2));
sem2 = nanstd(caData2b,0,2)/sqrt(size(caData2b,2));

if size(caData1, 1) == 17
     hz = 2;
elseif size(caData1, 1) == 33
     hz = 4;
elseif size(caData1, 1) == 65
     hz = 8;
end

xAx = linspace(-2,6,8*hz+1); 

% and plot Ca signals (with SEM)
% axes(handles.behavCaPlot);
% xlim([-2 6]); hold(handles.behavCaPlot);

checkbox1state = handles.checkbox1state;
%hold(handles.behavCaPlot, 'on');
%axes(handles.behavCaPlot); hold on;
if checkbox1state == 1
plot(handles.behavCaPlot, xAx, caData1b, 'c'); hold(handles.behavCaPlot, 'on');  
% plot(handles.behavCaPlot, xAx, mean(caData1,2), 'b');  xlim([-2 6]); hold on;
% xlabel(handles.behavCaPlot,'sec (from event)'); ylabel(handles.behavCaPlot,'dF/F');
% hold(handles.behavCaPlot);
plot(handles.behavCaPlot, xAx, caData2b, 'm');%hold(handles.behavCaPlot, 'off');
end
% plot(handles.behavCaPlot, xAx, mean(caData2,2), 'r');

caData1bAvg = nanmean(caData1b,2);
caData2bAvg = nanmean(caData2b,2);

errorbar(handles.behavCaPlot, xAx, caData2bAvg, sem2, 'r'); xlim([-2 6]); hold(handles.behavCaPlot, 'on');
errorbar(handles.behavCaPlot, xAx, caData1bAvg, sem1, 'b'); %hold off;
set(handles.behavCaPlot, 'Color', [1,1,1]); %hold off;
hleg = legend(handles.behavCaPlot, thisField2, thisField1); % , 'ForegroundColor', 'k');
set(hleg, 'TextColor', 'k');
hold(handles.behavCaPlot, 'off');

% and put lines on for start/stop of event epoch (3s window)
axes(handles.behavCaPlot); %hold on;

xlim([-2 6]); 
if checkbox1state == 1
    line([0 0],[min([min(caData1b) min(caData2b)])-0.05 max([max(caData1b) max(caData2b)])+0.05], 'Color', 'g');
    line([3 3],[min([min(caData1b) min(caData2b)])-0.05 max([max(caData1b) max(caData2b)])+0.05], 'Color', 'r');
    ylim([min([min(caData1b) min(caData2b)])-0.05 max([max(caData1b) max(caData2b)])+0.05]);
    
else
    line([0 0],[min([caData1bAvg; caData2bAvg])-0.05 max([caData1bAvg; caData2bAvg])+0.05], 'Color', 'g');
    line([3 3],[min([caData1bAvg; caData2bAvg])-0.05 max([caData1bAvg; caData2bAvg])+0.05], 'Color', 'r');
    ylim([min([caData1bAvg; caData2bAvg])-0.05 max([caData1bAvg; caData2bAvg])+0.05]);
end


% now plot peaks for these events
caPeakVal1 = [];
caPeakVal2 = [];

for animal = 1:size(caData1, 2)
   [C, I] = max(caData1(8:16,animal));
   caPeakVal1(animal) = C-nanmean(caData1(4:6, animal));
   caPeakInd1(animal) = I+7;
end

for animal = 1:size(caData2, 2)
   [C, I] = max(caData2(8:16,animal));
   caPeakVal2(animal) = C-nanmean(caData2(4:6, animal));
   caPeakInd2(animal) = I+7;
end

handles.caPeakVal1 = caPeakVal1;
handles.caPeakInd1 = caPeakInd1;
handles.caPeakVal2 = caPeakVal2;
handles.caPeakInd2 = caPeakInd2;

axes(handles.peakScatterPlot);% hold on;

checkbox2state = handles.checkbox2state;

if checkbox2state == 1
    plot(handles.peakScatterPlot, caPeakVal1, caPeakVal2, 'b.'); hold on;
    xlabel(thisField1); ylabel(thisField2);
    line([-0.05 0.3], [-0.05 0.3], 'Color', 'k');
else
    plot(handles.peakScatterPlot, caPeakVal1, 'b.');
    hold(handles.peakScatterPlot);
    plot(handles.peakScatterPlot, caPeakVal2, 'r.');
    
    % hold(handles.peakScatterPlot);
    % xlim([-0.05 0.3]); ylim([-0.05 0.3]);
    % xlabel(thisField1); ylabel(thisField2);
    xlabel('session OR animal'); ylabel('dF/F');
    % line([-0.05 0.3], [-0.05 0.3], 'Color', 'k');
end
set(handles.peakScatterPlot, 'Color',[1,1,1]);
hold off;

guidata(hObject, handles);


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
checkbox2state = get(hObject, 'Value');

% if isempty(checkbox2state)
%     checkbox2state = 0;
% else
%     checkbox2state = 1;
% end

handles.checkbox2state = checkbox2state;

set(handles.text7, 'String', checkbox2state);

guidata(hObject, handles);

plotAll(hObject, handles);
