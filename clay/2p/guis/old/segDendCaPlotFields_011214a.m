function varargout = segDendCaPlotFields_011214a(varargin)
% SEGDENDCAPLOTFIELDS_011214A MATLAB code for segDendCaPlotFields_011214a.fig
%      SEGDENDCAPLOTFIELDS_011214A, by itself, creates a new SEGDENDCAPLOTFIELDS_011214A or raises the existing
%      singleton*.
%
%      H = SEGDENDCAPLOTFIELDS_011214A returns the handle to a new SEGDENDCAPLOTFIELDS_011214A or the handle to
%      the existing singleton*.
%
%      SEGDENDCAPLOTFIELDS_011214A('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEGDENDCAPLOTFIELDS_011214A.M with the given input arguments.
%
%      SEGDENDCAPLOTFIELDS_011214A('Property','Value',...) creates a new SEGDENDCAPLOTFIELDS_011214A or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before segDendCaPlotFields_011214a_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to segDendCaPlotFields_011214a_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help segDendCaPlotFields_011214a

% Last Modified by GUIDE v2.5 13-Jan-2014 00:52:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @segDendCaPlotFields_011214a_OpeningFcn, ...
    'gui_OutputFcn',  @segDendCaPlotFields_011214a_OutputFcn, ...
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


% --- Executes just before segDendCaPlotFields_011214a is made visible.
function segDendCaPlotFields_011214a_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to segDendCaPlotFields_011214a (see VARARGIN)

% Choose default command line output for segDendCaPlotFields_011214a
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes segDendCaPlotFields_011214a wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = segDendCaPlotFields_011214a_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dataStruc = handles.caDataStruc;

contents = cellstr(get(hObject,'String'));
field = get(hObject,'Value');     % index of fieldNames
fieldNames = handles.fieldNames;
thisField1 = fieldNames{field(1)};
thisField2 = fieldNames{field(2)};
handles.field1 = thisField1;
handles.field2 = thisField2;
%disp(thisField);

caData1 = dataStruc.(thisField1);
caData2 = dataStruc.(thisField2);
handles.caData1 = caData1;
handles.caData2 = caData2;

% Update handles structure
guidata(hObject, handles);


% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile('.mat');
cd(pathname);
inStruc = load(filename);
fieldNames = fieldnames(inStruc);
caDataStruc = inStruc.(fieldNames{1});
handles.typeStruc = fieldNames{1};
handles.caDataStruc = caDataStruc;

handles.goodSeg = load('goodSeg.mat');

% need to find fields in calcium data structure
fieldNames = fieldnames(caDataStruc);
% fieldNames = fieldNames(2:length(fieldNames));  % cut out eventStruc

caFields = strfind(fieldNames, 'Ca');
caFieldInd = find(not(cellfun('isempty', caFields)));
fieldNames = fieldNames(caFieldInd);

handles.fieldNames = fieldNames;

handles.K = caDataStruc.K;
handles.A = caDataStruc.A;
handles.C = caDataStruc.C;
handles.d1 = caDataStruc.d1;
handles.d2 = caDataStruc.d2;


% and make them "string" properties in listbox1
set(handles.listbox1,'String',fieldNames);
% set(handles.listbox1,'Value',1:length(fieldNames));

set(handles.filenameTxt, 'String', filename);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dataStruc = handles.caDataStruc;

%figure;
plot(dataStruc.rewTime1CaAvg);


% --- Executes on slider movement.
function segNumSlider_Callback(hObject, eventdata, handles)
% hObject    handle to segNumSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

segNum = get(hObject, 'Value');
segNum = round(segNum);

caData1 = handles.caData1;
caData2 = handles.caData2;

handles.segNum = segNum;
goodSeg = handles.goodSeg;

set(hObject,'BackgroundColor','white');

hz = 4;
xAx = linspace(-2,6,8*hz+1);

% [max1 max1ind] = max(caData1(:,1,segNum));
% [max2 max2ind] = max(caData2(:,1,segNum));

if size(caData1,3)>2 && size(caData2,3)>2
    caData1avg = squeeze(mean(caData1(:,segNum,:),3));
    caData2avg = squeeze(mean(caData2(:,segNum,:),3));
    
    sem1 = std(caData1(:,segNum,:),0,3)/sqrt(size(caData1(:,segNum,:),3));
    sem2 = std(caData2(:,segNum,:),0,3)/sqrt(size(caData2(:,segNum,:),3));
    
    % now find peaks in Ca data for each field
    
    caDataStruc = handles.caDataStruc;
    fieldNames = handles.fieldNames;
    
    for field = 1:length(fieldNames)
        caDataField = caDataStruc.(fieldNames{field});
        caDataFieldAvg = squeeze(mean(caDataField(:,segNum,:), 3));
        [C, I] = max(caDataFieldAvg(7:16));
        caAvgPeakVal(field) = C;
        caAvgPeakInd(field) = I;
    end
    
    [maxPkFieldVal, maxPkFieldInd] = max(caAvgPeakVal);
    
    set(handles.maxFieldTxt, 'String', fieldNames{maxPkFieldInd});
    
    set(handles.segNumTxt, 'String', num2str(segNum));
    
else
    caData1avg = zeros(33,1);
    caData2avg = zeros(33,1);
    sem1 = zeros(33,1);
    sem2 = zeros(33,1);
end

%figure;
plot(handles.behavCaPlot, xAx, caData1avg, 'b'); % ylim([-0.05 0.3]);
errorbar(handles.behavCaPlot, xAx, caData1avg, sem1, 'b');
hold(handles.behavCaPlot);
plot(handles.behavCaPlot, xAx, caData2avg, 'r');
errorbar(handles.behavCaPlot, xAx, caData2avg, sem2, 'r');

[maxVal, maxValInd] = max([caData1avg; caData2avg]);
maxVal = maxVal(1) + 0.02;

% and put lines on for start/stop of event epoch (3s window)
axes(handles.behavCaPlot); %hold on;
line([0 0],[-0.02 maxVal], 'Color', 'g');
line([3 3],[-0.02 maxVal], 'Color', 'r');
xlim([-2 6]); ylim([-0.01 maxVal]);


A = handles.A;
C = handles.C;
d1 = handles.d1;
d2 = handles.d2;


plot(handles.factorTemporal, C(:,segNum), 'b');
whitebg;

A2 = reshape(A(segNum,:),d1,d2);
axes(handles.factorSpatial);
imagesc(A2); %axis equal; axis tight;
colormap(gray);
brighten(0.7);

% Update handles structure
guidata(hObject, handles);


% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function segNumSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to segNumSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% set(hObject,'SliderStep',[.02 .1]);


function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
