function varargout = segSomaCaPlotFieldsSEM_061214a(varargin)
% SEGSOMACAPLOTFIELDSSEM_061214A MATLAB code for segSomaCaPlotFieldsSEM_061214a.fig
%      SEGSOMACAPLOTFIELDSSEM_061214A, by itself, creates a new SEGSOMACAPLOTFIELDSSEM_061214A or raises the existing
%      singleton*.
%
%      H = SEGSOMACAPLOTFIELDSSEM_061214A returns the handle to a new SEGSOMACAPLOTFIELDSSEM_061214A or the handle to
%      the existing singleton*.
%
%      SEGSOMACAPLOTFIELDSSEM_061214A('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEGSOMACAPLOTFIELDSSEM_061214A.M with the given input arguments.
%
%      SEGSOMACAPLOTFIELDSSEM_061214A('Property','Value',...) creates a new SEGSOMACAPLOTFIELDSSEM_061214A or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before segSomaCaPlotFieldsSEM_061214a_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to segSomaCaPlotFieldsSEM_061214a_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help segSomaCaPlotFieldsSEM_061214a

% Last Modified by GUIDE v2.5 12-Jun-2014 16:45:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @segSomaCaPlotFieldsSEM_061214a_OpeningFcn, ...
                   'gui_OutputFcn',  @segSomaCaPlotFieldsSEM_061214a_OutputFcn, ...
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


% --- Executes just before segSomaCaPlotFieldsSEM_061214a is made visible.
function segSomaCaPlotFieldsSEM_061214a_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to segSomaCaPlotFieldsSEM_061214a (see VARARGIN)

% Choose default command line output for segSomaCaPlotFieldsSEM_061214a
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes segSomaCaPlotFieldsSEM_061214a wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = segSomaCaPlotFieldsSEM_061214a_OutputFcn(hObject, eventdata, handles) 
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

set(handles.text4, 'String', filename);

% need to find fields in calcium data structure
fieldNames = fieldnames(caDataStruc);
% fieldNames = fieldNames(2:length(fieldNames));  % cut out eventStruc

caFields = strfind(fieldNames, 'Ca');
caFieldInd = find(not(cellfun('isempty', caFields)));
fieldNames = fieldNames(caFieldInd);

handles.fieldNames = fieldNames;

% handles.K = caDataStruc.K;
% handles.A = caDataStruc.A;
handles.C = caDataStruc.C;
% handles.d1 = caDataStruc.d1;
% handles.d2 = caDataStruc.d2;


% and make them "string" properties in listbox1
set(handles.listbox1,'String',fieldNames);
% set(handles.listbox1,'Value',1:length(fieldNames));

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
handles.segNum = segNum;

set(handles.text2, 'String', segNum);

caData1 = handles.caData1;
caData2 = handles.caData2;

caData1b = squeeze(caData1(:,segNum, :));
caData2b = squeeze(caData2(:,segNum, :));

sem1 = std(caData1b,0,2)/sqrt(size(caData1b,2));
sem2 = std(caData2b,0,2)/sqrt(size(caData2b,2));

set(hObject,'BackgroundColor','white');

% %figure;
% plot(handles.behavCaPlot, caData1(:,segNum), 'b'); % ylim([-0.05 0.3]);
% hold(handles.behavCaPlot);
% plot(handles.behavCaPlot, caData2(:,segNum), 'r');

%%

hz = 4;
xAx = linspace(-2,6,8*hz+1); 

% and plot Ca signals (with SEM)
plot(handles.behavCaPlot, xAx, mean(caData1b,2), 'b');  xlim([-2 6]);
errorbar(handles.behavCaPlot, xAx, mean(caData1b,2), sem1, 'b');
xlabel(handles.behavCaPlot,'sec (from event)'); ylabel(handles.behavCaPlot,'dF/F');
hold(handles.behavCaPlot);
plot(handles.behavCaPlot, xAx, mean(caData2b,2), 'r');
errorbar(handles.behavCaPlot, xAx, mean(caData2b,2), sem2, 'r');

% and put lines on for start/stop of event epoch (3s window)
axes(handles.behavCaPlot); %hold on;
line([0 0],[-0.05 0.2], 'Color', 'g');
line([3 3],[-0.05 0.2], 'Color', 'r');
xlim([-2 6]);

% legend(handles.behavCaPlot, thisField1, thisField2);

%%

% A = handles.A;
C = handles.C;
% d1 = handles.d1;
% d2 = handles.d2;


plot(handles.factorTemporal, C(:,segNum), 'b');
whitebg;

% A2 = reshape(A(segNum,:),d1,d2);
% axes(handles.factorSpatial);
% imagesc(A2); %axis equal; axis tight;

axes(handles.factorSpatial);

plot(handles.factorSpatial, caData1b, 'b');
hold(handles.factorSpatial);
plot(handles.factorSpatial, caData2b, 'r');

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
