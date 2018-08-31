function varargout = GapcrossViewer(varargin)
% GAPCROSSVIEWER M-file for GapcrossViewer.fig
%      GAPCROSSVIEWER, by itself, creates a new GAPCROSSVIEWER or raises the existing
%      singleton*.
%
%      H = GAPCROSSVIEWER returns the handle to a new GAPCROSSVIEWER or the handle to
%      the existing singleton*.
%
%      GAPCROSSVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GAPCROSSVIEWER.M with the given input arguments.
%
%      GAPCROSSVIEWER('Property','Value',...) creates a new GAPCROSSVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GapcrossViewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GapcrossViewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GapcrossViewer

% Last Modified by GUIDE v2.5 27-Nov-2013 14:00:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GapcrossViewer_OpeningFcn, ...
                   'gui_OutputFcn',  @GapcrossViewer_OutputFcn, ...
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


% --- Executes just before GapcrossViewer is made visible.
function GapcrossViewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GapcrossViewer (see VARARGIN)

% Choose default command line output for GapcrossViewer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GapcrossViewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GapcrossViewer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loadfilebutton.
function loadfilebutton_Callback(hObject, eventdata, handles)
% hObject    handle to loadfilebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axes1);
[timestamps, events] = PlotGapCrossData;

ylim('manual');
ylim([-1 8]);
xlim([min(timestamps) min(timestamps)+str2double(get(handles.viewsize, 'String'))]);

handles.timestamps = timestamps;
handles.events = events;
guidata(hObject, handles);

function viewsize_Callback(hObject, eventdata, handles)
% hObject    handle to viewsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of viewsize as text
%        str2double(get(hObject,'String')) returns contents of viewsize as a double

x = xlim(handles.axes1);
xlim([x(1) x(1) + str2double(get(handles.viewsize, 'String'))]);


% --- Executes during object creation, after setting all properties.
function viewsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to viewsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in backwardbutton.
function backwardbutton_Callback(hObject, eventdata, handles)
% hObject    handle to backwardbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

x = xlim(handles.axes1);
if x(1) > min(handles.timestamps)
    xlim(x - str2double(get(handles.viewsize, 'String')) / 5);
end

% --- Executes on button press in forwardbutton.
function forwardbutton_Callback(hObject, eventdata, handles)
% hObject    handle to forwardbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

x = xlim(handles.axes1);
if x(2) < max(handles.timestamps)
    xlim(x + str2double(get(handles.viewsize, 'String')) / 5);
end


% --- Executes on button press in GoToBeginningButton.
function GoToBeginningButton_Callback(hObject, eventdata, handles)
% hObject    handle to GoToBeginningButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mn = min(handles.timestamps);
xlim([mn mn + str2double(get(handles.viewsize, 'String'))]);

% --- Executes on button press in GoToEndButton.
function GoToEndButton_Callback(hObject, eventdata, handles)
% hObject    handle to GoToEndButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mx = max(handles.timestamps);
xlim([mx - str2double(get(handles.viewsize, 'String')) mx]);



function GoToSecField_Callback(hObject, eventdata, handles)
% hObject    handle to GoToSecField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GoToSecField as text
%        str2double(get(hObject,'String')) returns contents of GoToSecField as a double

target = str2double(get(hObject,'String'));
xlim([target (target + str2double(get(handles.viewsize, 'String')))]);


% --- Executes during object creation, after setting all properties.
function GoToSecField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GoToSecField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

