function varargout = VSDframeGUI_102010a(varargin)
% VSDFRAMEGUI_102010A M-file for VSDframeGUI_102010a.fig
%      VSDFRAMEGUI_102010A, by itself, creates a new VSDFRAMEGUI_102010A or raises the existing
%      singleton*.
%
%      H = VSDFRAMEGUI_102010A returns the handle to a new VSDFRAMEGUI_102010A or the handle to
%      the existing singleton*.
%
%      VSDFRAMEGUI_102010A('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VSDFRAMEGUI_102010A.M with the given input arguments.
%
%      VSDFRAMEGUI_102010A('Property','Value',...) creates a new VSDFRAMEGUI_102010A or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before VSDframeGUI_102010a_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to VSDframeGUI_102010a_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help VSDframeGUI_102010a

% Last Modified by GUIDE v2.5 20-Oct-2010 17:21:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @VSDframeGUI_102010a_OpeningFcn, ...
                   'gui_OutputFcn',  @VSDframeGUI_102010a_OutputFcn, ...
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


% --- Executes just before VSDframeGUI_102010a is made visible.
function VSDframeGUI_102010a_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to VSDframeGUI_102010a (see VARARGIN)

% Choose default command line output for VSDframeGUI_102010a
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes VSDframeGUI_102010a wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = VSDframeGUI_102010a_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
