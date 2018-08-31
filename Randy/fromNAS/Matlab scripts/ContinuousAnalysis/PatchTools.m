function varargout = PatchTools(varargin)
% PATCHTOOLS M-file for PatchTools.fig
%      PATCHTOOLS, by itself, creates a new PATCHTOOLS or raises the existing
%      singleton*.
%
%      H = PATCHTOOLS returns the handle to a new PATCHTOOLS or the handle to
%      the existing singleton*.
%
%      PATCHTOOLS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PATCHTOOLS.M with the given input arguments.
%
%      PATCHTOOLS('Property','Value',...) creates a new PATCHTOOLS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PatchTools_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PatchTools_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PatchTools

% Last Modified by GUIDE v2.5 27-Oct-2003 11:03:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PatchTools_OpeningFcn, ...
                   'gui_OutputFcn',  @PatchTools_OutputFcn, ...
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


% --- Executes just before PatchTools is made visible.
function PatchTools_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PatchTools (see VARARGIN)

% Choose default command line output for PatchTools
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PatchTools wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PatchTools_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in SelectFileButton.
function SelectFileButton_Callback(hObject, eventdata, handles)
% hObject    handle to SelectFileButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

startpath = get(handles.StartPath, 'String');
cd(startpath);

[filename pathname OK] = uigetfile('*.dat', 'Select a dat file to read');
if (~OK) return; end
filepath = fullfile(pathname, filename);
set(handles.SelectedFileName, 'String', filepath);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function AnalysisPopupMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AnalysisPopupMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in AnalysisPopupMenu.
function AnalysisPopupMenu_Callback(hObject, eventdata, handles)
% hObject    handle to AnalysisPopupMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns AnalysisPopupMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from AnalysisPopupMenu


% --- Executes on button press in RunButton.
function RunButton_Callback(hObject, eventdata, handles)
% hObject    handle to RunButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

analysis = get(handles.AnalysisPopupMenu, 'Value');
filepath = get(handles.SelectedFileName, 'String');
duration = str2double(get(handles.duration, 'String'));
stimonset = str2double(get(handles.StimOnset, 'String'));
trialstart = str2double(get(handles.TrialStart, 'String'));
trialend = str2double(get(handles.TrialEnd, 'String'));

switch analysis
    case 1
        h = figure;
        VmDistribution(filepath, duration);
    case 2
        h = figure;
        measureRi(filepath, duration);
    case 3
        h = figure;
        VmByTrial(filepath, duration, stimonset, 1, 50, trialstart, trialend);
    case 4
        h = figure;
        MeanContinuous(filepath, duration, stimonset, true, [], trialstart, trialend);
    case 5
        h = figure;
        MeanContinuousByStim(filepath, duration, stimonset);
    case 6
        h = OverlayV(filepath, duration, stimonset);
    case 7
        h = figure;
        FindBestFilters4(filepath, duration);
    case 8
        SeparateSpikesAndPSPs(filepath, duration);
    case 9
        PolarPlots(filepath, duration, stimonset, [], [], 350, true, trialstart, trialend);
    case 10
        TuningTimeCourse(filepath, duration, stimonset);
    case 11
        h = figure;
        PowerSpectrum(filepath, duration);
    case 12
        DetectDownByMeanVar(filepath, duration);        
end

orient landscape;

if ~iselement(analysis, [8 9 10 12])
    figure(h);
    whitebg(h, 'w');
    plotedit('ON');
    set(h, 'Name', get(handles.SelectedFileName, 'String'));
end

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
function StimOnset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StimOnset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function StimOnset_Callback(hObject, eventdata, handles)
% hObject    handle to StimOnset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StimOnset as text
%        str2double(get(hObject,'String')) returns contents of StimOnset as a double


% --- Executes during object creation, after setting all properties.
function TrialStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TrialStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function TrialStart_Callback(hObject, eventdata, handles)
% hObject    handle to TrialStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TrialStart as text
%        str2double(get(hObject,'String')) returns contents of TrialStart as a double


% --- Executes during object creation, after setting all properties.
function TrialEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TrialEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function TrialEnd_Callback(hObject, eventdata, handles)
% hObject    handle to TrialEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TrialEnd as text
%        str2double(get(hObject,'String')) returns contents of TrialEnd as a double


% --- Executes during object creation, after setting all properties.
function StartPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StartPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

startpath = get(hObject, 'String');
cd(startpath);

function StartPath_Callback(hObject, eventdata, handles)
% hObject    handle to StartPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StartPath as text
%        str2double(get(hObject,'String')) returns contents of StartPath as a double

startpath = get(hObject, 'String');
cd(startpath);
