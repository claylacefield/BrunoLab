function varargout = STA(varargin)
% STA M-file for STA.fig
%      STA, by itself, creates a new STA or raises the existing
%      singleton*.
%
%      H = STA returns the handle to a new STA or the handle to
%      the existing singleton*.
%
%      STA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STA.M with the given input arguments.
%
%      STA('Property','Value',...) creates a new STA or raises the
%      existing singleton*.  STArting from the left, property value pairs are
%      applied to the GUI before STA_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to STA_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      inSTAnce to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help STA

% Last Modified by GUIDE v2.5 04-Jun-2003 18:28:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_state = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @STA_OpeningFcn, ...
                   'gui_OutputFcn',  @STA_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_state.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_state, varargin{:});
else
    gui_mainfcn(gui_state, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before STA is made visible.
function STA_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to STA (see VARARGIN)

% Choose default command line output for STA
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes STA wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = STA_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function duration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function duration_Callback(hObject, eventdata, handles)
% hObject    handle to duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of duration as text
%        str2double(get(hObject,'String')) returns contents of duration as a double


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
mode = get(hObject, 'Value');
switch mode
    case 1
        set(handles.duration, 'Enable', 'off');
        set(handles.winSTArt, 'String', '0');
        set(handles.winSTArt, 'Enable', 'off');
        set(handles.winend, 'String', 'Inf');
        set(handles.winend, 'Enable', 'off');
        set(handles.ShiftCorrect, 'Enable', 'off');
    case 2
        set(handles.duration, 'Enable', 'on');
        set(handles.winend, 'Enable', 'on');
        set(handles.winstart, 'Enable', 'on');
        set(handles.ShiftCorrect, 'Enable', 'on');
end


% --- Executes during object creation, after setting all properties.
function winstart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to winstart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function winstart_Callback(hObject, eventdata, handles)
% hObject    handle to winstart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of winstart as text
%        str2double(get(hObject,'String')) returns contents of winstart as a double


% --- Executes during object creation, after setting all properties.
function winend_CreateFcn(hObject, eventdata, handles)
% hObject    handle to winend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function winend_Callback(hObject, eventdata, handles)
% hObject    handle to winend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of winend as text
%        str2double(get(hObject,'String')) returns contents of winend as a double


% --- Executes on button press in ShiftCorrect.
function ShiftCorrect_Callback(hObject, eventdata, handles)
% hObject    handle to ShiftCorrect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ShiftCorrect

% --- Executes during object creation, after setting all properties.
function PreSpikeVmCriteria_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PreSpikeVmCriteria (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function PreSpikeVmCriteria_Callback(hObject, eventdata, handles)
% hObject    handle to PreSpikeVmCriteria (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PreSpikeVmCriteria as text
%        str2double(get(hObject,'String')) returns contents of PreSpikeVmCriteria as a double



% --- Executes during object creation, after setting all properties.
function filetype_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filetype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in filetype.
function filetype_Callback(hObject, eventdata, handles)
% hObject    handle to filetype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns filetype contents as cell array
%        contents{get(hObject,'Value')} returns selected item from filetype



% --- Executes on button press in OKbutton.
function OKbutton_Callback(hObject, eventdata, handles)
% hObject    handle to OKbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set parameters
if (get(handles.popupmenu1,'Value') == 1)
    %continuous acquisition
        duration = 2^32;
else
    %sweep/trial-based acquisition
        duration = str2double(get(handles.duration, 'String'));
end
switch get(handles.filetype, 'Value')
    case 1
        filetype = 'dat';
    case 2
        filetype = 'cluster';
end
winstart = str2double(get(handles.winstart, 'String'));
winend = str2double(get(handles.winend, 'String'));
ShiftCorrect = get(handles.ShiftCorrect, 'Value');
UpDownBorder = str2double(get(handles.PreSpikeVmCriteria, 'String'));

% select a spike file and read in spikes
switch filetype
    case 'dat'
        [filename pathname OK] = uigetfile(['*.dat'], 'Select triggering file');
    case 'cluster'
        [filename pathname OK] = uigetfile(['*.cluster?'], 'Select triggering file');
end
if (~OK) return; end

triggerpath = [pathname, filename];
switch filetype
    case 'dat'
        cluster = ReadDAT(triggerpath);
    case 'cluster'
        cluster = ReadCluster(triggerpath);
    otherwise
        error('STA.m: Appropriate filetype not specified.')
end
% excerpt specified time window
cluster = cluster(cluster(:,4) >= winstart & cluster(:,4) <= winend, :);

% select a continuous file
[filename pathname OK] = uigetfile('*.dat', 'Select file to average');
if (~OK) return; end
averagingpath = [pathname, filename];
disp([averagingpath, ' selected']);

% compute/plot the raw STA
figure(1);
[x, raw] = SpikeTriggerAverage(duration, cluster, averagingpath, UpDownBorder);
if (ShiftCorrect) subplot(3,1,1); end
plot(x, raw);
ylabel('Vm');
title('raw sta');

% compute/plot a shift corrector and a subtraction
if (ShiftCorrect)
    maxTrial = max(cluster(:,2));
    cluster = cluster(cluster(:,2) ~= maxTrial, :);
    cluster(:,2) = cluster(:,2) + 1;

    [x, shift] = SpikeTriggerAverage(duration, cluster, averagingpath, UpDownBorder);
    subplot(3,1,2);
    plot(x, shift);
    ylabel('Vm');
    title('shift corrector');
    
    corrected = raw - shift;
    subplot(3,1,3);
    plot(x, corrected);
    xlabel('lag (msec)');
    ylabel('delta Vm');
    title('corrected sta');
end

