function varargout = TiffViewer(varargin)
% TIFFVIEWER MATLAB code for TiffViewer.fig
%      TIFFVIEWER, by itself, creates a new TIFFVIEWER or raises the existing
%      singleton*.
%
%      H = TIFFVIEWER returns the handle to a new TIFFVIEWER or the handle to
%      the existing singleton*.
%
%      TIFFVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TIFFVIEWER.M with the given input arguments.
%
%      TIFFVIEWER('Property','Value',...) creates a new TIFFVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TiffViewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TiffViewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TiffViewer

% Last Modified by GUIDE v2.5 12-Dec-2012 12:25:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TiffViewer_OpeningFcn, ...
                   'gui_OutputFcn',  @TiffViewer_OutputFcn, ...
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


% --- Executes just before TiffViewer is made visible.
function TiffViewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TiffViewer (see VARARGIN)

% Choose default command line output for TiffViewer
handles.output = hObject;

global C
% default colormap
C = [1,0,0;
    0,1,0;
    0,0,1;
    1,0,1];

addpath('C:\Users\Alistair\Documents\Projects\General_STORM\Matlab_Tools');

% set up sliders
set(handles.gammaslider,'Min',0);
set(handles.gammaslider,'Max',4); 
set(handles.gammaslider,'Value',1);

try 
     newimage_Callback(hObject, eventdata, handles);
catch
    disp('please load an image');
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TiffViewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TiffViewer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




% --------------------------------------------------------------------
function saveimage_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to saveimage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global I 

[savename,savepath] = uiputfile({'*.png';'*.tif'},'Save Image As');

figure(1); 
xs = round(get(gca,'XLim'));
ys = round(get(gca,'YLim'));

if savename ~= 0 % save was not 'canceled'
    imwrite(I(xs(1):xs(2),ys(1):ys(2),:),[savepath,filesep,savename]); 
    disp(['wrote ', savepath,filesep,savename]);
end


% --------------------------------------------------------------------
function savegrays_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to savegrays (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global I1 I
figure(1);
xs = round(get(gca,'XLim'));
ys = round(get(gca,'YLim'));
s = 1;

channels(1) = get(handles.chn1,'Value');
channels(2) = get(handles.chn2,'Value');
channels(3) = get(handles.chn3,'Value');
channels(4) = get(handles.chn4,'Value');
channels = find(channels); 


 [fname,output_folder] = uiputfile('.png'); 
 fname = regexprep(fname,'.png',''); 
 imwrite((I(ys(1):ys(2),xs(1):xs(2),:)),[output_folder,filesep,fname,'.png']);
 for c = channels
     Itemp = I1;
%      [h,w,cs] = size(Itemp);
%      all_other_channels = 1:cs; 
%       all_other_channels(c) = [];
%      Itemp(:,:,all_other_channels) = uint16(0); 
 imwrite((Itemp(ys(1):ys(2),xs(1):xs(2),c)),[output_folder,filesep,fname,'_c',num2str(c),'.png']);
 end



% --- Executes on button press in newimage.
function newimage_Callback(hObject, eventdata, handles)
% hObject    handle to newimage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global myImage I1 I C H W Cs
I1 = myImage;
I = Ncolor(myImage,C);
figure(1); clf; imagesc(I); 

[H,W,Cs] = size(I); 

set(handles.chn1,'Value',true);
if length(Cs>1)
set(handles.chn2,'Value',true);
end
if length(Cs>2)
set(handles.chn3,'Value',true);
end
if length(Cs>3)
set(handles.chn4,'Value',true);
end

set(handles.minslider,'Value',0);
set(handles.maxslider,'Value',1);

%--------- updates image when colors are changed
function updateimage
global I1 C
figure(1);
xs = get(gca,'XLim');
ys = get(gca,'YLim');
I = Ncolor(I1,C);
figure(1); clf; imagesc(I); 

xlim(xs);
ylim(ys);

function sliders(hObject, eventdata, handles)
global I1 myImage
minC = get(handles.minslider,'Value');
maxC = get(handles.maxslider,'Value');
gamma = get(handles.gammaslider,'Value');
channels(1) = get(handles.editchn1,'Value');
channels(2) = get(handles.editchn2,'Value');
channels(3) = get(handles.editchn3,'Value');
channels(4) = get(handles.editchn4,'Value');
c = find(channels); 
I1(:,:,c) = imadjust(myImage(:,:,c),[minC,maxC],[0,1],gamma);
updateimage;

% --- Executes on slider movement.
function maxslider_Callback(hObject, eventdata, handles)
% hObject    handle to maxslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliders(hObject, eventdata, handles)

% --- Executes on slider movement.
function minslider_Callback(hObject, eventdata, handles)
% hObject    handle to minslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliders(hObject, eventdata, handles)

% --- Executes on slider movement.
function gammaslider_Callback(hObject, eventdata, handles)
% hObject    handle to gammaslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sliders(hObject, eventdata, handles)

% --------------------------------------------------------------------
function showchannels_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to showchannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in updatecolor.
function updatecolor_Callback(hObject, eventdata, handles)
global C

C(1,1) = str2double(get(handles.c1r,'String')); 
C(1,2) = str2double(get(handles.c1g,'String')); 
C(1,3) = str2double(get(handles.c1b,'String')); 

C(2,1) = str2double(get(handles.c2r,'String')); 
C(2,2) = str2double(get(handles.c2g,'String')); 
C(2,3) = str2double(get(handles.c2b,'String'));  

C(3,1) = str2double(get(handles.c3r,'String')); 
C(3,2) = str2double(get(handles.c3g,'String')); 
C(3,3) = str2double(get(handles.c3b,'String')); 

C(4,1) = str2double(get(handles.c4r,'String')); 
C(4,2) = str2double(get(handles.c4g,'String')); 
C(4,3) = str2double(get(handles.c4b,'String'));  

%--------- if channel is off, set to zero
% find which channels are toggled
channels(1) = get(handles.chn1,'Value');
channels(2) = get(handles.chn2,'Value');
channels(3) = get(handles.chn3,'Value');
channels(4) = get(handles.chn4,'Value');
% if not toggled, set to zero; 
C(logical(1-channels),:) = zeros(sum(1-channels),3);
updateimage







% --- Executes on button press in chn1.
function chn1_Callback(hObject, eventdata, handles)
updatecolor_Callback(hObject, eventdata, handles)


% --- Executes on button press in chn2.
function chn2_Callback(hObject, eventdata, handles)
updatecolor_Callback(hObject, eventdata, handles)


% --- Executes on button press in chn3.
function chn3_Callback(hObject, eventdata, handles)
updatecolor_Callback(hObject, eventdata, handles)

% --- Executes on button press in chn4.
function chn4_Callback(hObject, eventdata, handles)
updatecolor_Callback(hObject, eventdata, handles)





% ================= Just for building the GUI: 

function c1r_Callback(hObject, eventdata, handles)

function c1r_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function c1g_Callback(hObject, eventdata, handles)

function c1g_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function c1b_Callback(hObject, eventdata, handles)

function c1b_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function c3r_Callback(hObject, eventdata, handles)

function c3r_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function c3g_Callback(hObject, eventdata, handles)

function c3g_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function c3b_Callback(hObject, eventdata, handles)

function c3b_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function c2r_Callback(hObject, eventdata, handles)

function c2r_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function c2g_Callback(hObject, eventdata, handles)

function c2g_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function c2b_Callback(hObject, eventdata, handles)

function c2b_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function c4r_Callback(hObject, eventdata, handles)

function c4r_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function c4g_Callback(hObject, eventdata, handles)

function c4g_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function c4b_Callback(hObject, eventdata, handles)

function c4b_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function minslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
% --- Executes during object creation, after setting all properties.
function maxslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end







% --- Executes during object creation, after setting all properties.
function gammaslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gammaslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
%        slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

