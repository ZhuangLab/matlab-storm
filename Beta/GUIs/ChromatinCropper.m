function varargout = ChromatinCropper(varargin)
% CHROMATINCROPPER MATLAB code for ChromatinCropper.fig
%      CHROMATINCROPPER, by itself, creates a new CHROMATINCROPPER or raises the existing
%      singleton*.
%
%      H = CHROMATINCROPPER returns the handle to a new CHROMATINCROPPER or the handle to
%      the existing singleton*.
%
%      CHROMATINCROPPER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHROMATINCROPPER.M with the given input arguments.
%
%      CHROMATINCROPPER('Property','Value',...) creates a new CHROMATINCROPPER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ChromatinCropper_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ChromatinCropper_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ChromatinCropper

% Last Modified by GUIDE v2.5 20-Jan-2014 14:55:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ChromatinCropper_OpeningFcn, ...
                   'gui_OutputFcn',  @ChromatinCropper_OutputFcn, ...
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


% --- Executes just before ChromatinCropper is made visible.
function ChromatinCropper_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ChromatinCropper (see VARARGIN)

% Choose default command line output for ChromatinCropper
handles.output = hObject;

% Update handles structure -- initializes the axes fields, etc.
guidata(hObject, handles);

% Run CC startup -- sets up default options    
 handles = CCstartup(handles); 
  
 % Update handles structure
guidata(hObject, handles);   

% UIWAIT makes ChromatinCropper wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ChromatinCropper_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in RunStep.
function RunStep_Callback(hObject, eventdata, handles) %#ok<*DEFNU,*INUSL,*INUSD>
% hObject    handle to RunStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RunRunStep(hObject, eventdata, handles);

    
% --- Executes on button press in StepParameters.
function StepParameters_Callback(hObject, eventdata, handles)
% hObject    handle to StepParameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RunStepParameters(hObject, eventdata, handles);

    

% --- Executes on button press in NextStep.
function NextStep_Callback(hObject, eventdata, handles)
% hObject    handle to NextStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RunNextStep(hObject, eventdata, handles);

    
% --- Executes on button press in BackStep.
function BackStep_Callback(hObject, eventdata, handles)
% hObject    handle to BackStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RunBackStep(hObject, eventdata, handles);


% --- Executes on button press in NextImage.
function NextImage_Callback(hObject, eventdata, handles)
% hObject    handle to NextImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RunNextImage(hObject, eventdata, handles);


% --- Executes on button press in PreviousImage.
function PreviousImage_Callback(hObject, eventdata, handles)
% hObject    handle to PreviousImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RunPreviousImage(hObject, eventdata, handles);



function SourceFolder_Callback(hObject, eventdata, handles)
% hObject    handle to SourceFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GetSourceFolder(hObject, eventdata, handles);



% --- Executes on slider movement.
function DotSlider_Callback(hObject, eventdata, handles)
% hObject    handle to DotSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GetDotSlider(hObject, eventdata, handles);


function ImageBox_Callback(hObject, eventdata, handles)


function SaveFolder_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function DotSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function SourceFolder_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function SaveFolder_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function ImageBox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function DotNum_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function CMaxSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function CMinSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in AutoCycle.
function AutoCycle_Callback(hObject, eventdata, handles)
% hObject    handle to AutoCycle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RunAutoCycle(hObject, eventdata, handles);



% --- Executes when DotNum Edit text is updated
function DotNum_Callback(hObject, eventdata, handles)
% hObject    handle to AutoCycle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GetDotNum(hObject, eventdata, handles);


% --- Executes on slider movement.
function CMaxSlider_Callback(hObject, eventdata, handles)
% hObject    handle to CMaxSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GetCMaxSlider(hObject, eventdata, handles);


% --- Executes on slider movement.
function CMinSlider_Callback(hObject, eventdata, handles)
% hObject    handle to CMinSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GetCMinSlider(hObject, eventdata, handles);


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function OptionsMenu_Callback(hObject, eventdata, handles)
% hObject    handle to OptionsMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MenuResumePrevious_Callback(hObject, eventdata, handles)
% hObject    handle to MenuResumePrevious (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
notCancel = ResumePrevious(handles);
if notCancel ~= 0
    RunNextImage(hObject, eventdata, handles);
end


% --------------------------------------------------------------------
function MenuSetWorkingDir_Callback(hObject, eventdata, handles)
% hObject    handle to MenuSetWorkingDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SetWorkingDir(hObject, eventdata, handles);




% --- Executes on button press in sLayer1.
function sLayer1_Callback(hObject, eventdata, handles)
% hObject    handle to sLayer1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sLayer1


% --- Executes on button press in sLayer2.
function sLayer2_Callback(hObject, eventdata, handles)
% hObject    handle to sLayer2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sLayer2


% --------------------------------------------------------------------
function MenuSpecifyOverlays_Callback(hObject, eventdata, handles)
% hObject    handle to MenuSpecifyOverlays (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SpecifyOverlays(handles); 


% --------------------------------------------------------------------
function MenuSelectColormap_Callback(hObject, eventdata, handles)
% hObject    handle to MenuSelectColormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SelectColormap(handles)


%% Set these to update display 
% need a new update display function that checks the step number


% --- Executes on button press in oLayer1.
function oLayer1_Callback(hObject, eventdata, handles)
% hObject    handle to oLayer1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of oLayer1

% --- Executes on button press in oLayer2.
function oLayer2_Callback(hObject, eventdata, handles)
% hObject    handle to oLayer2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of oLayer2

% --- Executes on button press in oLayer3.
function oLayer3_Callback(hObject, eventdata, handles)
% hObject    handle to oLayer3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of oLayer3


% --- Executes on button press in oLayer4.
function oLayer4_Callback(hObject, eventdata, handles)
% hObject    handle to oLayer4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of oLayer4


% --- Executes on button press in AdjustChn2.
function AdjustChn2_Callback(hObject, eventdata, handles)
% hObject    handle to AdjustChn2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AdjustChn2


% --- Executes on button press in AdjustChn1.
function AdjustChn1_Callback(hObject, eventdata, handles)
% hObject    handle to AdjustChn1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AdjustChn1

