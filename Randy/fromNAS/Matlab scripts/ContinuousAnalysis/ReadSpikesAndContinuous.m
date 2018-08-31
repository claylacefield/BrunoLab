function varargout = ReadSpikesAndContinuous(varargin)
% READSPIKESANDCONTINUOUS M-file for ReadSpikesAndContinuous.fig
%      READSPIKESANDCONTINUOUS, by itself, creates a new READSPIKESANDCONTINUOUS or raises the existing
%      singleton*.
%
%      H = READSPIKESANDCONTINUOUS returns the handle to a new READSPIKESANDCONTINUOUS or the handle to
%      the existing singleton*.
%
%      READSPIKESANDCONTINUOUS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in READSPIKESANDCONTINUOUS.M with the given input arguments.
%
%      READSPIKESANDCONTINUOUS('Property','Value',...) creates a new READSPIKESANDCONTINUOUS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ReadSpikesAndContinuous_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ReadSpikesAndContinuous_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ReadSpikesAndContinuous

% Last Modified by GUIDE v2.5 19-Feb-2011 20:58:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ReadSpikesAndContinuous_OpeningFcn, ...
                   'gui_OutputFcn',  @ReadSpikesAndContinuous_OutputFcn, ...
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


% --- Executes just before ReadSpikesAndContinuous is made visible.
function ReadSpikesAndContinuous_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ReadSpikesAndContinuous (see VARARGIN)

% Choose default command line output for ReadSpikesAndContinuous
handles.output = hObject;
%handles.trial = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ReadSpikesAndContinuous wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ReadSpikesAndContinuous_OutputFcn(hObject, eventdata, handles)
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

cd(get(handles.startpath, 'String'));
handles.cluster = ReadCluster;

[filename pathname OK] = uigetfile('*.dat', 'Select a .dat file containing a continuous signal');
if (~OK) return; end
filepath = fullfile(pathname, filename);
fid = fopen(filepath, 'r', 'b');
if (fid == -1)
    error('LoadFiles_Callbacks could not open file for reading.');
end
handles.filepath = filepath;
handles.headerSize = SkipHeader(fid);
set(handles.trial, 'String', '0');
fclose(fid);

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
if (trial < max(handles.cluster(:,2)))
    set(handles.trial, 'String', num2str(trial + 1));
    UpdateDisplays(handles);
end

% -- Called by NextButton and PrevButton
function UpdateDisplays(handles)

SAMPLERATE = 32000;

currentTrial = str2double(get(handles.trial, 'String'));
duration = str2double(get(handles.trialDuration, 'String'));
winStart = str2double(get(handles.winStart, 'String'));
winEnd = str2double(get(handles.winEnd, 'String'));

cluster = handles.cluster;
trial = cluster(:, 2);
cluster = cluster(trial==currentTrial, :);
timestamp = cluster(:, 4);
if nrows(cluster)
    sstim = cluster(1, 3);
else
    sstim = NaN;
end
set(handles.sstimcode, 'String', num2str(sstim));

axes(handles.SpikeGraph);
x = repeach(timestamp, 3);
y = repmat([0 1 0], 1, length(timestamp));
plot(x, y, 'g');
%xlim([0 500]);
xlim([winStart, winEnd]);
%plotedit('on');

fid = fopen(handles.filepath, 'r', 'b');
nScans = str2double(get(handles.trialDuration, 'String')) * SAMPLERATE / 1000;
recSize = (nScans + 1) * 4;
offset = handles.headerSize + currentTrial * recSize;
err = fseek(fid, offset, 'bof');
if (err) error('could not seek to start of record'); end
cstim = fread(fid, 1, 'float32');
set(handles.cstimcode, 'String', num2str(cstim));
cdata = fread(fid, nScans, 'float32') * 100; % put data on mV scale
fclose(fid);

axes(handles.ContinuousGraph);
cx = linspace(0, duration, nScans);
cy = cdata(cx >= winStart & cx <= winEnd);
cx = cx(cx >= winStart & cx <= winEnd);
plot(cx, cy);
ax = axis;
hold on;
plot(x, y*(ax(4)-ax(3))+ax(3), ':g');
hold off;
xlim([winStart, winEnd]);
%plotedit('on');

if ~isnan(sstim)
    if (cstim ~= sstim) errordlg('stimuli codes do not match'); end
end

% --- Executes during object creation, after setting all properties.
function winStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to winStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function winStart_Callback(hObject, eventdata, handles)
% hObject    handle to winStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of winStart as text
%        str2double(get(hObject,'String')) returns contents of winStart as a double

UpdateDisplays(handles);

% --- Executes during object creation, after setting all properties.
function winEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to winEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function winEnd_Callback(hObject, eventdata, handles)
% hObject    handle to winEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of winEnd as text
%        str2double(get(hObject,'String')) returns contents of winEnd as a double

UpdateDisplays(handles);


% --- Executes on button press in fullviewbutton.
function fullviewbutton_Callback(hObject, eventdata, handles)
% hObject    handle to fullviewbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.winStart, 'String', '0');
set(handles.winEnd, 'String', get(handles.trialDuration, 'String'));
UpdateDisplays(handles);


% --- Executes on button press in ZoomOnSpikeButton.
function ZoomOnSpikeButton_Callback(hObject, eventdata, handles)
% hObject    handle to ZoomOnSpikeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% have user select a spike in the spike graph
axes(handles.SpikeGraph);
[x, y] = ginput(1);

% extract timestamps for just the current trial
currentTrial = str2double(get(handles.trial, 'String'));
cluster = handles.cluster;
trial = cluster(:, 2);
cluster = cluster(trial==currentTrial, :);
timestamp = cluster(:, 4);
diff = abs(timestamp - x);
z = timestamp(diff == min(diff));
z = z(1);

set(handles.winStart, 'String', num2str(z-10));
set(handles.winEnd, 'String', num2str(z+50));
UpdateDisplays(handles);


% --- Executes on button press in GoToNextSpikeButton.
function GoToNextSpikeButton_Callback(hObject, eventdata, handles)
% hObject    handle to GoToNextSpikeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

winStart = str2double(get(handles.winStart, 'String'));
winEnd = str2double(get(handles.winEnd, 'String'));

% extract timestamps for just the current trial
currentTrial = str2double(get(handles.trial, 'String'));
cluster = handles.cluster;
trial = cluster(:, 2);
cluster = cluster(trial==currentTrial, :);
timestamp = cluster(:, 4);

% find next spike in trial
nextSpike = timestamp(timestamp > winStart+10);
if isempty(nextSpike)
    % nothing left in this trial
    if (currentTrial < max(handles.cluster(:,2)))
        set(handles.trial, 'String', num2str(currentTrial + 1));
        set(handles.winStart, 'String', '1');
        set(handles.winEnd, 'String', num2str(winEnd-winStart+1));
        GoToNextSpikeButton_Callback(hObject,eventdata,handles);
    else
        beep;
    end
    return
end
nextSpike = nextSpike(1);
set(handles.winStart, 'String', num2str(nextSpike-10));
set(handles.winEnd, 'String', num2str(nextSpike+50));
UpdateDisplays(handles);



function GoToTrial_Callback(hObject, eventdata, handles)
% hObject    handle to GoToTrial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GoToTrial as text
%        str2double(get(hObject,'String')) returns contents of GoToTrial as a double

selectedtrial = str2double(get(handles.GoToTrial, 'String'));

if selectedtrial >=0 & selectedtrial < max(handles.cluster(:,2))
    set(handles.trial, 'String',  num2str(selectedtrial));
    UpdateDisplays(handles);
end

% --- Executes during object creation, after setting all properties.
function GoToTrial_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GoToTrial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
