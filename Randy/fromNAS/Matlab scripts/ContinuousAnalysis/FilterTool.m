function varargout = FilterTool(varargin)
% FILTERTOOL M-file for FilterTool.fig
%      FILTERTOOL, by itself, creates a new FILTERTOOL or raises the existing
%      singleton*.
%
%      H = FILTERTOOL returns the handle to a new FILTERTOOL or the handle to
%      the existing singleton*.
%
%      FILTERTOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FILTERTOOL.M with the given input arguments.
%
%      FILTERTOOL('Property','Value',...) creates a new FILTERTOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Read2Continuous_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FilterTool_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FilterTool

% Last Modified by GUIDE v2.5 26-Sep-2014 15:19:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FilterTool_OpeningFcn, ...
                   'gui_OutputFcn',  @FilterTool_OutputFcn, ...
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


% --- Executes just before FilterTool is made visible.
function FilterTool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FilterTool (see VARARGIN)

% Choose default command line output for FilterTool
handles.output = hObject;
%handles.trial = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FilterTool wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FilterTool_OutputFcn(hObject, eventdata, handles)
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

handles.scanrate = GetScanrate(filepath);
set(handles.samplingRate, 'String', num2str(handles.scanrate));

% [filename pathname OK] = uigetfile('*.dat', 'Select LFP');
% if (~OK) return; end
% filepath = fullfile(pathname, filename);
% fid = fopen(filepath, 'r', 'b');
% if (fid == -1)
%     error('LoadFiles_Callbacks could not open file for reading.');
% end
% handles.filepath2 = filepath;
% handles.headerSize2 = SkipHeader(fid);
% fclose(fid);

set(handles.trial, 'String', '0');
guidata(hObject, handles);

UpdateDisplays(hObject, handles);

% --- Executes on button press in PrevButton.
function PrevButton_Callback(hObject, eventdata, handles)
% hObject    handle to PrevButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

trial = str2double(get(handles.trial, 'String'));
if (trial > 0)
    set(handles.trial, 'String',  num2str(trial - 1));
    UpdateDisplays(hObject, handles);
end

% --- Executes on button press in NextButton.
function NextButton_Callback(hObject, eventdata, handles)
% hObject    handle to NextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

trial = str2double(get(handles.trial, 'String'));
set(handles.trial, 'String', num2str(trial + 1));
UpdateDisplays(hObject, handles);

% -- Called by NextButton and PrevButton
function UpdateDisplays(hObject, handles)

currentTrial = str2double(get(handles.trial, 'String'));
duration = str2double(get(handles.trialDuration, 'String'));

fid = fopen(handles.filepath1, 'r', 'b');
nScans = duration * handles.scanrate / 1000;
recSize = (nScans + 1) * 4;
offset = handles.headerSize1 + currentTrial * recSize;
err = fseek(fid, offset, 'bof');
if (err) error('could not seek to start of record'); end
stim1 = fread(fid, 1, 'float32');
set(handles.stimcode1, 'String', num2str(stim1));
cdata1 = fread(fid, nScans, 'float32') * 100; % put data on mV scale

handles.cdata1 = cdata1;
guidata(hObject, handles);

fclose(fid);

axes(handles.ContinuousGraph1);
plot(linspace(0, duration, nScans), cdata1);

% fid = fopen(handles.filepath2, 'r', 'b');
% recSize = (nScans + 1) * 4;
% offset = handles.headerSize2 + currentTrial * recSize;
% err = fseek(fid, offset, 'bof');
% if (err) error('could not seek to start of record'); end
% stim2 = fread(fid, 1, 'float32');
% set(handles.stimcode2, 'String', num2str(stim2));
% if (stim1 ~= stim2) warning('stimuli codes do not match'); end
% cdata2 = fread(fid, nScans, 'float32');
% fclose(fid);
% 
% axes(handles.ContinuousGraph2);
% plot(linspace(0, duration, nScans), cdata2);

% [c,lags] = xcorr(cdata1, -(cdata2), 'coeff');
% [c,lags] = xcorr(cdata1 - mean(cdata1), -(cdata2-mean(cdata2)), 'coeff');
% axes(handles.ContinuousGraph3);
% plot(lags/32,c);

% plotedit('on');
drawnow;

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



function MedFiltSize_Callback(hObject, eventdata, handles)
% hObject    handle to MedFiltSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MedFiltSize as text
%        str2double(get(hObject,'String')) returns contents of MedFiltSize as a double


% --- Executes during object creation, after setting all properties.
function MedFiltSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MedFiltSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RunMedFiltButton.
function RunMedFiltButton_Callback(hObject, eventdata, handles)
% hObject    handle to RunMedFiltButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

SAMPLERATE = handles.scanrate;
DOWNSAMPLEFACTOR = 16;
duration = str2double(get(handles.trialDuration, 'String'));
nScans = duration * SAMPLERATE / DOWNSAMPLEFACTOR / 1000;
x = linspace(0, duration, nScans);

bandwidth = str2double(get(handles.MedFiltSize, 'String'));
cdata1 = handles.cdata1;
% downsample so that median filtering doesn't take too long
cdata1 = decimate(cdata1, DOWNSAMPLEFACTOR);

% median filtering
cdata2 = medfilt1(cdata1, round(SAMPLERATE/1000/DOWNSAMPLEFACTOR*bandwidth));
axes(handles.ContinuousGraph2);
plot(x, cdata2);
ylim([min(cdata2(2:end-1)) max(cdata2(2:end-1))]);

% subtract median filter off of raw voltage
cdata3 = cdata1 - cdata2;
axes(handles.ContinuousGraph3);
plot(x, cdata3);
ylim([min(cdata3(2:end-1)) max(cdata3(2:end-1))]);

drawnow;


function Fcutoff_Callback(hObject, eventdata, handles)
% hObject    handle to Fcutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Fcutoff as text
%        str2double(get(hObject,'String')) returns contents of Fcutoff as a double


% --- Executes during object creation, after setting all properties.
function Fcutoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Fcutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RunLowpassButton.
function RunLowpassButton_Callback(hObject, eventdata, handles)
% hObject    handle to RunLowpassButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

SAMPLERATE = handles.scanrate;
duration = str2double(get(handles.trialDuration, 'String'));
nScans = duration * SAMPLERATE / 1000;
x = linspace(0, duration, nScans);

Fc = str2double(get(handles.Fcutoff, 'String'));
cdata1 = handles.cdata1;

h = msgbox('Running filter...');
cdata2 = highpassbutter(cdata1, Fc, SAMPLERATE);
close(h);
axes(handles.ContinuousGraph2);
plot(x, cdata2);
n = length(cdata2);
excerpt = cdata2(n*.1:n*.9);
ylim([min(excerpt) max(excerpt)]);
%xlim([0 n]);

cdata3 = cdata1 - cdata2;
axes(handles.ContinuousGraph3);
plot(x,cdata3);
n = length(cdata3);
excerpt = cdata3(n*.1:n*.9);
ylim([min(excerpt) max(excerpt)]);
%xlim([0 n]);
drawnow;





function Fpass1_Callback(hObject, eventdata, handles)
% hObject    handle to Fpass1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Fpass1 as text
%        str2double(get(hObject,'String')) returns contents of Fpass1 as a double


% --- Executes during object creation, after setting all properties.
function Fpass1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Fpass1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RunBandpassButton.
function RunBandpassButton_Callback(hObject, eventdata, handles)
% hObject    handle to RunBandpassButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

SAMPLERATE = handles.scanrate;
DOWNSAMPLEFACTOR = 16;
duration = str2double(get(handles.trialDuration, 'String'));
nScans = duration * SAMPLERATE / 1000;

fp1 = str2double(get(handles.Fpass1, 'String'));
fp2 = str2double(get(handles.Fpass2, 'String'));
cdata1 = handles.cdata1;

h = msgbox('Running filter...');
cdata2 = bandpassfilter(cdata1, fp1, fp2);
close(h);
axes(handles.ContinuousGraph2);
plot(cdata2);
n = length(cdata2);
excerpt = cdata2(n*.1:n*.9);
ylim([min(excerpt) max(excerpt)]);
xlim([0 n]);

cdata3 = cdata1 - cdata2;
axes(handles.ContinuousGraph3);
plot(cdata3);
n = length(cdata3);
excerpt = cdata3(n*.1:n*.9);
ylim([min(excerpt) max(excerpt)]);
xlim([0 n]);
drawnow;


function Fpass2_Callback(hObject, eventdata, handles)
% hObject    handle to Fpass2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Fpass2 as text
%        str2double(get(hObject,'String')) returns contents of Fpass2 as a double


% --- Executes during object creation, after setting all properties.
function Fpass2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Fpass2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in PlotCvSkew.
function PlotCvSkew_Callback(hObject, eventdata, handles)
% hObject    handle to PlotCvSkew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

duration = str2double(get(handles.trialDuration, 'String'));
SAMPLERATE = handles.scanrate;
nScans = duration * SAMPLERATE / 1000;
x = linspace(0, duration, nScans);
binwidth = str2double(get(handles.MedFiltSize, 'String'));
nbins = duration / binwidth;

CV = zeros(nbins, 1);
S = zeros(nbins, 1);
for i = 1:nbins
    excerpt = handles.cdata1(x > binwidth * (i-1) & x < binwidth * i);
    CV(i) = std(excerpt) / mean(excerpt);
    S(i) = skewness(excerpt);
end

NEWLIMITS = [0 6000];

axes(handles.ContinuousGraph1);
xlim(NEWLIMITS);

axes(handles.ContinuousGraph2);
plot((1:nbins)*binwidth, CV);
xlim(NEWLIMITS);

axes(handles.ContinuousGraph3);
plot((1:nbins)*binwidth, S);
xlim(NEWLIMITS);




% --- Executes on button press in PowerSpectrumButton.
function PowerSpectrumButton_Callback(hObject, eventdata, handles)
% hObject    handle to PowerSpectrumButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

y = handles.cdata1;
Fs = handles.scanrate;
h = spectrum.periodogram;
Hpsd=psd(h,y-median(y),'Fs',Fs);
axes(handles.ContinuousGraph2);
plot(Hpsd);
xlim([0.001 .02])


% --------------------------------------------------------------------
function CopyGraph1_Callback(hObject, eventdata, handles)
% hObject    handle to CopyGraph1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Create a figure to receive this axes' data
axes1fig = figure;
% Copy the axes and size it to the figure
axes1copy = copyobj(handles.ContinuousGraph1,axes1fig);
set(axes1copy,'Units','Normalized',...
              'Position',[.05,.20,.90,.60])
% Assemble a title for this new figure
str = [get(handles.uipanel3,'Title') ' for ' ...
       get(handles.poplabel,'String')];
title(str,'Fontweight','bold')
% Save handles to new fig and axes in case
% we want to do anything else to them
handles.axes1fig = axes1fig;
handles.axes1copy = axes1copy;
guidata(hObject,handles);



% --- Executes on button press in DerivativeButton.
function DerivativeButton_Callback(hObject, eventdata, handles)
% hObject    handle to DerivativeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

DOWNSAMPLE = 128;
SAMPLERATE = handles.scanrate;
duration = str2double(get(handles.trialDuration, 'String'));
nScans = duration * SAMPLERATE / 1000;
x = linspace(0, duration, nScans);

cdata1 = handles.cdata1;

% calculate derivative
cdata2 = diff(decimate(cdata1,DOWNSAMPLE));
axes(handles.ContinuousGraph2);
plot(cdata2);
n = length(cdata2);
ylim([min(cdata2(2:end-1)) max(cdata2(2:end-1))]);
xlim([0 n]);

% subtract median filter off of raw voltage
% cdata3 = cdata1 - cdata2;
% axes(handles.ContinuousGraph3);
% plot(cdata3);
% n = length(cdata3);
% ylim([min(cdata3(2:end-1)) max(cdata3(2:end-1))]);
% xlim([0 n]);

drawnow;


% --------------------------------------------------------------------
function CopyGraph2_Callback(hObject, eventdata, handles)
% hObject    handle to CopyGraph2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Create a figure to receive this axes' data
axes2fig = figure;
% Copy the axes and size it to the figure
axes2copy = copyobj(handles.ContinuousGraph2,axes2fig);
set(axes2copy,'Units','Normalized',...
              'Position',[.05,.20,.90,.60])
% Assemble a title for this new figure
str = [get(handles.uipanel3,'Title') ' for ' ...
       get(handles.poplabel,'String')];
title(str,'Fontweight','bold')
% Save handles to new fig and axes in case
% we want to do anything else to them
handles.axes2fig = axes2fig;
handles.axes2copy = axes2copy;
guidata(hObject,handles);


% --- Executes on slider movement.
function DerivSlider_Callback(hObject, eventdata, handles)
% hObject    handle to DerivSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

DOWNSAMPLE = round(get(hObject,'Value'));
currentwindow = str2double(handles.DerivWindow);
if DOWNSAMPLE == currentwindow
    return
end

SAMPLERATE = handles.scanrate;
duration = str2double(get(handles.trialDuration, 'String'));
nScans = duration * SAMPLERATE / 1000;
x = linspace(0, duration, nScans);

cdata1 = handles.cdata1;

% display derivative (decimated)
cdata2 = diff(decimate(cdata1,DOWNSAMPLE * SAMPLERATE/1000));
axes(handles.ContinuousGraph2);
plot(cdata2);
n = length(cdata2);
ylim([min(cdata2(2:end-1)) max(cdata2(2:end-1))]);
xlim([0 n]);
ylabel('decimated DmV');

% display derivative (only downsampled)
cdata3 = diff(downsample(cdata1,DOWNSAMPLE * SAMPLERATE/1000));
axes(handles.ContinuousGraph3);
plot(cdata3);
n = length(cdata3);
ylim([min(cdata3(2:end-1)) max(cdata3(2:end-1))]);
xlim([0 n]);
ylabel('downsampled DmV');


set(handles.DerivWindow, 'String', num2str(DOWNSAMPLE));
guidata(hObject, handles);
drawnow;

% --- Executes during object creation, after setting all properties.
function DerivSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DerivSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in NotchFilterButton.
function NotchFilterButton_Callback(hObject, eventdata, handles)
% hObject    handle to NotchFilterButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

SAMPLERATE = handles.scanrate;
duration = str2double(get(handles.trialDuration, 'String'));
nScans = duration * SAMPLERATE / 1000;

fp1 = str2double(get(handles.Fpass1, 'String'));
fp2 = str2double(get(handles.Fpass2, 'String'));
cdata1 = handles.cdata1;

h = msgbox('Running filter...');
cdata2 = notchfilter(cdata1);
close(h);
axes(handles.ContinuousGraph2);
plot(cdata2);
n = length(cdata2);
excerpt = cdata2(n*.1:n*.9);
% ylim([min(excerpt) max(excerpt)]);
% xlim([0 n]);

cdata3 = cdata1 - cdata2;
axes(handles.ContinuousGraph3);
plot(cdata3);
n = length(cdata3);
excerpt = cdata3(n*.1:n*.9);
% ylim([min(excerpt) max(excerpt)]);
% xlim([0 n]);
drawnow;



function boxcarSize_Callback(hObject, eventdata, handles)
% hObject    handle to boxcarSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of boxcarSize as text
%        str2double(get(hObject,'String')) returns contents of boxcarSize as a double


% --- Executes during object creation, after setting all properties.
function boxcarSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to boxcarSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RunBoxcarFilterButton.
function RunBoxcarFilterButton_Callback(hObject, eventdata, handles)
% hObject    handle to RunBoxcarFilterButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

SAMPLERATE = handles.scanrate;
duration = str2double(get(handles.trialDuration, 'String'));
nScans = duration * SAMPLERATE / 1000;
x = linspace(0, duration, nScans);

bandwidth = str2double(get(handles.boxcarSize, 'String'));
bandwidth = bandwidth * SAMPLERATE / 1000;
cdata1 = handles.cdata1;

% filtering
cdata2 = BoxcarFilter(cdata1, bandwidth);
axes(handles.ContinuousGraph2);
plot(x, cdata2);
ylim([min(cdata2(bandwidth:end-1)) max(cdata2(bandwidth:end-1))]);

% subtract filter off of raw voltage
cdata3 = cdata1 - cdata2;
axes(handles.ContinuousGraph3);
plot(x, cdata3);
ylim([min(cdata3(bandwidth:end-1)) max(cdata3(bandwidth:end-1))]);

drawnow;
