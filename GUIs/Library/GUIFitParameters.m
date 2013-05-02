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

% Last Modified by GUIDE v2.5 03-Apr-2013 10:53:06

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

global SF 
% when called at closing there is no varargin input...  
if ~isempty(varargin)
    instanceID = varargin{1}; 
    handles.instanceID = instanceID;
    disp(['instanceID =',num2str(instanceID)]);
    
% Set up default values based on input default pars file
    % General
    set(handles.minheight,'String',SF{instanceID}.FitPars.minheight);
    set(handles.maxheight,'String',SF{instanceID}.FitPars.maxheight);
    set(handles.bkd,'String',SF{instanceID}.FitPars.bkd);
    set(handles.minwidth,'String',SF{instanceID}.FitPars.minwidth);
    set(handles.maxwidth,'String',SF{instanceID}.FitPars.maxwidth);
    set(handles.initwidth,'String',SF{instanceID}.FitPars.initwidth);
    set(handles.maxaxratio,'String',SF{instanceID}.FitPars.maxaxratio);
    set(handles.fitROI,'String',SF{instanceID}.FitPars.fitROI);
    set(handles.displacement,'String',SF{instanceID}.FitPars.displacement);
    set(handles.startFrame,'String',SF{instanceID}.FitPars.startFrame);

    % Drift
    if  strcmp(SF{instanceID}.FitPars.CorDrift,'1')
        set(handles.CorDrift,'Value',true);
    else 
       set(handles.CorDrift,'Value',false);
    end
    set(handles.xymols,'String',SF{instanceID}.FitPars.xymols);
    set(handles.zmols,'String',SF{instanceID}.FitPars.zmols);
    set(handles.minframes,'String',SF{instanceID}.FitPars.minframes);
    set(handles.maxframes,'String',SF{instanceID}.FitPars.maxframes);
    set(handles.xygridxy,'String',SF{instanceID}.FitPars.xygridxy);
    set(handles.xygridz,'String',SF{instanceID}.FitPars.xygridz);
    set(handles.movAxy,'String',SF{instanceID}.FitPars.movAxy);
    set(handles.movAz,'String',SF{instanceID}.FitPars.movAz);

    % Zcal
    if strcmp(SF{instanceID}.FitPars.Fit3D,'2')
       set(handles.Fit3D,'Value',1);
    else 
        set(handles.Fit3D,'Value',0);
    end
    set(handles.zcaltxt,'String',SF{instanceID}.FitPars.zcaltxt);
    set(handles.zop,'String',SF{instanceID}.FitPars.zop);
    set(handles.zstart,'String',SF{instanceID}.FitPars.zstart);
    set(handles.zend,'String',SF{instanceID}.FitPars.zend);
    set(handles.zstep,'String',SF{instanceID}.FitPars.zstep);
end

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
function SavePars_Callback(hObject, eventdata, handles) %#ok<*DEFNU,*INUSL>
% hObject    handle to SavePars (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global SF

instanceID = handles.instanceID; 

% General
SF{instanceID}.FitPars.minheight = get(handles.minheight,'String');
SF{instanceID}.FitPars.maxheight = get(handles.maxheight,'String');
SF{instanceID}.FitPars.bkd = get(handles.bkd,'String');
SF{instanceID}.FitPars.minwidth = get(handles.minwidth,'String');
SF{instanceID}.FitPars.maxwidth = get(handles.maxwidth,'String');
SF{instanceID}.FitPars.initwidth = get(handles.initwidth,'String');
SF{instanceID}.FitPars.maxaxratio = get(handles.maxaxratio,'String');
SF{instanceID}.FitPars.fitROI = get(handles.fitROI,'String');
SF{instanceID}.FitPars.displacement =  get(handles.displacement,'String');
SF{instanceID}.FitPars.startFrame = get(handles.startFrame,'String'); 

% Drift
SF{instanceID}.FitPars.CorDrift =  num2str(get(handles.CorDrift,'Value'));
SF{instanceID}.FitPars.xymols = get(handles.xymols,'String');
SF{instanceID}.FitPars.zmols = get(handles.zmols,'String');
SF{instanceID}.FitPars.minframes = get(handles.minframes,'String');
SF{instanceID}.FitPars.maxframes = get(handles.maxframes,'String');
SF{instanceID}.FitPars.xygridxy = get(handles.xygridxy,'String');
SF{instanceID}.FitPars.xygridz = get(handles.xygridz,'String');
SF{instanceID}.FitPars.movAxy = get(handles.movAxy,'String');
SF{instanceID}.FitPars.movAz = get(handles.movAz,'String');

% Zcal
fit3d = get(handles.Fit3D,'Value');
if fit3d == 1   
    SF{instanceID}.FitPars.Fit3D = '2';
else 
    SF{instanceID}.FitPars.Fit3D = '0';
end
SF{instanceID}.FitPars.zcaltxt = get(handles.zcaltxt,'String');
SF{instanceID}.FitPars.zop  = get(handles.zop,'String');
SF{instanceID}.FitPars.zstart = get(handles.zstart,'String');
SF{instanceID}.FitPars.zend = get(handles.zend,'String');
SF{instanceID}.FitPars.zstep = get(handles.zstep,'String');
SF{instanceID}.FitPars.OK = true;

pause(.1); 
close(GUIFitParameters);

% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SF
instanceID = handles.instanceID; 
SF{instanceID}.FitPars.OK = false;
close(GUIFitParameters);



% --- Executes on button press in CorDrift.
function CorDrift_Callback(hObject, eventdata, handles) %#ok<*INUSD>
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


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
