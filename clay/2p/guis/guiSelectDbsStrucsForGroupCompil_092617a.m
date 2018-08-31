function varargout = guiSelectDbsStrucsForGroupCompil_092617a(varargin)
% GUISELECTDBSSTRUCSFORGROUPCOMPIL_092617A MATLAB code for guiSelectDbsStrucsForGroupCompil_092617a.fig
%      GUISELECTDBSSTRUCSFORGROUPCOMPIL_092617A, by itself, creates a new GUISELECTDBSSTRUCSFORGROUPCOMPIL_092617A or raises the existing
%      singleton*.
%
%      H = GUISELECTDBSSTRUCSFORGROUPCOMPIL_092617A returns the handle to a new GUISELECTDBSSTRUCSFORGROUPCOMPIL_092617A or the handle to
%      the existing singleton*.
%
%      GUISELECTDBSSTRUCSFORGROUPCOMPIL_092617A('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUISELECTDBSSTRUCSFORGROUPCOMPIL_092617A.M with the given input arguments.
%
%      GUISELECTDBSSTRUCSFORGROUPCOMPIL_092617A('Property','Value',...) creates a new GUISELECTDBSSTRUCSFORGROUPCOMPIL_092617A or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guiSelectDbsStrucsForGroupCompil_092617a_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guiSelectDbsStrucsForGroupCompil_092617a_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guiSelectDbsStrucsForGroupCompil_092617a

% Last Modified by GUIDE v2.5 27-Sep-2017 01:08:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @guiSelectDbsStrucsForGroupCompil_092617a_OpeningFcn, ...
    'gui_OutputFcn',  @guiSelectDbsStrucsForGroupCompil_092617a_OutputFcn, ...
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


%% --- Executes just before guiSelectDbsStrucsForGroupCompil_092617a is made visible.
function guiSelectDbsStrucsForGroupCompil_092617a_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guiSelectDbsStrucsForGroupCompil_092617a (see VARARGIN)

% Choose default command line output for guiSelectDbsStrucsForGroupCompil_092617a
handles.output = hObject;

% Update handles structure
%guidata(hObject, handles);

% UIWAIT makes guiSelectDbsStrucsForGroupCompil_092617a wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%% Put in this stuff to run at beginning(not sure if this works?)

% build output struc with all possible fields
% for field = 1:length(masterFieldNamesCaAvg)
%     group1Struc.(masterFieldNamesCaAvg{field}) = [];
%     group2Struc.(masterFieldNamesCaAvg{field}) = [];
% end

handles.group1Struc = struct;
handles.group2Struc = struct;

handles.group1num = 0;
handles.group2num = 0;
handles.group1fileNames = [];
handles.group2fileNames = [];
handles.fileTag = [];

handles.toPlotGroup = 0;
%handles.toPlotGroup = 1;

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = guiSelectDbsStrucsForGroupCompil_092617a_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%% GROUP 1 selection
% --- Executes on button press in addGroup1strucButton.
function addGroup1strucButton_Callback(hObject, eventdata, handles)

% load in dendBehavStruc
struc1 = handles.struc1;
fieldNames1 = handles.fieldNames1;

% add the filename to a list
group1num = handles.group1num;
group1num = group1num + 1;  % just add up how many datasets are included
group1fileNames = handles.group1fileNames;
group1fileNames{group1num} = handles.filename1;
handles.group1fileNames = group1fileNames;
handles.group1num = group1num;

% concat event/avg data with other files in group
group1Struc = handles.group1Struc;
[group1Struc] = groupStrucCompile(group1Struc, fieldNames1, struc1);
handles.group1Struc = group1Struc;

%fieldNames = handles.fieldNames;
set(handles.group1namesTxt,'String',group1fileNames);

% Update handles structure
guidata(hObject, handles);

%% GROUP 2 selection
% --- Executes on button press in addGroup2strucButton.
function addGroup2strucButton_Callback(hObject, eventdata, handles)

% load in dendBehavStruc

struc2 = handles.struc2;
fieldNames2 = handles.fieldNames2;

% add the filename to a list
group2num = handles.group2num;
group2num = group2num + 1;  % just add up how many datasets are included
group2fileNames = handles.group2fileNames;
group2fileNames{group2num} = handles.filename2;
handles.group2fileNames = group2fileNames;
handles.group2num = group2num;

% concat event/avg data with other files in group
group2Struc = handles.group2Struc;
[group2Struc] = groupStrucCompile(group2Struc, fieldNames2, struc2);
handles.group2Struc = group2Struc;

set(handles.group2namesTxt,'String',group2fileNames);

% Update handles structure
guidata(hObject, handles);


% Load prev compil struc
function loadPrevStruc_Callback(hObject, eventdata, handles)
% hObject    handle to loadPrevStruc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile('.mat');   % select data struc with GUI
cd(pathname);
load([pathname '/' filename]);

handles.group1Struc = group1Struc;
handles.group2Struc = group2Struc;
handles.group1fileNames = group1fileNames;
handles.group2fileNames = group2fileNames;

fieldNames = handles.fieldNames;
set(handles.fieldnameListbox,'String',fieldNames);

set(handles.filenameTxt, 'String', filename);

% Update handles structure
guidata(hObject, handles);


%% --- Executes on selection change in fieldnameListbox.
% In this case, this allows selection of multiple event-triggered
% calcium signals and plots (after data and event fieldNames are
% loaded from desired structure via loaddata1)

function fieldnameListbox_Callback(hObject, eventdata, handles)
% hObject    handle to fieldnameListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



contents = cellstr(get(hObject,'String'));  % get selected listbox1 fieldNames
field = get(hObject,'Value');     % index of fieldNames
fieldNames = handles.fieldNames; % get all fieldNames from handles struc

try
    thisField1 = fieldNames{field(1)};  % name of first selected field
    handles.field1 = thisField1;    % and save these back into handles
    
    %     try
    %         handles.caData1 = handles.
    %     catch
    %     end
    
catch
end

try
    thisField2 = fieldNames{field(2)};  % and second
    handles.field2 = thisField2;
    
    
    
catch
end

plotCaData(handles);

% Update handles structure
guidata(hObject, handles);



% Hints: contents = cellstr(get(hObject,'String')) returns fieldnameListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fieldnameListbox


%% --- Executes during object creation, after setting all properties.
function fieldnameListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldnameListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% fieldNames = handles.fieldNames;
% set(handles.fieldnameListbox,'String',fieldNames);


% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load in relevant variables from handles struc and save

group1Struc = handles.group1Struc;
group2Struc = handles.group2Struc;
group1fileNames = handles.group1fileNames;
group2fileNames = handles.group2fileNames;

% typeStruc = handles.typeStruc;
% strucFileName = handles.filename;

%[FileName, PathName] = uiputfile('.mat');
cd ..; cd ..; cd ..; cd ..;
%delimInd = strfind(pwd, '/');
fileTag = handles.fileTag;
filename = ['groupDbsStrucs_' date '.mat'];
%save([fileTag '_groupStruc_' date '.mat'], 'group1Struc', 'group2Struc', 'group1fileNames', 'group2fileNames');
save(filename, 'group1Struc', 'group2Struc', 'group1fileNames', 'group2fileNames');


% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in groupPlotCheckbox.
function groupPlotCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to groupPlotCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

toPlotGroup = get(hObject,'Value');
set(handles.text6, 'String', num2str(toPlotGroup));

handles.toPlotGroup = toPlotGroup;

% Hint: get(hObject,'Value') returns toggle state of groupPlotCheckbox

plotCaData(handles);

guidata(hObject, handles);




function plotCaData(handles)%hObject, eventdata, handles)

% hz = 4;
% xAx = linspace(-2,6,8*hz+1);

%xAx = -3000:100:3000;
xAx = -2:0.25:6;
handles.xAx = xAx;

%toPlotGroup = handles.toPlotGroup;

% load in calcium data structure (or other struc) from handles struc

%handles.toPlotGroup=0;
thisField1 = handles.field1;

hold off;

% calculate SEM of the calcium data for these fields
% try
    if handles.toPlotGroup~=0
        caStruc1 = handles.group1Struc;
    else
        caStruc1 = handles.struc1;
    end
    
    caData1 = caStruc1.(thisField1);
    %caData1 = caData1(1:100:end);
    handles.caData1 = caData1;
    sem1 = nanstd(caData1,0,2)/sqrt(size(caData1,2));
    % and plot Ca signals (with SEM)
    %plot(handles.behavCaPlot, xAx, mean(caData1,2), 'b');  %xlim([-2 6]);
    errorbar(handles.behavCaPlot, xAx, nanmean(caData1,2), sem1, 'b');
    
    xlabel(handles.behavCaPlot,'sec (from event)'); ylabel(handles.behavCaPlot,'dF/F');
    set(handles.behavCaPlot, 'Color', [1,1,1]);
    hold(handles.behavCaPlot);
    
    % and put lines on for start/stop of event epoch (3s window)
    axes(handles.behavCaPlot); %hold on;
    line([0 0],[-0.05 0.2], 'Color', 'g');
    line([3 3],[-0.05 0.2], 'Color', 'r');
    xlim([-2 6]);
    
    
% catch
%     disp('Problem plotting data1');
% end

%     xlabel(handles.behavCaPlot,'sec (from event)'); ylabel(handles.behavCaPlot,'dF/F');
%     set(handles.behavCaPlot, 'Color', [1,1,1]);
%     hold(handles.behavCaPlot);

try
    if handles.toPlotGroup
        caStruc2 = handles.group2Struc;
    else
        caStruc2 = handles.struc2;
    end
    
    caData2 = caStruc2.(thisField1);
    %caData2 = caData2(1:100:end);
    handles.caData2 = caData2;
    
    sem2 = nanstd(caData2,0,2)/sqrt(size(caData2,2));
    % and plot Ca signals (with SEM)
    %plot(handles.behavCaPlot, xAx, nanmean(caData2,2), 'r');  xlim([-2 6]);
    errorbar(handles.behavCaPlot, xAx, nanmean(caData2,2), sem2, 'r');
catch
end

%hold off;

try
    caData3 = caStruc1.(thisField2);
    %caData3 = caData3(1:100:end);
    handles.caData3 = caData3;
    
    sem3 = nanstd(caData3,0,2)/sqrt(size(caData3,2));
    %plot(handles.behavCaPlot, xAx, mean(caData3,2), 'c');
    errorbar(handles.behavCaPlot, xAx, nanmean(caData3,2), sem3, 'c');
catch
end

try
    caData4 = caStruc2.(thisField2);
    %caData4 = caData4(1:100:end);
    handles.caData4 = caData4;
    sem4 = nanstd(caData4,0,2)/sqrt(size(caData4,2));
    %plot(handles.behavCaPlot, xAx, mean(caData4,2), 'm');
    errorbar(handles.behavCaPlot, xAx, nanmean(caData4,2), sem4, 'm');
    %set(handles.behavCaPlot, 'Color', [1,1,1]);
catch
end

%     % and put lines on for start/stop of event epoch (3s window)
% axes(handles.behavCaPlot); %hold on;
% line([0 0],[-0.05 0.2], 'Color', 'g');
% line([3 3],[-0.05 0.2], 'Color', 'r');
% xlim([-2 6]);

%legend(handles.behavCaPlot, thisField1, thisField2);
% set(gca, 'TextColor', 'k');
%hold off;

%guidata(hObject, handles);

% --- Executes on button press in loadData1.
function loadData1_Callback(hObject, eventdata, handles)
% hObject    handle to loadData1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load in dendBehavStruc
[filename, pathname] = uigetfile('.mat');   % select data struc with GUI
cd(pathname);
s = load([pathname '/' filename]);   % load in data structure (NOTE: will be one field deep, due to "s=" in "load" func)
strucName = fieldnames(s);
struc1 = s.(strucName{1}); % dendriteBehavStruc;
fieldNames1 = fieldnames(struc1);
handles.struc1 = struc1;
handles.fieldNames = fieldNames1;
handles.fieldNames1 = fieldNames1;
handles.filename1 = filename;

set(handles.fieldnameListbox,'String',fieldNames1);

set(handles.filenameTxt, 'String', filename);

guidata(hObject, handles);

% --- Executes on button press in loadData2.
function loadData2_Callback(hObject, eventdata, handles)
% hObject    handle to loadData2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load in dendBehavStruc
[filename, pathname] = uigetfile('.mat');   % select data struc with GUI
cd(pathname);
s = load([pathname '/' filename]);   % load in data structure (NOTE: will be one field deep, due to "s=" in "load" func)
strucName = fieldnames(s);
struc2 = s.(strucName{1}); % dendriteBehavStruc;
fieldNames2 = fieldnames(struc2);
handles.struc2 = struc2;
handles.fieldNames2 = fieldNames2;
handles.filename2 = filename;

set(handles.filenameTxt2, 'String', filename);

guidata(hObject, handles);



function fileTagEdit_Callback(hObject, eventdata, handles)
% hObject    handle to fileTagEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fileTagEdit as text
%        str2double(get(hObject,'String')) returns contents of fileTagEdit as a double

handles.fileTag = get(hObject, 'String');

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function fileTagEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileTagEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
