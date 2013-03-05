function varargout = ImageShop(varargin)
% IMAGESHOP MATLAB code for ImageShop.fig
%      IMAGESHOP, by itself, creates a new IMAGESHOP or raises the existing
%      singleton*.
%
%      H = IMAGESHOP returns the handle to a new IMAGESHOP or the handle to
%      the existing singleton*.
%
%      IMAGESHOP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGESHOP.M with the given input arguments.
%
%      IMAGESHOP('Property','Value',...) creates a new IMAGESHOP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ImageShop_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ImageShop_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ImageShop

% Last Modified by GUIDE v2.5 04-Mar-2013 23:21:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ImageShop_OpeningFcn, ...
                   'gui_OutputFcn',  @ImageShop_OutputFcn, ...
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


% --- Executes just before ImageShop is made visible.
function ImageShop_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ImageShop (see VARARGIN)

global ImShop;
handles.gui_number = length(ImShop) + 1; 

 axes(handles.axes1); 
 set(gca,'color','k');
 set(gca,'XTick',[],'YTick',[]);
 axes(handles.axes2); 
 set(gca,'color','k');
set(gca,'XTick',[],'YTick',[]);
 axes(handles.axes3); 
 set(gca,'color','w');
set(gca,'XTick',[],'YTick',[]);

% Choose default command line output for ImageShop
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ImageShop wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ImageShop_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



%% Image Navigation Functions
% --- Executes on slider movement.
function Xslider_Callback(hObject, eventdata, handles)
% hObject    handle to Xslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% --- Executes on slider movement.
function Yslider_Callback(hObject, eventdata, handles)
% hObject    handle to Yslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes on button press in image1.
function image1_Callback(hObject, eventdata, handles)
% hObject    handle to image1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of image1





%% Adjust Levels Functions
% ------
 function scalecolor(hObject,handles)
 global ImShop ScratchPath
% x scale for histogram (log or normal)
logscalecolor = logical(get(handles.logscalecolor,'Value'));
selected_channel = get(handles.LevelsChannel,'Value');

% Read in current slider postions, set numeric displays accordingly
maxin = get(handles.MaxIntSlider,'Value');
minin = get(handles.MinIntSlider,'Value'); 
set(handles.MaxIntBox,'String',num2str(maxin));
set(handles.MinIntBox,'String',num2str(minin));
   

% save([ScratchPath,'test.mat']);
% load([ScratchPath,'test.mat']);

    raw_ints  = double(ImShop{handles.gui_number}.I(:,:,selected_channel)); 
    ImShop{handles.gui_number}.cmax(selected_channel) = maxin;
    ImShop{handles.gui_number}.cmin(selected_channel) = minin;
 
 % Display histogram;            
    raw_ints = raw_ints(:);
    max_int = max(raw_ints);

   axes(handles.axes3); cla reset; 
    set(gca,'XTick',[],'YTick',[]); 
   if ~logscalecolor
       xs = linspace(0,max_int,1000); 
        hi1 = hist(nonzeros(raw_ints)./max_int,xs);
        hist(nonzeros(raw_ints),xs); hold on;
        inrange = nonzeros(raw_ints( raw_ints/max_int>minin & raw_ints/max_int<maxin))./max_int;
        hist(inrange,xs);
        h2 = findobj('type','patch'); 
        xlim([min(xs),max(xs)]);
   else  % For Log-scale histogram  
       xs = linspace(-5,0,50);
       lognorm =  log10(nonzeros(raw_ints)/max_int);
       hi1 = hist(lognorm,xs);
       hist(lognorm,xs); hold on;
       xlim([min(xs),max(xs)]);
       log_min = (minin-1)*5; % map relative [0,1] to logpowers [-5 0];
       log_max = (maxin-1)*5; % map relative [0,1] to logpowers [-5 0];
       inrange = lognorm(lognorm>log_min & lognorm<log_max);
       hist(inrange,xs);
       xlim([min(xs),max(xs)]);
       clear h2;
       h2 = findobj('type','patch'); 
   end
    ylim([0,1.2*max(hi1)]);
   set(h2(2),'FaceColor','b','EdgeColor','b');
   set(h2(1),'FaceColor','r','EdgeColor','r');
   set(gca,'XTick',[],'YTick',[]);
   alpha .5;

 %      save([ScratchPath,'test.mat']);
 %     load([ScratchPath,'test.mat']);  figure(3); clf;
  clear raw_ints;        
  update_maindisplay(hObject,handles);
  guidata(hObject, handles);


% --- Executes on selection change in LevelsChannel.
function LevelsChannel_Callback(hObject, eventdata, handles)
% hObject    handle to LevelsChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ImShop
N_stormchannels = length(ImShop{handles.gui_number}.cmax);
selected_channel = get(handles.LevelsChannel,'Value');
if selected_channel <= N_stormchannels
% Set slider positions and values to the current selected channel
    minin = ImShop{handles.gui_number}.cmin(selected_channel);
    maxin = ImShop{handles.gui_number}.cmax(selected_channel);
else
    minin = ImShop{handles.gui_number}.omin(selected_channel - N_stormchannels);
    maxin = ImShop{handles.gui_number}.omax(selected_channel - N_stormchannels);    
end
set(handles.MaxIntSlider,'Value',minin);
set(handles.MaxIntBox,'String',num2str(minin));
set(handles.MaxIntSlider,'Value',maxin);
set(handles.MaxIntBox,'String',num2str(maxin));
  
% --- Executes on update of MinIntBox  
function MinIntBox_Callback(hObject, eventdata, handles) %#ok<*INUSL>
 minin = str2double(get(handles.MinIntBox,'Value'));
 set(handles.MinIntSlider,'Value',minin);
 scalecolor(hObject,handles);
 guidata(hObject, handles); 

 % --- Executes on update of MaxIntBox
function MaxIntBox_Callback(hObject, eventdata, handles)      
 maxin = str2double(get(handles.MaxIntBox,'Value'));
 set(handles.MaxIntSlider,'Value',maxin);
 scalecolor(hObject,handles);
 guidata(hObject, handles); 
 
% --- Executes on slider movement.
function MaxIntSlider_Callback(hObject, eventdata, handles)
 scalecolor(hObject,handles);
 guidata(hObject, handles);   
 
% --- Executes on slider movement.
function MinIntSlider_Callback(hObject, eventdata, handles)
 scalecolor(hObject,handles);
 guidata(hObject, handles);
 
 % --- Executes on button press in logscale.
function logscale_Callback(hObject, eventdata, handles)

%% Other

function pathin_Callback(hObject, eventdata, handles)
% hObject    handle to pathin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ImShop
pathin = get(handles.pathin,'String');
ImShop{handles.gui_number}.pathin = pathin; 

    
%% Create button Functions
% --- Executes during object creation, after setting all properties.
function LevelsChannel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function MinIntBox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function MaxIntBox_CreateFcn(hObject, eventdata, handles)
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
% --- Executes during object creation, after setting all properties.
function Xslider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
% --- Executes during object creation, after setting all properties.
function Yslider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
% --- Executes during object creation, after setting all properties.
function pathin_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% File Menu Functions
% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MenuOpen_Callback(hObject, eventdata, handles)
% hObject    handle to MenuOpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --------------------------------------------------------------------
function MenuOpenMulti_Callback(hObject, eventdata, handles)
% hObject    handle to MenuOpenMulti (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ImShop
startfolder = pwd;
multiselect = 'on'; 
[FileName,PathName,FilterIndex] = ...
    uigetfile({'*.jpg;*.tif;*.png;*.gif','All Image Files';...
          '*.*','All Files' },'Select Images',startfolder,...
        'MultiSelect',multiselect);
if FilterIndex ~= 0 
    Nfiles = length(FileName);
    ImageList = cell(1,Nfiles);
    for i=1:Nfiles
        ImageList{i} = imread([PathName,FileName{i}]);
        if i<8
        handles = AddImageTab(hObject,handles,FileName{i},i);
        guidata(hObject,handles);
        elseif i==8
           disp('Maximum number of images reached');   
        end
    end
end
% save in ImShop data structure
ImShop{handles.gui_number}.ImageListNames = FileName;
ImShop{handles.gui_number}.ImageList = ImageList;    
ImShop{handles.gui_number}.pathin = PathName;
set(handles.pathin,'String',PathName); 
guidata(hObject,handles);



% --------------------------------------------------------------------
function MenuOpenNewLayer_Callback(hObject, eventdata, handles)
% hObject    handle to MenuOpenNewLayer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MenuCloseCurrent_Callback(hObject, eventdata, handles)
% hObject    handle to MenuCloseCurrent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MenuCloseAll_Callback(hObject, eventdata, handles)
% hObject    handle to MenuCloseAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% Batch Menu Functions


% --------------------------------------------------------------------
function BatchMenu_Callback(hObject, eventdata, handles)
% hObject    handle to BatchMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MenuConvertFormat_Callback(hObject, eventdata, handles)
% hObject    handle to MenuConvertFormat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ImShop


ImageListString = CSL2str(ImShop{handles.gui_number}.ImageListNames);
prompt = {'Files',...
          'Save Folder',...
          'Format',...
          'bitdepth',...
          };
               
opts = {ImageListString,...
        ImShop{handles.gui_number}.pathin,...
        '.png',...
        '8',...
        };

dlg_title = 'Convert Format';
num_lines = 1;
opts = inputdlg(prompt,dlg_title,num_lines,opts);
ImageList = parseCSL(opts{1});

for i=1:length(ImageList)
    k = strfind(ImageList{i},'.');
    ftype = ImageList{i}(k:end);
    newname = regexprep(ImageList{i},ftype,opts{3});
    imwrite(ImShop{handles.gui_number}.ImageList{i},[opts{2},newname],...
        'bitdepth',eval(opts{4}));
end


%%  Add new image tabs

    function handles = AddImageTab(hObject,handles,image_name,tab_number)
    global ImShop
    if ~isfield(handles,'ImageTab')
        handles.ImageTab = [];
    end
    
    button_position = [26+80*(tab_number-1), 575, 70, 22];
    handles.ImageTab(tab_number) = ...
                    uicontrol( 'Style', 'Togglebutton', ...
                               'Callback', @ToggleImageTab, ...
                               'Units',    'pixels', ...
                               'Position', button_position, ...
                               'String',   image_name, ...
                               'TooltipString',image_name,...
                               'Value',    0);
                           guidata(hObject,handles);
    button_position = [26+80*(tab_number-1)+70, 575, 10, 22];
    handles.ImageTabExit(tab_number) = ...
                    uicontrol( 'Style', 'Pushbutton', ...
                               'Callback', @CloseImageTab, ...
                               'Units',    'pixels', ...
                               'Position', button_position, ...
                               'String',   'X', ...
                               'TooltipString','close',...
                               'Value',    0);
                           guidata(hObject,handles);
                           
                           
        function ToggleImageTab(hObject,eventdata)
            global ImShop
            handles = guidata(hObject);
            hObject
            otherTabs = handles.ImageTab(handles.ImageTab ~= hObject)
            set(otherTabs, 'Value', 0);
            current_tab = handles.ImageTab == hObject; 
            axes(handles.axes1);
            imagesc(ImShop{handles.gui_number}.ImageList{current_tab}); 
            set(gca,'XTick',[],'YTick',[]);
            guidata(hObject,handles);
            
     function handles = CloseImageTab(hObject,eventdata)
            global ImShop
            handles = guidata(hObject);
            otherTabs = find(handles.ImageTabExit ~= hObject);
            current_tab = handles.ImageTabExit == hObject; % 
            
            disp(['deleting tab:',num2str(find(current_tab)),' id:',num2str(hObject)]);
            disp(['other tabs:' num2str(otherTabs),' all tab ids:']); 
            disp(handles.ImageTab);
            
            for i = otherTabs(otherTabs > find(current_tab))
                cp = get(handles.ImageTab(i),'Position');
                set(handles.ImageTab(i),'Position',[cp(1)-80,cp(2:4)]);
                cp = get(handles.ImageTabExit(i),'Position');
                set(handles.ImageTabExit(i),'Position',[cp(1)-80,cp(2:4)]);
            end
            
            axes(handles.axes1);
            % remove from image list
            ImShop{handles.gui_number}.ImageList(current_tab) = []; 
            ImShop{handles.gui_number}.ImageListNames(current_tab) = []; 
            try
            imagesc(ImShop{handles.gui_number}.ImageList{current_tab}); 
            set(gca,'XTick',[],'YTick',[]);
            hObject = handles.ImageTab(current_tab);
            catch
                imagesc(ImShop{handles.gui_number}.ImageList{1}); 
                set(gca,'XTick',[],'YTick',[]);
                hObject = handles.ImageTab(1);
            end
            guidata(hObject,handles);
            delete(handles.ImageTab(current_tab)); % remove tab
            delete(handles.ImageTabExit(current_tab)); % remove exit
            handles.ImageTab(current_tab) = []; % remove from list
            handles.ImageTabExit(current_tab) = []; % remove from list
            guidata(ImageShop,handles);
            % If we delete it frist we can't update guidata
            % If we 
                           
%%  Add new Layers
%~~~~~~~
    function handles = AddLayer(hObject,handles,layer_name)
        % Adds a new radio button to the OverlayPanel, which can toggle this
        % channel on and off.  
    global ImShop
    if ~isfield(handles,'layerbutton')
        handles.layerbutton = [];
    end
    
    if isempty(layer_number)  % allows overwriting existing buttons upon load.  
        layer_number = length(handles.layerbutton) + 1;
    end

    % update levels
    LevelsNames = get(handles.LevelsChannel,'String');
    LevelsNames{layer_number} = layer_name;
    set(handles.LevelsChannel,'String',LevelsNames);
    
    ImShop{handles.gui_number}.cmin(layer_number) = 0;
    ImShop{handles.gui_number}.cmax(layer_number) = 1; 
    
    % create button
    button_position = [26+80*(layer_number-1), 575, 80, 22];
    handles.stormbutton(layer_number) = ...
                    uicontrol( 'Parent', handles.StormPanel,...
                               'Style', 'radiobutton', ...
                               'Callback', @StormButtonToggle, ...
                               'Units',    'pixels', ...
                               'Position', button_position, ...
                               'String',   layer_name, ...
                               'Value',    1);
    guidata(hObject, handles);
    set( handles.stormbutton(layer_number),'Units','normalized');
    guidata(hObject, handles);


        function StormButtonToggle(hObject, EventData)
            handles = guidata(hObject);
            update_maindisplay(hObject,handles);



%% Recently Added 
