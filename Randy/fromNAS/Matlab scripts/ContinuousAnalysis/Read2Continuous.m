function varargout = Read2Continuous(varargin)
% READ2CONTINUOUS M-file for Read2Continuous.fig
%      READ2CONTINUOUS, by itself, creates a new READ2CONTINUOUS or raises the existing
%      singleton*.
%
%      H = READ2CONTINUOUS returns the handle to a new READ2CONTINUOUS or the handle to
%      the existing singleton*.
%
%      READ2CONTINUOUS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in READ2CONTINUOUS.M with the given input arguments.
%
%      READ2CONTINUOUS('Property','Value',...) creates a new READ2CONTINUOUS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Read2Continuous_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Read2Continuous_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Read2Continuous

% Last Modified by GUIDE v2.5 18-Sep-2003 11:00:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Read2Continuous_OpeningFcn, ...
                   'gui_OutputFcn',  @Read2Continuous_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Read2Continuous is made visible.
function Read2Continuous_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Read2Continuous (see VARARGIN)

% Choose default command line output for Read2Continuous
handles.output = hObject;
%handles.trial = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Read2Continuous wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Read2Continuous_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function startpath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startpath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function startpath_Callback(hObject, eventdata, handles)
% hObject    handle to startpath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startpath as text
%        str2double(get(hObject,'String')) returns contents of startpath as a double


% --- Executes during object creation, after setting all properties.
function trialDuration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trialDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function trialDuration_Callback(hObject, eventdata, handles)
% hObject    handle to trialDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trialDuration as text
%        str2double(get(hObject,'String')) returns contents of trialDuration as a double


% --- Executes on button press in LoadFiles.
function LoadFiles_Callback(hObject, eventdata, handles)
% hObject    handle to LoadFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename pathname OK] = uigetfile('*.dat', 'Select whole-cell recording');
if (~OK) return; end
filepath = fullfile(pathname, filename);
fid = fopen(filepath, 'r', 'b');
if (fid == -1)
    error('LoadFiles_Callbacks could not open file for reading.');
end
handles.filepath1 = filepath;
handles.headerSize1 = SkipHeader(fid);
fclose(fid);

[filename pathname OK] = uigetfile('*.dat', 'Select LFP');
if (~OK) return; end
filepath = fullfile(pathname, filename);
fid = fopen(filepath, 'r', 'b');
if (fid == -1)
    error('LoadFiles_Callbacks could not open file for reading.');
end
handles.filepath2 = filepath;
handles.headerSize2 = SkipHeader(fid);
fclose(fid);

set(handles.trial, 'String', '0');
guidata(hObject, handles);

UpdateDisplays(handles);

% --- Executes on button press in PrevButton.
function PrevButton_Callback(hObject, eventdata, handles)
% hObject    handle to PrevButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

trial = str2double(get(handles.trial, 'String'));
if (trial > 0)
    set(handles.trial, 'String',  num2str(trial - 1));
    UpdateDisplays(handles);
end

% --- Executes on button press in NextButton.
function NextButton_Callback(hObject, eventdata, handles)
% hObject    handle to NextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

trial = str2double(get(handles.trial, 'String'));
set(handles.trial, 'String', num2str(trial + 1));
UpdateDisplays(handles);

% -- Called by NextButton and PrevButton
function UpdateDisplays(handles)

SAMPLERATE = 32000;

currentTrial = str2double(get(handles.trial, 'String'));
duration = str2double(get(handles.trialDuration, 'String'));

fid = fopen(handles.filepath1, 'r', 'b');
nScans = duration * SAMPLERATE / 1000;
recSize = (nScans + 1) * 4;
offset = handles.headerSize1 + currentTrial * recSize;
err = fseek(fid, offset, 'bof');
if (err) error('could not seek to start of record'); end
stim1 = fread(fid, 1, 'float32');
set(handles.stimcode1, 'String', num2str(stim1));
cdata1 = fread(fid, nScans, 'float32') * 100; % put data on mV scale
fclose(fid);

axes(handles.ContinuousGraph1);
plot(linspace(0, duration, nScans), cdata1);

fid = fopen(handles.filepath2, 'r', 'b');
recSize = (nScans + 1) * 4;
offset = handles.headerSize2 + currentTrial * recSize;
err = fseek(fid, offset, 'bof');
if (err) error('could not seek to start of record'); end
stim2 = fread(fid, 1, 'float32');
set(handles.stimcode2, 'String', num2str(stim2));
if (stim1 ~= stim2) warning('stimuli codes do not match'); end
cdata2 = fread(fid, nScans, 'float32');
fclose(fid);

axes(handles.ContinuousGraph2);
plot(linspace(0, duration, nScans), cdata2);

% plotedit('on');


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MoveGraph1_Callback(hObject, eventdata, handles)
% hObject    handle to MoveGraph1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure(3);
axes(handles.ContinuousGraph1);
set(handles.ContinuousGraph1,'Parent',3)