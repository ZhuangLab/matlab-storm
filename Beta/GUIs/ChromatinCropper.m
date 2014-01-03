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

% Last Modified by GUIDE v2.5 03-Jan-2014 17:15:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
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

global CC

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

% global parameters
global CC ScratchPath %#ok<*NUSED>
   
% Actual Step Commands
step = CC{handles.gui_number}.step;
if step == 1
    handles = LoadConv(handles);   
          
elseif step == 2
   handles = ConvMask(handles);       
        
elseif step == 3
    handles = StormMask(handles); 
        
elseif step == 4  
    handles = CropperDriftCorrection(handles);

elseif step == 5
    handles = FindChromatinClusters(handles);
 

elseif step == 6
    handles = FliterChromatinClusters(handles);
   
elseif step == 7
    handles = SaveChromatinClusters(handles);
   
end % end if statement over steps
   
% Update handles structure
guidata(hObject, handles);

    
% --- Executes on button press in StepParameters.
function StepParameters_Callback(hObject, eventdata, handles)
% hObject    handle to StepParameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CC
step = CC{handles.gui_number}.step;
notCancel = true; 

% parameters get updated in the CC structure array
if step == 1
  GetParsLoadConv(handles); % just loading the image
  
elseif step == 2
    GetParsConvMask(handles);
    
elseif step == 3
    GetParsStormMask(handles);
    
elseif step == 4
    GetParsCropperDrift(handles);

elseif step == 5
    GetParsFindChromatin(handles);
    
elseif step == 6
    GetParsFilterChromatin(handles) 
    
elseif step == 7
    GetParsSaveChromatin(handles)
end
    

% --- Executes on button press in NextStep.
function NextStep_Callback(hObject, eventdata, handles)
% hObject    handle to NextStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CC
Dirs = CC{handles.gui_number}.Dirs;
CC{handles.gui_number}.step = CC{handles.gui_number}.step +1;
step = CC{handles.gui_number}.step;
if step>7
    NextImage_Callback(hObject, eventdata, handles);
    step = 1;
    % step = 7;
    % CC{handles.gui_number}.step = step;
end
set(handles.DirectionsBox,'String',Dirs{step});
    
% --- Executes on button press in BackStep.
function BackStep_Callback(hObject, eventdata, handles)
% hObject    handle to BackStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CC

Dirs = CC{handles.gui_number}.Dirs;
CC{handles.gui_number}.step = CC{handles.gui_number}.step -1;
step = CC{handles.gui_number}.step;
set(handles.DirectionsBox,'String',Dirs{step});



% --- Executes on button press in NextImage.
function NextImage_Callback(hObject, eventdata, handles)
% hObject    handle to NextImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CC
Nbins = length(CC{handles.gui_number}.binfiles);
CC{handles.gui_number}.imnum = CC{handles.gui_number}.imnum + 1;
if CC{handles.gui_number}.imnum <= 0
    CC{handles.gui_number}.imnum = 1;
end
if CC{handles.gui_number}.imnum > Nbins
    CC{handles.gui_number}.imnum = Nbins;
end

binfile = CC{handles.gui_number}.binfiles(CC{handles.gui_number}.imnum);    
set(handles.ImageBox,'String',binfile.name);
CC{handles.gui_number}.step = 1;
set(handles.DirectionsBox,'String',CC{handles.gui_number}.Dirs{1});
RunStep_Callback(hObject, eventdata, handles)

% --- Executes on button press in PreviousImage.
function PreviousImage_Callback(hObject, eventdata, handles)
% hObject    handle to PreviousImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CC
Nbins = length(CC{handles.gui_number}.binfiles);
CC{handles.gui_number}.imnum = CC{handles.gui_number}.imnum - 1;
if CC{handles.gui_number}.imnum <= 0
    CC{handles.gui_number}.imnum = 1;
end
if CC{handles.gui_number}.imnum > Nbins
    CC{handles.gui_number}.imnum = Nbins;
end

binfile = CC{handles.gui_number}.binfiles(CC{handles.gui_number}.imnum);    
set(handles.ImageBox,'String',binfile.name);
CC{handles.gui_number}.step = 1;
set(handles.DirectionsBox,'String',CC{handles.gui_number}.Dirs{1});


function SourceFolder_Callback(hObject, eventdata, handles)
% hObject    handle to SourceFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CC
CC{handles.gui_number}.step = 1;
CC{handles.gui_number}.source = get(handles.SourceFolder,'String');
CC{handles.gui_number}.binfiles = ...
         dir([CC{handles.gui_number}.source,filesep,'*_alist.bin']);
set(handles.DirectionsBox,'String',CC{handles.gui_number}.Dirs{1});
CC{handles.gui_number}.imnum = 1;
if isempty(CC{handles.gui_number}.binfiles)
 error(['error, no alist.bin files found in folder ',...
     CC{handles.gui_number}.source]);
end
binfile = CC{handles.gui_number}.binfiles(CC{handles.gui_number}.imnum);    
set(handles.ImageBox,'String',binfile.name);

StepParameters_Callback(hObject, eventdata, handles)
RunStep_Callback(hObject, eventdata, handles)

% Clear current data
cleardata = input('New folder selected.  Clear current data? y/n? ','s');
if strcmp(cleardata,'y');
     CC{handles.gui_number}.data = [];
     CC{handles.gui_number}.pars7.saveroot ='';
     disp('data cleared'); 
end




% --- Executes on slider movement.
function DotSlider_Callback(hObject, eventdata, handles)
% hObject    handle to DotSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CC
if CC{handles.gui_number}.step == 5
    n = round(get(hObject,'Value'));
    set(handles.DotNum,'String',num2str(n));
    CC{handles.gui_number}.dotnum = n;
    ChromatinPlots(handles, n);
end
if CC{handles.gui_number}.step >= 6
    n = round(get(hObject,'Value'));
    set(handles.DotNum,'String',num2str(n));
    CC{handles.gui_number}.dotnum = n;
    ChromatinPlots2(handles, n);
end

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

global CC
CC{handles.gui_number}.auto = true; 
currImage = CC{handles.gui_number}.imnum;
dat = dir([handles.Source,filesep,'*_alist.bin']);
Nfiles = length(dat); 
for n=currImage:Nfiles
    disp(['Analyzing image ',num2str(1),' of ',num2str(Nfiles),' ',...
        dat.Name]); 
    for step = 1:7
        CC{handles.gui_number}.step = step;
        RunStep_Callback(hObject, eventdata, handles);
    end
    NextImage_Callback(hObject, eventdata, handles)
end
CC{handles.gui_number}.auto = false; 



function DotNum_Callback(hObject, eventdata, handles)
global CC
CC{handles.gui_number}.dotnum = str2double(get(hObject,'String'));
try
 set(handles.DotSlider,'Value',CC{handles.gui_number}.dotnum);
 DotSlider_Callback; 
catch er
    disp(er.message);
    warning('value out of range.');
end

 
% Hints: get(hObject,'String') returns contents of DotNum as text
%        str2double(get(hObject,'String')) returns contents of DotNum as a double





% --- Executes on slider movement.
function CMaxSlider_Callback(hObject, eventdata, handles)
% hObject    handle to CMaxSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CC
CC{handles.gui_number}.pars0.cmax = get(hObject,'Value');
if CC{handles.gui_number}.step > 4
    axes(handles.subaxis2); cla;
    ShowSTORM(handles,CC{handles.gui_number}.dotnum);
end

% --- Executes on slider movement.
function CMinSlider_Callback(hObject, eventdata, handles)
% hObject    handle to CMinSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CC
CC{handles.gui_number}.pars0.cmin = get(hObject,'Value');
if CC{handles.gui_number}.step > 4
    axes(handles.subaxis2); cla;
    ShowSTORM(handles,CC{handles.gui_number}.dotnum);
end


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
    NextImage_Callback(hObject, eventdata, handles);
end


% --------------------------------------------------------------------
function MenuSetWorkingDir_Callback(hObject, eventdata, handles)
% hObject    handle to MenuSetWorkingDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CC
CC{handles.gui_number}.source = uigetdir;
set(handles.SourceFolder,'String',CC{handles.gui_number}.source);
SourceFolder_Callback(hObject, eventdata, handles);


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
