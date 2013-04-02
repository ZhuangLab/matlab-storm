function varargout = ChromeWarpParameters(varargin)
% CHROMEWARPPARAMETERS MATLAB code for ChromeWarpParameters.fig
%      CHROMEWARPPARAMETERS, by itself, creates a new CHROMEWARPPARAMETERS or raises the existing
%      singleton*.
%
%      H = CHROMEWARPPARAMETERS returns the handle to a new CHROMEWARPPARAMETERS or the handle to
%      the existing singleton*.
%
%      CHROMEWARPPARAMETERS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHROMEWARPPARAMETERS.M with the given input arguments.
%
%      CHROMEWARPPARAMETERS('Property','Value',...) creates a new CHROMEWARPPARAMETERS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ChromeWarpParameters_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ChromeWarpParameters_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ChromeWarpParameters

% Last Modified by GUIDE v2.5 13-Mar-2013 16:23:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ChromeWarpParameters_OpeningFcn, ...
                   'gui_OutputFcn',  @ChromeWarpParameters_OutputFcn, ...
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


% --- Executes just before ChromeWarpParameters is made visible.
function ChromeWarpParameters_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ChromeWarpParameters (see VARARGIN)

global chromeWarpPars
% Choose default command line output for ChromeWarpParameters
handles.output = hObject;

% Set defaults:
if ~chromeWarpPars.OK  % only update on load, not on exit
chromeWarpPars.ChannelNames{1} = '750,647';
chromeWarpPars.DaxfileRoots{1} = 'IRbeads';
chromeWarpPars.ParameterRoots{1} = 'IRBead';
chromeWarpPars.ReferenceChannel{1} = '647';
chromeWarpPars.Quadview{1} = 1;

chromeWarpPars.ChannelNames{2} = '647,561,488';
chromeWarpPars.DaxfileRoots{2} = 'Visbeads';
chromeWarpPars.ParameterRoots{2} = 'VisBead';
chromeWarpPars.ReferenceChannel{2} = '647';
chromeWarpPars.Quadview{2} = 1;
chromeWarpPars.ListQVorder = '647,561,750,488';
end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ChromeWarpParameters wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ChromeWarpParameters_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global chromeWarpPars %#ok<NUSED>
pause(.1);
close(ZCalibrationParameters); 

% --- Executes on button press in SavePars.
function SavePars_Callback(hObject, eventdata, handles)
% hObject    handle to SavePars (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global chromeWarpPars
chromeWarpPars.OK = true;
chromeWarpPars.NMovieSets = str2double(get(handles.NMovieSets,'String'));
chromeWarpPars.FramesPerZ = str2double(get(handles.FramesPerZ,'String'));
chromeWarpPars.AffineRadius = str2double(get(handles.AffineRadius,'String'));
chromeWarpPars.PolyRadius = str2double(get(handles.PolyRadius,'String'));
chromeWarpPars.SaveNameRoot = get(handles.SaveNameRoot,'String');
chromeWarpPars.OverwriteBin = logical(get(handles.OverwriteBin,'Value'));
chromeWarpPars.HideTerminal = logical(get(handles.HideTerminal,'Value'));
chromeWarpPars.ExcludePoorZ = logical(get(handles.ExcludePoorZ,'Value'));
chromeWarpPars.VerboseOn = logical(get(handles.VerboseOn,'Value'));
chromeWarpPars.ListQVorder = get(handles.ListQVorder,'String');

for m=1:chromeWarpPars.NMovieSets
    chromeWarpPars.Chns{m} = parseCSL(chromeWarpPars.ChannelNames{m}); 
end
chromeWarpPars.QVorder = parseCSL(chromeWarpPars.ListQVorder); 
pause(.1);
close(ZCalibrationParameters); 

% --- Executes on selection change in SelectSet.
function SelectSet_Callback(hObject, eventdata, handles)
% hObject    handle to SelectSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SelectSet contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectSet
global chromeWarpPars
 m = get(handles.SelectSet,'Value');
 try  % may not exist yet
set(handles.ChannelNames,'String',chromeWarpPars.ChannelNames{m});
set(handles.DaxfileRoots,'String',chromeWarpPars.DaxfileRoots{m});
set(handles.ParameterRoots,'String',chromeWarpPars.ParameterRoots{m});
set(handles.ReferenceChannel,'String',chromeWarpPars.ReferenceChannel{m});
set(handles.Quadview,'Value',chromeWarpPars.Quadview{m});
 catch
 end

 % --- Executes when selected object is changed in CameraMode.
function CameraMode_SelectionChangeFcn(hObject, eventdata, handles)
global chromeWarpPars
 m = get(handles.SelectSet,'Value');
chromeWarpPars.Quadview{m} = get(handles.Quadview,'Value');
dualview = get(handles.Dualview,'Value');
if dualview
    disp('sorry, dualview analysis not yet available. please chose another option');
    set(handles.Quadview,'Value',1);
end



function NMovieSets_Callback(hObject, eventdata, handles)
 Nmovies = str2double(get(handles.NMovieSets,'String'));
 newsets = num2str( (1:Nmovies)' );
 set(handles.SelectSet,'String',newsets);


function ChannelNames_Callback(hObject, eventdata, handles)
global chromeWarpPars
 m = get(handles.SelectSet,'Value');
chromeWarpPars.ChannelNames{m} = get(handles.ChannelNames,'String');

function DaxfileRoots_Callback(hObject, eventdata, handles)
global chromeWarpPars
 m = get(handles.SelectSet,'Value');
 chromeWarpPars.DaxfileRoots{m} = get(handles.DaxfileRoots,'String');
 
function ParameterRoots_Callback(hObject, eventdata, handles)
global chromeWarpPars
 m = get(handles.SelectSet,'Value');
 chromeWarpPars.ParameterRoots{m} = get(handles.ParameterRoots,'String');
 
function ReferenceChannel_Callback(hObject, eventdata, handles)
global chromeWarpPars
 m = get(handles.SelectSet,'Value');
 chromeWarpPars.ReferenceChannel{m} = get(handles.ReferenceChannel,'String');
 
function ListQVorder_Callback(hObject, eventdata, handles) %#ok<*INUSL>
global chromeWarpPars
 m = get(handles.SelectSet,'Value');
 chromeWarpPars.ListQVorder = get(handles.ListQVorder,'String');


% --- Executes on button press in OverwriteBin.
function OverwriteBin_Callback(hObject, eventdata, handles)  %#ok<*DEFNU,*INUSD>
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

% --------------------------------------------------------------------
function CameraMode_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to CameraMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);




