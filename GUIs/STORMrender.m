function varargout = STORMrender(varargin)
% STORMRENDER MATLAB code for STORMrender.fig
%      STORMRENDER, by itself, creates a new STORMRENDER or raises the existing
%      singleton*.
%
%      H = STORMRENDER returns the handle to a new STORMRENDER or the handle to
%      the existing singleton*.
%
%      STORMRENDER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STORMRENDER.M with the given input arguments.
%
%      STORMRENDER('Property','Value',...) creates a new STORMRENDER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before STORMrender_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to STORMrender_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help STORMrender

% Last Modified by GUIDE v2.5 28-Dec-2013 15:46:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @STORMrender_OpeningFcn, ...
                   'gui_OutputFcn',  @STORMrender_OutputFcn, ...
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


% --- Executes just before STORMrender is made visible.
function STORMrender_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to STORMrender (see VARARGIN)


% Choose default command line output for STORMrender
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Get default parameters for STORMrender
handles = SRstartup(hObject,eventdata,handles);
guidata(hObject, handles);

% UIWAIT makes STORMrender wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = STORMrender_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




%========================================================================%
%%                               Load Data
%========================================================================%

% --------------------------------------------------------------------
function MenuOpenBin_Callback(hObject, eventdata, handles)
% hObject    handle to MenuOpenBin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
multiselect = 'off';
handles = LoadBin(hObject,eventdata,handles,multiselect);
guidata(hObject, handles);

% --------------------------------------------------------------------
function MenuOpenMulti_Callback(hObject, eventdata, handles)
% hObject    handle to MenuOpenMulti (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
multiselect = 'on';
% Multiload assumes you wish to clear all current data;
handles = LoadBin(hObject,eventdata,handles,multiselect);
guidata(hObject, handles);

% --------------------------------------------------------------------
function MenuAutoMultiLoad_Callback(hObject, eventdata, handles)
% Automatically group bin files and load the one indicated by the Load
% options (default = # 1).  
% 
% hObject    handle to MenuAutoMultiLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = ClearCurrentData(hObject,eventdata,handles);
handles = AutoMultiLoad(handles); 
guidata(hObject, handles);
 
% --------------------------------------------------------------------
function MenuLoadOptions_Callback(hObject, eventdata, handles)
% hObject    handle to MenuLoadOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SR;
SRLoadOptions(handles);
set(handles.datapath,'String',SR{handles.gui_number}.LoadOps.pathin);
guidata(hObject, handles);

% --------------------------------------------------------------------
function ToolbarOpenFile_ClickedCallback(hObject, eventdata, handles)
LoadBin(hObject,eventdata,handles,'off')

%=========================================================================%  
%       end of load data functions
%=========================================================================%






%=========================================================================%
%% Toolbar Functions
%=========================================================================%

function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to SaveData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function SaveData_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to SaveData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    RunSaveData(hObject, eventdata, handles);



% --------------------------------------------------------------------
function SaveImage_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to SaveImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RunSaveImage(handles);


%  I don't think this function is live anymore
% % --------------------------------------------------------------------
% function saveimage_ClickedCallback(hObject, eventdata, handles)
% % hObject    handle to saveimage (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% global SR
% Io = SR{handles.gui_number}.Io;
% [filename,pathname] = uiputfile;
% tiffwrite(Io,[pathname,filesep,filename]);

% --------------------------------------------------------------------
function datapath_Callback(hObject, eventdata, handles)
global SR
SR{handles.gui_number}.LoadOps.pathin = get(handles.datapath,'String');
guidata(hObject,handles); 

%=========================================================================%





%=========================================================================%
%%                   Data Filters
%=========================================================================%
% --- Executes on selection change in choosefilt.
function choosefilt_Callback(hObject, eventdata, handles)
    handles = SelectFilter(hObject,handles); 
    guidata(hObject,handles); 
    

% --- Executes on button press in ClearFilters.
function ClearFilters_Callback(hObject, eventdata, handles)
    handles = RunClearFilters(hObject,eventdata,handles);
    guidata(hObject,handles); 
    

% --- Executes on button press in ApplyFilter.
function ApplyFilter_Callback(hObject, eventdata, handles)
% chose filter
handles = RunApplyFilter(hObject,eventdata,handles); 
guidata(hObject,handles); 


% --- Executes on button press in ShowFilters.
function ShowFilters_Callback(hObject, eventdata, handles)
% hObject    handle to ShowFilters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('this function still under development'); 


% --------------------------------------------------------------------
function ManualContrastTool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to ManualContrastTool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RunManualContrast(hObject, eventdata, handles)

 
% --------------------------------------------------------------------
function AutoContrastTool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to AutoContrastTool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RunAutoContrast(hObject, eventdata, handles);

% --- Executes on selection change in LevelsChannel.
function LevelsChannel_Callback(hObject, eventdata, handles)
% hObject    handle to LevelsChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = RunLevelsChannel(hObject,eventdata,handles); 
guidata(hObject,handles); 
 
% --- Executes on update of MinIntBox  
function MinIntBox_Callback(hObject, eventdata, handles) %#ok<*INUSL>
 minin = str2double(get(handles.MinIntBox,'String'));
 set(handles.MinIntSlider,'Value',minin);
 ScaleColor(hObject,handles);
 guidata(hObject, handles); 

 % --- Executes on update of MaxIntBox
function MaxIntBox_Callback(hObject, eventdata, handles)      
 maxin = str2double(get(handles.MaxIntBox,'String'));
 set(handles.MaxIntSlider,'Value',maxin);
  ScaleColor(hObject,handles);
  guidata(hObject, handles); 
 
% --- Executes on slider movement.
function MaxIntSlider_Callback(hObject, eventdata, handles)
 ScaleColor(hObject,handles);
 guidata(hObject, handles);   
 
% --- Executes on slider movement.
function MinIntSlider_Callback(hObject, eventdata, handles)
ScaleColor(hObject,handles);
guidata(hObject, handles);

% --- Executes on button press in logScaleColor.
function logScaleColor_Callback(hObject, eventdata, handles)
ScaleColor(hObject,handles);
guidata(hObject, handles);


%========================================================================%
%% GUI buttons for manipulating zooming, scrolling, recentering etc
%========================================================================%
function zoomin_Callback(hObject, eventdata, handles)
% hObject    handle to zoomin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ButtonZoomIn(hObject, eventdata, handles)

% --- Executes on button press in zoomout.
function zoomout_Callback(hObject, eventdata, handles)
% hObject    handle to zoomout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ButtonZoomOut(hObject, eventdata, handles)


function displayzm_Callback(hObject, eventdata, handles)
% Execute on direct user input specific zoom value
SetDisplayZoom(hObject, eventdata, handles);


% --------------------------------------------------------------------
function zoomtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to zoomtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = RunZoomTool(hObject,eventdata,handles);
guidata(hObject, handles);



% --------------------------------------------------------------------
function recenter_ClickedCallback(hObject, eventdata, handles)
% Recenter image over clicked location
% hObject    handle to recenter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RunRecenter(hObject, eventdata, handles);

% --- Executes on slider movement.
function Yslider_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
RunYslider(hObject,eventdata,handles); 

% --- Executes during object creation, after setting all properties.
function Yslider_CreateFcn(hObject, eventdata, handles)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function Xslider_Callback(hObject, eventdata, handles)
RunXsilder(hObject,eventdata,handles); 


% --- Executes during object creation, after setting all properties.
function Xslider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end





%% 3D Plotting Options
% --------------------------------------------------------------------
function Render3D_ClickedCallback(hObject, eventdata, handles)
    RunRender3D(hObject,eventdata,handles);
 
% --------------------------------------------------------------------
function Rotate3Dslices_ClickedCallback(hObject, eventdata, handles)
    RunRotate3Dslices(hObject,eventdata,handles);    

% --------------------------------------------------------------------
function plot3Ddots_ClickedCallback(hObject, eventdata, handles)
    RunPlot3Ddots(hObject,eventdata,handles); 
    
% --------------------------------------------------------------------
function plotColorByFrame_ClickedCallback(hObject, eventdata, handles)
    RunPlotColorByFrame(hObject,eventdata,handles);
    
% --------------------------------------------------------------------
function plot2Ddots_ClickedCallback(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>
    RunPlot2Ddots(handles)
    

    % --- Executes during object creation, after setting all properties.
function LevelsChannel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LevelsChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
    
function datapath_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function CustomFilter_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function choosefilt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function MaxIntBox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function MinIntBox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function MaxIntSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function MinIntSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



%==========================================================================
%% Options Menu 
%==========================================================================
% *Overlays*
% *Additional Display Options*
% *Image Context*
% 
% --------------------------------------------------------------------
function OptionsMenu_Callback(hObject, eventdata, handles)
% hObject    handle to OptionsMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MenuOverlay_Callback(hObject, eventdata, handles)
% hObject    handle to MenuOverlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
LoadOverlay(hObject,eventdata,handles);

  
% --------------------------------------------------------------------
function MenuDisplayOps_Callback(hObject, eventdata, handles)
% hObject    handle to MenuSR{handles.gui_number}.DisplayOps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RunMenuDisplayOps(hObject, eventdata, handles);


% --------------------------------------------------------------------
function MenuViewMosaic_Callback(hObject, eventdata, handles)
% hObject    handle to MenuViewMosaic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RunMenuViewMosaic(hObject, eventdata, handles);


% --------------------------------------------------------------------
function AnalysisMenu_Callback(hObject, eventdata, handles)
% hObject    handle to AnalysisMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MenuFeducialDrift_Callback(hObject, eventdata, handles)
% hObject    handle to MenuFeducialDrift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RunMenuFeudicalDrift(hObject, eventdata, handles);



% --------------------------------------------------------------------
function MenuCorrelDrift_Callback(hObject, eventdata, handles)
% hObject    handle to MenuCorrelDrift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RunMenuCorrelDrift(hObject, eventdata, handles)


function oLayer1_Callback(hObject, eventdata, handles)
ImLoad(hObject,eventdata, handles);
    
function oLayer2_Callback(hObject, eventdata, handles)
ImLoad(hObject,eventdata, handles);
    
function oLayer3_Callback(hObject, eventdata, handles)
ImLoad(hObject,eventdata, handles);
    
function oLayer4_Callback(hObject, eventdata, handles)
ImLoad(hObject,eventdata, handles);
    
function oLayer5_Callback(hObject, eventdata, handles)
ImLoad(hObject,eventdata, handles);
    
function oLayer6_Callback(hObject, eventdata, handles)
ImLoad(hObject,eventdata, handles);
    
function sLayer1_Callback(hObject, eventdata, handles)
ImLoad(hObject,eventdata, handles);
    
function sLayer2_Callback(hObject, eventdata, handles)
ImLoad(hObject,eventdata, handles);
    
function sLayer3_Callback(hObject, eventdata, handles)
ImLoad(hObject,eventdata, handles);

function sLayer4_Callback(hObject, eventdata, handles)
ImLoad(hObject,eventdata, handles);

function sLayer5_Callback(hObject, eventdata, handles)
ImLoad(hObject,eventdata, handles);

function sLayer6_Callback(hObject, eventdata, handles)
ImLoad(hObject,eventdata, handles);


%========================================================================
% I think these funtions are obsolete: 
%========================================================================

%------- Is This sitll a button?  
function CustomFilter_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function chn4_CreateFcn(hObject, eventdata, handles)

% --- Executes on button press in fchn1.
function fchn1_Callback(hObject, eventdata, handles)

% --- Executes on button press in fchn2.
function fchn2_Callback(hObject, eventdata, handles)

% --- Executes on button press in fchn3.
function fchn3_Callback(hObject, eventdata, handles)

% --- Executes on button press in fchn4.
function fchn4_Callback(hObject, eventdata, handles)

%========================================================================