function varargout = dendCaPlotFieldsSEM_122113a(varargin)
% DENDCAPLOTFIELDSSEM_122113A MATLAB code for dendCaPlotFieldsSEM_122113a.fig
%      DENDCAPLOTFIELDSSEM_122113A, by itself, creates a new DENDCAPLOTFIELDSSEM_122113A or raises the existing
%      singleton*.
%
%      H = DENDCAPLOTFIELDSSEM_122113A returns the handle to a new DENDCAPLOTFIELDSSEM_122113A or the handle to
%      the existing singleton*.
%
%      DENDCAPLOTFIELDSSEM_122113A('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DENDCAPLOTFIELDSSEM_122113A.M with the given input arguments.
%
%      DENDCAPLOTFIELDSSEM_122113A('Property','Value',...) creates a new DENDCAPLOTFIELDSSEM_122113A or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dendCaPlotFieldsSEM_122113a_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dendCaPlotFieldsSEM_122113a_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dendCaPlotFieldsSEM_122113a

% Last Modified by GUIDE v2.5 22-Dec-2013 02:27:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dendCaPlotFieldsSEM_122113a_OpeningFcn, ...
                   'gui_OutputFcn',  @dendCaPlotFieldsSEM_122113a_OutputFcn, ...
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


%% --- Executes just before dendCaPlotFieldsSEM_122113a is made visible.
function dendCaPlotFieldsSEM_122113a_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dendCaPlotFieldsSEM_122113a (see VARARGIN)

% Choose default command line output for dendCaPlotFieldsSEM_122113a
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dendCaPlotFieldsSEM_122113a wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = dendCaPlotFieldsSEM_122113a_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%% --- Executes on selection change in listbox1.
% In this case, this allows selection of multiple event-triggered
% calcium signals and plots (after data and event fieldNames are 
% loaded from desired structure via pushButton1)

function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load in calcium data structure (or other struc) from handles struc
dataStruc = handles.caDataStruc;

contents = cellstr(get(hObject,'String'));  % get selected listbox1 fieldNames
field = get(hObject,'Value');     % index of fieldNames
fieldNames = handles.fieldNames; % get all fieldNames from handles struc
thisField1 = fieldNames{field(1)};  % name of first selected field
thisField2 = fieldNames{field(2)};  % and second
handles.field1 = thisField1;    % and save these back into handles
handles.field2 = thisField2;
%disp(thisField);

hz = 4;
xAx = linspace(-2,6,8*hz+1); 

% calculate SEM of the calcium data for these fields
caData1 = dataStruc.(thisField1);
caData2 = dataStruc.(thisField2);
handles.caData1 = caData1;
handles.caData2 = caData2;
sem1 = std(caData1,0,2)/sqrt(size(caData1,2));
sem2 = std(caData2,0,2)/sqrt(size(caData2,2));

% and plot everything
%figure;
plot(handles.behavCaPlot, xAx, mean(caData1,2), 'b');  xlim([-2 6]);
errorbar(xAx, mean(caData1,2), sem1, 'b');
hold(handles.behavCaPlot);
plot(handles.behavCaPlot, xAx, mean(caData2,2), 'r');
errorbar(xAx, mean(caData2,2), sem2, 'r');

% Update handles structure
guidata(hObject, handles);


% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


%% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%% --- Executes on button press in pushbutton1.
% In this case, this loads in a structure (usually a cageBatch or animal
% struc) and records the fieldNames and Ca data

function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile('.mat');   % select data struc with GUI
cd(pathname);
inStruc = load(filename);   % load in data structure (NOTE: will be one field deep, due to "load" func)
fieldNames = fieldnames(inStruc);   % get the fieldNames (which will be equal to the name/type of target data structure)
caDataStruc = inStruc.(fieldNames{1});  % so now extract bottom level data structure
handles.typeStruc = fieldNames{1};  % and save the type of struc
handles.caDataStruc = caDataStruc;  % and the caData into handles struc

% find fields in calcium data structure
fieldNames = fieldnames(caDataStruc);
% fieldNames = fieldNames(2:length(fieldNames));  % cut out eventStruc

% and only save fieldNames for Ca data
caFields = strfind(fieldNames, 'Ca');   % this give some # for each field with "Ca" in title, zeros if none
caFieldInd = find(not(cellfun('isempty', caFields)));   % finds indices of Ca fields
fieldNames = fieldNames(caFieldInd);    % and only use these fieldNames

handles.fieldNames = fieldNames;    % and save back into handles struc

% so now, take the fieldNames of Ca data
% and make them "string" properties to select from in listbox1
set(handles.listbox1,'String',fieldNames);
% set(handles.listbox1,'Value',1:length(fieldNames));

% Update handles structure
guidata(hObject, handles);
