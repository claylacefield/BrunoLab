function varargout = dendCaPlotFieldsPeaksSEM_2dataset2field_050815a(varargin)
% DENDCAPLOTFIELDSPEAKSSEM_2DATASET2FIELD_050815A MATLAB code for dendCaPlotFieldsPeaksSEM_2dataset2field_050815a.fig
%      DENDCAPLOTFIELDSPEAKSSEM_2DATASET2FIELD_050815A, by itself, creates a new DENDCAPLOTFIELDSPEAKSSEM_2DATASET2FIELD_050815A or raises the existing
%      singleton*.
%
%      H = DENDCAPLOTFIELDSPEAKSSEM_2DATASET2FIELD_050815A returns the handle to a new DENDCAPLOTFIELDSPEAKSSEM_2DATASET2FIELD_050815A or the handle to
%      the existing singleton*.
%
%      DENDCAPLOTFIELDSPEAKSSEM_2DATASET2FIELD_050815A('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DENDCAPLOTFIELDSPEAKSSEM_2DATASET2FIELD_050815A.M with the given input arguments.
%
%      DENDCAPLOTFIELDSPEAKSSEM_2DATASET2FIELD_050815A('Property','Value',...) creates a new DENDCAPLOTFIELDSPEAKSSEM_2DATASET2FIELD_050815A or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dendCaPlotFieldsPeaksSEM_2dataset2field_050815a_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dendCaPlotFieldsPeaksSEM_2dataset2field_050815a_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dendCaPlotFieldsPeaksSEM_2dataset2field_050815a

% Last Modified by GUIDE v2.5 09-May-2015 00:48:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dendCaPlotFieldsPeaksSEM_2dataset2field_050815a_OpeningFcn, ...
                   'gui_OutputFcn',  @dendCaPlotFieldsPeaksSEM_2dataset2field_050815a_OutputFcn, ...
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


%% --- Executes just before dendCaPlotFieldsPeaksSEM_2dataset2field_050815a is made visible.
function dendCaPlotFieldsPeaksSEM_2dataset2field_050815a_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dendCaPlotFieldsPeaksSEM_2dataset2field_050815a (see VARARGIN)

% Choose default command line output for dendCaPlotFieldsPeaksSEM_2dataset2field_050815a
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dendCaPlotFieldsPeaksSEM_2dataset2field_050815a wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = dendCaPlotFieldsPeaksSEM_2dataset2field_050815a_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



%% --- Executes on button press in loadDataButton1.
% In this case, this loads in a structure (usually a cageBatch or animal
% struc) and records the fieldNames and Ca data

function loadDataButton1_Callback(hObject, eventdata, handles)
% hObject    handle to loadDataButton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile('.mat');   % select data struc with GUI
cd(pathname);
inStruc = load(filename);   % load in data structure (NOTE: will be one field deep, due to "load" func)
fieldNames = fieldnames(inStruc);   % get the fieldNames (which will be equal to the name/type of target data structure)
caDataStruc = inStruc.(fieldNames{1});  % so now extract bottom level data structure
handles.typeStruc1 = fieldNames{1};  % and save the type of struc
handles.caDataStruc1 = caDataStruc;  % and the caData into handles struc
handles.filename1 = filename;

% find fields in calcium data structure
fieldNames = fieldnames(caDataStruc);
% fieldNames = fieldNames(2:length(fieldNames));  % cut out eventStruc

% and only save fieldNames for Ca data
caFields = strfind(fieldNames, 'Ca');   % this give some # for each field with "Ca" in title, zeros if none
caFieldInd = find(not(cellfun('isempty', caFields)));   % finds indices of Ca fields
fieldNames = fieldNames(caFieldInd);    % and only use these fieldNames

handles.fieldNames = fieldNames;    % and save back into handles struc
handles.caFieldInd = caFieldInd;  % 051814 need this to find right fields if some skipped in fieldNames

handles.field1 = fieldNames{1};    % and save these back into handles to intialize fields (not sure it matters)
handles.field2 = fieldNames{2};

% so now, take the fieldNames of Ca data
% and make them "string" properties to select from in listbox1
set(handles.listbox1,'String',fieldNames);
% set(handles.listbox1,'Value',1:length(fieldNames));

% now find peaks in Ca data for each field


for field = 1:length(fieldNames)
    if ~isempty(caDataStruc.(fieldNames{field}))
        caDataField = caDataStruc.(fieldNames{field});
        caDataFieldAvg = nanmean(caDataField, 2);
        [C, I] = max(caDataFieldAvg);
        caAvgPeakVal(field) = C;
        caAvgPeakInd(field) = I;
    else
        caAvgPeakVal(field) = 0;
        caAvgPeakInd(field) = 0;
        
    end
end

[maxPkFieldVal, maxPkFieldInd] = max(caAvgPeakVal);

set(handles.maxFieldTxt, 'String', fieldNames{maxPkFieldInd});

set(handles.filenameTxt1, 'String', ['Filename = ' filename]);

% Update handles structure
guidata(hObject, handles);


function loadDataButton2_Callback(hObject, eventdata, handles)
% hObject    handle to loadDataButton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile('.mat');   % select data struc with GUI
cd(pathname);
inStruc = load(filename);   % load in data structure (NOTE: will be one field deep, due to "load" func)
fieldNames = fieldnames(inStruc);   % get the fieldNames (which will be equal to the name/type of target data structure)
caDataStruc = inStruc.(fieldNames{1});  % so now extract bottom level data structure
handles.typeStruc2 = fieldNames{1};  % and save the type of struc
handles.caDataStruc2 = caDataStruc;  % and the caData into handles struc
handles.filename2 = filename;

% % find fields in calcium data structure
% fieldNames = fieldnames(caDataStruc);
% % fieldNames = fieldNames(2:length(fieldNames));  % cut out eventStruc
% 
% % and only save fieldNames for Ca data
% caFields = strfind(fieldNames, 'Ca');   % this give some # for each field with "Ca" in title, zeros if none
% caFieldInd = find(not(cellfun('isempty', caFields)));   % finds indices of Ca fields
% fieldNames = fieldNames(caFieldInd);    % and only use these fieldNames
% 
% handles.fieldNames = fieldNames;    % and save back into handles struc
% handles.caFieldInd = caFieldInd;  % 051814 need this to find right fields if some skipped in fieldNames
% 
% handles.field1 = fieldNames{1};    % and save these back into handles
% %handles.field2 = fieldNames{2};
% 
% % so now, take the fieldNames of Ca data
% % and make them "string" properties to select from in listbox1
% set(handles.listbox1,'String',fieldNames);
% % set(handles.listbox1,'Value',1:length(fieldNames));

% now find peaks in Ca data for each field

% for field = 1:length(fieldNames)
%     if ~isempty(caDataStruc.(fieldNames{field}))
%         caDataField = caDataStruc.(fieldNames{field});
%         caDataFieldAvg = mean(caDataField, 2);
%         [C, I] = max(caDataFieldAvg);
%         caAvgPeakVal(field) = C;
%         caAvgPeakInd(field) = I;
%     else
%         caAvgPeakVal(field) = 0;
%         caAvgPeakInd(field) = 0;
%         
%     end
% end
% 
% [maxPkFieldVal, maxPkFieldInd] = max(caAvgPeakVal);
% 
% set(handles.maxFieldTxt, 'String', fieldNames{maxPkFieldInd});

set(handles.filenameTxt2, 'String', ['Filename = ' filename]);

% Update handles structure
guidata(hObject, handles);

%% --- Executes on selection change in listbox1.
% In this case, this allows selection of multiple event-triggered
% calcium signals and plots (after data and event fieldNames are 
% loaded from desired structure via loaddatabutton1)


function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load in calcium data structure (or other struc) from handles struc
dataStruc1 = handles.caDataStruc1;
dataStruc2 = handles.caDataStruc2;

contents = cellstr(get(hObject,'String'));  % get selected listbox1 fieldNames
field = get(hObject,'Value');     % index of fieldNames
fieldNames = handles.fieldNames; % get all fieldNames from handles struc
caFieldInd = handles.caFieldInd;  % 051814 need to unpack this to find right field when some skipped in fieldNames

% thisField1 = handles.field1;
% thisField2 = handles.field2;


%% if one field selected, plot for both datasets
if length(field) == 1


try
thisField1 = fieldNames{field(1)};  % name of first selected field
catch
end
handles.field1 = thisField1; 

caData1 = dataStruc1.(thisField1);
%caData2 = dataStruc1.(thisField2);
caData2 = dataStruc2.(thisField1);
handles.caData1 = caData1;
handles.caData2 = caData2;

plotFields(handles);


end

%% if two fields are selected, plot first dataset with field1, second with
% field2
if length(field) == 2

    try
thisField1 = fieldNames{field(1)};  % name of first selected field
    catch
    end
    
try
thisField2 = fieldNames{field(2)};  % and second
catch
end

handles.field1 = thisField1;    % and save these back into handles
handles.field2 = thisField2;
%disp(thisField);

% calculate SEM of the calcium data for these fields
caData1 = dataStruc1.(thisField1);
%caData2 = dataStruc1.(thisField2);
caData2 = dataStruc2.(thisField2);
handles.caData1 = caData1;
handles.caData2 = caData2;

plotFields(handles);

end





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



% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load in relevant variables from handles struc and save 
field1 = handles.field1;
%field2 = handles.field2;

caData1 = handles.caData1;
caData2 = handles.caData2;

caPeakVal1 = handles.caPeakVal1;
caPeakInd1 = handles.caPeakInd1;
caPeakVal2 = handles.caPeakVal2;
caPeakInd2 = handles.caPeakInd2;

typeStruc = handles.typeStruc;
strucFileName = handles.filename; 

[FileName, PathName] = uiputfile('.mat');
save(FileName, 'field1', 'field2', 'caData1', 'caData2', 'caPeakVal1', 'caPeakInd1', 'caPeakVal2', 'caPeakInd2', 'typeStruc', 'strucFileName');

% 
% % --- Executes on button press in loadDataButton1.
% function loadDataButton1_Callback(hObject, eventdata, handles)
% % hObject    handle to loadDataButton1 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)


function plotFields(handles)

cla;


% calculate SEM of the calcium data for these fields

caData1 = handles.caData1;
caData2 = handles.caData2;

try
sem1 = nanstd(caData1,0,2)/sqrt(size(caData1,2));
catch
    disp('Prob with sem1');
end

try
sem2 = nanstd(caData2,0,2)/sqrt(size(caData2,2));
catch
    disp('Prob with sem2');
end

% calculate imaging rate
framesPerTrial = size(caData1, 1);

if framesPerTrial == 33
    hz = 4;
elseif framesPerTrial == 65
    hz = 8;
end

xAx = linspace(-2,6,8*hz+1); % and specify xAxis based upon this

%hold(handles.behavCaPlot);

% and plot Ca signals (with SEM)
% try
%plot(handles.behavCaPlot, xAx, nanmean(caData1,2), 'b');  
%xlim([-2 6]);
errorbar(handles.behavCaPlot, xAx, nanmean(caData1,2), sem1, 'b');
xlabel(handles.behavCaPlot,'sec (from event)'); ylabel(handles.behavCaPlot,'dF/F');
% catch
%     disp(['Error plotting: ' thisField1]);
% end

hold(handles.behavCaPlot);

% try
%plot(handles.behavCaPlot, xAx, nanmean(caData2,2), 'r');
errorbar(handles.behavCaPlot, xAx, nanmean(caData2,2), sem2, 'r');
%hold off;

% catch
%     disp(['Error plotting: ' thisField2]);
% end

% and put lines on for start/stop of event epoch (3s window)
axes(handles.behavCaPlot); %hold on;
line([0 0],[-0.05 0.2], 'Color', 'g');
line([3 3],[-0.05 0.2], 'Color', 'r');
xlim([-2 6]); 
hold off;

%legend(handles.behavCaPlot, thisField1, thisField2);
%hold off;

plot(handles.peakScatterPlot, xAx, caData1, 'b');  xlim([-2 6]);
xlabel(handles.peakScatterPlot,'sec (from event)'); ylabel(handles.peakScatterPlot,'dF/F');
hold(handles.peakScatterPlot);
plot(handles.peakScatterPlot, xAx, caData2, 'r');


% and put lines on for start/stop of event epoch (3s window)
axes(handles.peakScatterPlot); %hold on;
line([0 0],[-0.05 0.2], 'Color', 'g');
line([3 3],[-0.05 0.2], 'Color', 'r');
xlim([-2 6]);
hold off;

%legend(handles.peakScatterPlot, thisField1, thisField2);


% % now plot peaks for these events
% caPeakVal1 = [];
% caPeakVal2 = [];
% 
% for animal = 1:size(caData1, 2)
%    [C, I] = max(caData1(:,animal));
%    caPeakVal1(animal) = C;
%    caPeakInd1(animal) = I;
% end
% 
% for animal = 1:size(caData2, 2)
%    [C, I] = max(caData2(:,animal));
%    caPeakVal2(animal) = C;
%    caPeakInd2(animal) = I;
% end
% 
% handles.caPeakVal1 = caPeakVal1;
% handles.caPeakInd1 = caPeakInd1;
% handles.caPeakVal2 = caPeakVal2;
% handles.caPeakInd2 = caPeakInd2;
% 
% axes(handles.peakScatterPlot);% hold on;
% plot(handles.peakScatterPlot, caPeakVal1, caPeakVal2, 'b.');
% % hold(handles.peakScatterPlot);
% xlim([-0.05 0.3]); ylim([-0.05 0.3]);
% xlabel(thisField1); ylabel(thisField2);
% line([-0.05 0.3], [-0.05 0.3], 'Color', 'k');
% %hold off;
