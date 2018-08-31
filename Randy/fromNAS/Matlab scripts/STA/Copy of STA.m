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
handles.mode = 'GUI';

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
UpDownBorder = str2double(get(handles.PreSpikeVmCriteria, 'String'));
GreaterThan = get(handles.GreaterThan, 'Value') - 1;
memoryless = get(handles.memoryless, 'Value');

if strcmp(handles.mode, 'GUI')
    % select a spike file and read in spikes
    switch filetype
        case 'dat'
            [filename pathname OK] = uigetfile(['*.dat'], 'Select triggering file');
        case 'cluster'
            [filename pathname OK] = uigetfile(['*.cluster?'], 'Select triggering file');
    end
    if (~OK) return; end
    triggerpath = [pathname, filename];
else
    triggerpath = handles.clusterpath;
end

switch filetype
    case 'dat'
        cluster = ReadDAT(triggerpath);
    case 'cluster'
        cluster = ReadCluster(triggerpath);
    otherwise
        error('STA.m: Appropriate filetype not specified.')
end
    
if (get(handles.acquisitionMode, 'Value') == 1)
    %continuous acquisition
        duration = 2^32;
else
    %sweep/trial-based acquisition
    duration = str2double(get(handles.duration, 'String'));
    % excerpt specified time window
    cluster = cluster(cluster(:,4) >= winstart & cluster(:,4) <= winend, :);
    % excerpt specified trials
    cluster = cluster(cluster(:,2) >= trialStart & cluster(:,2) <= trialEnd, :);
end

% apply thalamic ISI lockout, if any
lockout = str2num(get(handles.TClockout, 'String'));
lockout2 = str2num(get(handles.TClockout2, 'String'));
successorLockout = str2num(get(handles.minsuccessor, 'String'));
if (lockout > 0 | lockout2 < Inf | successorLockout > 0)
    ISI = ISIof(cluster)
    ISInext = [ISI(2:end); NaN];
    cluster = cluster(isnan(ISI) | (ISI > lockout & ISI < lockout2 & ISInext > successorLockout), :);
    disp(['spikes remaining after applying TC lockouts: ' num2str(nrows(cluster))]);
end

% or excerpt just the n-th spike of high frequency Ca++ bursts
burstSpike = str2num(get(handles.burstSpike, 'String'));
burstCrit = str2num(get(handles.burstCrit, 'String'));
if (burstSpike > 0)
    %[nS, tr] = SpikesPerTrial(cluster, false);
    %nSpikes = zeros(nrows(cluster), 1);
    %for i = 1:nrows(cluster)
    %    nSpikes(i) = nS(tr == cluster(i, 2));
    %end  
    %cluster = cluster(nSpikes == burstCrit, :);
    selectedSpikes = IdentifyCaBurstsForSTA(cluster, burstSpike, burstCrit);
    cluster = cluster(selectedSpikes, :);
    disp(['# of Ca++ bursts: ' num2str(nrows(cluster))]);
end

% If shift correcting, remove the last trial's spikes.
% This is necessary because the Shift Corrector will not use the last
% trial's spikes, and we want both the raw and corrector to be based off
% the same set of spikes.
if (ShiftCorrect)
    maxTrial = max(cluster(:,2));
    cluster = cluster(cluster(:,2) ~= maxTrial, :); % +1 shift corrector
    %cluster = cluster(cluster(:,2) ~= 0, :); % -1 shift corrector
end

if strcmp(handles.mode, 'GUI')
    % select a continuous file
    [filename pathname OK] = uigetfile('*.dat', 'Select file to average');
    if (~OK) return; end
    averagingpath = [pathname, filename];
else
    averagingpath = handles.averagingpath;
end
disp([averagingpath, ' selected']);

% compute/plot the raw STA
[x, raw, nraw, isis, meanVm1] = SpikeTriggerAverage(duration, cluster, averagingpath, limit, UpDownBorder, [], GreaterThan, memoryless);
raw = raw - 7; % correct for jxn potential
h = figure;
whitebg('w');
if (ShiftCorrect) subplot(4,1,1); end
figure(h);
plot(x, raw);
line([0 0], ylim, 'Color', 'black');
box off;
ylabel('Vm');
global rawx;
global rawy;
rawx = x;
rawy = raw;

% compute a simple significance test of the post-thalamic Vm change
spon = raw(x < -5);
CI = 2.57 * std(spon) + raw(x == 1); % 99% 2-tailed CI
if (ShiftCorrect) subplot(4,1,1); end
line([min(x) max(x)], [CI CI], 'LineStyle', '--');

% compute/plot a shift corrector and a subtraction
if (ShiftCorrect)
    cluster(:,2) = cluster(:,2) + 1;

    [x, shift, nshift, isis2, meanVm2] = SpikeTriggerAverage(duration, cluster, averagingpath, limit, UpDownBorder, [], GreaterThan, memoryless);
    shift = shift - 7; % correct for jnxn potential
    mi = min([raw shift]);
    mx = max([raw shift]);
    ylim([mi mx]);
    figure(h);
    subplot(4,1,2);
    plot(x, shift);
    box off;
    ylim([mi mx]);
    line([0 0], ylim, 'Color', 'black'); 
    ylabel('Vm');
    title('shift corrector');
    
    corrected = raw - shift;
    
    % write corrected STA to a text file
    dlmwrite([averagingpath(1:(length(averagingpath)-4)) '-sta.txt'], [x; corrected]', '\t');
    
    % make available to workspace
    global stax
    global stay
    stax = x;
    stay = corrected; 
        
    subplot(4,1,3);
    plot(x, corrected);
    box off;
    line([0 0], ylim, 'Color', 'black'); 
    ylabel('delta Vm');
    title('corrected sta');
    figure(h);
    subplot(4,1,4);
    subset = x >= -10 & x <= 50;
    plot(x(subset), corrected(subset));
    box off;
    line([0 0], ylim, 'Color', 'black'); 
    xlabel('lag (msec)');
    ylabel('delta Vm');
    [amp, rt, peaktime, tau, latency] = MeasurePSP(stax, stay, false, 20);
    title(['latency = ' num2str(latency) ' ms, amplitude = ' num2str(amp), ' mV, 20-80% RT = ' num2str(rt) ' ms, tau = ' num2str(tau) ' ms']);
    
    % compute a simple significance test of the post-thalamic Vm change
    spon = corrected(x < -5);
    CI = 2.57 * std(spon) + corrected(x==0); % 99% 2-tailed CI
    subplot(4,1,3);
    line([min(x) max(x)], [CI CI], 'LineStyle', '--');
    subplot(4,1,4);
    line([-10 50], [CI CI], 'LineStyle', '--');
end

if ShiftCorrect
    spikestr = ['raw spikes: ' num2str(nraw) ', corrector spikes: ' num2str(nshift)];
    subplot(4,1,1);
else
    spikestr = ['raw spikes: ' num2str(nraw)];
end

if isinf(UpDownBorder)
    Vmstr = [];
else
    switch GreaterThan
        case 0
            Vmstr = [', Vm < ' num2str(UpDownBorder)];
        case 1
            Vmstr = [', Vm > ' num2str(UpDownBorder)];
        case 2
            Vmstr = [', ' num2str(UpDownBorder) ' < Vm < ' num2str(Vend)];
    end
end

title(sprintf([strrep(triggerpath, '\', '\\') ...
    ', trials: ' num2str(trialStart) '-' num2str(max(cluster(:,2))) ...
    ', TC lockout: ' num2str(lockout) ...
    ', successor lockout: ' num2str(successorLockout) ...
    ', ' spikestr ...
    Vmstr ...
    '\nraw sta']));

orient landscape;
set(gcf, 'Name', averagingpath);
plotedit on;

disp(['mean ISI of raw spikes = ' num2str(mean(excise(isis)))]);
disp(['stderr = ' num2str(stderr(isis))]);
disp(['mean ISI of corrector spikes = ' num2str(mean(excise(isis2)))]);
disp(['stderr = ' num2str(stderr(isis2))]);
disp(['mean Vm during raw calculation = ' num2str(meanVm1)]);
disp(['mean Vm during corrector calculation = ' num2str(meanVm2)]);
ttest2(excise(isis), excise(isis2))


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


