function varargout = CCG(varargin)
% CCG M-file for CCG.fig
%      CCG, by itself, creates a new CCG or raises the existing
%      singleton*.
%
%      H = CCG returns the handle to a new CCG or the handle to
%      the existing singleton*.
%
%      CCG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CCG.M with the given input arguments.
%
%      CCG('Property','Value',...) creates a new CCG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CCG_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CCG_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CCG

% Last Modified by GUIDE v2.5 14-Feb-2011 17:07:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CCG_OpeningFcn, ...
                   'gui_OutputFcn',  @CCG_OutputFcn, ...
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


% --- Executes just before CCG is made visible.
function CCG_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CCG (see VARARGIN)

% Choose default command line output for CCG
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CCG wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CCG_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in ShiftCorrect.
function ShiftCorrect_Callback(hObject, eventdata, handles)
% hObject    handle to ShiftCorrect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ShiftCorrect


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


% --- Executes during object creation, after setting all properties.
function triggerlockout_CreateFcn(hObject, eventdata, handles)
% hObject    handle to triggerlockout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function triggerlockout_Callback(hObject, eventdata, handles)
% hObject    handle to triggerlockout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of triggerlockout as text
%        str2double(get(hObject,'String')) returns contents of triggerlockout as a double


% --- Executes on button press in OKbutton.
function OKbutton_Callback(hObject, eventdata, handles)
% hObject    handle to OKbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (get(handles.popupmenu1,'Value') == 1)
    %continuous acquisition
        duration = 2^32;
else
    %sweep/trial-based acquisition
        duration = str2double(get(handles.duration, 'String'));
end

winstart = str2double(get(handles.winstart, 'String'));
winend = str2double(get(handles.winend, 'String'));
trialstart = str2double(get(handles.trialstart, 'String'));
trialend = str2double(get(handles.trialend, 'String'));
limits = str2double(get(handles.limits, 'String'));
binsize = str2double(get(handles.binsize, 'String'));
ShiftCorrect = get(handles.ShiftCorrect, 'Value');
interpolateZero = get(handles.interpolateZero, 'Value');
%ignoreRange = str2double(get(handles.ignoreRange, 'String'));
ignoreRange = str2double(handles.ignoreRange);
disp(ignoreRange)

% read in trigger spike file and read in spikes
[filename pathname OK] = uigetfile(['*cluster?'], 'Select trigger file');
if (~OK) return; end
clusterB = ReadCluster(fullfile(pathname, filename));
% excerpt specified time and trial windows
clusterB = clusterB(clusterB(:,4) >= winstart & clusterB(:,4) <= winend ...
    & clusterB(:,2) >= trialstart & clusterB(:,2) <= trialend, :);

% apply trigger ISI lockout, if any
lockout = str2num(get(handles.triggerlockout, 'String'));
if (lockout)
    ISI = ISIof(clusterB);
    clusterB = clusterB(ISI > lockout, :);
end

% select a target file
[filename pathname OK] = uigetfile('*cluster?', 'Select target file');
if (~OK) return; end
clusterA = ReadCluster(fullfile(pathname, filename));
% excerpt specified time and trial windows
clusterA = clusterA(clusterA(:,4) >= winstart & clusterA(:,4) <= winend ...
    & clusterA(:,2) >= trialstart & clusterA(:,2) <= trialend, :);

figure;
CrossCorrelationAnalysis(clusterA, clusterB, winstart, winend, 0, 1000, limits, binsize, ShiftCorrect, interpolateZero, ignoreRange);

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


% --- Executes during object creation, after setting all properties.
function binsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to binsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function binsize_Callback(hObject, eventdata, handles)
% hObject    handle to binsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of binsize as text
%        str2double(get(hObject,'String')) returns contents of binsize as a double


% --- Executes on button press in interpolateZero.
function interpolateZero_Callback(hObject, eventdata, handles)
% hObject    handle to interpolateZero (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of interpolateZero




% --- Executes on button press in ignore.
function ignore_Callback(hObject, eventdata, handles)
% hObject    handle to ignore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ignore

if ~get(hObject,'Value')
    handles.ignoreRange = '0';
    guidata(hObject, handles);
end

function ignoreRange_Callback(hObject, eventdata, handles)
% hObject    handle to ignoreRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ignoreRange as text
%        str2double(get(hObject,'String')) returns contents of ignoreRange as a double


% --- Executes during object creation, after setting all properties.
function ignoreRange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ignoreRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function trialstart_Callback(hObject, eventdata, handles)
% hObject    handle to trialstart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trialstart as text
%        str2double(get(hObject,'String')) returns contents of trialstart as a double


% --- Executes during object creation, after setting all properties.
function trialstart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trialstart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function trialend_Callback(hObject, eventdata, handles)
% hObject    handle to trialend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trialend as text
%        str2double(get(hObject,'String')) returns contents of trialend as a double


% --- Executes during object creation, after setting all properties.
function trialend_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trialend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
