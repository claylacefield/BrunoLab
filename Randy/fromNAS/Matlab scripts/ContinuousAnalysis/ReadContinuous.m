function varargout = ReadContinuous(varargin)
% READCONTINUOUS M-file for ReadContinuous.fig
%      READCONTINUOUS, by itself, creates a new READCONTINUOUS or raises the existing
%      singleton*.
%
%      H = READCONTINUOUS returns the handle to a new READCONTINUOUS or the handle to
%      the existing singleton*.
%
%      READCONTINUOUS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in READCONTINUOUS.M with the given input arguments.
%
%      READCONTINUOUS('Property','Value',...) creates a new READCONTINUOUS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Read2Continuous_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ReadContinuous_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ReadContinuous

% Last Modified by GUIDE v2.5 20-Dec-2013 16:26:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ReadContinuous_OpeningFcn, ...
                   'gui_OutputFcn',  @ReadContinuous_OutputFcn, ...
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


% --- Executes just before ReadContinuous is made visible.
function ReadContinuous_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ReadContinuous (see VARARGIN)

% Choose default command line output for ReadContinuous
handles.output = hObject;
%handles.trial = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ReadContinuous wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ReadContinuous_OutputFcn(hObject, eventdata, handles)
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

[filename pathname OK] = uigetfile('*.dat', 'Select continuous recording');
if (~OK) return; end
filepath = fullfile(pathname, filename);
fid = fopen(filepath, 'r', 'b');
if (fid == -1)
    error('LoadFiles_Callbacks could not open file for reading.');
end
handles.filepath1 = filepath;
[handles.headerSize1, header] = SkipHeader(fid);
fclose(fid);
set(handles.filepathField, 'String', filepath);
set(handles.headerField, 'String', header);

d = get(handles.trialDuration, 'String');
if strcmp(d, 'auto')
    set(handles.trialDuration, 'String', num2str(GetTrialDuration(filepath)));
end
duration = str2double(get(handles.trialDuration, 'String'));
handles.nrecs = GetNumberOfRecords(filepath, duration);
handles.scanrate = GetScanrate(filepath);

set(handles.trial, 'String', '0');

UpdateDisplays(handles);

%set up the zoom window
hg = handles.ContinuousGraph1;
x = xlim(hg);
y = ylim(hg);
handles.ROIp = [x(1) y(1) x(2)-x(1) y(2)-y(1)];
handles.ROIh = imrect(handles.ContinuousGraph1, handles.ROIp);
api = iptgetapi(handles.ROIh);
api.setColor('r');
fcn = makeConstrainToRectFcn('imrect', get(gca,'XLim'),get(gca,'YLim'));
api.setPositionConstraintFcn(fcn);
% add a callback to update traces display when position is changed
api.addNewPositionCallback(@(p) UpdateZoomGraph(hObject, handles));

guidata(hObject, handles);

% --- Executes on button press in PrevButton.
function PrevButton_Callback(hObject, eventdata, handles)
% hObject    handle to PrevButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

trial = str2double(get(handles.trial, 'String'));
if (trial > 0)
    set(handles.trial, 'String',  num2str(trial - 1));
    UpdateDisplays(handles);
    RedisplayROI(hObject, handles);
end

% --- Executes on button press in NextButton.
function NextButton_Callback(hObject, eventdata, handles)
% hObject    handle to NextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

trial = str2double(get(handles.trial, 'String'));
if trial < (handles.nrecs - 1)
    set(handles.trial, 'String', num2str(trial + 1));    
    UpdateDisplays(handles);
    RedisplayROI(hObject, handles);
end

function UpdateDisplays(handles)
% Called by NextButton and PrevButton and other functions
% to change the data in the full and zoom graphs
% (whenever a different trial must be displayed)

SAMPLERATE = handles.scanrate;

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

axes(handles.ZoomGraph);
plot(linspace(0, duration, nScans), cdata1);
drawnow;

function RedisplayROI(hObject, handles)

%put the ROI back on the graph
h = imrect(handles.ContinuousGraph1, handles.ROIp);
handles.ROIh = h;
api = iptgetapi(h);
api.setColor('r');
fcn = makeConstrainToRectFcn('imrect', get(gca,'XLim'),get(gca,'YLim'));
api.setPositionConstraintFcn(fcn);
% add a callback to update traces display when position is changed
api.addNewPositionCallback(@(p) UpdateZoomGraph(hObject, handles));
UpdateZoomGraph(hObject, handles);

function UpdateZoomGraph(hObject, handles)
% updates the scales of the zoom graph

api = iptgetapi(handles.ROIh);
p = api.getPosition();
p = round(p);
axes(handles.ZoomGraph);
xlim([p(1) p(1)+p(3)]);
handles.ROIp = p;
guidata(hObject, handles);

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



function GoToRecordField_Callback(hObject, eventdata, handles)
% hObject    handle to GoToRecordField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GoToRecordField as text
%        str2double(get(hObject,'String')) returns contents of GoToRecordField as a double

GoToRec = str2double(get(hObject,'String'));

if GoToRec >= 0
    set(handles.trial, 'String',  num2str(GoToRec));
    UpdateDisplays(handles);
end

% --- Executes during object creation, after setting all properties.
function GoToRecordField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GoToRecordField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

