function varargout = GUIFitParameters(varargin)
% GUIFITPARAMETERS MATLAB code for GUIFitParameters.fig
%      GUIFITPARAMETERS, by itself, creates a new GUIFITPARAMETERS or raises the existing
%      singleton*.
%
%      H = GUIFITPARAMETERS returns the handle to a new GUIFITPARAMETERS or the handle to
%      the existing singleton*.
%
%      GUIFITPARAMETERS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIFITPARAMETERS.M with the given input arguments.
%
%      GUIFITPARAMETERS('Property','Value',...) creates a new GUIFITPARAMETERS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUIFitParameters_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUIFitParameters_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUIFitParameters

% Last Modified by GUIDE v2.5 19-Jan-2013 18:32:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUIFitParameters_OpeningFcn, ...
                   'gui_OutputFcn',  @GUIFitParameters_OutputFcn, ...
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


% --- Executes just before GUIFitParameters is made visible.
function GUIFitParameters_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUIFitParameters (see VARARGIN)

global FitPars
% Set up default values based on input default pars file
    % General
    set(handles.minheight,'String',FitPars.minheight);
    set(handles.maxheight,'String',FitPars.maxheight);
    set(handles.bkd,'String',FitPars.bkd);
    set(handles.minwidth,'String',FitPars.minwidth);
    set(handles.maxwidth,'String',FitPars.maxwidth);
    set(handles.initwidth,'String',FitPars.initwidth);
    set(handles.maxaxratio,'String',FitPars.maxaxratio);
    set(handles.fitROI,'String',FitPars.fitROI);
    set(handles.displacement,'String',FitPars.displacement);
    set(handles.startFrame,'String',FitPars.startFrame);

    % Drift
    if  strmatch(FitPars.CorDrift,'1')
        set(handles.CorDrift,'Value',true);
    else 
       set(handles.CorDrift,'Value',false);
    end
    set(handles.xymols,'String',FitPars.xymols);
    set(handles.zmols,'String',FitPars.zmols);
    set(handles.minframes,'String',FitPars.minframes);
    set(handles.maxframes,'String',FitPars.maxframes);
    set(handles.xygridxy,'String',FitPars.xygridxy);
    set(handles.xygridz,'String',FitPars.xygridz);
    set(handles.movAxy,'String',FitPars.movAxy);
    set(handles.movAz,'String',FitPars.movAz);

    % Zcal
    if strmatch(FitPars.Fit3D,'2')
       set(handles.Fit3D,'Value',1)
    else 
        set(handles.Fit3D,'Value',0)
    end
    set(handles.zcaltxt,'String',FitPars.zcaltxt);
    set(handles.zop,'String',FitPars.zop);
    set(handles.zstart,'String',FitPars.zstart);
    set(handles.zend,'String',FitPars.zend);
    set(handles.zstep,'String',FitPars.zstep);



% Choose default command line output for GUIFitParameters
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUIFitParameters wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUIFitParameters_OutputFcn(hObject, eventdata, handles) 
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

global FitPars

% General
FitPars.minheight = get(handles.minheight,'String');
FitPars.maxheight = get(handles.maxheight,'String');
FitPars.bkd = get(handles.bkd,'String');
FitPars.minwidth = get(handles.minwidth,'String');
FitPars.maxwidth = get(handles.maxwidth,'String');
FitPars.initwidth = get(handles.initwidth,'String');
FitPars.maxaxratio = get(handles.maxaxratio,'String');
FitPars.fitROI = get(handles.fitROI,'String');
FitPars.displacement =  get(handles.displacement,'String');
FitPars.startFrame = get(handles.startFrame,'String'); 

% Drift
FitPars.CorDrift =  num2str(get(handles.CorDrift,'Value'));
FitPars.xymols = get(handles.xymols,'String');
FitPars.zmols = get(handles.zmols,'String');
FitPars.minframes = get(handles.minframes,'String');
FitPars.maxframes = get(handles.maxframes,'String');
FitPars.xygridxy = get(handles.xygridxy,'String');
FitPars.xygridz = get(handles.xygridz,'String');
FitPars.movAxy = get(handles.movAxy,'String');
FitPars.movAz = get(handles.movAz,'String');

% Zcal
fit3d = get(handles.Fit3D,'Value');
if fit3d == 1   
    FitPars.Fit3D = '2';
else 
    FitPars.Fit3D = '0';
end
FitPars.zcaltxt = get(handles.zcaltxt,'String');
FitPars.zop  = get(handles.zop,'String');
FitPars.zstart = get(handles.zstart,'String');
FitPars.zend = get(handles.zend,'String');
FitPars.zstep = get(handles.zstep,'String');

pause(.1); 
close(GUIFitParameters);


% --- Executes on button press in CorDrift.
function CorDrift_Callback(hObject, eventdata, handles)
% hObject    handle to CorDrift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CorDrift



function minheight_Callback(hObject, eventdata, handles)
% hObject    handle to minheight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minheight as text
%        str2double(get(hObject,'String')) returns contents of minheight as a double


% --- Executes during object creation, after setting all properties.
function minheight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minheight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxheight_Callback(hObject, eventdata, handles)
% hObject    handle to maxheight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxheight as text
%        str2double(get(hObject,'String')) returns contents of maxheight as a double


% --- Executes during object creation, after setting all properties.
function maxheight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxheight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bkd_Callback(hObject, eventdata, handles)
% hObject    handle to bkd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bkd as text
%        str2double(get(hObject,'String')) returns contents of bkd as a double


% --- Executes during object creation, after setting all properties.
function bkd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bkd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function minwidth_Callback(hObject, eventdata, handles)
% hObject    handle to minwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minwidth as text
%        str2double(get(hObject,'String')) returns contents of minwidth as a double


% --- Executes during object creation, after setting all properties.
function minwidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxwidth_Callback(hObject, eventdata, handles)
% hObject    handle to maxwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxwidth as text
%        str2double(get(hObject,'String')) returns contents of maxwidth as a double


% --- Executes during object creation, after setting all properties.
function maxwidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function initwidth_Callback(hObject, eventdata, handles)
% hObject    handle to initwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of initwidth as text
%        str2double(get(hObject,'String')) returns contents of initwidth as a double


% --- Executes during object creation, after setting all properties.
function initwidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to initwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxaxratio_Callback(hObject, eventdata, handles)
% hObject    handle to maxaxratio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxaxratio as text
%        str2double(get(hObject,'String')) returns contents of maxaxratio as a double


% --- Executes during object creation, after setting all properties.
function maxaxratio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxaxratio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fitROI_Callback(hObject, eventdata, handles)
% hObject    handle to fitROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fitROI as text
%        str2double(get(hObject,'String')) returns contents of fitROI as a double


% --- Executes during object creation, after setting all properties.
function fitROI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fitROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in Fit3D.
function Fit3D_Callback(hObject, eventdata, handles)
% hObject    handle to Fit3D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Fit3D



function zcaltxt_Callback(hObject, eventdata, handles)
% hObject    handle to zcaltxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zcaltxt as text
%        str2double(get(hObject,'String')) returns contents of zcaltxt as a double


% --- Executes during object creation, after setting all properties.
function zcaltxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zcaltxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zop_Callback(hObject, eventdata, handles)
% hObject    handle to zop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zop as text
%        str2double(get(hObject,'String')) returns contents of zop as a double


% --- Executes during object creation, after setting all properties.
function zop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zstart_Callback(hObject, eventdata, handles)
% hObject    handle to zstart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zstart as text
%        str2double(get(hObject,'String')) returns contents of zstart as a double


% --- Executes during object creation, after setting all properties.
function zstart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zstart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zend_Callback(hObject, eventdata, handles)
% hObject    handle to zend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zend as text
%        str2double(get(hObject,'String')) returns contents of zend as a double


% --- Executes during object creation, after setting all properties.
function zend_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zstep_Callback(hObject, eventdata, handles)
% hObject    handle to zstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zstep as text
%        str2double(get(hObject,'String')) returns contents of zstep as a double


% --- Executes during object creation, after setting all properties.
function zstep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xymols_Callback(hObject, eventdata, handles)
% hObject    handle to xymols (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xymols as text
%        str2double(get(hObject,'String')) returns contents of xymols as a double


% --- Executes during object creation, after setting all properties.
function xymols_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xymols (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zmols_Callback(hObject, eventdata, handles)
% hObject    handle to zmols (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zmols as text
%        str2double(get(hObject,'String')) returns contents of zmols as a double


% --- Executes during object creation, after setting all properties.
function zmols_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zmols (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function minframes_Callback(hObject, eventdata, handles)
% hObject    handle to minframes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minframes as text
%        str2double(get(hObject,'String')) returns contents of minframes as a double


% --- Executes during object creation, after setting all properties.
function minframes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minframes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxframes_Callback(hObject, eventdata, handles)
% hObject    handle to maxframes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxframes as text
%        str2double(get(hObject,'String')) returns contents of maxframes as a double


% --- Executes during object creation, after setting all properties.
function maxframes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxframes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xygridxy_Callback(hObject, eventdata, handles)
% hObject    handle to xygridxy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xygridxy as text
%        str2double(get(hObject,'String')) returns contents of xygridxy as a double


% --- Executes during object creation, after setting all properties.
function xygridxy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xygridxy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xygridz_Callback(hObject, eventdata, handles)
% hObject    handle to xygridz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xygridz as text
%        str2double(get(hObject,'String')) returns contents of xygridz as a double


% --- Executes during object creation, after setting all properties.
function xygridz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xygridz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function movAxy_Callback(hObject, eventdata, handles)
% hObject    handle to movAxy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of movAxy as text
%        str2double(get(hObject,'String')) returns contents of movAxy as a double


% --- Executes during object creation, after setting all properties.
function movAxy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to movAxy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function movAz_Callback(hObject, eventdata, handles)
% hObject    handle to movAz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of movAz as text
%        str2double(get(hObject,'String')) returns contents of movAz as a double


% --- Executes during object creation, after setting all properties.
function movAz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to movAz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function displacement_Callback(hObject, eventdata, handles)
% hObject    handle to displacement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of displacement as text
%        str2double(get(hObject,'String')) returns contents of displacement as a double


% --- Executes during object creation, after setting all properties.
function displacement_CreateFcn(hObject, eventdata, handles)
% hObject    handle to displacement (see GCBO)
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
