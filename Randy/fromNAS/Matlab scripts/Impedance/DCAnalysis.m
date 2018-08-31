function varargout = DCAnalysis(varargin)
% DCANALYSIS M-file for DCAnalysis.fig
%      DCANALYSIS, by itself, creates a new DCANALYSIS or raises the existing
%      singleton*.
%
%      H = DCANALYSIS returns the handle to a new DCANALYSIS or the handle to
%      the existing singleton*.
%
%      DCANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DCANALYSIS.M with the given input arguments.
%
%      DCANALYSIS('Property','Value',...) creates a new DCANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DCAnalysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DCAnalysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DCAnalysis

% Last Modified by GUIDE v2.5 04-Dec-2008 10:39:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DCAnalysis_OpeningFcn, ...
                   'gui_OutputFcn',  @DCAnalysis_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before DCAnalysis is made visible.
function DCAnalysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DCAnalysis (see VARARGIN)

% Choose default command line output for DCAnalysis
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DCAnalysis wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DCAnalysis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function StartPath_Callback(hObject, eventdata, handles)
% hObject    handle to StartPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StartPath as text
%        str2double(get(hObject,'String')) returns contents of StartPath as a double
startpath = get(hObject, 'String');
cd(startpath);

% --- Executes during object creation, after setting all properties.
function StartPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StartPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

startpath = get(hObject, 'String');
cd(startpath);


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
guidata(hObject, handles);


function Ion_Callback(hObject, eventdata, handles)
% hObject    handle to Ion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Ion as text
%        str2double(get(hObject,'String')) returns contents of Ion as a double


% --- Executes during object creation, after setting all properties.
function Ion_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Idur_Callback(hObject, eventdata, handles)
% hObject    handle to Idur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Idur as text
%        str2double(get(hObject,'String')) returns contents of Idur as a double


% --- Executes during object creation, after setting all properties.
function Idur_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Idur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function StimOn_Callback(hObject, eventdata, handles)
% hObject    handle to StimOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StimOn as text
%        str2double(get(hObject,'String')) returns contents of StimOn as a double


% --- Executes during object creation, after setting all properties.
function StimOn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StimOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TrialStart_Callback(hObject, eventdata, handles)
% hObject    handle to TrialStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TrialStart as text
%        str2double(get(hObject,'String')) returns contents of TrialStart as a double


% --- Executes during object creation, after setting all properties.
function TrialStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TrialStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TrialEnd_Callback(hObject, eventdata, handles)
% hObject    handle to TrialEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TrialEnd as text
%        str2double(get(hObject,'String')) returns contents of TrialEnd as a double


% --- Executes during object creation, after setting all properties.
function TrialEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TrialEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RunButton.
function RunButton_Callback(hObject, eventdata, handles)
% hObject    handle to RunButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

filepath = get(handles.SelectedFileName, 'String');
duration = str2double(get(handles.duration, 'String'));
Ion = str2double(get(handles.Ion, 'String'));
Idur = str2double(get(handles.Idur, 'String'));
StimOn = str2double(get(handles.StimOn, 'String'));
trialstart = str2double(get(handles.TrialStart, 'String'));
trialend = str2double(get(handles.TrialEnd, 'String'));
I1amp = str2double(get(handles.I1amp, 'String'));
I2amp = str2double(get(handles.I2amp, 'String'));
Iamp = [0 I1amp I2amp];
Iamp = sort(Iamp);
I1ind = find(Iamp==I1amp);
I2ind = find(Iamp ==I2amp); 
I0ind = find(Iamp ==0);
Imin = min(Iamp);
Iminind = find(Iamp==Imin);

stimuli = ReverseArray(GetStimCodes(filepath, duration))
n_stim = length(stimuli);
nI1 = 0;
nI2 = 0;
nI0 = 0;
for i = 1:n_stim
    if abs(stimuli(i)) <= 360
        nI0 = nI0+1;
        I0angles(nI0) = stimuli(i);
    elseif abs(stimuli(i)) >= 1000 & abs(stimuli(i))<2000
        nI1 = nI1+1;
        I1angles(nI1) = stimuli(i);
    elseif abs(stimuli(i)) >= 2000
        nI2 = nI2+1;
        I2angles(nI2) = stimuli(i);
    end
end

if nI1 ~= nI0 && nI2 ~= nI0
    error('Different number of whisker and white-noise stim');
else
    n_angles = nI0
end

SCALINGFACTOR = 100;
SAMPLERATE = 32000; % in Hz
nScans = SAMPLERATE * (duration / 1000);
stim_on = StimOn;
x = linspace(0, duration, nScans);
recSize = (nScans + 1) * 4; %in bytes

disp(filepath);
fid = fopen(filepath, 'r', 'b');
headerSize = SkipHeader(fid);

nRecs = floor(GetNumberOfRecords(filepath, duration));
n_trials = ceil(nRecs/n_stim);
dur = find(x>stim_on & x< stim_on+100);
ndur = length(dur);
I0 = zeros(nScans, n_trials, n_angles);
I1 = zeros(nScans, n_trials, n_angles);
I2 = zeros(nScans, n_trials, n_angles);

I0_trial = zeros(1, n_angles);
I1_trial = zeros(1, n_angles);
I2_trial = zeros(1, n_angles);
trial = 0; 

while (~feof(fid))
    stimulus = fread(fid, 1, 'float32');
    
    trial = trial +1;
    if (feof(fid)) break; end;
    signal = fread(fid, nScans, 'float32')*100;
    if (feof(fid)) break; end;
    if (trial >= trialstart) && (trial <= trialend)
%         baseline = median(signal(x> Ion+100 & x< stim_on));
%         psp = signal(dur)-baseline;
        
        if abs(stimulus)<= 360
            c = find(I0angles == stimulus);
            I0_trial(c) = I0_trial(c) +1;
            I0(:, I0_trial(c), c) = signal;
            
        elseif abs(stimulus) >= 1000 && abs(stimulus) < 2000
            c = find(I1angles == stimulus);
            I1_trial(c) = I1_trial(c) +1;
            I1(:, I1_trial(c), c) = signal;
            
        elseif abs(stimulus) >= 2000
            c = find(I2angles == stimulus);
            I2_trial(c) = I2_trial(c) +1;
            I2(:, I2_trial(c), c) = signal;
            
        end
    end
    if (feof(fid)) break; end;
      
end
             
for j = 1:n_angles
    I0mean = mean(I0(:, 1:I0_trial(j), j), 2);
    figure; plot(I0mean(x> 300 & x< 350));
    [ind, I0baseline] = ginput(1);
    psp0 = I0mean(dur)-I0baseline;
    I0psp(:,j) = psp0;
%     I0peak(j) = max(psp0);
%     figure;
%     plot(psp0);
%     [peak_ind,I0peak(j)] = ginput(1);
%     hold on;
%     plot(peak_ind, I0peak(j), 'ro')
    
    I1mean = mean(I1(:, 1:I1_trial(j), j), 2);
    figure; plot(I1mean(x> 300 & x< 350));
    [ind, I1baseline] = ginput(1);
    psp1 = I1mean(dur)-I1baseline;
    I1psp(:,j) = psp1;
%     I1peak(j)=max(psp1);
%    I1peak(j) = psp1(ceil(peak_ind));
     
    I2mean = mean(I2(:, 1:I2_trial(j), j), 2);
    figure; plot(I2mean(x> 300 & x< 350));
    [ind, I2baseline] = ginput(1);
    %I2baseline = median(I2mean(x> 300 & x< 305));
    psp2 = I2mean(dur)-I2baseline;
    I2psp(:,j) = psp2;
%     I2peak(j)=max(psp2);
%     I2peak(j) = psp2(ceil(peak_ind));
       
end
% figure;
% plot(I0psp(:, 1));
% [peak_ind, I0peak(1)] = ginput(1);
% hold on;
% plot(peak_ind, I0peak(1), 'go')
for j = 1:n_angles
    I0peak(j) = max(I0psp(:,j));
    I0peakInd(j) = find(I0psp(:, j)==max(I0psp(:,j)), 1);
    I1peak(j) = max(I1psp(:,j));
    I1peakInd(j) = find(I1psp(:, j)==max(I1psp(:,j)), 1);

    I2peak(j) = max(I2psp(:, j));
    I2peakInd(j) = find(I2psp(:, j)==max(I2psp(:,j)),1);

%     I0peak(j) = I0psp(ceil(peak_ind),j);
%     I1peak(j) = I1psp(ceil(peak_ind),j);
%     I2peak(j) = I2psp(ceil(peak_ind), j);
end

 

angle1(I1ind)=I1peak(1);
% angle1err(I1ind)=I1peakerr(1);
angle1(I2ind)=I2peak(1);
% angle1err(I2ind)=I2peakerr(1);
angle1(I0ind)=I0peak(1);
% angle1err(I0ind)=I0peakerr(1);
norm1=angle1./I1peak(1);

angle2(I1ind)=I1peak(2);
% angle2err(I1ind)=I1peakerr(2); 
angle2(I2ind)=I2peak(2);
% angle2err(I2ind)=I2peakerr(2);
angle2(I0ind)=I0peak(2);
% angle2err(I0ind)=I0peakerr(2);
norm2=angle2./I1peak(2);

% angle3(I1ind)=I1peak(3);
% 
% angle3(I2ind)=I2peak(3);
% 
% angle3(I0ind)=I0peak(3);
%  
% norm3=angle3./I0peak(3);

% angle4(I1ind)=I1peak(4);
% % angle3err(I1ind)=I1peakerr(3);
% angle4(I2ind)=I2peak(4);
% % angle3err(I2ind)=I2peakerr(3);
% angle4(I0ind)=I0peak(4);
% % angle3err(I0ind)=I0peakerr(3);
% norm4=angle4./I0peak(4);
pspduration = x(dur);
figure 
subplot(3, 1, 1)
plot(pspduration, I0psp(:, 1), 'k')
hold on
plot(pspduration(ceil(I0peakInd(1))),I0peak(1), 'go')
plot(pspduration, I1psp(:, 1), 'r')
plot(pspduration(ceil(I1peakInd(1))),I1peak(1), 'go')
plot(pspduration, I2psp(:, 1), 'g')
plot(pspduration(ceil(I2peakInd(1))),I2peak(1), 'go')

subplot(3, 1, 2)
plot(pspduration, I0psp(:, 2), 'k')
hold on
plot(pspduration(ceil(I0peakInd(2))),I0peak(2), 'go')
plot(pspduration, I1psp(:, 2), 'r')
plot(pspduration(ceil(I1peakInd(2))),I1peak(2), 'go')
plot(pspduration, I2psp(:, 2), 'g')
plot(pspduration(ceil(I2peakInd(2))),I2peak(2), 'go')

% subplot(3, 1, 3)
% plot(pspduration, I0psp(:, 3), 'k')
% hold on
% plot(pspduration(ceil(peak_ind)),I0peak(3), 'go')
% plot(pspduration, I1psp(:, 3), 'r')
% plot(pspduration(ceil(peak_ind)),I1peak(3), 'go')
% plot(pspduration, I2psp(:, 3), 'g')
% plot(pspduration(ceil(peak_ind)),I2peak(3), 'go')
 
figure;
plot(Iamp, norm1, 'mo-')
hold on
plot(Iamp, norm2, 'ko-')
% plot(Iamp, norm3, 'ro-')
% plot(Iamp, norm4, 'o-')
 
diff(1) = 0;  
diff(2) = I1peak(1)-I0peak(1);
diff(3) = I2peak(1)-I0peak(1);
diff
diff2(1) = 0; 
diff2(2)= I1peak(2)-I0peak(2);
diff2(3) = I2peak(2)-I0peak(2);
diff2
% diff3(1) = 0;
% diff3(2) = I1peak(3)-I0peak(3);
% diff3(3) = I2peak(3)-I0peak(3);
% diff3
diff = diff./(diff(3)-diff(2))
diff2 = diff2./(diff2(3)-diff2(2))
% diff3 = diff3./diff3(2)
figure
plot(Iamp, diff)
hold on
plot(Iamp, diff2, 'r')
hold on
% plot(Iamp, diff3, 'g')
display('end') 
  
    
       
 
function duration_Callback(hObject, eventdata, handles)
% hObject    handle to duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of duration as text
%        str2double(get(hObject,'String')) returns contents of duration as a double


% --- Executes during object creation, after setting all properties.
function duration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function I1amp_Callback(hObject, eventdata, handles)
% hObject    handle to I1amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of I1amp as text
%        str2double(get(hObject,'String')) returns contents of I1amp as a double


% --- Executes during object creation, after setting all properties.
function I1amp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to I1amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function I2amp_Callback(hObject, eventdata, handles)
% hObject    handle to I2amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of I2amp as text
%        str2double(get(hObject,'String')) returns contents of I2amp as a double


% --- Executes during object creation, after setting all properties.
function I2amp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to I2amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

