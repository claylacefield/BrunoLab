function varargout = dendCaPlotFieldsMulti_051214a(varargin)
% DENDCAPLOTFIELDSMULTI_051214A MATLAB code for dendCaPlotFieldsMulti_051214a.fig
%      DENDCAPLOTFIELDSMULTI_051214A, by itself, creates a new DENDCAPLOTFIELDSMULTI_051214A or raises the existing
%      singleton*.
%
%      H = DENDCAPLOTFIELDSMULTI_051214A returns the handle to a new DENDCAPLOTFIELDSMULTI_051214A or the handle to
%      the existing singleton*.
%
%      DENDCAPLOTFIELDSMULTI_051214A('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DENDCAPLOTFIELDSMULTI_051214A.M with the given input arguments.
%
%      DENDCAPLOTFIELDSMULTI_051214A('Property','Value',...) creates a new DENDCAPLOTFIELDSMULTI_051214A or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dendCaPlotFieldsMulti_051214a_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dendCaPlotFieldsMulti_051214a_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dendCaPlotFieldsMulti_051214a

% Last Modified by GUIDE v2.5 14-May-2014 00:58:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dendCaPlotFieldsMulti_051214a_OpeningFcn, ...
                   'gui_OutputFcn',  @dendCaPlotFieldsMulti_051214a_OutputFcn, ...
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


%% --- Executes just before dendCaPlotFieldsMulti_051214a is made visible.
function dendCaPlotFieldsMulti_051214a_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dendCaPlotFieldsMulti_051214a (see VARARGIN)

% Choose default command line output for dendCaPlotFieldsMulti_051214a
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dendCaPlotFieldsMulti_051214a wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%% Put in this stuff to run at beginning(not sure if this works?)
% load masterFieldNamesCa2 into workspace
load('/home/clay/Documents/Data/2p mouse behavior/masterFieldNamesCaAvg.mat');
handles.fieldNames = masterFieldNamesCaAvg;

% build output struc with all possible fields
for field = 1:length(masterFieldNamesCaAvg)
    group1Struc.(masterFieldNamesCaAvg{field}) = [];
    group2Struc.(masterFieldNamesCaAvg{field}) = [];
end

handles.group1Struc = group1Struc;
handles.group2Struc = group2Struc;

handles.group1num = 0;
handles.group2num = 0;

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = dendCaPlotFieldsMulti_051214a_OutputFcn(hObject, eventdata, handles) 
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

hz = 4;
xAx = linspace(-2,6,8*hz+1); 

% load in calcium data structure (or other struc) from handles struc
group1Struc = handles.group1Struc;
group2Struc = handles.group2Struc;

contents = cellstr(get(hObject,'String'));  % get selected listbox1 fieldNames
field = get(hObject,'Value');     % index of fieldNames
fieldNames = handles.fieldNames; % get all fieldNames from handles struc

try
    thisField1 = fieldNames{field(1)};  % name of first selected field
    handles.field1 = thisField1;    % and save these back into handles
    
    % calculate SEM of the calcium data for these fields
    try
        caData1 = group1Struc.(thisField1);
        handles.caData1 = caData1;
        sem1 = std(caData1,0,2)/sqrt(size(caData1,2));
        % and plot Ca signals (with SEM)
        plot(handles.behavCaPlot, xAx, mean(caData1,2), 'b');  xlim([-2 6]);
        errorbar(handles.behavCaPlot, xAx, mean(caData1,2), sem1, 'b');
    catch
    end
    
    xlabel(handles.behavCaPlot,'sec (from event)'); ylabel(handles.behavCaPlot,'dF/F');
    set(handles.behavCaPlot, 'Color', [1,1,1]);
    hold(handles.behavCaPlot);
    
    try
        caData2 = group2Struc.(thisField1);
        handles.caData2 = caData2;
        sem2 = std(caData2,0,2)/sqrt(size(caData2,2));
        % and plot Ca signals (with SEM)
        plot(handles.behavCaPlot, xAx, mean(caData2,2), 'c');  xlim([-2 6]);
        errorbar(handles.behavCaPlot, xAx, mean(caData2,2), sem2, 'c');
    catch
    end
    
catch
end

try
    thisField2 = fieldNames{field(2)};  % and second
    handles.field2 = thisField2;
    
    try
        caData3 = group1Struc.(thisField2);
        handles.caData3 = caData3;
        sem3 = std(caData3,0,2)/sqrt(size(caData3,2));
        plot(handles.behavCaPlot, xAx, mean(caData3,2), 'r');
        errorbar(handles.behavCaPlot, xAx, mean(caData3,2), sem3, 'r');
    catch
    end
    
    try
        caData4 = group2Struc.(thisField2);
        handles.caData4 = caData4;
        sem4 = std(caData4,0,2)/sqrt(size(caData4,2));
        plot(handles.behavCaPlot, xAx, mean(caData4,2), 'm');
        errorbar(handles.behavCaPlot, xAx, mean(caData4,2), sem4, 'm');
        %set(handles.behavCaPlot, 'Color', [1,1,1]);
    catch
    end
    
catch
end

% and put lines on for start/stop of event epoch (3s window)
axes(handles.behavCaPlot); %hold on;
line([0 0],[-0.05 0.2], 'Color', 'g');
line([3 3],[-0.05 0.2], 'Color', 'r');
xlim([-2 6]);

%legend(handles.behavCaPlot, thisField1, thisField2);
% set(gca, 'TextColor', 'k');
%hold off;

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

% fieldNames = handles.fieldNames;
% set(handles.listbox1,'String',fieldNames);


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


typeStruc = handles.typeStruc;
strucFileName = handles.filename; 

[FileName, PathName] = uiputfile('.mat');
save(FileName, 'field1', 'field2', 'caData1', 'caData2', 'caPeakVal1', 'caPeakInd1', 'caPeakVal2', 'caPeakInd2', 'typeStruc', 'strucFileName');

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load in dendBehavStruc
[filename, pathname] = uigetfile('.mat');   % select data struc with GUI
cd(pathname);
load([pathname '/' filename]);   % load in data structure (NOTE: will be one field deep, due to "load" func)
dendriteBehavStruc1 = dendriteBehavStruc;
handles.dendriteBehavStruc1 = dendriteBehavStruc1;

% add the filename to a list
group1num = handles.group1num;
group1num = group1num + 1;
group1fileNames{group1num} = filename;
handles.group1fileNames = group1fileNames;

% concat event/avg data with other files in group
fieldNames = handles.fieldNames;
group1Struc = handles.group1Struc;
[group1Struc] = groupCompile(group1Struc, fieldNames, dendriteBehavStruc1);
handles.group1Struc = group1Struc;

fieldNames = handles.fieldNames;
set(handles.listbox1,'String',fieldNames);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% load in dendBehavStruc
[filename, pathname] = uigetfile('.mat');   % select data struc with GUI
cd(pathname);
load([pathname '/' filename]);   % load in data structure (NOTE: will be one field deep, due to "load" func)
dendriteBehavStruc2 = dendriteBehavStruc;
handles.dendriteBehavStruc2 = dendriteBehavStruc2;

% add the filename to a list
group2num = handles.group2num;
group2num = group2num + 1;
group2fileNames{group2num} = filename;
handles.group2fileNames = group2fileNames;

% concat event/avg data with other files in group
fieldNames = handles.fieldNames;
group2Struc = handles.group2Struc;
[group2Struc] = groupCompile(group2Struc, fieldNames, dendriteBehavStruc2);
handles.group2Struc = group2Struc;

% Update handles structure
guidata(hObject, handles);
