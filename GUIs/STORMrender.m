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

global binfile SR
if isempty(SR)
    SR = cell(1,1);
else
    SR = [SR;cell(1,1)];
end

handles.gui_number = length(SR);
set(handles.SRinstance,'String',['inst id',num2str(handles.gui_number)]);


% Initialize a few blank fields
SR{handles.gui_number}.Oz = {};  

% Default Display Options
    SR{handles.gui_number}.DisplayOps.ColorZ = false; 
    SR{handles.gui_number}.DisplayOps.Zsteps = 5;
    SR{handles.gui_number}.DisplayOps.DotScale = 4;
    SR{handles.gui_number}.DisplayOps.HidePoor = false;
    SR{handles.gui_number}.DisplayOps.scalebar = 500;
    SR{handles.gui_number}.DisplayOps.npp = 160;
    SR{handles.gui_number}.DisplayOps.verbose = true;
    SR{handles.gui_number}.DisplayOps.zrange = [-500,500];
    SR{handles.gui_number}.DisplayOps.CorrDrift = true;
    SR{handles.gui_number}.DislpayOps.clrmap = 'lines';

% Default MultiBinFile Load Options
    SR{handles.gui_number}.LoadOps.warpD = 3; % set to 0 for no chromatic warp
    SR{handles.gui_number}.LoadOps.warpfile = ''; % can leave blank if no chromatic warp
    SR{handles.gui_number}.LoadOps.chns = {''};% {'750','647','561','488'};
    SR{handles.gui_number}.LoadOps.pathin = '';
    SR{handles.gui_number}.LoadOps.correctDrift = true;
    SR{handles.gui_number}.LoadOps.chnOrder = '[1:end]'; 
    SR{handles.gui_number}.LoadOps.sourceroot = '';
    SR{handles.gui_number}.LoadOps.bintype = '_alist.bin';
    SR{handles.gui_number}.LoadOps.chnFlag = {'750','647','561','488'};  
    SR{handles.gui_number}.LoadOps.dataset = 0;

% Default Contrast values
    SR{handles.gui_number}.omin = 0;
    SR{handles.gui_number}.omax = 1;
    
% Choose default command line output for STORMrender
handles.output = hObject;

% avoid startup error
set(handles.Yslider,'Value',128);
set(handles.Yslider,'Min',0);
set(handles.Yslider,'Max',256);
set(handles.Yslider,'SliderStep',[0.005,0.05]);

% set up axes for plotting
 axes(handles.axes1); 
 set(gca,'color','k');
 set(gca,'XTick',[],'YTick',[]);
 colormap hot;
 axes(handles.axes2); 
 set(gca,'color','k');
set(gca,'XTick',[],'YTick',[]);
colormap hot;
 axes(handles.axes3); 
 set(gca,'color','w');
set(gca,'XTick',[],'YTick',[]);
% build dropdown menu
molfields = {'custom';'region';'z';'h';'a';'i';'w'};
set(handles.choosefilt,'String',molfields);

% set up sliders for contrast adjustment
set(handles.MaxIntSlider,'Max',1);
set(handles.MaxIntSlider,'Min',0);
set(handles.MaxIntSlider,'Value',1);
set(handles.MaxIntSlider,'SliderStep',[1/2^12,1/2^4])
set(handles.MinIntSlider,'Max',1);
set(handles.MinIntSlider,'Min',0);
set(handles.MinIntSlider,'Value',0); 
set(handles.MinIntSlider,'SliderStep',[1/2^12,1/2^4])
guidata(hObject, handles);


if ~isempty(binfile)
    QuickLoad(hObject, eventdata, handles);
    handles = guidata(hObject); % for some reason this doesn't work if called from within QuickLoad.  
end

% Update handles structure
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
% --- Executes on button press in QuickLoad.
function QuickLoad(hObject, eventdata, handles)
global binfile SR
SR{handles.gui_number}.mlist = [];
if isempty(binfile)
   [FileName,PathName] = uigetfile('*.bin');
   binfile = [PathName,filesep,FileName];
else
    [~,FileName] = extractpath(binfile);
end
handles = AddStormLayer(hObject,handles,FileName,1);
guidata(hObject, handles);
handles = guidata(hObject);
SingleBinLoad(hObject,eventdata,handles);
handles = guidata(hObject);
guidata(hObject, handles);

% --------------------------------------------------------------------
function MenuOpenBin_Callback(hObject, eventdata, handles)
% hObject    handle to MenuOpenBin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
multiselect = 'off';
LoadBin(hObject,eventdata,handles,multiselect);
   
% --------------------------------------------------------------------
function MenuOpenMulti_Callback(hObject, eventdata, handles)
% hObject    handle to MenuOpenMulti (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
multiselect = 'on';
% Multiload assumes you wish to clear all current data;
LoadBin(hObject,eventdata,handles,multiselect);




        
function LoadBin(hObject,eventdata,handles,multiselect)
% Brings up dialogue box to select bin file(s) to load;     
global binfile SR
handles=ClearCurrentData(hObject,eventdata,handles);

if ~isempty(SR{handles.gui_number}.LoadOps.pathin)
    startfolder = SR{handles.gui_number}.LoadOps.pathin;
elseif ~isempty(binfile)
    startfolder = extractpath(binfile);
else
    startfolder = pwd;
end
[FileName,PathName,FilterIndex] = uigetfile({'*.bin','Bin file (*.bin)';...
    '*.*','All Files (*.*)'},'Select molecule list',startfolder,...
    'MultiSelect',multiselect);
if FilterIndex ~=0
    SR{handles.gui_number}.LoadOps.pathin = PathName;
    set(handles.datapath,'String',SR{handles.gui_number}.LoadOps.pathin); 
    if ~iscell(FileName)
        binfile = [PathName,filesep,FileName];
        handles = AddStormLayer(hObject,handles,FileName,1);
        guidata(hObject, handles);
        SingleBinLoad(hObject,eventdata,handles);
    else
        
        prompt = 'In what order were these taken?  ';
        chnOrder = inputdlg(char({prompt,FileName{:}}),...
            '',1,{['[',num2str(1:length(FileName)),']'] }) ;  
        chnOrder = chnOrder{1}; 
        SR{handles.gui_number}.LoadOps.chnOrder = chnOrder;     
        binnames = eval(['FileName(',chnOrder,')']);
        for c=1:length(FileName)
            handles = AddStormLayer(hObject,handles,binnames{c},c);
            guidata(hObject, handles);
        end
        MultiBinLoad(hObject,eventdata,handles,binnames);
    end       
end




% --------------------------------------------------------------------
function MenuAutoMultiLoad_Callback(hObject, eventdata, handles)
% Automatically group bin files and load the one indicated by the Load
% options (default = # 1).  
% 
% hObject    handle to MenuAutoMultiLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SR scratchPath  %#ok<NUSED>

handles=ClearCurrentData(hObject,eventdata,handles);
stoprun = 0;
% confirm auto-load options
dlg_title = 'Bin file names must begin with unique channel flag';
num_lines = 1;
prompt = ...
    {'files containing string',...
    'bin type',...
    'channel flag',...
    'Match set to load (0 to print matches)'...
    };
default_opts = ...
    {SR{handles.gui_number}.LoadOps.sourceroot,...
    SR{handles.gui_number}.LoadOps.bintype,...
    CSL2str(SR{handles.gui_number}.LoadOps.chnFlag),...
    num2str(SR{handles.gui_number}.LoadOps.dataset),...
    };   
opts = inputdlg(prompt,dlg_title,num_lines,default_opts);

if ~isempty(opts) % don't try anything if dialogue box is canceled
    SR{handles.gui_number}.LoadOps.sourceroot = opts{1};
    SR{handles.gui_number}.LoadOps.bintype = opts{2};
    SR{handles.gui_number}.LoadOps.chnFlag = parseCSL(opts{3}); 
    SR{handles.gui_number}.LoadOps.dataset = str2double(opts{4});
    %  if we don't have a file path, prompt user to find one. 
    if isempty(SR{handles.gui_number}.LoadOps.pathin)
        SR{handles.gui_number}.LoadOps.pathin = uigetdir(pwd,'select data folder');
        if ~SR{handles.gui_number}.LoadOps.pathin
            SR{handles.gui_number}.LoadOps.pathin = '';
            stoprun = 1;
        end
    end

    if ~stoprun
        % Automatically group all bin files of same section in different colors
        %   based on image number, if it has not already been done
        if SR{handles.gui_number}.LoadOps.dataset == 0 || isempty(SR{handles.gui_number}.fnames)
        [SR{handles.gui_number}.bins,SR{handles.gui_number}.allfnames] = ...
            automatch_files( [SR{handles.gui_number}.LoadOps.pathin,filesep],...
               'sourceroot',SR{handles.gui_number}.LoadOps.sourceroot,...
               'filetype',SR{handles.gui_number}.LoadOps.bintype,...
               'chns',SR{handles.gui_number}.LoadOps.chnFlag);
        disp('files found and grouped:'); 
        disp(SR{handles.gui_number}.bins(:));
        end

        % Figure out which channels are really in data set  
        if SR{handles.gui_number}.LoadOps.dataset == 0
         i=1;
        else
         i=SR{handles.gui_number}.LoadOps.dataset;
        end

        hasdata = logical(1-cellfun(@isempty, SR{handles.gui_number}.bins(:,i)));
        binnames =  SR{handles.gui_number}.bins(hasdata,i); % length cls must equal length binnames
        if sum((logical(1-hasdata))) ~=0
        disp('no data found for in channels:');
        disp(SR{handles.gui_number}.LoadOps.chnFlag(logical(1-hasdata)))
        end

        SR{handles.gui_number}.fnames = SR{handles.gui_number}.allfnames(hasdata,i);
        disp('will load:');
        disp(SR{handles.gui_number}.fnames);   
        for c=1:length(SR{handles.gui_number}.fnames)
        handles = AddStormLayer(hObject,handles,SR{handles.gui_number}.fnames{c},[]);
        guidata(hObject, handles);
        end
    MultiBinLoad(hObject,eventdata,handles,binnames);    
    end
end



%~~~~~~~~~~~~~~~~~~
 function handles=ClearAllData(hObject,eventdata,handles)
    global SR
     SR{handles.gui_number}.allfnames = [];
     SR{handles.gui_number}.froots = [];
     SR{handles.gui_number}.bins = [];
     handles=ClearCurrentData(hObject,eventdata,handles);

function handles=ClearCurrentData(hObject,eventdata,handles)
        % clear existing fields for these variables
        global SR
        SR{handles.gui_number}.mlist = [];
        SR{handles.gui_number}.fnames = [];
        SR{handles.gui_number}.infofile = [];
        SR{handles.gui_number}.Oz = {};     
        SR{handles.gui_number}.O = {};
        if isfield(SR{handles.gui_number},'imaxes');
        SR{handles.gui_number}=rmfield(SR{handles.gui_number},'imaxes');
        end
        
    % Clear levels (contrasting)
    set(handles.LevelsChannel,'Value',1);
    set(handles.LevelsChannel,'String',{'channel1'});
      
    % Make STORM and Overlay layers invisible again
    for c=1:6
        eval(['set(','handles.sLayer',num2str(c),', ','''Visible''',', ','''off''',')']);
        eval(['set(','handles.oLayer',num2str(c),', ','''Visible''',', ','''off''',')']);
    end


 %~~~~~~~
function handles = AddStormLayer(hObject,handles,Sname,layer_number)
        % Adds a new radio button to the STORM layer, which can toggle this
        % channel on and off.  
global SR scratchPath  %#ok<NUSED>

verbose = SR{handles.gui_number}.DisplayOps.verbose;
if verbose
disp(['Adding New STORM layer ',num2str(layer_number)]);
end

% Make button visible
buttonName = ['handles.sLayer',num2str(layer_number)];
makeVisible = ['set(',buttonName,', ','''Visible''',', ','''on''',')'];
buttonPress = ['set(',buttonName,', ','''Value''',', ','true',')'];
updateName =  ['set(',buttonName,', ','''String''',', ','''',Sname,'''',')'];
eval(makeVisible); 
eval(buttonPress); 
eval(updateName); 
guidata(hObject, handles);

% update levels
LevelsNames = get(handles.LevelsChannel,'String');
LevelsNames{layer_number} = Sname;
set(handles.LevelsChannel,'String',LevelsNames);   
SR{handles.gui_number}.cmin(layer_number) = 0;
SR{handles.gui_number}.cmax(layer_number) = .7; 

            
          


function SingleBinLoad(hObject,eventdata,handles)
% Loads single bin files
global binfile SR 
[pathname,filename] = extractpath(binfile); 
disp('reading binfile...');
SR{handles.gui_number}.mlist{1} = ReadMasterMoleculeList(binfile);
SR{handles.gui_number}.LoadOps.pathin = pathname;
SR{handles.gui_number}.fnames{1} = filename; 
disp('file loaded'); 

k = strfind(filename,'_');
SR{handles.gui_number}.infofile = ReadInfoFile(...
    [pathname,filesep,filename(1:k(end)-1),'.inf']);
disp('setting up image options...');
ImSetup(hObject,eventdata, handles);
disp('drawing data...');
ClearFilters_Callback(hObject, eventdata, handles); 
guidata(hObject, handles);



        
 function MultiBinLoad(hObject,eventdata,handles,binnames)
 global SR scratchPath  %#ok<NUSED>
 % ----------------------------------------------------
 % Passed Inputs:
 % binnames
 % ----------------------------------------------------
 % % Global Inputs (from SR structure):
 % .LoadOps: structure containing filepaths for data, warps etc
 % .fnames: cell array of names of current data files in display 
 %          (used for display only).
 %------------------------------------------------------
 % Outputs (saved in SR data structure)
 % .mlist:  cell array of all molecule lists loaded for display
 % .infofile: InfoFile structure for dataset (contains stage position,
 %          needed for MosaicView reconstruction).  

% Extract some useful info for later:
    guidata(hObject, handles);
%  Set up title field in display   
SR{handles.gui_number}.fnames = binnames; % display name for the files
% Get infofile #1 for position information
k = strfind(binnames{1},'_'); 
SR{handles.gui_number}.infofile = ...
    ReadInfoFile([SR{handles.gui_number}.LoadOps.pathin,filesep,binnames{1}(1:k(end)-1),'.inf']);

% Load the binfiles 
Tchns = length(binnames);
mlist = cell(Tchns,1); 
for c=1:Tchns
    fullBinName = strcat(SR{handles.gui_number}.LoadOps.pathin,filesep,binnames{c});
    mlist{c} = ReadMasterMoleculeList(fullBinName,'verbose',...
                    SR{handles.gui_number}.DisplayOps.verbose); 
end

    
% Apply global drift correction, then return loaded mlist file.
% Then apply chromewarp.
mlist = MultiChnDriftCorrect(mlist,...
        'correctDrift',SR{handles.gui_number}.LoadOps.correctDrift,...
        'verbose',SR{handles.gui_number}.DisplayOps.verbose);

% Need a warp map.  
if isempty(SR{handles.gui_number}.LoadOps.warpfile)
[FileName,PathName] = uigetfile({'*.mat','Matlab data (*.mat)';...
'*.*','All Files (*.*)'},'Select warpfile',SR{handles.gui_number}.LoadOps.pathin);
SR{handles.gui_number}.LoadOps.warpfile = [PathName,FileName];
end

if isempty([SR{handles.gui_number}.LoadOps.chns{:}])
chns = inputdlg({'Channel Names: (name must match warpmap, order match layer order)'},...
'',1,{'750,647,561,488'});  % <--  Default channel names
SR{handles.gui_number}.LoadOps.chns = parseCSL(chns{1});
end
% Automatically dealing with old or new style chromewarp format
if ~isempty(SR{handles.gui_number}.LoadOps.warpfile)   
[warppath,warpname] = extractpath(SR{handles.gui_number}.LoadOps.warpfile); % detect old style
    if ~isempty(strfind(warpname,'tform'))
        for c=1:length(mlist)
            mlist{c} = chromewarp(SR{handles.gui_number}.LoadOps.chns(c),...
                mlist{c},warppath,'warpD',SR{handles.gui_number}.LoadOps.warpD);
        end        
    else  % Run new style
        mlist = ApplyChromeWarp(mlist,SR{handles.gui_number}.LoadOps.chns,...
            SR{handles.gui_number}.LoadOps.warpfile,...
            'warpD',SR{handles.gui_number}.LoadOps.warpD,...
            'names',SR{handles.gui_number}.fnames);    
    end
else
    disp('warning, no warp file found to align color channels');
end
% Cleanup settings from any previous data and render image:
SR{handles.gui_number}.mlist = mlist; 
ImSetup(hObject,eventdata, handles);
ClearFilters_Callback(hObject, eventdata, handles); 
guidata(hObject, handles);


    

% --------------------------------------------------------------------
function MenuLoadOptions_Callback(hObject, eventdata, handles)
% hObject    handle to MenuLoadOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SR scratchPath  %#ok<NUSED>

    dlg_title = 'Update Load Options';
    num_lines = 1;

    default_opts = ...
        {SR{handles.gui_number}.LoadOps.pathin,...
        CSL2str(SR{handles.gui_number}.LoadOps.chns),...
        SR{handles.gui_number}.LoadOps.warpfile,...
        num2str(SR{handles.gui_number}.LoadOps.warpD),...
        num2str(SR{handles.gui_number}.LoadOps.correctDrift),...
        SR{handles.gui_number}.LoadOps.chnOrder,...
        }';
    prompt = ...
        {'Data Folder',...
        'Channel Names (must match names in chromewarp)',...
        'warpfile',...
        'warp dimension',...
        'Correct global drift (files must be loaded in order acquired)',...
        'Order acquired (see display channels box for order listed)',...
        };
try    
opts = inputdlg(prompt,dlg_title,num_lines,default_opts);
catch er  % if values get really screwed up, start again
    disp(er.message); 
    SR{handles.gui_number}.LoadOps.warpD = 3; % set to 0 for no chromatic warp
    SR{handles.gui_number}.LoadOps.warpfile = ''; % can leave blank if no chromatic warp
    SR{handles.gui_number}.LoadOps.chns = {''};% {'750','647','561','488'};
    SR{handles.gui_number}.LoadOps.pathin = '';
    SR{handles.gui_number}.LoadOps.correctDrift = true;
    SR{handles.gui_number}.LoadOps.chnOrder = '[1:end]'; 
    SR{handles.gui_number}.LoadOps.sourceroot = '';
    SR{handles.gui_number}.LoadOps.bintype = '_alist.bin';
    SR{handles.gui_number}.LoadOps.chnFlag = {'750','647','561','488'};  
    SR{handles.gui_number}.LoadOps.dataset = 0;
        default_opts = ...
        {SR{handles.gui_number}.LoadOps.pathin,...
        CSL2str(SR{handles.gui_number}.LoadOps.chns),...
        SR{handles.gui_number}.LoadOps.warpfile,...
        num2str(SR{handles.gui_number}.LoadOps.warpD),...
        num2str(SR{handles.gui_number}.LoadOps.correctDrift),...
        SR{handles.gui_number}.LoadOps.chnOrder,...
        }';
    opts = inputdlg(prompt,dlg_title,num_lines,default_opts);
end

if ~isempty(opts)
    SR{handles.gui_number}.LoadOps.pathin = opts{1};
    SR{handles.gui_number}.LoadOps.chns = parseCSL(opts{2});
    SR{handles.gui_number}.LoadOps.warpfile = opts{3};
    SR{handles.gui_number}.LoadOps.warpD = str2double(opts{4});
    SR{handles.gui_number}.LoadOps.correctDrift = logical(str2double(opts{5}));
    SR{handles.gui_number}.LoadOps.chnOrder = opts{6}; 
    set(handles.datapath,'String',SR{handles.gui_number}.LoadOps.pathin);     
end

% --------------------------------------------------------------------
function ToolbarOpenFile_ClickedCallback(hObject, eventdata, handles)
LoadBin(hObject,eventdata,handles,'off')





% Setup defaults
% -------------------------------------------------------------------
function ImSetup(hObject,eventdata, handles)
global SR scratchPath

% if imaxes is already defined, use it. 
if isfield(SR{handles.gui_number},'imaxes')
   imaxes = SR{handles.gui_number}.imaxes; 
else
    % build new imaxes structure using ROI from parameter file if available
    mlist = SR{handles.gui_number}.mlist;  % short hand;
    w = zeros(length(mlist),1);
    h = zeros(length(mlist),1);
    for i=1:length(mlist)
        binfile = [SR{handles.gui_number}.LoadOps.pathin,SR{handles.gui_number}.fnames{i}];
        parsfile = ReadListParsFile(binfile);
        hasROIinfo = true;  
        if   ~isempty(parsfile)
            parsflag = parsfile(end-3:end);
            if strcmp(parsflag,'.xml');
            roiFlags = {'<x_start type="int">',...
                        '<x_stop type="int">',...
                        '<y_start type="int">',...
                        '<y_stop type="int">'};
            endmarker = '<';
            elseif strcmp(parsflag,'.ini');
            roiFlags = {'ROI_x0=',...
                        'ROI_x1=',...
                        'ROI_y0=',...
                        'ROI_y1='};
            endmarker = '';
            else
               hasROIinfo = false;  
            end
            if hasROIinfo
                roiInfo = read_parameterfile(parsfile,roiFlags,endmarker);
                roi = cellfun(@str2double,roiInfo);
                w(i) = roi(2) - roi(1);
                h(i) = roi(4) - roi(3); 
                mlist{i}.xc = mlist{i}.xc - roi(1);
                mlist{i}.x = mlist{i}.x - roi(1);
                mlist{i}.yc = mlist{i}.yc - roi(3);
                mlist{i}.y = mlist{i}.y - roi(3);      
            end
        else
            h(i) = SR{handles.gui_number}.infofile.frame_dimensions(2); % actual size of image
            w(i) = SR{handles.gui_number}.infofile.frame_dimensions(1);
        end
    end
    if sum(w==w(1)) ~= length(mlist) || sum(h==h(1)) ~= length(mlist)
        error('ROIs for the selected molecule lists different sizes'); 
    end
    imaxes.W = w(1);
    imaxes.H = h(1);
    SR{handles.gui_number}.mlist = mlist;
end

imaxes.scale = 2;  % upscale on display
imaxes.zm = 1;
imaxes.cx = imaxes.W/2;
imaxes.cy = imaxes.H/2;
imaxes.xmin = 0;
imaxes.xmax = imaxes.W;
imaxes.ymin = 0; 
imaxes.ymax = imaxes.H; 
imaxes.updatemini = true; 
set(handles.Xslider,'Min',imaxes.xmin);
set(handles.Xslider,'Max',imaxes.xmax);
set(handles.Yslider,'Min',imaxes.ymin);
set(handles.Yslider,'Max',imaxes.ymax);
SR{handles.gui_number}.imaxes = imaxes;
guidata(hObject, handles);
UpdateSliders(hObject,eventdata,handles);

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

global SR  

I = SR{handles.gui_number}.I;
Io = SR{handles.gui_number}.Io;
Oz = SR{handles.gui_number}.Oz; 
if ~isfield(SR{handles.gui_number},'savepath')
    SR{handles.gui_number}.savepath = '';    
end
savepath=SR{handles.gui_number}.savepath;
vlist = MolsInView(handles); %#ok<NASGU>

try
[savename,savepath] = uiputfile(savepath);
catch %#ok<CTCH>
    disp(['unable to open savepath ',savepath]);
    [savename,savepath] = uiputfile;
end
SR{handles.gui_number}.savepath = savepath;

% strip extra file endings, the script will put these on appropriately. 
k = strfind(savename,'.');
if ~isempty(k)
    savename = savename(1:k-1); 
end

if isempty(I) || isempty(SR{handles.gui_number}.cmax) || isempty(SR{handles.gui_number}.cmin)
    disp('no image data to save');
end
if isempty(Oz)
    disp('no overlay(s) to save');
end

if savename ~= 0 % save was not 'canceled'
    fnames = SR{handles.gui_number}.fnames; %#ok<NASGU>
    save([savepath,filesep,savename,'.mat'],'vlist','I','Oz','fnames');
    disp([savepath,filesep,savename,'.mat' ' saved successfully']);
    imwrite(Io,[savepath,filesep,savename,'.png']); 
    disp(['wrote ', savepath,filesep,savename,'.png']);
end


% --------------------------------------------------------------------
function SaveImage_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to SaveImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SR
Io = SR{handles.gui_number}.Io;
if ~isfield(SR{handles.gui_number},'savepath')
    SR{handles.gui_number}.savepath = '';    
end
savepath=SR{handles.gui_number}.savepath;

if ischar(savepath)
    [savename,savepath] = uiputfile(savepath);
else
    [savename,savepath] = uiputfile;
end
if savename ~= 0
    imwrite(Io,[savepath,filesep,savename,'.tif']); 
    disp(['wrote ', savepath,filesep,savename,'.tif']);
end
%=========================================================================%












%=========================================================================%  
%%               Start of plotting functions
%=========================================================================%

%-------------------------------------------------------------------------




function GetEdges(hObject, eventdata, handles)
% if cx/cy is near the edge and zoom is small, we should have a different
% maxx maxy
global SR     
imaxes = SR{handles.gui_number}.imaxes;
% imaxes.xmin = max(0,imaxes.cx - imaxes.W/2/imaxes.zm);
% imaxes.xmax = min(imaxes.W,imaxes.cx + imaxes.W/2/imaxes.zm);
% imaxes.ymin = max(0,imaxes.cy - imaxes.H/2/imaxes.zm);
% imaxes.ymax = min(imaxes.H,imaxes.cy + imaxes.H/2/imaxes.zm);

% Attempt to bounce back from edges if center point overlaps a substantial
% blank image at this amount of zoom.  
imaxes.xmin = imaxes.cx - imaxes.W/2/imaxes.zm;
imaxes.xmax = imaxes.cx + imaxes.W/2/imaxes.zm;
imaxes.ymin = imaxes.cy - imaxes.H/2/imaxes.zm;
imaxes.ymax = imaxes.cy + imaxes.H/2/imaxes.zm;

if imaxes.xmin < 0 
    imaxes.cx = imaxes.cx - imaxes.xmin;
    imaxes.xmin = imaxes.cx - imaxes.W/2/imaxes.zm;
end
if imaxes.xmax > imaxes.W
    imaxes.cx = imaxes.cx - (imaxes.xmax - imaxes.W);
    imaxes.xmax = imaxes.cx + imaxes.W/2/imaxes.zm;
end
if imaxes.ymin < 0 
    imaxes.cy = imaxes.cy - imaxes.ymin;
    imaxes.ymin = imaxes.cy - imaxes.H/2/imaxes.zm;
end
if imaxes.ymax > imaxes.H
    imaxes.cy = imaxes.cy - (imaxes.ymax - imaxes.H);
    imaxes.ymax = imaxes.cy + imaxes.H/2/imaxes.zm;
end
SR{handles.gui_number}.imaxes = imaxes;





%==========================================================================
%% Main plotting function
%==========================================================================
function ImLoad(hObject,eventdata, handles)
% load variables
global   SR

mlist = SR{handles.gui_number}.mlist;  

% if we're zoomed out fully, recenter everything
if SR{handles.gui_number}.imaxes.zm == 1
  ImSetup(hObject,eventdata, handles); % reset to center
end
GetEdges(hObject, eventdata, handles);
UpdateSliders(hObject,eventdata,handles);

% tic
if SR{handles.gui_number}.DisplayOps.ColorZ
    Zsteps = SR{handles.gui_number}.DisplayOps.Zsteps;
    % In general, not worth excluding these dots from 2d images.
    % if desired, can be done by applying a molecule list filter.  
    if SR{handles.gui_number}.DisplayOps.HidePoor 
        for c = 1:length(SR{handles.gui_number}.infilter)
            SR{handles.gui_number}.infilter{c}(mlist{c}.c==9) = 0;  
        end
    end
else
    Zsteps = 1;
end


SR{handles.gui_number}.I = list2img(mlist, SR{handles.gui_number}.imaxes,...
    'filter',SR{handles.gui_number}.infilter,...
    'Zrange',SR{handles.gui_number}.DisplayOps.zrange,...
    'dotsize',SR{handles.gui_number}.DisplayOps.DotScale,...
    'Zsteps',Zsteps,'scalebar',0,...
    'N',6,...
    'correct drift',SR{handles.gui_number}.DisplayOps.CorrDrift);

if ~isempty(SR{handles.gui_number}.Oz)
    IntegrateOverlay(hObject,handles); % Integrate the Overlay, if it exists
end

UpdateMainDisplay(hObject,handles); % converts I, applys contrast, to RBG
guidata(hObject, handles);
% plottime = toc;
% disp(['total time to render image: ',num2str(plottime)]);













%=========================================================================%
%%                   Data Filters
%=========================================================================%
% --- Executes on selection change in choosefilt.
function choosefilt_Callback(hObject, eventdata, handles)
    contents = cellstr(get(handles.choosefilt,'String')); % returns choosefilt contents as cell array
    par = contents{get(handles.choosefilt,'Value')}; % returns selected item from choosefilt 
 if strcmp(par,'custom') % apply custom filter
          disp({'custom filter: f = logical function of m.*';
              'examples: (remove " to eval)';
              'returns molecules with parameter a > 100:'
              '    "f = [m.a] > 100" ';
              'return molecules with an i/a ratio of .5-5';
              ' or total intensity > 1000';
              '   "f =  ([m.i] ./ [m.a]) > .5 & ([m.i] ./ [m.a]) <5 ';
              '    | [m.i] > 1000" returns  '; 
              ' returns molecules with more than k=4 neighbors';
              'in a radius of dmax=5:';
              '       "d = transpose([[m.xc];[m.yc]]);" ';
              '       "[idx,dist] = knnsearch(d,d,"k",4);"';
              '       "f = (max(dist,[],2) < 5);"';
           ' note: need to change double "k" to single to eval.'});
 end
 
 

% --- Executes on button press in ClearFilters.
function ClearFilters_Callback(hObject, eventdata, handles)
global  SR
SR{handles.gui_number}.filts = struct('custom',[]); % empty structure to store filters
Cs = length(SR{handles.gui_number}.mlist);
    SR{handles.gui_number}.infilter = cell(Cs,1);
    channels = find(1-cellfun(@isempty,SR{handles.gui_number}.mlist))';
    for i=channels
        SR{handles.gui_number}.infilter{i} = true(size([SR{handles.gui_number}.mlist{i}.xc]));  % 
    end
SR{handles.gui_number}.cmax = .3*ones(Cs,1); % default values
SR{handles.gui_number}.cmin = 0*ones(Cs,1);  % default values
ImLoad(hObject,eventdata, handles); % calls plotdata function
 
 

% --- Executes on button press in ApplyFilter.
function ApplyFilter_Callback(hObject, eventdata, handles)
% chose filter
  global  SR scratchPath  %#ok<NUSED>
  filts = SR{handles.gui_number}.filts;
  contents = cellstr(get(handles.choosefilt,'String')); % returns choosefilt contents as cell array
  par = contents{get(handles.choosefilt,'Value')}; % returns selected item from choosefilt 

    % see which channels are selected to apply
    channels(1) = get(handles.fchn1,'Value');
    channels(2) = get(handles.fchn2,'Value');
    channels(3) = get(handles.fchn3,'Value');
    channels(4) = get(handles.fchn4,'Value');
    channels = find(channels);
    
    myfilt = get(handles.CustomFilter,'String');
    vlist = MolsInView(handles);
    
    local_filter = cell(max(channels),1);
 for c=1:channels;
    local_filter{c} = vlist{c}.locinfilter;
 end
  axes(handles.axes2);  
  [newfilter,filts] = applyfilter(vlist,local_filter, filts, channels, par, myfilt,...
      SR{handles.gui_number}.imaxes); 
  
  
  for c=1:channels
    SR{handles.gui_number}.infilter{c}(vlist{c}.inbox & vlist{c}.infilter) =  newfilter{c};
  end
   SR{handles.gui_number}.filts = filts;
  ImLoad(hObject,eventdata, handles); % calls plotdata function

% --- Executes on button press in ShowFilters.
function ShowFilters_Callback(hObject, eventdata, handles)
% hObject    handle to ShowFilters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('this function still under development'); 



 
 
function UpdateMainDisplay(hObject,handles)
global  SR scratchPath  %#ok<NUSED>

I = SR{handles.gui_number}.I;
imaxes = SR{handles.gui_number}.imaxes;
% I cell containing current STORM image
% Oz cell containing appropriately rescaled overlay image
% Io 3-color output image. Global only to pass to export/save image calls.

guidata(hObject, handles);
numChannels = length(I); 
[h,w,Zs] = size(I{1});
numOverlays = length(SR{handles.gui_number}.Oz);

% Find out which channels are toggled for display
%------------------------------------------------------------        
channels = zeros(1,numChannels); % Storm Channels
for c = 1:numChannels; 
    channels(c) = eval(['get(','handles.sLayer',num2str(c),', ','''Value''',')']);
end
active_channels = find(channels);

overlays = zeros(1,numOverlays); % Overlay channels
for c = 1:numOverlays
    overlays(c) = eval(['get(','handles.oLayer',num2str(c),', ','''Value''',')']);
end
active_overlays = find(overlays);
numClrs = numChannels + numOverlays;  
%-----------------------------------------------------------
% Stack all image layers (channels, z-dimensions, and overlays)
%   into a common matrix for multicolor rendering.  Apply indicated
%   contrast for all data.  
Io = STORMcell2img(I,'overlays',SR{handles.gui_number}.Oz,...
'active channels',active_channels,'active overlays',active_overlays,...
'cmin',SR{handles.gui_number}.cmin,'cmax',SR{handles.gui_number}.cmax,...
'omin',SR{handles.gui_number}.omin,'omax',SR{handles.gui_number}.omax,...
'numClrs',numClrs,'colormap',SR{handles.gui_number}.DisplayOps.clrmap);

% Add ScaleBar (if indicated)
Cs_out = size(Io,3); 
if SR{handles.gui_number}.DisplayOps.scalebar > 0 
    scb = round(1:SR{handles.gui_number}.DisplayOps.scalebar/SR{handles.gui_number}.DisplayOps.npp*imaxes.zm*imaxes.scale);
    h1 = round(imaxes.H*.9*imaxes.scale);
    Io(h1:h1+2,10+scb,:) = 2^16*ones(3,length(scb),Cs_out,'uint16'); % Add scale bar and labels
end
%-----------------------------------------------------------

% Update the display
%--------------------------------------------------
axes(handles.axes2); cla;
set(gca,'XTick',[],'YTick',[]);
imagesc(Io); 
shading interp;
axes(handles.axes2);
set(handles.imtitle,'String',SR{handles.gui_number}.fnames(:)); % interpreter, none
% colorbar; colormap(hsv(Zs*Cs));
set(gca,'XTick',[],'YTick',[]);
if imaxes.updatemini
    axes(handles.axes1); cla;
    set(gca,'XTick',[],'YTick',[]);
    imagesc(Io); 
    imaxes.updatemini = false;
    set(gca,'XTick',[],'YTick',[]);
    SR{handles.gui_number}.imaxes = imaxes;
end
SR{handles.gui_number}.Io = Io; 
guidata(hObject, handles);


% --------------------------------------------------------------------
function ManualContrastTool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to ManualContrastTool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SR
SR{handles.gui_number}.cmax = input('enter a vector for max intensity for each channel: ');
SR{handles.gui_number}.cmin = input('enter a vector for min intensity for each channel: ');
 UpdateMainDisplay(hObject,handles);
 guidata(hObject, handles);
 
% --------------------------------------------------------------------
function AutoContrastTool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to AutoContrastTool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SR
    Cs = length(SR{handles.gui_number}.mlist);
    for c=1:Cs
        SR{handles.gui_number}.cmax(c) = .9;
        SR{handles.gui_number}.cmin(c) = 0;
    end
 UpdateMainDisplay(hObject,handles);
 guidata(hObject, handles);

% ------
 function scalecolor(hObject,handles)
 global SR scratchPath %#ok<NUSED>

% x scale for histogram (log or normal)
logscalecolor = logical(get(handles.logscalecolor,'Value'));
N_stormchannels = length(SR{handles.gui_number}.cmax);
selected_channel = get(handles.LevelsChannel,'Value');

% Read in current slider postions, set numeric displays accordingly
maxin = get(handles.MaxIntSlider,'Value');
minin = get(handles.MinIntSlider,'Value'); 
set(handles.MaxIntBox,'String',num2str(maxin));
set(handles.MinIntBox,'String',num2str(minin));

% If it's STORM data, record data range from I and store max min as
% cmax / cmin
if selected_channel <= N_stormchannels
    raw_ints  = double(SR{handles.gui_number}.I{selected_channel}(:)); 
    SR{handles.gui_number}.cmax(selected_channel) = maxin;
    SR{handles.gui_number}.cmin(selected_channel) = minin;
else % If it's Overlay data adjust O
    selected_channel = selected_channel-N_stormchannels;
    raw_ints  = double(SR{handles.gui_number}.Oz{selected_channel}(:)); 
    SR{handles.gui_number}.omax(selected_channel) = maxin;
    SR{handles.gui_number}.omin(selected_channel) = minin;
end
 
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

  clear raw_ints;        
  UpdateMainDisplay(hObject,handles);
  guidata(hObject, handles);


% --- Executes on selection change in LevelsChannel.
function LevelsChannel_Callback(hObject, eventdata, handles)
% hObject    handle to LevelsChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SR
N_stormchannels = length(SR{handles.gui_number}.cmax);
selected_channel = get(handles.LevelsChannel,'Value');
if selected_channel <= N_stormchannels
% Set slider positions and values to the current selected channel
    minin = SR{handles.gui_number}.cmin(selected_channel);
    maxin = SR{handles.gui_number}.cmax(selected_channel);
else
    minin = SR{handles.gui_number}.omin(selected_channel - N_stormchannels);
    maxin = SR{handles.gui_number}.omax(selected_channel - N_stormchannels);    
end
set(handles.MaxIntSlider,'Value',minin);
set(handles.MaxIntBox,'String',num2str(minin));
set(handles.MaxIntSlider,'Value',maxin);
set(handles.MaxIntBox,'String',num2str(maxin));
  
% --- Executes on update of MinIntBox  
function MinIntBox_Callback(hObject, eventdata, handles) %#ok<*INUSL>
 minin = str2double(get(handles.MinIntBox,'String'));
 set(handles.MinIntSlider,'Value',minin);
 scalecolor(hObject,handles);
 guidata(hObject, handles); 

 % --- Executes on update of MaxIntBox
function MaxIntBox_Callback(hObject, eventdata, handles)      
 maxin = str2double(get(handles.MaxIntBox,'String'));
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







%========================================================================%
%% GUI buttons for manipulating zooming, scrolling, recentering etc
%========================================================================%
function zoomin_Callback(hObject, eventdata, handles)
% hObject    handle to zoomin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SR
imaxes = SR{handles.gui_number}.imaxes;
imaxes.zm = imaxes.zm*2; 
if imaxes.zm > 128
    imaxes.zm = 128;
    disp('max zoom reached...');
end
SR{handles.gui_number}.imaxes = imaxes;
set(handles.displayzm,'String',num2str(imaxes.zm,2));
ImLoad(hObject,eventdata, handles);
guidata(hObject, handles);


% --- Executes on button press in zoomout.
function zoomout_Callback(hObject, eventdata, handles)
% hObject    handle to zoomout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SR
imaxes = SR{handles.gui_number}.imaxes;
imaxes.zm = imaxes.zm/2; 
if imaxes.zm < 1
    imaxes.zm = 1; % all the way out
    imaxes.cx = imaxes.W/2; % recenter
    imaxes.cy = imaxes.H/2;
end
set(handles.displayzm,'String',num2str(imaxes.zm,2));
SR{handles.gui_number}.imaxes = imaxes;
guidata(hObject, handles);
UpdateSliders(hObject,eventdata,handles);
ImLoad(hObject,eventdata, handles);
guidata(hObject, handles);


function displayzm_Callback(hObject, eventdata, handles)
% Execute on direct user input specific zoom value
global SR
imaxes = SR{handles.gui_number}.imaxes;
imaxes.zm = str2double(get(handles.displayzm,'String')); 
if imaxes.zm < 1
    imaxes.zm = 1; % all the way out
    imaxes.cx = imaxes.W/2; % recenter
    imaxes.cy = imaxes.H/2;
end
set(handles.displayzm,'String',num2str(imaxes.zm,2));
SR{handles.gui_number}.imaxes = imaxes;
guidata(hObject, handles);
UpdateSliders(hObject,eventdata,handles);
ImLoad(hObject,eventdata, handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function zoomtool_ClickedCallback(hObject, eventdata, handles)
% Zoom in on the boxed region specified by user selection of upper left and
% lower right coordinates.
% Inputs:
% hObject    handle to zoomtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SR scratchPath %#ok<NUSED>

imaxes = SR{handles.gui_number}.imaxes;
handles = guidata(hObject);
% user specifies box:
axes(handles.axes2); 
set(gca,'XTick',[],'YTick',[]);
% GetEdges(hObject, eventdata, handles)
[x,y] = ginput(2);  % These are relative to the current axis
xim = imaxes.xmin + x/imaxes.scale/imaxes.zm;
yim = imaxes.ymin + y/imaxes.scale/imaxes.zm;
imaxes.cx = mean(xim);  % this is relative to the whole image
imaxes.cy = mean(yim); % y is indexed bottom to top for plotting
xdiff = abs(xim(2) - xim(1));
ydiff = abs(yim(2) - yim(1));
imaxes.zm =   min(imaxes.W/xdiff, imaxes.H/ydiff); 
if imaxes.zm > 128
    imaxes.zm = 128;
    disp('max zoom reached...');
end
set(handles.displayzm,'String',num2str(imaxes.zm,2));
SR{handles.gui_number}.imaxes = imaxes;
UpdateSliders(hObject,eventdata,handles)

%  save([scratchPath,'test.mat']);
 % load([scratchPath,'test.mat']);

% plot box
axes(handles.axes2); hold on;
set(gca,'Xtick',[],'Ytick',[]);
rectangle('Position',[min(x),min(y),abs(x(2)-x(1)),abs(y(2)-y(1))],'EdgeColor','w'); hold off;
guidata(hObject, handles);
pause(.1); 
ImLoad(hObject,eventdata, handles);
guidata(hObject, handles);



%----------------------------------------------
function UpdateNavigator(hObject,handles)
global SR
imaxes = SR{handles.gui_number}.imaxes;
    axes(handles.axes1);
    set(gca,'Xtick',[],'Ytick',[]);
    hold on;
    hside= imaxes.H*imaxes.scale/imaxes.zm;
    wside = imaxes.W*imaxes.scale/imaxes.zm;
    lower_x = imaxes.scale*imaxes.cx-wside/2;
    lower_y = imaxes.scale*imaxes.cy-hside/2;
    prevbox = findobj(gca,'Type','rectangle');
    delete(prevbox); 
    rectangle('Position',[lower_x,lower_y,wside,hside],...
        'EdgeColor','w','linewidth',1); 
    set(gca,'Xtick',[],'Ytick',[]);
    hold off;
    guidata(hObject, handles);
% ------------------------------------------


% --------------------------------------------------------------------
function recenter_ClickedCallback(hObject, eventdata, handles)
% Recenter image over clicked location
% hObject    handle to recenter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SR
imaxes = SR{handles.gui_number}.imaxes;
handles = guidata(hObject);
axes(handles.axes2); 
[x,y] = ginput(1); % these are relative to the current frame
xim = imaxes.xmin + x/imaxes.scale/imaxes.zm;
yim = imaxes.ymin + y/imaxes.scale/imaxes.zm;
imaxes.cx = xim;  % these are relative to the whole image
imaxes.cy = yim;
SR{handles.gui_number}.imaxes = imaxes;
guidata(hObject, handles);
ImLoad(hObject,eventdata, handles);
guidata(hObject, handles);

function UpdateSliders(hObject,eventdata,handles)
global SR
imaxes = SR{handles.gui_number}.imaxes;
handles = guidata(hObject);
set(handles.Xslider,'Value',imaxes.cx);
set(handles.Yslider,'Value',imaxes.ymax-imaxes.cy+imaxes.ymin);
set(handles.Xslider,'Min',imaxes.xmin);
set(handles.Xslider,'Max',imaxes.xmax);
set(handles.Yslider,'Min',imaxes.ymin);
set(handles.Yslider,'Max',imaxes.ymax);
SR{handles.gui_number}.imaxes = imaxes;
UpdateNavigator(hObject,handles);
guidata(hObject, handles);

% --- Executes on slider movement.
function Yslider_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global SR
imaxes = SR{handles.gui_number}.imaxes;
imaxes.cy = imaxes.ymax - get(handles.Yslider,'Value')+imaxes.ymin;
% imaxes.cy = get(handles.Yslider,'Value');
SR{handles.gui_number}.imaxes = imaxes;
ImLoad(hObject,eventdata, handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function Yslider_CreateFcn(hObject, eventdata, handles)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function Xslider_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global SR
SR{handles.gui_number}.imaxes.cx = get(handles.Xslider,'Value');
ImLoad(hObject,eventdata, handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Xslider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end





%% 3D Plotting Options
% --------------------------------------------------------------------
function Render3D_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Render3D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global SR scratchPath
I = SR{handles.gui_number}.I;
imaxes = SR{handles.gui_number}.imaxes;
% currently hard-coded, should be user options 
npp =SR{handles.gui_number}.DisplayOps.npp; 
zrange = SR{handles.gui_number}.DisplayOps.zrange; % = [-600,600];

if SR{handles.gui_number}.DisplayOps.ColorZ && SR{handles.gui_number}.DisplayOps.Zsteps > 1
    disp('use cell arrays of parameters for multichannel rendering'); 
    disp('see help Im3D for more options'); 

    dlg_title = 'Render3D. Group multichannel options in {}';
    num_lines = 1;

        Dprompt = {
        'threshold (blank for auto)',...
        'downsample',...
        'smoothing (must be odd integer)',...
        'color',...
        'alpha'};
    try
        default_Dopts = SR{handles.gui_number}.default_Dopts;
        opts = inputdlg(Dprompt,dlg_title,num_lines,default_Dopts);
    catch %#ok<CTCH>
        default_Dopts = {
        '[]',...
        '3',...
        '3',...
        'blue',...
        '1'};
        opts = inputdlg(Dprompt,dlg_title,num_lines,default_Dopts);
    end

    if ~isempty(opts)
        SR{handles.gui_number}.default_Dopts  = opts;
        Zs = SR{handles.gui_number}.DisplayOps.Zsteps;

        xyp = npp/imaxes.scale/imaxes.zm; % nm per x/y pixel
        zstp = (zrange(2)-zrange(1))/Zs;

        theta = eval(opts{1});
        stp = eval(opts{2});
        res = eval(opts{3});
        colr = opts{4}; 
        Cs = length(I);

        channels = zeros(1,Cs); % Storm Channels
        for c = 1:Cs; 
            channels(c) = eval(['get(','handles.sLayer',num2str(c),', ','''Value''',')']);
        end
        
        active_channels = find(channels);
        figure; clf; 
        Im3D(I(active_channels),'resolution',res,'zStepSize',zstp,'xyStepSize',xyp,...
            'theta',theta,'downsample',stp,'color',colr); %#ok<FNDSB> % NOT equiv! 
        set(gcf,'color','w');
        camlight left;
        xlabel('nm');
        ylabel('nm');
        zlabel('nm');
        xlim([0,(imaxes.xmax-imaxes.xmin)*npp]);
        ylim([0,(imaxes.ymax-imaxes.ymin)*npp]);
        alpha( eval(opts{5}) ); 
    end
else
    disp('must set Display Ops color Z to true for 3D rendering'); 
    disp('Go to "More Display Ops" and set first field as "true"');
end



% --------------------------------------------------------------------
function Rotate3Dslices_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Rotate3Dslices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global  SR
I=SR{handles.gui_number}.I;
imaxes = SR{handles.gui_number}.imaxes;
% currently hard-coded, should be user options 
npp =SR{handles.gui_number}.DisplayOps.npp; % npp 
zrange = SR{handles.gui_number}.DisplayOps.zrange; %  [-600,600];

if SR{handles.gui_number}.DisplayOps.ColorZ && SR{handles.gui_number}.DisplayOps.Zsteps > 1
dlg_title = 'Render3D';
num_lines = 1;

    Dprompt = {
    'threshold (blank for auto)',...
    'downsample'};
    default_Dopts = {
    '[]',...
    '3'};

opts = inputdlg(Dprompt,dlg_title,num_lines,default_Dopts);

Zs = SR{handles.gui_number}.DisplayOps.Zsteps;
xyp = npp/imaxes.scale/imaxes.zm; % nm per x/y pixel
zstp = (zrange(2)-zrange(1))/Zs;

theta = eval(opts{1});
stp = str2double(opts{2});


figure; clf; 
Im3Dslices(I,'zStepSize',zstp,'xyStepSize',xyp,...
    'theta',theta,'downsample',stp,'coloroffset',0);
set(gcf,'color','w');
xlabel('x-position (nm)');
ylabel('y-position (nm)');
zlabel('z-position (nm)');
xlim([0,(imaxes.xmax-imaxes.xmin)*npp]);
ylim([0,(imaxes.ymax-imaxes.ymin)*npp])

else
    disp('must set Display Ops color Z to true for 3D rendering'); 
    dips('Go to "More Display Ops" and set first field as "true"');
end

% make coloroffset larger than largest intensity of previous image to have
% stacked dots rendered in different intensities.  

% --------------------------------------------------------------------
function plot3Ddots_ClickedCallback(hObject, eventdata, handles)
global SR scratchPath

if ~isfield(SR{handles.gui_number},'plt3Dfig')
SR{handles.gui_number}.plt3Dfig =[];
end

npp = 160; % should be a global in imageops or something
vlist = MolsInView(handles);
chns = find(cellfun(@(x) ~isempty(x),vlist))';
Cs = length(chns); 
cmap = hsv(Cs);
lab = cell(Cs,1);
if ~isempty(SR{handles.gui_number}.plt3Dfig)
    if ishandle(SR{handles.gui_number}.plt3Dfig)
        close(SR{handles.gui_number}.plt3Dfig);
    end
end
SR{handles.gui_number}.plt3Dfig = figure; 

for c = chns
    if length(vlist{c}.x) > 2000
        msize = 1;
    else
        msize = 5; 
    end
    plot3(vlist{c}.xc*npp,vlist{c}.yc*npp,vlist{c}.zc*npp,'.','color',cmap(c,:),...
        'MarkerSize',msize);
    lab{c} = ['channel ',num2str(c)', ' # loc:',num2str(length(vlist{c}.x))];
    hold on;
end
xlabel('x (nm)'); ylabel('y (nm)'); zlabel('z (nm)'); 
title(lab); 


% --------------------------------------------------------------------
function plotColorByFrame_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to plotColorByFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SR scratchPath

if ~isfield(SR{handles.gui_number},'pltColorByFramefig')
SR{handles.gui_number}.pltColorByFramefig =[];
end

npp = 160; % should be a global in imageops or something
vlist = MolsInView(handles);
chns = find(cellfun(@(x) ~isempty(x),vlist))';
Cs = length(chns); 
lab = cell(Cs,1);
if ~isempty(SR{handles.gui_number}.pltColorByFramefig)
    if ishandle(SR{handles.gui_number}.pltColorByFramefig)
        close(SR{handles.gui_number}.pltColorByFramefig);
    end
end
SR{handles.gui_number}.pltColorByFramefig = figure; 

for c = chns
    if length(vlist{c}.x) > 2000
        msize = 1;
    else
        msize = 5; 
    end
    subplot(length(chns),1,c);
            %  Indicate color as time. 
        dxc = vlist{c}.xc;
        dyc = vlist{c}.yc;
        numDots = length(vlist{c}.frame);
        normFrames = vlist{c}.frame - min(vlist{c}.frame);
        normFrames = normFrames*numDots/(max(normFrames))+1;
        cmp = jet(numDots+1); % create the color maps changed as in jet color map
        cmp = cmp(normFrames,:);
        scatter(dxc*npp, dyc*npp, msize, cmp, 'filled');
        set(gcf,'color','w'); 
        xlabel('nm'); 
        ylabel('nm'); 
end
xlabel('x (nm)'); ylabel('y (nm)');
title(lab); 


% load([scratchPath,'test.mat']);



% --------------------------------------------------------------------
function plot2Ddots_ClickedCallback(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>
global SR scratchPath

if ~isfield(SR{handles.gui_number},'plt3Dfig')
SR{handles.gui_number}.plt3Dfig =[];
end

npp = 160; % should be a global in imageops or something
vlist = MolsInView(handles);
chns = find(cellfun(@(x) ~isempty(x),vlist))';
Cs = length(chns); 
cmap = hsv(Cs);
lab = cell(Cs,1);
if ~isempty(SR{handles.gui_number}.plt3Dfig)
    if ishandle(SR{handles.gui_number}.plt3Dfig)
        close(SR{handles.gui_number}.plt3Dfig);
    end
end
SR{handles.gui_number}.plt3Dfig = figure; 

for c = chns
    if length(vlist{c}.x) > 2000
        msize = 1;
    else
        msize = 5; 
    end
    plot(vlist{c}.xc*npp,vlist{c}.yc*npp,'.','color',cmap(c,:),...
        'MarkerSize',msize);
    lab{c} = ['channel ',num2str(c)', ' # loc:',num2str(length(vlist{c}.x))];
    hold on;
end
xlabel('x (nm)'); ylabel('y (nm)');
title(lab); 


    
    
function vlist = MolsInView(handles)
% return just the portion of the molecule list in the fied of view; 
   
    global SR 
    infilter = SR{handles.gui_number}.infilter;
    imaxes = SR{handles.gui_number}.imaxes;
     mlist = SR{handles.gui_number}.mlist;
     
     Cs = length(mlist); 
    channels = zeros(1,Cs); % Storm Channels
    for c = 1:Cs; 
       channels(c) = eval(['get(','handles.sLayer',num2str(c),', ','''Value''',')']);
    end
    active_channels = find(channels);

    vlist = cell(Cs,1);
    
    for c=active_channels;
      if length(mlist{c}.x) >1
         vlist{c} = msublist(mlist{c},imaxes,'filter',infilter{c});
         vlist{c}.channel = c; 
         vlist{c}.infilter = infilter{c};
         vlist{c}.locinfilter = infilter{c}(infilter{c} & vlist{c}.inbox);
      end
    end  
  
%=========================================================================%









%% Other






     
        


% --------------------------------------------------------------------
function saveimage_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to saveimage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SR
Io = SR{handles.gui_number}.Io;
[filename,pathname] = uiputfile;
tiffwrite(Io,[pathname,filesep,filename]);


function datapath_Callback(hObject, eventdata, handles)
global SR
SR{handles.gui_number}.LoadOps.pathin = get(handles.datapath,'String');
guidata(hObject,handles); 


function datapath_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function CustomFilter_Callback(hObject, eventdata, handles)

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

% --- Executes on button press in fchn2.
function fchn2_Callback(hObject, eventdata, handles)

% --- Executes on button press in fchn4.
function fchn4_Callback(hObject, eventdata, handles)

% --- Executes on button press in fchn3.
function fchn3_Callback(hObject, eventdata, handles)

% --- Executes on button press in fchn1.
function fchn1_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function chn4_CreateFcn(hObject, eventdata, handles)

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


% --- Executes on button press in logscalecolor.
function logscalecolor_Callback(hObject, eventdata, handles)

    
 
    
  

    
%% 
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
global SR binfile

if ~isfield(SR{handles.gui_number},'Overlay_opts')
    SR{handles.gui_number}.Overlay_opts = [];
end
Overlay_opts =  SR{handles.gui_number}.Overlay_opts ;
if ~isfield(SR{handles.gui_number},'O')
    SR{handles.gui_number}.O = [];
end

% ------------- load image
% open dialog box to decide whether image should be flipped or rotated
dlg_title = 'Set Load Options';
num_lines = 1;
  Overlay_prompt = {
    'Image selected (leave blank to select with getfile prompt)',...
    'Flip Vertical',...
    'Flip Horizontal',...
    'Rotate by N degrees'...
    'horizontal shift'...
    'vertical shift'...
    'channels'...
    'Max frames (for Daxfiles)',...
    'Overlay Layer (leave blank to add new layer)',...
    'Contrast',...
    'Channel for chromatic warp (blank for no warp)'};

try
Overlay_opts = inputdlg(Overlay_prompt,dlg_title,num_lines,Overlay_opts);
catch er 
    % reset 
    disp(er.message)
    Overlay_opts = {
    '',...
    'false',...
    'false',...
    '0',...
    '0',...
    '0',...
    '[]',...
    '4',...
    '',...
    '[0,.3]',...
    ''};
    Overlay_opts = inputdlg(Overlay_prompt,dlg_title,num_lines,Overlay_opts);
end

if ~isempty(Overlay_opts) % Load Overlay Not canceled

    if isempty(Overlay_opts{1})
        
        if ~isempty(SR{handles.gui_number}.LoadOps.pathin)
            startfolder = SR{handles.gui_number}.LoadOps.pathin;
        elseif ~isempty(binfile)
            startfolder = extractpath(binfile);
        else
            startfolder = pwd;
        end
        
        
    [filename,pathname,selected] = uigetfile(...
        {'*.dax;*.jpg;*.png;*.tif','Image files (*.dax, *.jpg, *.png, *.tif)';
        '*.dax','DAX (*.dax)';
        '*.jpg', 'JPEGS (*.jpg)';
        '*.tif', 'TIFF (*.tif)';
        '*.png', 'PNG (*.png)';
        '*.*', 'All Files (*.*)'},...
        'Choose an image file to overlay',...
        startfolder); % prompts user to select directory 
    sourcename = [pathname,filesep,filename];
    Overlay_opts{1} = sourcename;
    else 
        selected = 1;
    end
    
    if selected~=0;
        k = strfind(Overlay_opts{1},'.dax');
        if isempty(k)
            tempO = imread(Overlay_opts{1}); % load image file;
        else  % For DAX files
            tempO = ReadDax(Overlay_opts{1},'endFrame',Overlay_opts{8});
            tempO = uint16(mean(tempO,3));  %average all frames loaded.   might cause problems
        end
        
        if ~isempty(Overlay_opts{11})
           if isempty(SR{handles.gui_number}.LoadOps.warpfile)
                if ~isempty(SR{handles.gui_number}.LoadOps.pathin)
                    startfolder = SR{handles.gui_number}.LoadOps.pathin;
                elseif ~isempty(binfile)
                    startfolder = extractpath(binfile);
                else
                    startfolder = pwd;
                end
              [filename,pathname,selected] = uigetfile({'*.mat'},'Select Warpfile',startfolder);
              SR{handles.gui_number}.LoadOps.warpfile = [pathname,filesep,filename];
           end
            if selected
                tempO = WarpImage(tempO,Overlay_opts{11},SR{handles.gui_number}.LoadOps.warpfile);
            end
        end
        
        Noverlays = length(SR{handles.gui_number}.O);
        if isempty(Overlay_opts{9})
            SR{handles.gui_number}.O{Noverlays+1} = tempO; 
            overlay_number = length(SR{handles.gui_number}.O);%  ;
        else
            overlay_number =  eval(Overlay_opts{9});
            SR{handles.gui_number}.O{overlay_number} = tempO;
        end

        % Still need to address contrast for overlays
        imcaxis = eval(Overlay_opts{10});
        SR{handles.gui_number}.omin(overlay_number) = imcaxis(1);
        SR{handles.gui_number}.omax(overlay_number) = imcaxis(2);
        [~,filename] = extractpath(Overlay_opts{1});
        SR{handles.gui_number}.Overlay_opts = Overlay_opts ;

        % Add to Overlays List
        handles = AddOverlayLayer(hObject,handles,overlay_number,filename);
        guidata(hObject, handles);
        IntegrateOverlay(hObject,handles);
    end
end



    %~~~~~~~
    function handles = AddOverlayLayer(hObject,handles,overlay_number,oname)
        % Adds a new radio button to the OverlayPanel, which can toggle this
        % channel on and off.  
    global SR
    
    
verbose = SR{handles.gui_number}.DisplayOps.verbose;
if verbose
disp(['Adding New Overlay ',num2str(overlay_number)]);
end

% Make button visible
buttonName = ['handles.oLayer',num2str(overlay_number)];
makeVisible = ['set(',buttonName,', ','''Visible''',', ','''on''',')'];
buttonPress = ['set(',buttonName,', ','''Value''',', ','true',')'];
updateName =  ['set(',buttonName,', ','''String''',', ','''',oname,'''',')'];
eval(makeVisible); 
eval(buttonPress); 
eval(updateName); 
guidata(hObject, handles);

SR{handles.gui_number}.OverlayNames{overlay_number} = oname;  

% update levels
N_stormlayers = length(SR{handles.gui_number}.cmax);
LevelsNames = get(handles.LevelsChannel,'String');
LevelsNames{N_stormlayers+overlay_number} = oname;
set(handles.LevelsChannel,'String',LevelsNames);

    
                 
    %---------------------------------------------------------------------
    % IntegrateOverlay into field of view
    %    - subfunction of MenuOverlay, also called each time image resizes
    %    in order to maintain overlay display.  
    function IntegrateOverlay(hObject,handles)
    global   SR scratchPath  %#ok<NUSED>
    if isfield(SR{handles.gui_number},'Overlay_opts');
    Overlay_opts =  SR{handles.gui_number}.Overlay_opts;
    imaxes = SR{handles.gui_number}.imaxes;
    for n=1:length(SR{handles.gui_number}.O);
        if ~isempty(SR{handles.gui_number}.O{n})
        SR{handles.gui_number}.Oz{n} = fxn_AddOverlay(SR{handles.gui_number}.O{n},imaxes,...
            'flipV',eval(Overlay_opts{2}),'flipH',eval(Overlay_opts{3}),...
            'rotate',eval(Overlay_opts{4}),'xshift',eval(Overlay_opts{5}),...
            'yshift',eval(Overlay_opts{6}),'channels',eval(Overlay_opts{7}) ); 
       % figure(4); clf; imagesc(I{imlayer});
        UpdateMainDisplay(hObject,handles);
        end
    end
    end

   
    
% --------------------------------------------------------------------
function MenuDisplayOps_Callback(hObject, eventdata, handles)
% hObject    handle to MenuSR{handles.gui_number}.DisplayOps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SR

dlg_title = 'More Display Options';
num_lines = 1;
Dprompt = {
    'Display Z as color',...
    'Number of Z-steps',...
    'Z range (nm)',...
    'hide poor z-fits',...
    'Dot scale',...
    'scalebar (0 for off)',...
    'nm per pixel',...
    'verbose'...
    'Correct image drift',...
    'Color map'};
default_Dopts{1} = num2str(SR{handles.gui_number}.DisplayOps.ColorZ);
default_Dopts{2} = num2str(SR{handles.gui_number}.DisplayOps.Zsteps);
default_Dopts{3} = strcat('[',num2str(SR{handles.gui_number}.DisplayOps.zrange),']');
default_Dopts{4} = num2str(SR{handles.gui_number}.DisplayOps.HidePoor);
default_Dopts{5} = strcat('[',num2str(SR{handles.gui_number}.DisplayOps.DotScale),']');
default_Dopts{6} = num2str(SR{handles.gui_number}.DisplayOps.scalebar);
default_Dopts{7} = num2str(SR{handles.gui_number}.DisplayOps.npp);
default_Dopts{8} = num2str(SR{handles.gui_number}.DisplayOps.verbose); 
default_Dopts{9} = num2str(SR{handles.gui_number}.DisplayOps.CorrDrift);
default_Dopts{10} = num2str(SR{handles.gui_number}.DisplayOps.clrmap);
% if the menu is screwed up, reset 
try
default_Dopts = inputdlg(Dprompt,dlg_title,num_lines,default_Dopts);
catch er
    disp(er.message)
    default_Dopts = {
    'false',...
    '8',...
    '[-500,500]',...
    'false',...
    '4',...
    '500',...
    '160',...
    'true',...
    'true',...
    'hsv'};
end
if length(default_Dopts) > 1 % Do nothing if canceled
    SR{handles.gui_number}.DisplayOps.ColorZ = eval(default_Dopts{1}); 
    SR{handles.gui_number}.DisplayOps.Zsteps = eval(default_Dopts{2});
    SR{handles.gui_number}.DisplayOps.zrange = eval(default_Dopts{3});
    SR{handles.gui_number}.DisplayOps.HidePoor = eval(default_Dopts{4});
    SR{handles.gui_number}.DisplayOps.DotScale = eval(default_Dopts{5});
    SR{handles.gui_number}.DisplayOps.scalebar = eval(default_Dopts{6});
    SR{handles.gui_number}.DisplayOps.npp = eval(default_Dopts{7});
    SR{handles.gui_number}.DisplayOps.verbose = eval(default_Dopts{8});
    SR{handles.gui_number}.DisplayOps.CorrDrift= eval(default_Dopts{9});
    SR{handles.gui_number}.DisplayOps.clrmap = default_Dopts{10};
    ImLoad(hObject,eventdata, handles);
    guidata(hObject, handles);
end


% --------------------------------------------------------------------
function MenuViewMosaic_Callback(hObject, eventdata, handles)
% hObject    handle to MenuViewMosaic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global  SR
if ~isfield(SR{handles.gui_number}, 'Mosaicfolder')
    SR{handles.gui_number}.Mosaicfolder = [];
end
infofile = SR{handles.gui_number}.infofile;
if isempty(SR{handles.gui_number}.Mosaicfolder)
    SR{handles.gui_number}.Mosaicfolder = [infofile.localPath,filesep,'..',filesep,'Mosaic'];
    if ~exist(SR{handles.gui_number}.Mosaicfolder,'dir')
        SR{handles.gui_number}.Mosaicfolder = uigetdir(infofile.localPath);
    end
end    
position = [infofile.Stage_X,infofile.Stage_Y];


try
    figure;
    viewSteveMosaic(SR{handles.gui_number}.Mosaicfolder,position,'showbox',true,'Ntiles',100);
catch er
    disp(er.message); 
    disp('trying old MosaicViewer...');
    MosaicViewer(SR{handles.gui_number}.Mosaicfolder,position,'showbox',true,'Ntiles',6);
    figure;
    MosaicViewer(SR{handles.gui_number}.Mosaicfolder,position,'showbox',true,'Ntiles',36);
end
    
%%

% --------------------------------------------------------------------
function MenuColors_Callback(hObject, eventdata, handles)
% hObject    handle to MenuColors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.axes2,'BusyAction','cancel');
axes(handles.axes2); cla;


% % 





% --- Executes during object creation, after setting all properties.
function LevelsChannel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LevelsChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





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
%--------------------------------------------------------------------------
% feducialDriftCorrection(binname)
% feducialDriftCorrection(mlist)
% feducialDriftCorrection([],'daxname',daxname,'mlist',mlist,...);
%
%--------------------------------------------------------------------------
% Required Inputs
%
% daxname / string - name of daxfile to correct drift
% or 
% mlist / structure 
% 
%--------------------------------------------------------------------------
% Optional Inputs
% 
% 'startframe' / double / 1  
%               -- first frame to find feducials in
% 'maxdrift' / double / 2.5 
%               -- max distance a feducial can get from its starting 
%                  position and still be considered the same molecule
% 'integrateframes' / double / 500
% 'fmin' / double / .5
%               -- fraction of frames which must contain feducial
% 'nm per pixel' / double / 158 
%               -- nm per pixel in camera
% 'showplots' / boolean / true
% 'showextraplots' / boolean / false
% 
global SR scratchPath

mlist = SR{handles.gui_number}.mlist;

for c = 1:length(mlist) 
dlg_title = 'Feducial Drift Correction Options';
num_lines = 1;
Dprompt = {
    'feducial binfile (STORM-chn or binfile string)',... 1
    'correct STORM chn: ',... 2
    'start frame (1 = first appearance)',...        3
    'max drift (pixels)',...          4
    'integrate frames (smoothing localization noise)',...   5
    'min fraction of frames ',...              6
    'nm per pixel',...      7 
    'show plots',...          8
    'show extra plots',...   9
    'frame to ID feducials (1 = first appearance)',...
    'correct back from previous channels'};       
Opts{1} = '';
Opts{2} = ''; % ['[',num2str(1:length(mlist)),']'];
Opts{3} = num2str(1);
Opts{4} = num2str(2.5);
Opts{5} = num2str(500);
Opts{6} = num2str(0.7);
Opts{7} = num2str(SR{handles.gui_number}.DisplayOps.npp);
Opts{8} = 'true';
Opts{9} = 'false';
Opts{10} = num2str(1);
Opts{11} = 'true';
Opts = inputdlg(Dprompt,dlg_title,num_lines,Opts);

if length(Opts) > 1 % Do nothing if cancelled      
    if isempty(Opts{1})
        startfolder = SR{handles.gui_number}.LoadOps.pathin;
        if isempty(startfolder)
            startfolder = extractpath(SR{handles.gui_number}.infofile.localPath);
        end
        [filename,pathname,selected] = uigetfile(...
            {'*.bin', 'Molecule List (*.bin)';
            '*.*', 'All Files (*.*)'},...
            ['Choose bin file with feducials for chn ',num2str(c)],...
            startfolder); % prompts user to select directory 
        if selected > 0
            sourcename = [pathname,filesep,filename];
        end
    end
    
    %  save([scratchPath,'test.mat']); 
    % load([scratchPath,'test.mat']); 
    
    [dxc,dyc] = feducialDriftCorrection(sourcename,...        
        'startframe',eval(Opts{3}),...     3
        'maxdrift',eval(Opts{4}),...          4
        'integrateframes',eval(Opts{5}),...
        'fmin',eval(Opts{6}),...
        'nm per pixel',eval(Opts{7}),...
        'showplots',eval(Opts{8}),...
        'showextraplots',eval(Opts{9}),...
        'spotframe',eval(Opts{10}) );
       
    % record drift in this channel.  Calc drift from previous channels
   SR{handles.gui_number}.driftData{c}.xDrift = nonzeros(dxc);
   SR{handles.gui_number}.driftData{c}.yDrift = nonzeros(dyc);
   if eval(Opts{11}) && c>1
    prevXdrift = [0,SR{handles.gui_number}.driftData{1:c-1}.xDrift(end)];
    prevYdrift = [0,SR{handles.gui_number}.driftData{1:c-1}.yDrift(end)]; 
   else
    prevXdrift = 0; 
    prevYdrift = 0;
   end
    mlist{c}.xc = mlist{c}.x - dxc(mlist{c}.frame) - sum(prevXdrift);
    mlist{c}.yc = mlist{c}.y - dyc(mlist{c}.frame) - sum(prevYdrift); 
end  
   
end
% Need to reapply chromewarps 
if length(mlist) > 1
mlist = ApplyChromeWarp(mlist,SR{handles.gui_number}.LoadOps.chns,...
        SR{handles.gui_number}.LoadOps.warpfile,...
        'warpD',SR{handles.gui_number}.LoadOps.warpD,...
        'names',SR{handles.gui_number}.fnames); 
end
SR{handles.gui_number}.mlist = mlist;
ImLoad(hObject,eventdata, handles);



% --------------------------------------------------------------------
function MenuCorrelDrift_Callback(hObject, eventdata, handles)
% hObject    handle to MenuCorrelDrift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%--------------------------------------------------------------------------
% mlist = XcorrDriftCorrect(binfile)
% mlist = XcorrDriftCorrect(mlist)
%
%--------------------------------------------------------------------------
% Required Inputs
% mlist (molecule list structure)
% OR
% binfile (string)
% 
%
%--------------------------------------------------------------------------
% Optional Inputs
% 'imagesize' / double 2-vector / [256 256] -- size of image
% 'scale' / double / 5 -- upsampling factor for binning localizations
% 'stepframe' / double / 10E3 -- number of frames to average
% 'nm per pixel' / double / 158 -- nm per pixel in original data
% 'showplots' / logical / true -- plot computed drift?
%--------------------------------------------------------------------------
% Outputs
% mlist (molecule list structure) 
%           -- mlist.xc and mlist.yc are overwritten with the new drift
%           corrected values.  
% 
%--------------------------------------------------------------------------
global SR scratchPath

%--------------------------------------------------------------------------
% Get parameters: 
imagesize = [SR{handles.gui_number}.imaxes.H,...
    SR{handles.gui_number}.imaxes.W];


dlg_title = 'Correlation-based Drift Correction';
num_lines = 1;
Dprompt = {
    'stepframe',... 1
    'channel',... 2
    'scale',...        3
    'nm per pixel',...
    'showplots',...
    'use only current ROI'};     %5   
Opts{1} = num2str(6E3);
Opts{2} = num2str(1);
Opts{3} = num2str(4);
Opts{4} = num2str(SR{handles.gui_number}.DisplayOps.npp);
Opts{5} = 'true';
Opts{6} = 'true';
Opts = inputdlg(Dprompt,dlg_title,num_lines,Opts);

if ~isempty(Opts)
    c = str2double(Opts{2});
    mlist = SR{handles.gui_number}.mlist;

    if eval(Opts{6})
              vlist = MolsInView(handles);
              % imaxes = SR{handles.gui_number}.imaxes;  
              % H = imaxes.ymax - imaxes.ymin + 1;
              % W = imaxes.xmax - imaxes.xmin + 1; 
               H = vlist{c}.imaxes.H;
               W = vlist{c}.imaxes.W;
               npp = SR{handles.gui_number}.DisplayOps.npp;

              [dxc,dyc] = XcorrDriftCorrect(vlist{c},...
                 'stepframe',eval(Opts{1}),...
                'scale',eval(Opts{2}),'showplots',eval(Opts{3}),...    
                'imagesize',[H,W],'nm per pixel',npp);  
            % local area may not have dots localized up through the last frame
            % of the movie.  Just assume no drift for these final frames if
            % doing local region based correction.  (They should only be a
            % couple to couple dozen of frames = a few seconds of drift at most).
            dxc = [dxc,zeros(1,max(mlist{c}.frame)-max(vlist{c}.frame))];
            dyc = [dyc,zeros(1,max(mlist{c}.frame)-max(vlist{c}.frame))];
    else
        [dxc,dyc] =  XcorrDriftCorrect( ...
            SR{handles.gui_number}.mlist{ c },...
            'imagesize',imagesize,...
            'scale',eval(Opts{3}),...
            'stepframe',eval(Opts{1}),...
            'nm per pixel',eval(Opts{4}),...
            'showplots',eval(Opts{5}) ); 
    end
    mlist{c}.xc = mlist{c}.x - dxc(mlist{c}.frame)';
    mlist{c}.yc = mlist{c}.y - dyc(mlist{c}.frame)';  
    SR{handles.gui_number}.mlist = mlist;
    ImLoad(hObject,eventdata, handles);
end
 


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
