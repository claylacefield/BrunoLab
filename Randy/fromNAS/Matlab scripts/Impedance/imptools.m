function varargout = imptools(varargin)
% IMPTOOLS M-file for imptools.fig
%      IMPTOOLS, by itself, creates a new IMPTOOLS or raises the existing
%      singleton*.
%
%      H = IMPTOOLS returns the handle to a new IMPTOOLS or the handle to
%      the existing singleton*.
%
%      IMPTOOLS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMPTOOLS.M with the given input arguments.
%
%      IMPTOOLS('Property','Value',...) creates a new IMPTOOLS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before imptools_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to imptools_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help imptools

% Last Modified by GUIDE v2.5 05-Mar-2008 13:45:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @imptools_OpeningFcn, ...
                   'gui_OutputFcn',  @imptools_OutputFcn, ...
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


% --- Executes just before imptools is made visible.
function imptools_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to imptools (see VARARGIN)

% Choose default command line output for imptools
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes imptools wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = imptools_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function duration_Callback(hObject, eventdata, handles)
% hObject    handle to duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of duration as text
%        str2double(get(hObject,'String')) returns contents of duration as a double


% --- Executes during object creation, after setting all properties.
function duration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Current_Callback(hObject, eventdata, handles)
% hObject    handle to Current (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Current as text
%        str2double(get(hObject,'String')) returns contents of Current as a double
currentpath = get(hObject, 'String');
cd(currentpath);

% --- Executes during object creation, after setting all properties.
function Current_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Current (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

currentpath = get(hObject, 'String');
cd(currentpath);


function Voltage_Callback(hObject, eventdata, handles)
% hObject    handle to Voltage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Voltage as text
%        str2double(get(hObject,'String')) returns contents of Voltage as a double
voltagepath = get(hObject, 'String');
cd(voltagepath);

% --- Executes during object creation, after setting all properties.
function Voltage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Voltage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
voltagepath = get(hObject, 'String');
cd(voltagepath);


function stim_onset_Callback(hObject, eventdata, handles)
% hObject    handle to stim_onset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stim_onset as text
%        str2double(get(hObject,'String')) returns contents of stim_onset as a double


% --- Executes during object creation, after setting all properties.
function stim_onset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stim_onset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function st_end_Callback(hObject, eventdata, handles)
% hObject    handle to st_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of st_end as text
%        str2double(get(hObject,'String')) returns contents of st_end as a double


% --- Executes during object creation, after setting all properties.
function st_end_CreateFcn(hObject, eventdata, handles)
% hObject    handle to st_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Current_file.
function Current_file_Callback(hObject, eventdata, handles)
% hObject    handle to Current_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
currentpath = get(handles.Current, 'String');
cd(currentpath);

[filename_i pathname_i OK] = uigetfile('*.dat', 'Select injected current file');
if (~OK) return; end
filepath_i = fullfile(pathname_i, filename_i);
set(handles.SelectedCurrentFileName, 'String', filepath_i);
guidata(hObject,handles);

% --- Executes on button press in Voltage_file.
function Voltage_file_Callback(hObject, eventdata, handles)
% hObject    handle to Voltage_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
voltagepath = get(handles.Voltage, 'String');
cd(voltagepath);
[filename_v pathname_v OK] = uigetfile('*.dat', 'Select recorded voltage file');
if (~OK) return; end
filepath_v = fullfile(pathname_v, filename_v);
set(handles.SelectedVoltageFileName, 'String', filepath_v);
guidata(hObject,handles);


function avg_window_Callback(hObject, eventdata, handles)
% hObject    handle to avg_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of avg_window as text
%        str2double(get(hObject,'String')) returns contents of avg_window as a double


% --- Executes during object creation, after setting all properties.
function avg_window_CreateFcn(hObject, eventdata, handles)
% hObject    handle to avg_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RunButton.
function RunButton_Callback(hObject, eventdata, handles)
% hObject    handle to RunButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

filepath_v = get(handles.SelectedVoltageFileName, 'String');
filepath_i = get(handles.SelectedCurrentFileName, 'String');
duration = str2double(get(handles.duration, 'String'));
ps_on = str2double(get(handles.pre_stim_on, 'String'));
ps_end = str2double(get(handles.pre_stim_end, 'String'));

stim_on = str2double(get(handles.stim_onset, 'String'));
stim_end = str2double(get(handles.st_end, 'String'));

Fmax = str2double(get(handles.Fmax, 'String'));
Fs = str2double(get(handles.Fs, 'String'));
fpass = str2double(get(handles.fpass, 'String'));
NW = str2double(get(handles.NW, 'String'));
K = str2double(get(handles.K, 'String'));
pad = str2double(get(handles.pad, 'String'));
trialave = get(handles.trialave, 'Value');

%BasicImpedanceAnalysis(filepath_v, filepath_i, duration, stim_onset, analysis_window, avg_window);
ImpedanceAnalysis_chronux(filepath_v, filepath_i, duration, ps_on, ps_end, stim_on, stim_end, Fmax, NW, K, Fs, fpass, pad, trialave);


function pre_stim_on_Callback(hObject, eventdata, handles)
% hObject    handle to pre_stim_on (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pre_stim_on as text
%        str2double(get(hObject,'String')) returns contents of pre_stim_on as a double


% --- Executes during object creation, after setting all properties.
function pre_stim_on_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pre_stim_on (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pre_stim_end_Callback(hObject, eventdata, handles)
% hObject    handle to pre_stim_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pre_stim_end as text
%        str2double(get(hObject,'String')) returns contents of pre_stim_end as a double


% --- Executes during object creation, after setting all properties.
function pre_stim_end_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pre_stim_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Fmax_Callback(hObject, eventdata, handles)
% hObject    handle to Fmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Fmax as text
%        str2double(get(hObject,'String')) returns contents of Fmax as a double


% --- Executes during object creation, after setting all properties.
function Fmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Fmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function K_Callback(hObject, eventdata, handles)
% hObject    handle to K (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of K as text
%        str2double(get(hObject,'String')) returns contents of K as a double


% --- Executes during object creation, after setting all properties.
function K_CreateFcn(hObject, eventdata, handles)
% hObject    handle to K (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NW_Callback(hObject, eventdata, handles)
% hObject    handle to NW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NW as text
%        str2double(get(hObject,'String')) returns contents of NW as a double


% --- Executes during object creation, after setting all properties.
function NW_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Fs_Callback(hObject, eventdata, handles)
% hObject    handle to Fs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Fs as text
%        str2double(get(hObject,'String')) returns contents of Fs as a double


% --- Executes during object creation, after setting all properties.
function Fs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Fs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in trialave.
function trialave_Callback(hObject, eventdata, handles)
% hObject    handle to trialave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of trialave



function fpass_Callback(hObject, eventdata, handles)
% hObject    handle to fpass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fpass as text
%        str2double(get(hObject,'String')) returns contents of fpass as a double


% --- Executes during object creation, after setting all properties.
function fpass_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fpass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pad_Callback(hObject, eventdata, handles)
% hObject    handle to pad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pad as text
%        str2double(get(hObject,'String')) returns contents of pad as a double


% --- Executes during object creation, after setting all properties.
function pad_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


