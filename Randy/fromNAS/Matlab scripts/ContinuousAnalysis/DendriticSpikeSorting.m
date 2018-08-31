function varargout = DendriticSpikeSorting(varargin)
% DENDRITICSPIKESORTING M-file for DendriticSpikeSorting.fig
%      DENDRITICSPIKESORTING, by itself, creates a new DENDRITICSPIKESORTING or raises the existing
%      singleton*.
%
%      H = DENDRITICSPIKESORTING returns the handle to a new DENDRITICSPIKESORTING or the handle to
%      the existing singleton*.
%
%      DENDRITICSPIKESORTING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DENDRITICSPIKESORTING.M with the given input arguments.
%
%      DENDRITICSPIKESORTING('Property','Value',...) creates a new DENDRITICSPIKESORTING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DendriticSpikeSorting_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DendriticSpikeSorting_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DendriticSpikeSorting

% Last Modified by GUIDE v2.5 29-Aug-2008 12:42:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @DendriticSpikeSorting_OpeningFcn, ...
    'gui_OutputFcn',  @DendriticSpikeSorting_OutputFcn, ...
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


% --- Executes just before DendriticSpikeSorting is made visible.
function DendriticSpikeSorting_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DendriticSpikeSorting (see VARARGIN)

% Choose default command line output for DendriticSpikeSorting
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DendriticSpikeSorting wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DendriticSpikeSorting_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function Start_Path_Callback(hObject, eventdata, handles)
% hObject    handle to Start_Path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Start_Path as text
%        str2double(get(hObject,'String')) returns contents of Start_Path as a double
startpath = get(hObject, 'String');
cd(startpath);

% --- Executes during object creation, after setting all properties.
function Start_Path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Start_Path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
startpath = get(hObject, 'String');
cd(startpath);


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


% --- Executes on button press in LoadFile.
function LoadFile_Callback(hObject, eventdata, handles)
% hObject    handle to LoadFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
startpath = get(handles.Start_Path, 'String');
cd(startpath);

[filename pathname OK] = uigetfile('*.dat', 'Select whole-cell recording');
if (~OK) return; end
filepath = fullfile(pathname, filename);
fid = fopen(filepath, 'r', 'b');
if (fid == -1)
    error('LoadFiles_Callbacks could not open file for reading.');
end
handles.filepath = filepath;
handles.headerSize = SkipHeader(fid);
fclose(fid);
set(handles.trial, 'String', '0');
guidata(hObject, handles);
hold off;


ClipAndFilter(handles);

function ClipAndFilter(handles)
SAMPLERATE = 32000;

currentTrial = str2double(get(handles.trial, 'String'))
duration = str2double(get(handles.duration, 'String'));
SpikesPath = [handles.filepath(1:(length(handles.filepath)-4)) '-spikes.cluster1']
dSpikesPath = [handles.filepath(1:(length(handles.filepath)-4)) '-dspikes.cluster1']
PspPath = [handles.filepath(1:(length(handles.filepath)-4)) '-psp.dat']

fid = fopen(handles.filepath, 'r', 'b');
nScans = duration * SAMPLERATE / 1000;
recSize = (nScans + 1) * 4;
offset = handles.headerSize + currentTrial * recSize;
err = fseek(fid, offset, 'bof');
SCALINGFACTOR = 100;

n_sAP = 0;
n_dAP = 0;
while (~feof(fid))
    if (err) error('could not seek to start of record'); end

    stimulus = fread(fid, 1, 'float32');

    if currentTrial == 0
        sid = fopen(SpikesPath, 'w');
        did = fopen(dSpikesPath, 'w');
        pid = fopen(PspPath, 'w', 'b');
        fprintf(pid, '%%%%ENDHEADER\n');
        srecord = [n_sAP currentTrial stimulus 0];
        fprintf(sid, '%d\t%d\t%d\t%d\r\n', srecord);
        n_sAP = n_sAP + 1;

        drecord = [n_dAP currentTrial stimulus 0];
        fprintf(did, '%d\t%d\t%d\t%d\r\n', drecord);
        n_dAP = n_dAP + 1;
    else
        sid = fopen(SpikesPath, 'a');
        did = fopen(dSpikesPath, 'a');
        pid = fopen(PspPath, 'a', 'b');

    end
    %set(handles.stimcode, 'String', num2str(stim));
    if (feof(fid) | isempty(stimulus)) break; end;
    cdata = fread(fid, nScans, 'float32') * 100; % put data on mV scale

    if max(cdata)> -30
        t = linspace(0, duration, nScans);
        axes(handles.ContinuousGraph1);
        plot(t, cdata);
        ylim([-75, 10]);


        answer = 1;
        while answer~=2;
            
            [x,y] = ginput(2);
            ClipIndices = find(t>=x(1) & t<=x(2));
            ClipStart = ClipIndices(1)
            ClipEnd = ClipIndices(end);
            set(handles.ClipStart, 'String', num2str(x(1)));
            set(handles.ClipEnd, 'String', num2str(x(2)));
            clip_t= t(t>=x(1) & t<=x(2));
            clip_data = cdata(t>=x(1) & t<=x(2));
            hold on;
            Vpre = cdata(ClipStart - 1);
            Vpost = cdata(ClipEnd + 1);
            m = (Vpost - Vpre) / ((ClipEnd + 1) - (ClipStart - 1));
            k = 0
            new = zeros(1, length(clip_t));
            for j = ClipStart:ClipEnd
                k = k +1;
                new(k) = Vpre + m*(j-ClipStart+1);
            end
            plot(clip_t, new, 'r:');
            hold off;
            cdata = [cdata(1:ClipStart-1); new'; cdata(ClipEnd+1:end)];
            axes(handles.ContinuousGraph2);
            plot(clip_t, clip_data);
            hold on;
            prompt_defineAP = {'Define AP type:'};
            defineAP = menu(prompt_defineAP, 'somatic', 'dedritic', 'both');
            if defineAP == 1
                n_sAP = n_sAP + 1;
                [u, w] = ginput(1);
                plot(u, w, 'ro'); hold off;
                spiketime = u;
                set(handles.sAP_start, 'String', num2str(u));
                srecord = [n_sAP currentTrial stimulus round(u*10)];
                fprintf(sid, '%d\t%d\t%d\t%d\r\n', srecord);
                
                
            elseif defineAP ==2
                n_dAP= n_dAP +1;
                [u, w] = ginput(1);
                plot(u, w, 'ro'); hold off;
                spiketime = u;
                set(handles.dAP_start, 'String', num2str(u));
                drecord = [n_dAP currentTrial stimulus round(u*10)];
                fprintf(did, '%d\t%d\t%d\t%d\r\n', drecord);
                
            elseif defineAP ==3
                n_sAP = n_sAP +1;
                n_dAP = n_dAP +1;
                
                [u, w] = ginput(2);
                plot(u(1), w(1), 'ro'); 
                plot(u(2), w(2), 'go'); hold off;
                s_spiketime = u(1);
                d_spiketime = u(2);
                set(handles.sAP_start, 'String', num2str(u(1)));
                set(handles.dAP_start, 'String', num2str(u(2)));
                srecord = [n_sAP currentTrial stimulus round(u(1)*10)];
                drecord = [n_dAP currentTrial stimulus round(u(2)*10)];
                fprintf(sid, '%d\t%d\t%d\t%d\r\n', srecord);
                fprintf(did, '%d\t%d\t%d\t%d\r\n', drecord);
                
            end



            prompt_end = {'Is there another spike in this trial?'};
            foo = menu(prompt_end, 'yes', 'no');
            answer = foo;
        end
        fwrite(pid, stimulus, 'float32'); % write stimulus code
        fwrite(pid, cdata/ SCALINGFACTOR, 'float32');


        currentTrial = currentTrial +1
        set(handles.trial, 'String', num2str(currentTrial));
    else
        currentTrial = currentTrial +1
        set(handles.trial, 'String', num2str(currentTrial));
        fwrite(pid, stimulus, 'float32');
        fwrite(pid, cdata/ SCALINGFACTOR, 'float32');
        fclose(sid);
        fclose(did);
        fclose(pid);
    end

    n_sAP
    n_dAP
end


% --- Executes on button press in Next.
function Next_Callback(hObject, eventdata, handles)
% hObject    handle to Next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
trial = str2double(get(handles.trial, 'String'));
set(handles.trial, 'String', num2str(trial+1));
ClipAndFilter(handles);
function Next(handles)
trial = str2double(get(handles.trial, 'String'));
set(handles.trial, 'String', num2str(trial+1));
ClipAndFilter(handles);
% --- Executes on button press in SaveFile.
function SaveFile_Callback(hObject, eventdata, handles)
% hObject    handle to SaveFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in ClipAP.
function ClipAP_Callback(hObject, eventdata, handles)
% hObject    handle to ClipAP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2




