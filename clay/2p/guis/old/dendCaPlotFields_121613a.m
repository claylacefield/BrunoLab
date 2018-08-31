function varargout = dendCaPlotFields_121613a(varargin)
% DENDCAPLOTFIELDS_121613A MATLAB code for dendCaPlotFields_121613a.fig
%      DENDCAPLOTFIELDS_121613A, by itself, creates a new DENDCAPLOTFIELDS_121613A or raises the existing
%      singleton*.
%
%      H = DENDCAPLOTFIELDS_121613A returns the handle to a new DENDCAPLOTFIELDS_121613A or the handle to
%      the existing singleton*.
%
%      DENDCAPLOTFIELDS_121613A('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DENDCAPLOTFIELDS_121613A.M with the given input arguments.
%
%      DENDCAPLOTFIELDS_121613A('Property','Value',...) creates a new DENDCAPLOTFIELDS_121613A or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dendCaPlotFields_121613a_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dendCaPlotFields_121613a_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dendCaPlotFields_121613a

% Last Modified by GUIDE v2.5 16-Dec-2013 17:04:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dendCaPlotFields_121613a_OpeningFcn, ...
                   'gui_OutputFcn',  @dendCaPlotFields_121613a_OutputFcn, ...
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


% --- Executes just before dendCaPlotFields_121613a is made visible.
function dendCaPlotFields_121613a_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dendCaPlotFields_121613a (see VARARGIN)

% Choose default command line output for dendCaPlotFields_121613a
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dendCaPlotFields_121613a wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = dendCaPlotFields_121613a_OutputFcn(hObject, eventdata, handles) 
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


%figure;
plot(handles.behavCaPlot, mean(caData1,2), 'b'); % ylim([-0.05 0.3]);
hold(handles.behavCaPlot);
plot(handles.behavCaPlot, mean(caData2,2), 'r');


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

% need to find fields in calcium data structure
fieldNames = fieldnames(caDataStruc);
% fieldNames = fieldNames(2:length(fieldNames));  % cut out eventStruc

caFields = strfind(fieldNames, 'Ca');
caFieldInd = find(not(cellfun('isempty', caFields)));
fieldNames = fieldNames(caFieldInd);

handles.fieldNames = fieldNames;


% and make them "string" properties in listbox1
set(handles.listbox1,'String',fieldNames);
% set(handles.listbox1,'Value',1:length(fieldNames));

% Update handles structure
guidata(hObject, handles);
