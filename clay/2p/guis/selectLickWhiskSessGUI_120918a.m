function varargout = selectLickWhiskSessGUI_120918a(varargin)
% SELECTLICKWHISKSESSGUI_120918A MATLAB code for selectLickWhiskSessGUI_120918a.fig
%      SELECTLICKWHISKSESSGUI_120918A, by itself, creates a new SELECTLICKWHISKSESSGUI_120918A or raises the existing
%      singleton*.
%
%      H = SELECTLICKWHISKSESSGUI_120918A returns the handle to a new SELECTLICKWHISKSESSGUI_120918A or the handle to
%      the existing singleton*.
%
%      SELECTLICKWHISKSESSGUI_120918A('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECTLICKWHISKSESSGUI_120918A.M with the given input arguments.
%
%      SELECTLICKWHISKSESSGUI_120918A('Property','Value',...) creates a new SELECTLICKWHISKSESSGUI_120918A or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before selectLickWhiskSessGUI_120918a_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to selectLickWhiskSessGUI_120918a_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help selectLickWhiskSessGUI_120918a

% Last Modified by GUIDE v2.5 10-Dec-2018 13:53:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @selectLickWhiskSessGUI_120918a_OpeningFcn, ...
                   'gui_OutputFcn',  @selectLickWhiskSessGUI_120918a_OutputFcn, ...
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


% --- Executes just before selectLickWhiskSessGUI_120918a is made visible.
function selectLickWhiskSessGUI_120918a_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for selectLickWhiskSessGUI_120918a
handles.output = hObject;

% Initialize certain vars
handles.plotAvgCheckboxState = 0;
handles.plotSelCheckboxState = 0;
handles.evTrigHistCompil = cell(3,3);
handles.groupStruc = struct;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes selectLickWhiskSessGUI_120918a wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = selectLickWhiskSessGUI_120918a_OutputFcn(hObject, eventdata, handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loadButton.
function loadButton_Callback(hObject, eventdata, handles)

sessPath = uigetdir;
cd(sessPath);
handles.sessPath = sessPath;
set(handles.sessPathTxt, 'String', sessPath);

[evTrigHistCell, eventNames, path] = eventTrigLickWhiskSess(0);
handles.evTrigHistCell=evTrigHistCell;
handles.eventNames=eventNames;

plotAll(handles);

% Update handles structure
guidata(hObject, handles);


%% --- Executes on button press in addSessButton.
function addSessButton_Callback(hObject, eventdata, handles)

sessPath = handles.sessPath;
slashInds = strfind(sessPath, '/');

groupStruc = handles.groupStruc;
numSess = length(groupStruc);
if numSess==1
    try
        x = groupStruc(1).mouseName;
    catch
        numSess = 0;
    end
end

groupStruc(numSess+1).mouseName = sessPath(slashInds(end-2)+1:slashInds(end-1)-1);
groupStruc(numSess+1).dayPath = sessPath(1:slashInds(end)-1);
groupStruc(numSess+1).sessName = sessPath(slashInds(end)+1:end);
groupStruc(numSess+1).eventNames = handles.eventNames;
groupStruc(numSess+1).evTrigHistCell = handles.evTrigHistCell;

evTrigHistCell = handles.evTrigHistCell;
evTrigHistCompil = handles.evTrigHistCompil;
handles.groupStruc = groupStruc;

%for i=1:length(groupStruc)
    for j=1:size(evTrigHistCell,1)
       for k=1:size(evTrigHistCell,2)
          evTrigHistCompil{j,k} = [evTrigHistCompil{j,k} evTrigHistCell{j,k}];
       end
    end
%end

handles.evTrigHistCompil = evTrigHistCompil;

plotAll(handles);

% Update handles structure
guidata(hObject, handles);

%% --- Executes on button press in loadPrevStrucButton.
function loadPrevStrucButton_Callback(hObject, eventdata, handles)

[filename, path] = uigetfile('/home/clay/Documents/analysis/brunoLab/lickWhiskRew_Dec2018/*.mat', 'Select previous lick/whisk groupStruc');
load([path filename]);
handles.groupStruc = groupStruc;

%plotAll(handles);

% Update handles structure
guidata(hObject, handles);

%%
function saveFileTxt_Callback(hObject, eventdata, handles)
% hObject    handle to saveFileTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of saveFileTxt as text
%        str2double(get(hObject,'String')) returns contents of saveFileTxt as a double


% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function saveFileTxt_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', 'lickWhiskRew_groupStruc');

%% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
outFilename = get(handles.saveFileTxt, 'String');
groupStruc = handles.groupStruc;
save(['/home/clay/Documents/analysis/brunoLab/lickWhiskRew_Dec2018/' outFilename '_' date '.mat'], 'groupStruc');

% Update handles structure
guidata(hObject, handles);


%% --- Executes on button press in removeButton.
function removeButton_Callback(hObject, eventdata, handles)

plotAll(handles);

% Update handles structure
guidata(hObject, handles);


%% --- Executes on slider movement.
function sessSlider_Callback(hObject, eventdata, handles)
% hObject    handle to sessSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

sessSliderVal = round(get(hObject, 'Value'));
handles.sessSliderVal = sessSliderVal;

set(handles.selSessTxt, 'String', ['#' num2str(sessSliderVal) ': ' handles.groupStruc(sessSliderVal).sessName]);

plotAll(handles);

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function sessSlider_CreateFcn(hObject, eventdata, handles)

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%% --- Executes on button press in plotAvgCheckbox.
function plotAvgCheckbox_Callback(hObject, eventdata, handles)

handles.plotAvgCheckboxState = get(hObject,'Value');
%set(handles.plotAvgCheckbox, 'Value', handles.plotAvgCheckboxState);

plotAll(handles);

% Update handles structure
guidata(hObject, handles);


%% Plotting function
function plotAll(handles)

evTrigHistCell = handles.evTrigHistCell;

axes(handles.axes1);
i=1;
plotMeanSEMshaderr(runmean(evTrigHistCell{i,1},100), 'r'); % lick
hold on;
plotMeanSEMshaderr(runmean(evTrigHistCell{i,3},100)*2, 'b');    % rew
plotMeanSEMshaderr(runmean(evTrigHistCell{i,2},100)/5, 'g'); % whisk contacts

if handles.plotAvgCheckboxState
    hold on;
    evTrigHistCompil = handles.evTrigHistCompil;
    plotMeanSEMshaderr(runmean(evTrigHistCompil{i,1},100), 'm');
    plotMeanSEMshaderr(runmean(evTrigHistCompil{i,3},100)*2, 'c');
    plotMeanSEMshaderr(runmean(evTrigHistCompil{i,2},100)/5, 'y');
end

if handles.plotSelCheckboxState
    hold on;
    sessSliderVal = handles.sessSliderVal;
    evTrigHistCompil = handles.evTrigHistCompil;
    plotMeanSEMshaderr(runmean(evTrigHistCompil{i,1},100), 'r');
    plotMeanSEMshaderr(runmean(evTrigHistCompil{i,3},100)*2, 'b');
    plotMeanSEMshaderr(runmean(evTrigHistCompil{i,2},100)/5, 'g');
end
title('lick=r, rew=g, wh=b');
hold off;

%% --- Executes on button press in plotSelCheckbox.
function plotSelCheckbox_Callback(hObject, eventdata, handles)
handles.plotSelCheckboxState = get(hObject,'Value');
%set(handles.plotAvgCheckbox, 'Value', handles.plotAvgCheckboxState);

plotAll(handles);

% Update handles structure
guidata(hObject, handles);

%% TODO
% - change plotting to select not plotting current
% - need to make removal button work
