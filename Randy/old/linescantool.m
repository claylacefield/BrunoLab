function varargout = linescantool(varargin)
% LINESCANTOOL M-file for linescantool.fig
%      LINESCANTOOL, by itself, creates a new LINESCANTOOL or raises the existing
%      singleton*.
%
%      H = LINESCANTOOL returns the handle to a new LINESCANTOOL or the handle to
%      the existing singleton*.
%
%      LINESCANTOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LINESCANTOOL.M with the given input arguments.
%
%      LINESCANTOOL('Property','Value',...) creates a new LINESCANTOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CFNTquick_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to linescantool_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help linescantool

% Last Modified by GUIDE v2.5 20-Jul-2010 11:37:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @linescantool_OpeningFcn, ...
                   'gui_OutputFcn',  @linescantool_OutputFcn, ...
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

% --- Executes just before linescantool is made visible.
function linescantool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to linescantool (see VARARGIN)

% Choose default command line output for linescantool
handles.output = hObject;

% init certain variables
handles.nFrames = 0;
handles.Np = [];
handles.Npx = [];
handles.Npy = [];
handles.ROIn = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes linescantool wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = linescantool_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function CurrentFrameSlider_Callback(hObject, eventdata, handles)
% hObject    handle to CurrentFrameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

f = round(get(hObject,'Value'));
set(handles.currentFrame, 'String', num2str(f));
UpdateImage(handles);

% --- Executes during object creation, after setting all properties.
function CurrentFrameSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CurrentFrameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function currentFrame_Callback(hObject, eventdata, handles)
% hObject    handle to currentFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of currentFrame as text
%        str2double(get(hObject,'String')) returns contents of currentFrame as a double

UpdateImage(handles);

% --- Executes during object creation, after setting all properties.
function currentFrame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to currentFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in LoadImageFile.
function LoadImageFile_Callback(hObject, eventdata, handles)
% hObject    handle to LoadImageFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LoadImageFile

[handles.I, handles.dx, handles.dy, handles.nFrames, handles.nbits, fn] = TIFFstackReader;
if isempty(fn)
    return
end

set(handles.filename, 'String', fn);
set(handles.currentFrame, 'String', '1');
set(handles.CurrentFrameSlider, 'Value', 1);
set(handles.CurrentFrameSlider, 'Min', 1)
set(handles.CurrentFrameSlider, 'Max', handles.nFrames);
set(handles.CurrentFrameSlider, 'SliderStep', [1/handles.nFrames, 10/handles.nFrames]);

handles.ROIn = 0;
handles.ROI = {};
handles.ROIx = {};
handles.ROIy = {};
handles.ROIh = [];

handles.AvgI = zeros(handles.dy, handles.dx);
for i = 1:handles.dy
    for j = 1:handles.dx
        handles.AvgI(i, j) = mean(handles.I(i,j,:));
    end
end

set(handles.MaxGraySlider, 'Value', max(max(handles.AvgI)) / (2^handles.nbits-1));
set(handles.MinGraySlider, 'Value', min(min(handles.AvgI)) / (2^handles.nbits-1));

y = zeros(handles.nFrames, 1);
for i = 1:handles.nFrames
    y(i) = mean(mean(handles.I(:,:,i)));
end
axes(handles.stabilityaxes);
plot(y);
xlabel('frame');
ylabel('mean intensity');

guidata(hObject, handles);
UpdateImage(handles);


function UpdateImage(handles)

if handles.nFrames == 0
    return
end

% Update image window
f = str2num(get(handles.currentFrame, 'String'));
Imin = get(handles.MinGraySlider, 'Value') * (2^handles.nbits-1);
Imax = get(handles.MaxGraySlider, 'Value') * (2^handles.nbits-1);
axes(handles.imageaxes);
if get(handles.AverageImageButton, 'Value')
    imagesc(handles.AvgI, [Imin Imax]);
else
    imagesc(handles.I(:,:,f), [Imin Imax]);
end
axis image;
if get(handles.ColormapGrayButton, 'Value')
    colormap(gray);
else
    colormap(jet);
end

% restore ROIs
colors = 'rgbymcrgbymc';
for i = 1:handles.ROIn
    h = imrect(handles.imageaxes, handles.ROIpos{i});
    handles.ROIh(handles.ROIn) = h;
    api = iptgetapi(h);

    % constrain position of rectangle to within graph
    % will need to fix gca at some point
    fcn = makeConstrainToRectFcn('imrect',...
        get(gca,'XLim'),get(gca,'YLim'));
    api.setPositionConstraintFcn(fcn);

    % add a callback to update traces display when position is changed
    api.addNewPositionCallback(@(p) UpdateTraces(handles));
end



function UpdateTraces(handles)

axes(handles.traces);
DisplayLinescanROITraces(handles);

% UPDATES DISPLAYS -- often called after changing something progamatically
function UpdateDisplays(handles)

UpdateImage(handles);
UpdateTraces(handles);


%         dF = y;
%     end
% end
% figure(fig1);

% figure(fig2);
% xlim([0 max(x)]);
%
% if get(handles.MedianFilterCheckbox, 'Value')
% 	figure;
%     plot(x, medfilt1(dF, str2num(get(handles.MedianFilterSize, 'String'))));
%     ylabel('median filtered');
% end


% --- Executes on button press in PlayButton.
function PlayButton_Callback(hObject, eventdata, handles)
% hObject    handle to PlayButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

for i = 1:handles.nFrames
    set(handles.currentFrame, 'String', num2str(i));
    set(handles.CurrentFrameSlider, 'Value', i);
    UpdateImage(handles);
end



% --- Executes on button press in SpecifyROIButton.
function SpecifyROIButton_Callback(hObject, eventdata, handles)
% hObject    handle to SpecifyROIButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.imageaxes);
[handles.ROI, handles.ROIx, handles.ROIy] = roipoly;
guidata(hObject, handles);
UpdateDisplays(handles);

% --- Executes on button press in PlotROIButton.
function PlotROIButton_Callback(hObject, eventdata, handles)
% hObject    handle to PlotROIButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in AverageImageButton.
function AverageImageButton_Callback(hObject, eventdata, handles)
% hObject    handle to AverageImageButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AverageImageButton

UpdateDisplays(handles);

    


% --------------------------------------------------------------------
function ColormapUIPanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to ColormapUIPanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

UpdateDisplays(handles);





function FrameDurationBox_Callback(hObject, eventdata, handles)
% hObject    handle to FrameDurationBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FrameDurationBox as text
%        str2double(get(hObject,'String')) returns contents of FrameDurationBox as a double

fnyquist = 1000 / str2num(get(hObject, 'String')) / 2;
set(handles.HighCutoff, 'String', num2str(fnyquist));

% --- Executes during object creation, after setting all properties.
function FrameDurationBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameDurationBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --------------------------------------------------------------------
function DisplayUIPanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to DisplayUIPanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

UpdateDisplays(handles);


function LowCutoff_Callback(hObject, eventdata, handles)
% hObject    handle to LowCutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LowCutoff as text
%        str2double(get(hObject,'String')) returns contents of LowCutoff as a double

Fl = str2num(get(hObject, 'String'));
framedur = str2num(get(handles.FrameDurationBox, 'String'));
n = handles.nFrames;
Flmin = 2 / (framedur / 1000 * n);

if Fl < Flmin
    set(hObject, 'String', num2str(Flmin));
end
guidata(hObject, handles);
UpdateTraces(handles);


% --- Executes during object creation, after setting all properties.
function LowCutoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LowCutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HighCutoff_Callback(hObject, eventdata, handles)
% hObject    handle to HighCutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HighCutoff as text
%        str2double(get(hObject,'String')) returns contents of HighCutoff as a double


% --- Executes during object creation, after setting all properties.
function HighCutoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HighCutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in ButterworthFilterCheckbox.
function ButterworthFilterCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to ButterworthFilterCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ButterworthFilterCheckbox

UpdateDisplays(handles);

% --- Executes on button press in MedianFilterCheckbox.
function MedianFilterCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to MedianFilterCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of MedianFilterCheckbox



function MedianFilterSize_Callback(hObject, eventdata, handles)
% hObject    handle to MedianFilterSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MedianFilterSize as text
%        str2double(get(hObject,'String')) returns contents of MedianFilterSize as a double


% --- Executes during object creation, after setting all properties.
function MedianFilterSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MedianFilterSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in AddROIButton.
function AddROIButton_Callback(hObject, eventdata, handles)
% hObject    handle to AddROIButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.imageaxes);
[mask, x, y] = roipolyold;

if length(x) > 3
    handles.ROIn = handles.ROIn + 1;
    handles.ROI{handles.ROIn} = mask;
    handles.ROIx{handles.ROIn} = x;
    handles.ROIy{handles.ROIn} = y;
    handles.ROItype{handles.ROIn} = 'frame';
    guidata(hObject, handles);
    UpdateDisplays(handles);
end


% --- Executes on button press in SelectNeuropilButton.
function SelectNeuropilButton_Callback(hObject, eventdata, handles)
% hObject    handle to SelectNeuropilButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.imageaxes);
[handles.Np, handles.Npx, handles.Npy] = roipolyold;
guidata(hObject, handles);
UpdateDisplays(handles);


% --------------------------------------------------------------------
function ScaleUIPanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to ScaleUIPanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

UpdateDisplays(handles);



% --- Executes on button press in DeleteLastButton.
function DeleteLastButton_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteLastButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.ROIn > 0
    handles.ROIn = handles.ROIn - 1;
    guidata(hObject, handles);
    UpdateDisplays(handles);
end

% --- Executes on button press in DeleteAllButton.
function DeleteAllButton_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteAllButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Np = [];
handles.Npx = [];
handles.Npy = [];
handles.ROIn = 0;
handles.ROI = {};
handles.ROIx = {};
handles.ROIy = {};
guidata(hObject, handles);
UpdateDisplays(handles);

% --- Executes on button press in LoadButton.
function LoadButton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fn = get(handles.filename, 'String');
fn = [fn(1:length(fn)-3) 'roi'];

if ~exist(fn, 'file')
    warndlg('No ROI file saved yet.');
    return;
end

M = dlmread(fn);
if M(1,1) == 0
    handles.Np = [];
    handles.Npx = [];
    handles.Npy = [];
else
    handles.Npx = RemoveZeros(M(1,:))';
    handles.Npy = RemoveZeros(M(2,:))';
    handles.Np = poly2mask(handles.Npx, handles.Npy, handles.dy, handles.dx);
end
handles.ROIn = nrows(M) / 2 - 1;
for i = 1:handles.ROIn
    handles.ROIx{i} = RemoveZeros(M((i+1)*2 - 1, :))';
    handles.ROIy{i} = RemoveZeros(M((i+1)*2, :))';
    handles.ROI{i} = poly2mask(handles.ROIx{i}, handles.ROIy{i}, handles.dy, handles.dx);
end
guidata(hObject, handles);
UpdateDisplays(handles);


% --- Executes on button press in SaveButton.
function SaveButton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fn = get(handles.filename, 'String');
fn = [fn(1:length(fn)-3) 'roi'];

M = [handles.Npx'; handles.Npy'];
if isempty(M)
    M = [0; 0];
end
dlmwrite(fn, M, 'delimiter', '\t', 'newline', 'pc');
for i = 1:handles.ROIn
    M = [handles.ROIx{i}'; handles.ROIy{i}'];
    dlmwrite(fn, M, '-append', 'delimiter', '\t', 'newline', 'pc');
end

% --- Executes on button press in OpenNewFigButton.
function OpenNewFigButton_Callback(hObject, eventdata, handles)
% hObject    handle to OpenNewFigButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure;
DisplayLinescanROITraces(handles);
title(get(handles.filename, 'String'));

% --- Executes on button press in DeleteROINumberButton.
function DeleteROINumberButton_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteROINumberButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

x = str2num(get(handles.ROItoDelete, 'String'));
if x > 0 & x <= handles.ROIn
    handles.ROIn = handles.ROIn - 1;
    for i = x:handles.ROIn
        handles.ROI{i} = handles.ROI{i+1};
        handles.ROIx{i} = handles.ROIx{i+1};
        handles.ROIy{i} = handles.ROIy{i+1};
        handles.ROItype{i} = handles.ROItype{i+1};
    end    
    guidata(hObject, handles);
    UpdateDisplays(handles);
end


function ROItoDelete_Callback(hObject, eventdata, handles)
% hObject    handle to ROItoDelete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROItoDelete as text
%        str2double(get(hObject,'String')) returns contents of ROItoDelete as a double


% --- Executes during object creation, after setting all properties.
function ROItoDelete_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROItoDelete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in BoxcarCheckbox.
function BoxcarCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to BoxcarCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of BoxcarCheckbox

UpdateTraces(handles);


function BoxcarSize_Callback(hObject, eventdata, handles)
% hObject    handle to BoxcarSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BoxcarSize as text
%        str2double(get(hObject,'String')) returns contents of BoxcarSize as a double

UpdateTraces(handles);


% --- Executes during object creation, after setting all properties.
function BoxcarSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BoxcarSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on slider movement.
function MaxGraySlider_Callback(hObject, eventdata, handles)
% hObject    handle to MaxGraySlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

UpdateImage(handles);

% --- Executes during object creation, after setting all properties.
function MaxGraySlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxGraySlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function MinGraySlider_Callback(hObject, eventdata, handles)
% hObject    handle to MinGraySlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

UpdateImage(handles);

% --- Executes during object creation, after setting all properties.
function MinGraySlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinGraySlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




% --- Executes on button press in AutoscaleButton.
function AutoscaleButton_Callback(hObject, eventdata, handles)
% hObject    handle to AutoscaleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.MaxGraySlider, 'Value', max(max(handles.AvgI)) / (2^handles.nbits-1));
set(handles.MinGraySlider, 'Value', min(min(handles.AvgI)) / (2^handles.nbits-1));
guidata(hObject, handles);
UpdateDisplays(handles);


% --- Executes on button press in DeleteInterleavedButton.
function DeleteInterleavedButton_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteInterleavedButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

answer = inputdlg({'Delete n-th frame', 'Starting with'}, 'Delete Interleaved Frames', 1, {'2','1'});
if isempty(answer)
    return
end
deln = str2num(answer{1});
delstart = str2num(answer{2});

framesToKeep = true(handles.nFrames, 1); %start off saying we're keeping all frames
framesToKeep(delstart:deln:handles.nFrames) = false; %change subset of frames to false so they're deleted

handles.I = handles.I(:,:,framesToKeep); %get subset of image array (delete frames)
handles.nFrames = handles.nFrames*(deln-1)/deln;
set(handles.CurrentFrameSlider, 'Max', handles.nFrames);
set(handles.CurrentFrameSlider, 'SliderStep', [1/handles.nFrames, 10/handles.nFrames]);

% image = zeros(handles.dy, handles.dx, handles.nFrames*(deln-1)/deln);
% n = 0;
% for i = 1:handles.nFrames
%     if mod(i, deln) ~= mod(i, delstart)
%         n = n + 1;
%         image(:,:,n) = handles.I(:,:,i);
%     end
% end


%update average
handles.AvgI = zeros(handles.dy, handles.dx);
for i = 1:handles.dy
    for j = 1:handles.dx
        handles.AvgI(i, j) = mean(handles.I(i,j,:));
    end
end

set(handles.MaxGraySlider, 'Value', max(max(handles.AvgI)) / (2^handles.nbits-1));
set(handles.MinGraySlider, 'Value', min(min(handles.AvgI)) / (2^handles.nbits-1));

%update stability axes
y = zeros(handles.nFrames, 1);
for i = 1:handles.nFrames
    y(i) = mean(mean(handles.I(:,:,i)));
end
axes(handles.stabilityaxes);
plot(y);
xlabel('frame');
ylabel('mean intensity');

guidata(hObject, handles);
UpdateImage(handles);


% --- Executes on button press in LinescanROIbutton.
function LinescanROIbutton_Callback(hObject, eventdata, handles)
% hObject    handle to LinescanROIbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.imageaxes);
handles.ROIn = handles.ROIn + 1;
h = imrect(handles.imageaxes, [1 1 10 256]);
handles.ROIh(handles.ROIn) = h;
guidata(hObject, handles);
api = iptgetapi(h);

% set color
colors = ['rgbymcrgbymc'];
api.setColor(colors(handles.ROIn));

% constrain position of rectangle to within graph
% will need to fix gca at some point
fcn = makeConstrainToRectFcn('imrect',...
                 get(gca,'XLim'),get(gca,'YLim'));
api.setPositionConstraintFcn(fcn);

% add a callback to update traces display when position is changed
api.addNewPositionCallback(@(p) UpdateTraces(handles));


