function varargout = GUIgpuParameters(varargin)
% GUIGPUPARAMETERS MATLAB code for GUIgpuParameters.fig
%      GUIGPUPARAMETERS, by itself, creates a new GUIGPUPARAMETERS or raises the existing
%      singleton*.
%
%      H = GUIGPUPARAMETERS returns the handle to a new GUIGPUPARAMETERS or the handle to
%      the existing singleton*.
%
%      GUIGPUPARAMETERS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIGPUPARAMETERS.M with the given input arguments.
%
%      GUIGPUPARAMETERS('Property','Value',...) creates a new GUIGPUPARAMETERS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUIgpuParameters_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUIgpuParameters_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUIgpuParameters

% Last Modified by GUIDE v2.5 23-Jan-2013 18:24:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUIgpuParameters_OpeningFcn, ...
                   'gui_OutputFcn',  @GUIgpuParameters_OutputFcn, ...
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


% --- Executes just before GUIgpuParameters is made visible.
function GUIgpuParameters_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUIgpuParameters (see VARARGIN)

global SF 
% when called at closing there is no varargin input...  
if ~isempty(varargin)
    instanceID = varargin{1}; 
    handles.instanceID = instanceID;
else
    instanceID = handles.instanceID;
end

set(handles.PSFsigma,'String',SF{instanceID}.FitPars.PSFsigma);
set(handles.AvePhotons,'String',SF{instanceID}.FitPars.Nave);
set(handles.Nmax,'String',SF{instanceID}.FitPars.Nmax);
set(handles.pvalue,'String',SF{instanceID}.FitPars.pvalue_threshold);
set(handles.resolution,'String',SF{instanceID}.FitPars.resolution);
set(handles.pixelsize,'String',SF{instanceID}.FitPars.pixelsize);
set(handles.boxsz,'String',SF{instanceID}.FitPars.boxsz);
set(handles.counts,'String',SF{instanceID}.FitPars.counts_per_photon);
set(handles.startFrame,'String',SF{instanceID}.FitPars.startFrame);
set(handles.endFrame,'String',SF{instanceID}.FitPars.endFrame);


% Choose default command line output for GUIgpuParameters
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUIgpuParameters wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUIgpuParameters_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in SavePars.
function SavePars_Callback(hObject, eventdata, handles) %#ok<*INUSL>
% hObject    handle to SavePars (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SF
instanceID = handles.instanceID;
SF{instanceID}.FitPars.PSFsigma = get(handles.PSFsigma,'String'); 
SF{instanceID}.FitPars.Nave = get(handles.AvePhotons,'String'); 
SF{instanceID}.FitPars.Nmax = get(handles.Nmax,'String'); 
SF{instanceID}.FitPars.pvalue_threshold = get(handles.pvalue,'String'); 
SF{instanceID}.FitPars.resolution = get(handles.resolution,'String'); 
SF{instanceID}.FitPars.pixelsize = get(handles.pixelsize,'String');
SF{instanceID}.FitPars.boxsz = get(handles.boxsz,'String');
SF{instanceID}.FitPars.counts_per_photon = get(handles.counts,'String');
SF{instanceID}.FitPars.startFrame = get(handles.startFrame,'String');
SF{instanceID}.FitPars.endFrame = get(handles.endFrame,'String');

SF{instanceID}.FitPars.OK = true;
pause(.1); 
close(GUIgpuParameters);













function PSFsigma_Callback(hObject, eventdata, handles) %#ok<*DEFNU,*INUSD>
% hObject    handle to PSFsigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PSFsigma as text
%        str2double(get(hObject,'String')) returns contents of PSFsigma as a double


% --- Executes during object creation, after setting all properties.
function PSFsigma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PSFsigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AvePhotons_Callback(hObject, eventdata, handles)
% hObject    handle to AvePhotons (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AvePhotons as text
%        str2double(get(hObject,'String')) returns contents of AvePhotons as a double


% --- Executes during object creation, after setting all properties.
function AvePhotons_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AvePhotons (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Nmax_Callback(hObject, eventdata, handles)
% hObject    handle to Nmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Nmax as text
%        str2double(get(hObject,'String')) returns contents of Nmax as a double


% --- Executes during object creation, after setting all properties.
function Nmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Nmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pvalue_Callback(hObject, eventdata, handles)
% hObject    handle to pvalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pvalue as text
%        str2double(get(hObject,'String')) returns contents of pvalue as a double


% --- Executes during object creation, after setting all properties.
function pvalue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pvalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function resolution_Callback(hObject, eventdata, handles)
% hObject    handle to resolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of resolution as text
%        str2double(get(hObject,'String')) returns contents of resolution as a double


% --- Executes during object creation, after setting all properties.
function resolution_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function boxsz_Callback(hObject, eventdata, handles)
% hObject    handle to boxsz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of boxsz as text
%        str2double(get(hObject,'String')) returns contents of boxsz as a double


% --- Executes during object creation, after setting all properties.
function boxsz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to boxsz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function counts_Callback(hObject, eventdata, handles)
% hObject    handle to counts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of counts as text
%        str2double(get(hObject,'String')) returns contents of counts as a double


% --- Executes during object creation, after setting all properties.
function counts_CreateFcn(hObject, eventdata, handles)
% hObject    handle to counts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startFrame_Callback(hObject, eventdata, handles)
% hObject    handle to startFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startFrame as text
%        str2double(get(hObject,'String')) returns contents of startFrame as a double


% --- Executes during object creation, after setting all properties.
function startFrame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function endFrame_Callback(hObject, eventdata, handles)
% hObject    handle to endFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of endFrame as text
%        str2double(get(hObject,'String')) returns contents of endFrame as a double


% --- Executes during object creation, after setting all properties.
function endFrame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to endFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pixelsize_Callback(hObject, eventdata, handles)
% hObject    handle to pixelsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pixelsize as text
%        str2double(get(hObject,'String')) returns contents of pixelsize as a double


% --- Executes during object creation, after setting all properties.
function pixelsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pixelsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
