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
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before STA_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to STA_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above statictext1 to modify the response to help STA

% Last Modified by GUIDE v2.5 16-Feb-2005 15:16:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @STA_OpeningFcn, ...
                   'gui_OutputFcn',  @STA_OutputFcn, ...
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

% Hints: get(hObject,'String') returns contents of duration as statictext1
%        str2double(get(hObject,'String')) returns contents of duration as a double


% --- Executes during object creation, after setting all properties.
function acquisitionMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to acquisitionMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in acquisitionMode.
function acquisitionMode_Callback(hObject, eventdata, handles)
% hObject    handle to acquisitionMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns acquisitionMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from acquisitionMode


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

% Hints: get(hObject,'String') returns contents of winstart as statictext1
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

% Hints: get(hObject,'String') returns contents of winend as statictext1
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

% Hints: get(hObject,'String') returns contents of PreSpikeVmCriteria as statictext1
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
switch get(handles.filetype, 'Value')
    case 1
        filetype = 'dat';
    case 2
        filetype = 'cluster';
end
winstart = str2double(get(handles.winstart, 'String'));
winend = str2double(get(handles.winend, 'String'));
trialStart = str2double(get(handles.trialStart, 'String'));
trialEnd = str2double(get(handles.trialEnd, 'String'));
limit = str2double(get(handles.limits, 'String'));
ShiftCorrect = get(handles.ShiftCorrect, 'Value');
UpDownBorder = get(handles.PreSpikeVmCriteria, 'String');
GreaterThan = get(handles.GreaterThan, 'Value') - 1;
memoryless = get(handles.memoryless, 'Value');
lockout = str2num(get(handles.TClockout, 'String'));
lockout2 = str2num(get(handles.TClockout2, 'String'));
successorLockout = str2num(get(handles.minsuccessor, 'String'));
burstSpike = str2num(get(handles.burstSpike, 'String'));
burstCrit = str2num(get(handles.burstCrit, 'String'));

% read in triggering file
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

% select a continuous file
[filename pathname OK] = uigetfile('*.dat', 'Select file to average');
if (~OK) return; end
averagingpath = [pathname, filename];
disp([averagingpath, ' selected']);
    
if (get(handles.acquisitionMode, 'Value') == 1)
    %continuous acquisition
        duration = 2^32;
else
    %sweep/trial-based acquisition
    duration = str2double(get(handles.duration, 'String'));
end

% Call core subroutine
[amp, nshift] = STAanalysis(averagingpath, duration, triggerpath, cluster, winstart, winend, trialStart, trialEnd, lockout, lockout2, successorLockout, burstSpike, burstCrit, ShiftCorrect, ...
    limit, UpDownBorder, GreaterThan, memoryless, true, true);

% --- Executes during object creation, after setting all properties.
function TClockout_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TClockout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function TClockout_Callback(hObject, eventdata, handles)
% hObject    handle to TClockout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TClockout as statictext1
%        str2double(get(hObject,'String')) returns contents of TClockout as a double


% --- Executes during object creation, after setting all properties.
function GreaterThan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GreaterThan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in GreaterThan.
function GreaterThan_Callback(hObject, eventdata, handles)
% hObject    handle to GreaterThan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns GreaterThan contents as cell array
%        contents{get(hObject,'Value')} returns selected item from GreaterThan


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as statictext1
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function trialEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trialEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function trialEnd_Callback(hObject, eventdata, handles)
% hObject    handle to trialEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trialEnd as statictext1
%        str2double(get(hObject,'String')) returns contents of trialEnd as a double


% --- Executes during object creation, after setting all properties.
function trialStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trialStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function trialStart_Callback(hObject, eventdata, handles)
% hObject    handle to trialStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trialStart as statictext1
%        str2double(get(hObject,'String')) returns contents of trialStart as a double


% --- Executes during object creation, after setting all properties.
function limits_CreateFcn(hObject, eventdata, handles)
% hObject    handle to limits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function limits_Callback(hObject, eventdata, handles)
% hObject    handle to limits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of limits as text
%        str2double(get(hObject,'String')) returns contents of limits as a double


% --- Executes on button press in Memoryless.
function Memoryless_Callback(hObject, eventdata, handles)
% hObject    handle to Memoryless (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Memoryless


% --- Executes on button press in memoryless.
function memoryless_Callback(hObject, eventdata, handles)
% hObject    handle to memoryless (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of memoryless


% --- Executes during object creation, after setting all properties.
function burstSpike_CreateFcn(hObject, eventdata, handles)
% hObject    handle to burstSpike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function burstSpike_Callback(hObject, eventdata, handles)
% hObject    handle to burstSpike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of burstSpike as text
%        str2double(get(hObject,'String')) returns contents of burstSpike as a double


% --- Executes during object creation, after setting all properties.
function TClockout2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TClockout2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function TClockout2_Callback(hObject, eventdata, handles)
% hObject    handle to TClockout2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TClockout2 as text
%        str2double(get(hObject,'String')) returns contents of TClockout2 as a double


% --- Executes during object creation, after setting all properties.
function burstCrit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to burstCrit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function burstCrit_Callback(hObject, eventdata, handles)
% hObject    handle to burstCrit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of burstCrit as text
%        str2double(get(hObject,'String')) returns contents of burstCrit as a double


% --- Executes during object creation, after setting all properties.
function minsuccessor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minsuccessor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function minsuccessor_Callback(hObject, eventdata, handles)
% hObject    handle to minsuccessor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minsuccessor as text
%        str2double(get(hObject,'String')) returns contents of minsuccessor as a double


