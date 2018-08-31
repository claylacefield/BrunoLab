function varargout = dendCaPlotFieldsPeaksSEM_122813a(varargin)
% DENDCAPLOTFIELDSPEAKSSEM_122813A MATLAB code for dendCaPlotFieldsPeaksSEM_122813a.fig
%      DENDCAPLOTFIELDSPEAKSSEM_122813A, by itself, creates a new DENDCAPLOTFIELDSPEAKSSEM_122813A or raises the existing
%      singleton*.
%
%      H = DENDCAPLOTFIELDSPEAKSSEM_122813A returns the handle to a new DENDCAPLOTFIELDSPEAKSSEM_122813A or the handle to
%      the existing singleton*.
%
%      DENDCAPLOTFIELDSPEAKSSEM_122813A('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DENDCAPLOTFIELDSPEAKSSEM_122813A.M with the given input arguments.
%
%      DENDCAPLOTFIELDSPEAKSSEM_122813A('Property','Value',...) creates a new DENDCAPLOTFIELDSPEAKSSEM_122813A or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dendCaPlotFieldsPeaksSEM_122813a_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dendCaPlotFieldsPeaksSEM_122813a_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dendCaPlotFieldsPeaksSEM_122813a

% Last Modified by GUIDE v2.5 28-Dec-2013 13:58:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dendCaPlotFieldsPeaksSEM_122813a_OpeningFcn, ...
                   'gui_OutputFcn',  @dendCaPlotFieldsPeaksSEM_122813a_OutputFcn, ...
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


%% --- Executes just before dendCaPlotFieldsPeaksSEM_122813a is made visible.
function dendCaPlotFieldsPeaksSEM_122813a_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dendCaPlotFieldsPeaksSEM_122813a (see VARARGIN)

% Choose default command line output for dendCaPlotFieldsPeaksSEM_122813a
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dendCaPlotFieldsPeaksSEM_122813a wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = dendCaPlotFieldsPeaksSEM_122813a_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%% --- Executes on selection change in listbox1.
% In this case, this allows selection of multiple event-triggered
% calcium signals and plots (after data and event fieldNames are 
% loaded from desired structure via loaddatabutton)

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

% and plot Ca signals (with SEM)
%figure;
plot(handles.behavCaPlot, xAx, mean(caData1,2), 'b');  xlim([-2 6]);
% hold(handles.behavCaPlot);
errorbar(handles.behavCaPlot, xAx, mean(caData1,2), sem1, 'b');
xlabel(handles.behavCaPlot,'sec (from event)'); ylabel(handles.behavCaPlot,'dF/F');
hold(handles.behavCaPlot);
plot(handles.behavCaPlot, xAx, mean(caData2,2), 'r');
errorbar(handles.behavCaPlot, xAx, mean(caData2,2), sem2, 'r');

% startX = 0; % 2*hz;
% stopX = 3;
% hold(handles.behavCaPlot);
% yL = get(handles.behavCaPlot, 'YLim');
axes(handles.behavCaPlot); %hold on;
line([0 0],[-0.05 0.2], 'Color', 'g');
line([3 3],[-0.05 0.2], 'Color', 'r');

legend(handles.behavCaPlot, thisField1, thisField2);
%hold off;

% now plot peaks for these events
caPeakVal1 = [];
caPeakVal2 = [];

for animal = 1:size(caData1, 2)
   [C, I] = max(caData1(:,animal));
   caPeakVal1(animal) = C;
   caPeakInd1(animal) = I;
   [C, I] = max(caData2(:,animal));
   caPeakVal2(animal) = C;
   caPeakInd2(animal) = I;
end

axes(handles.peakScatterPlot);% hold on;
plot(handles.peakScatterPlot, caPeakVal1, caPeakVal2, 'b.');
% hold(handles.peakScatterPlot);
xlim([-0.05 0.3]); ylim([-0.05 0.3]);
xlabel(thisField1); ylabel(thisField2);
line([-0.05 0.3], [-0.05 0.3], 'Color', 'k');
%hold off;

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



%% --- Executes on button press in loadDataButton.
% In this case, this loads in a structure (usually a cageBatch or animal
% struc) and records the fieldNames and Ca data

function loadDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadDataButton (see GCBO)
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

% now find peaks in Ca data for each field

% for field = 1:length(fieldNames)
%    caDataField = caDataStruc.(fieldNames{field}); 
%    caDataFieldAvg = mean(caDataField, 2);
%    [C, I] = max(caDataFieldAvg);
%    caAvgPeakVal(field) = C;
%    caAvgPeakInd(field) = I;
% end
% 
% handles.caAvgPeakVal = caAvgPeakVal;
% handles.caAvgPeakInd = caAvgPeakInd;

% Update handles structure
guidata(hObject, handles);
