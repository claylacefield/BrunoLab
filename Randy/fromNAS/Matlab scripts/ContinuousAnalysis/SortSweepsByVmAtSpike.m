function varargout = SortSweepsByVmAtSpike(varargin)
% SORTSWEEPSBYVMATSPIKE M-file for SortSweepsByVmAtSpike.fig
%      SORTSWEEPSBYVMATSPIKE, by itself, creates a new SORTSWEEPSBYVMATSPIKE or raises the existing
%      singleton*.
%
%      H = SORTSWEEPSBYVMATSPIKE returns the handle to a new SORTSWEEPSBYVMATSPIKE or the handle to
%      the existing singleton*.
%
%      SORTSWEEPSBYVMATSPIKE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SORTSWEEPSBYVMATSPIKE.M with the given input arguments.
%
%      SORTSWEEPSBYVMATSPIKE('Property','Value',...) creates a new SORTSWEEPSBYVMATSPIKE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SortSweepsByVmAtSpike_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SortSweepsByVmAtSpike_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SortSweepsByVmAtSpike

% Last Modified by GUIDE v2.5 09-Jul-2003 16:01:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SortSweepsByVmAtSpike_OpeningFcn, ...
                   'gui_OutputFcn',  @SortSweepsByVmAtSpike_OutputFcn, ...
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


% --- Executes just before SortSweepsByVmAtSpike is made visible.
function SortSweepsByVmAtSpike_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SortSweepsByVmAtSpike (see VARARGIN)

% Choose default command line output for SortSweepsByVmAtSpike
handles.output = hObject;
%handles.trial = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SortSweepsByVmAtSpike wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SortSweepsByVmAtSpike_OutputFcn(hObject, eventdata, handles)
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

set(0,'RecursionLimit', 1000)

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
set(handles.spikeNumber, 'String', '0');
fclose(fid);

%clear assignments
handles.assignment = ones(1, nrows(handles.cluster));

guidata(hObject, handles);

NextButton_Callback(hObject, eventdata, handles);

% --- Executes on button press in PrevButton.
function PrevButton_Callback(hObject, eventdata, handles)
% hObject    handle to PrevButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

LIMIT = 100;

cluster = handles.cluster;
duration = str2double(get(handles.trialDuration, 'String'));
spikeNumber = str2double(get(handles.spikeNumber, 'String'));
winStart = str2double(get(handles.winStart, 'String'));
winEnd = str2double(get(handles.winEnd, 'String'));

if (spikeNumber > 1)
    newTime = cluster(spikeNumber, 4); % 0 because Matlab arrays are not zero-indexed
    set(handles.spikeNumber, 'String', num2str(spikeNumber - 1));
    if (newTime < winStart | newTime > winEnd | newTime < LIMIT |  newTime > duration-LIMIT)
        PrevButton_Callback(hObject, eventdata, handles);
    else
        UpdateDisplays(handles);
    end
end

% --- Executes on button press in NextButton.
function NextButton_Callback(hObject, eventdata, handles)
% hObject    handle to NextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

LIMIT = 100;

cluster = handles.cluster;
duration = str2double(get(handles.trialDuration, 'String'));
spikeNumber = str2double(get(handles.spikeNumber, 'String'));
winStart = str2double(get(handles.winStart, 'String'));
winEnd = str2double(get(handles.winEnd, 'String'));

if (spikeNumber < nrows(cluster)-1)
    newTime = cluster(spikeNumber+2, 4); % +2 because Matlab arrays are not zero-indexed
    set(handles.spikeNumber, 'String', num2str(spikeNumber + 1));
    if (newTime < winStart | newTime > winEnd | newTime < LIMIT |  newTime > duration-LIMIT)
        NextButton_Callback(hObject, eventdata, handles);
    else
        UpdateDisplays(handles);
    end
else
    errordlg('End of file reached.');
end

% -- Called by NextButton and PrevButton
function UpdateDisplays(handles)

SAMPLERATE = 32000;
LIMIT = 100;

duration = str2double(get(handles.trialDuration, 'String'));
spikeNumber = str2double(get(handles.spikeNumber, 'String'));

cluster = handles.cluster;
spiketime = cluster(spikeNumber+1, 4);
currentTrial = cluster(spikeNumber+1, 2);
set(handles.trial, 'String', num2str(currentTrial));
sstim = cluster(spikeNumber+1, 3);
cluster = cluster(cluster(:,2) == currentTrial, :);
timestamp = cluster(:, 4);
set(handles.sstimcode, 'String', num2str(sstim));
set(handles.VmAssignment, 'Value', handles.assignment(spikeNumber+1));

% plot just spikes around current spike
winstart = spiketime-LIMIT;
winend = spiketime+LIMIT;
timestamp = timestamp(timestamp >= winstart & timestamp <= winend);
axes(handles.SpikeGraph);
x = repeach(timestamp, 3);
y = repmat([0 1 0], 1, length(timestamp));
plot(x, y);
xlim([winstart winend]);
plotedit('on');

fid = fopen(handles.filepath, 'r', 'b');
nScansRecord = str2double(get(handles.trialDuration, 'String')) * SAMPLERATE / 1000;
recSize = (nScansRecord + 1) * 4;
offset = handles.headerSize + currentTrial * recSize;
err = fseek(fid, offset, 'bof');
if (err) errordlg('could not seek to start of record'); end
cstim = fread(fid, 1, 'float32');
set(handles.cstimcode, 'String', num2str(cstim));
err = fseek(fid, round(winstart * SAMPLERATE / 1000) * 4, 'cof');
if (err) errordlg('could not seek to start of sample'); end
nScansWindow = 2 * LIMIT * SAMPLERATE / 1000 + 1;
cdata = fread(fid, nScansWindow, 'float32') * 100; % put data on mV scale
fclose(fid);

axes(handles.ContinuousGraph);
plot(linspace(winstart, winend, nScansWindow), cdata);
xlim([winstart winend]);
ylim([-80, -20]);
plotedit('on');

if (cstim ~= sstim) errordlg('stimuli codes do not match'); end


% --- Executes during object creation, after setting all properties.
function VmAssignment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VmAssignment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in VmAssignment.
function VmAssignment_Callback(hObject, eventdata, handles)
% hObject    handle to VmAssignment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns VmAssignment contents as cell array
%        contents{get(hObject,'Value')} returns selected item from VmAssignment

spikeNumber = str2double(get(handles.spikeNumber, 'String'));
assign = get(hObject, 'Value');

handles.assignment(spikeNumber+1) = assign;
guidata(hObject, handles);

NextButton_Callback(hObject, eventdata, handles);

% --- Executes on button press in WriteFiles.
function WriteFiles_Callback(hObject, eventdata, handles)
% hObject    handle to WriteFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

LIMIT = 100;
SAMPLERATE = 32000;

cluster = handles.cluster;

% open continuous signal for reading
fid = fopen(handles.filepath, 'r', 'b');
duration = str2double(get(handles.trialDuration, 'String'));
nScansRecord =  duration * SAMPLERATE / 1000;
recSize = (nScansRecord + 1) * 4;
nSpikes = nrows(cluster);
nScansWindow = 2 * LIMIT * SAMPLERATE / 1000; % + 1
fileroot = handles.filepath(1:(length(handles.filepath)-4));

upid = fopen([fileroot '.up.dat'], 'w', 'b');
count = fwrite(upid, ['%%ENDHEADER' char(10)]);
if (count==0) errordlg('could not write to file'); end
downid = fopen([fileroot '.down.dat'], 'w', 'b');
count = fwrite(downid, ['%%ENDHEADER' char(10)]);
if (count==0) errordlg('could not write to file'); end

for i = 1:nrows(cluster)
    spiketime = cluster(i, 4);
    if (spiketime >= LIMIT & spiketime <= duration-LIMIT)
        winstart = spiketime - LIMIT;
        sstim = cluster(i, 3);
        trial = cluster(i, 2);
        offset = handles.headerSize + trial * recSize;
        err = fseek(fid, offset, 'bof');
        if (err) error('could not seek to start of record'); end
        cstim = fread(fid, 1, 'float32');
        if (cstim ~= sstim) error('stimulus codes do not match -- check trial duration'); end
        err = fseek(fid, round(winstart * SAMPLERATE / 1000) * 4, 'cof');
        if (err) error('could not seek to start of sample'); end
        cdata = fread(fid, nScansWindow, 'float32');
  
        switch handles.assignment(i)
            case 1
                %dlmappend([fileroot '.ambig.txt'], cdata, '\t');
            case 2
                %dlmappend([fileroot '.up.txt'], cdata, '\t');
                count = fwrite(upid, cstim, 'float32');
                if (count==0) errordlg('could not write to file'); end
                count = fwrite(upid, cdata, 'float32');
                if (count==0) errordlg('could not write to file'); end
            case 3
                %dlmappend([fileroot '.down.txt'], cdata, '\t');
                count = fwrite(downid, cstim, 'float32');
                if (count==0) errordlg('could not write to file'); end
                count = fwrite(downid, cdata, 'float32');
                if (count==0) errordlg('could not write to file'); end
        end
    end
end
fclose(fid);
fclose(upid);
fclose(downid);

% --- Executes on button press in WriteAssignments.
function WriteAssignments_Callback(hObject, eventdata, handles)
% hObject    handle to WriteAssignments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fileroot = handles.filepath(1:(length(handles.filepath)-4));
dlmwrite([fileroot '.asmts.txt'], handles.assignment, '\t');

% --- Executes on button press in LoadAssignments.
function LoadAssignments_Callback(hObject, eventdata, handles)
% hObject    handle to LoadAssignments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fileroot = handles.filepath(1:(length(handles.filepath)-4));
handles.assignment = dlmread([fileroot '.asmts.txt'], '\t');
guidata(hObject, handles);


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


