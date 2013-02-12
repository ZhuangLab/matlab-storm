function varargout = ZCalibrationParameters(varargin)
% ZCALIBRATIONPARAMETERS MATLAB code for ZCalibrationParameters.fig
%      ZCALIBRATIONPARAMETERS, by itself, creates a new ZCALIBRATIONPARAMETERS or raises the existing
%      singleton*.
%
%      H = ZCALIBRATIONPARAMETERS returns the handle to a new ZCALIBRATIONPARAMETERS or the handle to
%      the existing singleton*.
%
%      ZCALIBRATIONPARAMETERS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ZCALIBRATIONPARAMETERS.M with the given input arguments.
%
%      ZCALIBRATIONPARAMETERS('Property','Value',...) creates a new ZCALIBRATIONPARAMETERS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ZCalibrationParameters_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ZCalibrationParameters_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ZCalibrationParameters

% Last Modified by GUIDE v2.5 12-Feb-2013 17:14:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ZCalibrationParameters_OpeningFcn, ...
                   'gui_OutputFcn',  @ZCalibrationParameters_OutputFcn, ...
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


% --- Executes just before ZCalibrationParameters is made visible.
function ZCalibrationParameters_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ZCalibrationParameters (see VARARGIN)

global Zcalpars
% Choose default command line output for ZCalibrationParameters
handles.output = hObject;

% Set defaults:
Zcalpars.ChannelNames{1} = '750,647';
Zcalpars.DaxfileRoots{1} = 'IRbeads';
Zcalpars.ParameterRoots{1} = 'IRBead';
Zcalpars.ReferenceChannel{1} = '647';
Zcalpars.Quadview{1} = 1;

Zcalpars.ChannelNames{2} = '647,561,488';
Zcalpars.DaxfileRoots{2} = 'Visbeads';
Zcalpars.ParameterRoots{2} = 'VisBead';
Zcalpars.ReferenceChannel{2} = '647';
Zcalpars.Quadview{2} = 1;
Zcalpars.ListQVorder = '647,561,750,488';
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ZCalibrationParameters wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ZCalibrationParameters_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in SavePars.
function SavePars_Callback(hObject, eventdata, handles)
% hObject    handle to SavePars (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zcalpars

Zcalpars.NMovieSets = num2str(get(handles.NMovieSets,'String'));
Zcalpars.FramesPerZ = num2str(get(handles.FramesPerZ,'String'));
Zcalpars.AffineRadius = num2str(get(handles.AffineRadius,'String'));
Zcalpars.PolyRadius = num2str(get(handles.PolyRadius,'String'));
Zcalpars.SaveNameRoot = get(handles.SaveNameRoot,'String');
Zcalpars.OverwriteBin = get(handles.SaveNameRoot,'Value');
Zcalpars.Hideterminal = get(handles.SaveNameRoot,'Value');
Zcalpars.ExcludePoorZ = get(handles.SaveNameRoot,'Value');
Zcalpars.VerboseOn = get(handles.SaveNameRoot,'Value');

Zcalpars.ListQVorder = get(handles.ListQVorder,'Value');

Nsets = get(handles.SelectSet,'Value');
for m=1:Nsets
    Zcalpars.Chns{m} = parseCSL(Zcalpars.ChannelNames{m}); 
end
Zcalpars.QVorder = parseCSL(Zcalpars.ListQVorder); 

close(ZCalibrationParameters); 

% --- Executes on selection change in SelectSet.
function SelectSet_Callback(hObject, eventdata, handles)
% hObject    handle to SelectSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SelectSet contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectSet
global Zcalpars
 m = get(handles.SelectSet,'Value');
 try  % may not exist yet
set(handles.ChannelNames,'String',Zcalpars.ChannelNames{m});
set(handles.DaxfileRoots,'String',Zcalpars.DaxfileRoots{m});
set(handles.ParameterRoots,'String',Zcalpars.ParameterRoots{m});
set(handles.ReferenceChannel,'String',Zcalpars.ReferenceChannel{m});
 catch
 end

 
% --------------------------------------------------------------------
function CameraMode_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to CameraMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Zcalpars
Zcalpars.Quadview{m} = get(handles.Quadview,'Value');
dualview = get(handles.Dualview,'Value');
if dualview
    error('sorry, dualview analysis not yet available. please chose another option');
end


function NMovieSets_Callback(hObject, eventdata, handles)
 Nmovies = str2double(get(handles.NMovieSets,'String'));
 num2str( (1:Nmovies)' );
 set(handles.SelectSet,'String');


function ChannelNames_Callback(hObject, eventdata, handles)
global Zcalpars
 m = get(handles.SelectSet,'Value');
Zcalpars.ChannelNames{m} = get(handles.ChannelNames,'String');

function DaxfileRoots_Callback(hObject, eventdata, handles)
global Zcalpars
 m = get(handles.SelectSet,'Value');
 Zcalpars.DaxfileRoots{m} = get(handles.DaxfileRoots,'String');
 
function ParameterRoots_Callback(hObject, eventdata, handles)
global Zcalpars
 m = get(handles.SelectSet,'Value');
 Zcalpars.ParameterRoots{m} = get(handles.ParameterRoots,'String');
 
function ReferenceChannel_Callback(hObject, eventdata, handles)
global Zcalpars
 m = get(handles.SelectSet,'Value');
 Zcalpars.ReferenceChannel{m} = get(handles.ReferenceChannel,'String');
 
function ListQVorder_Callback(hObject, eventdata, handles)
global Zcalpars
 m = get(handles.SelectSet,'Value');
 Zcalpars.ListQVorder = get(handles.ListQVorder,'String');


% --- Executes on button press in OverwriteBin.
function OverwriteBin_Callback(hObject, eventdata, handles)
% hObject    handle to OverwriteBin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of OverwriteBin


% --- Executes on button press in HideTerminal.
function HideTerminal_Callback(hObject, eventdata, handles)
% hObject    handle to HideTerminal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of HideTerminal


% --- Executes on button press in ExcludePoorZ.
function ExcludePoorZ_Callback(hObject, eventdata, handles)
% hObject    handle to ExcludePoorZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ExcludePoorZ


% --- Executes on button press in VerboseOn.
function VerboseOn_Callback(hObject, eventdata, handles)
% hObject    handle to VerboseOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of VerboseOn



function FramesPerZ_Callback(hObject, eventdata, handles)
% hObject    handle to FramesPerZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FramesPerZ as text
%        str2double(get(hObject,'String')) returns contents of FramesPerZ as a double


% --- Executes during object creation, after setting all properties.
function FramesPerZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FramesPerZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AffineRadius_Callback(hObject, eventdata, handles)
% hObject    handle to AffineRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AffineRadius as text
%        str2double(get(hObject,'String')) returns contents of AffineRadius as a double


% --- Executes during object creation, after setting all properties.
function AffineRadius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AffineRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PolyRadius_Callback(hObject, eventdata, handles)
% hObject    handle to PolyRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PolyRadius as text
%        str2double(get(hObject,'String')) returns contents of PolyRadius as a double


% --- Executes during object creation, after setting all properties.
function PolyRadius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PolyRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SaveNameRoot_Callback(hObject, eventdata, handles)
% hObject    handle to SaveNameRoot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SaveNameRoot as text
%        str2double(get(hObject,'String')) returns contents of SaveNameRoot as a double


% --- Executes during object creation, after setting all properties.
function SaveNameRoot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SaveNameRoot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes during object creation, after setting all properties.
function NMovieSets_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NMovieSets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function SelectSet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






% --- Executes during object creation, after setting all properties.
function ChannelNames_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ChannelNames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes during object creation, after setting all properties.
function DaxfileRoots_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DaxfileRoots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes during object creation, after setting all properties.
function ParameterRoots_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ParameterRoots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes during object creation, after setting all properties.
function ReferenceChannel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ReferenceChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end







% --- Executes during object creation, after setting all properties.
function ListQVorder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListQVorder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
