function varargout = GUIDaoParameters(varargin)
% GUIDAOPARAMETERS MATLAB code for GUIDaoParameters.fig
%      GUIDAOPARAMETERS, by itself, creates a new GUIDAOPARAMETERS or raises the existing
%      singleton*.
%
%      H = GUIDAOPARAMETERS returns the handle to a new GUIDAOPARAMETERS or the handle to
%      the existing singleton*.
%
%      GUIDAOPARAMETERS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIDAOPARAMETERS.M with the given input arguments.
%
%      GUIDAOPARAMETERS('Property','Value',...) creates a new GUIDAOPARAMETERS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUIDaoParameters_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUIDaoParameters_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUIDaoParameters

% Last Modified by GUIDE v2.5 03-Apr-2013 10:53:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUIDaoParameters_OpeningFcn, ...
                   'gui_OutputFcn',  @GUIDaoParameters_OutputFcn, ...
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


% --- Executes just before GUIDaoParameters is made visible.
function GUIDaoParameters_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUIDaoParameters (see VARARGIN)
% "Opening Func" actually called at opening AND closing!
global SF 

% when called at closing there is no varargin input...  
if ~isempty(varargin)
    instanceID = varargin{1}; 
    handles.instanceID = instanceID;
else
    instanceID = handles.instanceID;
end

% Set up default values based on input default pars file
   % General
   if strcmp(SF{instanceID}.FitPars.method,'2dfixed')
       Fmethod = 1;
   elseif strcmp(SF{instanceID}.FitPars.method,'2d')
       Fmethod = 2;
   elseif strcmp(SF{instanceID}.FitPars.method,'3d')
       Fmethod = 3;
   elseif strcmp(SF{instanceID}.FitPars.method,'Z')
       Fmethod = 4;
   end
       
    set(handles.method,'Value',Fmethod);
    set(handles.threshold,'String',SF{instanceID}.FitPars.threshold);
    set(handles.maxits,'String',SF{instanceID}.FitPars.maxits);
    set(handles.bkd,'String',SF{instanceID}.FitPars.bkd );
    set(handles.ppnm,'String',SF{instanceID}.FitPars.ppnm );
    set(handles.initwidth,'String',SF{instanceID}.FitPars.initwidth );
    set(handles.descriptor,'String',SF{instanceID}.FitPars.descriptor);
     set(handles.displacement,'String',SF{instanceID}.FitPars.displacement);
     set(handles.startFrame,'String',SF{instanceID}.FitPars.startFrame);
     set(handles.endFrame,'String',SF{instanceID}.FitPars.endFrame); 

    % Drift
    set(handles.CorDrift,'Value',logical(str2double(SF{instanceID}.FitPars.CorDrift)));
    set(handles.dframes,'String',SF{instanceID}.FitPars.dframes);
    set(handles.dscale,'String',SF{instanceID}.FitPars.dscale );

    % Zcal
   set(handles.Fit3D,'Value',logical(str2double(SF{instanceID}.FitPars.Fit3D)));
    set(handles.zcutoff,'String',SF{instanceID}.FitPars.zcutoff);
    set(handles.zstart,'String',SF{instanceID}.FitPars.zstart);
    set(handles.zend,'String',SF{instanceID}.FitPars.zend );
    set(handles.wx0,'String',SF{instanceID}.FitPars.wx0 );
    set(handles.gx,'String',SF{instanceID}.FitPars.gx );
     set(handles.zrx,'String',SF{instanceID}.FitPars.zrx);
    set(handles.Ax,'String',SF{instanceID}.FitPars.Ax );
    set(handles.Bx,'String',SF{instanceID}.FitPars.Bx  );
    set(handles.Cx,'String',SF{instanceID}.FitPars.Cx );
    set(handles.Dx,'String',SF{instanceID}.FitPars.Dx );
    set(handles.wy0,'String',SF{instanceID}.FitPars.wy0 );
     set(handles.gy,'String',SF{instanceID}.FitPars.gy);
    set(handles.zry,'String',SF{instanceID}.FitPars.zry );
     set(handles.Ay,'String',SF{instanceID}.FitPars.Ay);
    set(handles.By,'String',SF{instanceID}.FitPars.By );
    set(handles.Cy,'String',SF{instanceID}.FitPars.Cy );
    set(handles.Dy,'String',SF{instanceID}.FitPars.Dy );
    

% Choose default command line output for GUIDaoParameters
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUIDaoParameters wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUIDaoParameters_OutputFcn(hObject, eventdata, handles)  %#ok<*INUSL>
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

global SF 
instanceID = handles.instanceID;
% General
Fmethod =  get(handles.method,'Value');
   if  Fmethod == 1
      SF{instanceID}.FitPars.method='2dfixed';
   elseif Fmethod == 2 
       SF{instanceID}.FitPars.method = '2d';
   elseif Fmethod == 3
      SF{instanceID}.FitPars.method = '3d';
   elseif Fmethod == 4
      SF{instanceID}.FitPars.method = 'Z' ;
   end
SF{instanceID}.FitPars.threshold = get(handles.threshold,'String');
SF{instanceID}.FitPars.maxits = get(handles.maxits,'String');
SF{instanceID}.FitPars.bkd = get(handles.bkd,'String');
SF{instanceID}.FitPars.ppnm = get(handles.ppnm,'String');
SF{instanceID}.FitPars.initwidth = get(handles.initwidth,'String');
SF{instanceID}.FitPars.descriptor = get(handles.descriptor,'String');
SF{instanceID}.FitPars.displacement =  get(handles.displacement,'String');
SF{instanceID}.FitPars.startFrame = get(handles.startFrame,'String');
SF{instanceID}.FitPars.endFrame = get(handles.endFrame,'String'); 

% Drift
SF{instanceID}.FitPars.CorDrift =  num2str(get(handles.CorDrift,'Value'));
SF{instanceID}.FitPars.dframes = get(handles.dframes,'String');
SF{instanceID}.FitPars.dscale = get(handles.dscale,'String');

% Zcal
SF{instanceID}.FitPars.Fit3D = num2str(get(handles.Fit3D,'Value'));
SF{instanceID}.FitPars.zcutoff = get(handles.zcutoff,'String');
SF{instanceID}.FitPars.zstart = get(handles.zstart,'String');
SF{instanceID}.FitPars.zend = get(handles.zend,'String');
SF{instanceID}.FitPars.wx0  = get(handles.wx0,'String');
SF{instanceID}.FitPars.gx  = get(handles.gx,'String');
SF{instanceID}.FitPars.zrx  = get(handles.zrx,'String');
SF{instanceID}.FitPars.Ax  = get(handles.Ax,'String');
SF{instanceID}.FitPars.Bx  = get(handles.Bx,'String');
SF{instanceID}.FitPars.Cx  = get(handles.Cx,'String');
SF{instanceID}.FitPars.Dx  = get(handles.Dx,'String');
SF{instanceID}.FitPars.wy0  = get(handles.wy0,'String');
SF{instanceID}.FitPars.gy  = get(handles.gy,'String');
SF{instanceID}.FitPars.zry  = get(handles.zry,'String');
SF{instanceID}.FitPars.Ay  = get(handles.Ay,'String');
SF{instanceID}.FitPars.By  = get(handles.By,'String');
SF{instanceID}.FitPars.Cy  = get(handles.Cy,'String');
SF{instanceID}.FitPars.Dy  = get(handles.Dy,'String');

SF{instanceID}.FitPars.OK = true;
pause(.1); 
close(GUIDaoParameters);







% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles) %#ok<*DEFNU,*INUSD>
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SF
instanceID = handles.instanceID; 
SF{instanceID}.FitPars.OK = false;
pause(.1); 
close(GUIDaoParameters);








% --- Executes on button press in CorDrift.
function CorDrift_Callback(hObject, eventdata, handles)
% hObject    handle to CorDrift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CorDrift



function threshold_Callback(hObject, eventdata, handles)
% hObject    handle to threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of threshold as text
%        str2double(get(hObject,'String')) returns contents of threshold as a double


% --- Executes during object creation, after setting all properties.
function threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxits_Callback(hObject, eventdata, handles)
% hObject    handle to maxits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxits as text
%        str2double(get(hObject,'String')) returns contents of maxits as a double


% --- Executes during object creation, after setting all properties.
function maxits_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxits (see GCBO)
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



function ppnm_Callback(hObject, eventdata, handles)
% hObject    handle to ppnm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ppnm as text
%        str2double(get(hObject,'String')) returns contents of ppnm as a double


% --- Executes during object creation, after setting all properties.
function ppnm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ppnm (see GCBO)
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



function descriptor_Callback(hObject, eventdata, handles)
% hObject    handle to descriptor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of descriptor as text
%        str2double(get(hObject,'String')) returns contents of descriptor as a double


% --- Executes during object creation, after setting all properties.
function descriptor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to descriptor (see GCBO)
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



function zcutoff_Callback(hObject, eventdata, handles)
% hObject    handle to zcutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zcutoff as text
%        str2double(get(hObject,'String')) returns contents of zcutoff as a double


% --- Executes during object creation, after setting all properties.
function zcutoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zcutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function wx0_Callback(hObject, eventdata, handles)
% hObject    handle to wx0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of wx0 as text
%        str2double(get(hObject,'String')) returns contents of wx0 as a double


% --- Executes during object creation, after setting all properties.
function wx0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wx0 (see GCBO)
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



function dframes_Callback(hObject, eventdata, handles)
% hObject    handle to dframes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dframes as text
%        str2double(get(hObject,'String')) returns contents of dframes as a double


% --- Executes during object creation, after setting all properties.
function dframes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dframes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dscale_Callback(hObject, eventdata, handles)
% hObject    handle to dscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dscale as text
%        str2double(get(hObject,'String')) returns contents of dscale as a double


% --- Executes during object creation, after setting all properties.
function dscale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dscale (see GCBO)
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


% --- Executes on selection change in method.
function method_Callback(hObject, eventdata, handles)
% hObject    handle to method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns method contents as cell array
%        contents{get(hObject,'Value')} returns selected item from method


% --- Executes during object creation, after setting all properties.
function method_CreateFcn(hObject, eventdata, handles)
% hObject    handle to method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gx_Callback(hObject, eventdata, handles)
% hObject    handle to gx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gx as text
%        str2double(get(hObject,'String')) returns contents of gx as a double


% --- Executes during object creation, after setting all properties.
function gx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zrx_Callback(hObject, eventdata, handles)
% hObject    handle to zrx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zrx as text
%        str2double(get(hObject,'String')) returns contents of zrx as a double


% --- Executes during object creation, after setting all properties.
function zrx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zrx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Ax_Callback(hObject, eventdata, handles)
% hObject    handle to Ax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Ax as text
%        str2double(get(hObject,'String')) returns contents of Ax as a double


% --- Executes during object creation, after setting all properties.
function Ax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Bx_Callback(hObject, eventdata, handles)
% hObject    handle to Bx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Bx as text
%        str2double(get(hObject,'String')) returns contents of Bx as a double


% --- Executes during object creation, after setting all properties.
function Bx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Bx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Cx_Callback(hObject, eventdata, handles)
% hObject    handle to Cx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Cx as text
%        str2double(get(hObject,'String')) returns contents of Cx as a double


% --- Executes during object creation, after setting all properties.
function Cx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Dx_Callback(hObject, eventdata, handles)
% hObject    handle to Dx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Dx as text
%        str2double(get(hObject,'String')) returns contents of Dx as a double


% --- Executes during object creation, after setting all properties.
function Dx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Dx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function wy0_Callback(hObject, eventdata, handles)
% hObject    handle to wy0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of wy0 as text
%        str2double(get(hObject,'String')) returns contents of wy0 as a double


% --- Executes during object creation, after setting all properties.
function wy0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wy0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gy_Callback(hObject, eventdata, handles)
% hObject    handle to gy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gy as text
%        str2double(get(hObject,'String')) returns contents of gy as a double


% --- Executes during object creation, after setting all properties.
function gy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zry_Callback(hObject, eventdata, handles)
% hObject    handle to zry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zry as text
%        str2double(get(hObject,'String')) returns contents of zry as a double


% --- Executes during object creation, after setting all properties.
function zry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Ay_Callback(hObject, eventdata, handles)
% hObject    handle to Ay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Ay as text
%        str2double(get(hObject,'String')) returns contents of Ay as a double


% --- Executes during object creation, after setting all properties.
function Ay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function By_Callback(hObject, eventdata, handles)
% hObject    handle to By (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of By as text
%        str2double(get(hObject,'String')) returns contents of By as a double


% --- Executes during object creation, after setting all properties.
function By_CreateFcn(hObject, eventdata, handles)
% hObject    handle to By (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Cy_Callback(hObject, eventdata, handles)
% hObject    handle to Cy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Cy as text
%        str2double(get(hObject,'String')) returns contents of Cy as a double


% --- Executes during object creation, after setting all properties.
function Cy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Dy_Callback(hObject, eventdata, handles)
% hObject    handle to Dy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Dy as text
%        str2double(get(hObject,'String')) returns contents of Dy as a double


% --- Executes during object creation, after setting all properties.
function Dy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Dy (see GCBO)
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
