function varargout = STORMrenderBeta(varargin)
% STORMRENDERBETA MATLAB code for STORMrenderBeta.fig
%      STORMRENDERBETA, by itself, creates a new STORMRENDERBETA or raises the existing
%      singleton*.
%
%      H = STORMRENDERBETA returns the handle to a new STORMRENDERBETA or the handle to
%      the existing singleton*.
%
%      STORMRENDERBETA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STORMRENDERBETA.M with the given input arguments.
%
%      STORMRENDERBETA('Property','Value',...) creates a new STORMRENDERBETA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before STORMrenderBeta_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to STORMrenderBeta_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help STORMrenderBeta

% Last Modified by GUIDE v2.5 13-Feb-2013 17:59:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @STORMrenderBeta_OpeningFcn, ...
                   'gui_OutputFcn',  @STORMrenderBeta_OutputFcn, ...
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


% --- Executes just before STORMrenderBeta is made visible.
function STORMrenderBeta_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to STORMrenderBeta (see VARARGIN)

global DisplayOps binfile
DisplayOps.ColorZ = false; 
DisplayOps.Zsteps = 5;
DisplayOps.DotScale = 4;
DisplayOps.HidePoor = false;

% Choose default command line output for STORMrenderBeta
handles.output = hObject;

% avoid startup error
set(handles.Yslider,'Value',0);
set(handles.Yslider,'Min',-256);
set(handles.Yslider,'Max',256);

% set up axes for plotting
 axes(handles.axes1); 
 set(gca,'color','k');
 set(gca,'XTick',[],'','YTick',[]);
 axes(handles.axes2); 
 set(gca,'color','k');
set(gca,'XTick',[],'YTick',[]);
 axes(handles.axes3); 
 set(gca,'color','w');
set(gca,'XTick',[],'YTick',[]);
% build dropdown menu
molfields = {'custom';'region';'z';'h';'a';'i';'w'};
set(handles.choosefilt,'String',molfields);


set(handles.MaxIntSlider,'Max',1);
set(handles.MaxIntSlider,'Min',0);
set(handles.MaxIntSlider,'Value',1);
set(handles.MaxIntSlider,'SliderStep',[1/2^12,1/2^4])
set(handles.MinIntSlider,'Max',1);
set(handles.MinIntSlider,'Min',0);
set(handles.MinIntSlider,'Value',0); 
set(handles.MinIntSlider,'SliderStep',[1/2^12,1/2^4])

if ~isempty(binfile)
    QuickLoad_Callback(hObject, eventdata, handles);
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes STORMrenderBeta wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = STORMrenderBeta_OutputFcn(hObject, eventdata, handles) 
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
function QuickLoad_Callback(hObject, eventdata, handles)

 
axes(handles.axes2); cla; 
clear global mlist fnames;
global mlist fnames binfile
if isempty(binfile)
   [filename,pathname] = uigetfile('*.bin');
   binfile = [pathname,filesep,filename];
end
mlist{1} = ReadMasterMoleculeList(binfile);
fnames{1} = binfile; 
disp('file loaded'); 

imsetup(hObject,eventdata, handles);
ClearFilters_Callback(hObject, eventdata, handles); 
guidata(hObject, handles);



% --- Executes on button press in SetLoadOps.-----------------------------
function SetLoadOps_Callback(hObject, eventdata, handles)
   % Configure load options for multichannel loading 
    
global loadops prompt default_opts froots bins
if ~isempty(froots)
    disp(froots)
end
dlg_title = 'Set Load Options';
num_lines = 1;
try
default_opts = inputdlg(prompt,dlg_title,num_lines,default_opts);
catch er
    disp(er.message)
    prompt = {
    'Source Root',...
    'Image Number',...
    'Correct Drift to channel 1, frame 1?:',...
    'Apply chromatic warp?:',...
    'Warp dimension (2, 3 or 2.5)',...
    'Exlude bad z-fits for channel 1:4',...
    'binflag (_list.bin or _alist.bin)',...
    'channels'};
    default_opts = {'',...
    '1',...
    'true',...
    'true',...
    '3',...
    '[false,true,true,true]',...
    '_list.bin',...
    '750,647,561,488'}; 
end

loadops = default_opts; 
for n=[2:6,8]
    loadops{n} = eval(default_opts{n}); % saves a lot of str2double later.  
end
loadops{8} = parseCSL(loadops{8});


% parse pathin (whether it's a filename or a folder, we want the folder)
    pathin = get(handles.datapath,'String');
    f = strfind(pathin,'.');
    if ~isempty(f)
        f = strfind(pathin,'\');
        pathin = pathin(1:f(end));
    end
    set(handles.datapath,'String',pathin);
    disp(['searching for bin files in ', pathin,'...'])


  % Automatically group all bin files of same section in different colors
  %   based on image number. 
    [bins,froots] = automatch_files(pathin,'sourceroot',loadops{1},'filetype',loadops{7},'chns',loadops{8});
    disp('files found and grouped:'); 
    disp(bins(:));

    disp('will load');
    fname = froots(:,loadops{2});
    disp(fname);


% --- Executes on button press in MultiColorLoad.
function MultiColorLoad_Callback(hObject, eventdata, handles)
global loadops mlist fnames froots bins


  % Search for the correct chromatic warp file if chromatic warp is desired
    if loadops{4}
        warpD = loadops{5};
        
        
        if warpD == 3 || 2.5
            sfile = 'tforms3D.mat';
        elseif warD == 2
            sfile = 'tforms2D.mat';
        end
        maxup = 1; % levels below the root directory to restrict search. 
        % If this is not an external drive make this large or use with care. 
        disp('searching for chromatic warp files...')
        Bead_folder = findfile(pathin,sfile,maxup); % function that does the search
        if isempty(Bead_folder) 
            loadops{4} = false;
            disp(['no ,' sfile,' file found for chromatic warp']);
            disp('skipping chromatic correction'); 
        end
    else
        Bead_folder = [];
    end 

    i = loadops{2}; % im number

  % Figure out which channels are really in data set  
    hasdata = logical(1-cellfun(@isempty, bins(:,i)));
    binnames =  bins(hasdata,i); % length cls must equal length binnames
    fnames = froots(hasdata,i); 
    disp(fnames);
    axes(handles.axes2); 
    set(handles.imtitle,'String',fnames(:)); % ,'interpreter','none');  
    chns = loadops{8}(hasdata); 
    if sum((logical(1-hasdata))) ~=0
        disp('no data found for in channels:');
        disp(loadops{8}(logical(1-hasdata)))
    end
  % combine folder with binnames in order to call DriftCorrect / binload
    [Tchns,~] = size(binnames);
    allbins = cell(Tchns,1); 
    for c=1:Tchns
            allbins{c} = strcat(pathin,filesep,binnames{c});
    end

% Apply global drift correction, then return loaded mlist file.
% Then apply chromewarp.  
    mlist = MultiChnDriftCorrect(allbins);
if loadops{4}
    for c=1:length(mlist)
        mlist{c} = chromewarp(chns(c),mlist{c},Bead_folder,'warpD',loadops{5});
    end
end
    % Cleanup settings from any previous data and render image:
    imsetup(hObject,eventdata, handles);
    ClearFilters_Callback(hObject, eventdata, handles); 
    guidata(hObject, handles);
    % save('C:\Users\Alistair\Documents\Projects\General_STORM\Test_data\test.mat');
    % load('C:\Users\Alistair\Documents\Projects\General_STORM\Test_data\test.mat');



% --------------------------------------------------------------------
function openfile_ClickedCallback(hObject, eventdata, handles)
    sourcepath = uigetdir;
    set(handles.datapath,'String',sourcepath);
    clear global Im; % clear mosaic if path has changed
    clear global stage;
    guidata(hObject, handles);
    
    % % to set file instead of path, use: 
    %  [filename,pathname] = uigetfile('*.bin'); % prompts user to select directory 
    %  sourcename = [pathname,filesep,filename];
    % set(handles.datapath,'String',sourcename);


% Setup defaults
% -------------------------------------------------------------------
function imsetup(hObject,eventdata, handles)
    global imaxes
    imaxes.H = 256; % actual size of image
    imaxes.W = 256;
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
    guidata(hObject, handles);
    UpdateSliders(hObject,eventdata,handles);


%=========================================================================%  
%       end of load data functions
%=========================================================================%






%=========================================================================%
%% Toolbar Functions
%=========================================================================%

function openfile_1_Callback(hObject, eventdata, handles)
% hObject    handle to SaveData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% this is the toolbar open icon 
sourcepath = uigetdir;
set(handles.datapath,'String',sourcepath);
clear global Im; % clear mosaic if path has changed
clear global stage;
guidata(hObject, handles);


% --------------------------------------------------------------------
function SaveData_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to SaveData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global mlist infilter imaxes I Ozoom max_sat min_off savepath Io
chns = find(true - cellfun(@isempty,mlist))';
Cs = length(chns);
molist = cell(Cs,1);
mfilter = cell(Cs,1);

% save('C:\Users\Alistair\Documents\Projects\General_STORM\Test_data\test.mat');
% load('C:\Users\Alistair\Documents\Projects\General_STORM\Test_data\test.mat');   

for c=chns
    inbox = [mlist{c}.xc]>imaxes.xmin & [mlist{c}.xc] < imaxes.xmax & [mlist{c}.yc] >imaxes.ymin & [mlist{c}.yc] <imaxes.ymax;
    molist{c} = structfun(@(x) x(inbox), mlist{c},'UniformOutput',false);
    mfilter{c} = infilter{c}(inbox); 
end

try
[savename,savepath] = uiputfile(savepath);
catch
    [savename,savepath] = uiputfile;
end

% strip extra file endings, the script will put these on appropriately. 
k = strfind(savename,'.');
if ~isempty(k)
    savename = savename(1:k-1); 
end

if isempty(I) || isempty(max_sat) || isempty(min_off)
    disp('no image data to save');
end
if isempty(Ozoom)
    disp('no overlay to save');
end

if savename ~= 0 % save was not 'canceled'
    save([savepath,filesep,savename,'.mat'],'molist','mfilter','I','Ozoom','imaxes','max_sat','min_off');
    disp([savepath,filesep,savename,'.mat' ' saved successfully']);
    imwrite(Io,[savepath,filesep,savename,'.png']); 
    disp(['wrote ', savepath,filesep,savename,'.png']);
end


% --------------------------------------------------------------------
function SaveImage_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to SaveImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Io savepath
try
[savename,savepath] = uiputfile(savepath);
catch
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




function getedges(hObject, eventdata, handles)
% if cx/cy is near the edge and zoom is small, we should have a different
% maxx maxy
global imaxes
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






%==========================================================================
%% Main plotting function
%==========================================================================
function loadim(hObject,eventdata, handles)
% load variables
global mlist imaxes I infilter DisplayOps
axes(handles.axes2); 
% if we're zoomed out fully, recenter everything
disp(imaxes);
if imaxes.zm == 1
  imsetup(hObject,eventdata, handles); % reset to center
end
getedges(hObject, eventdata, handles);
UpdateSliders(hObject,eventdata,handles);
disp(['updated minx=',num2str(imaxes.xmin)]);
disp(['updated miny=',num2str(imaxes.ymin)]); 

tic
if DisplayOps.ColorZ
    % In general, not worth excluding these dots from 2d images.
    % if desired, can be done by applying a molecule list filter.  
    if DisplayOps.HidePoor 
        for c = 1:length(infilter)
            infilter{c}(mlist{c}.c==9) = 0;  
        end
    end
    I = plotSTORM_colorZ(mlist, imaxes,'filter',infilter,...
        'dotsize',DisplayOps.DotScale,'Zsteps',DisplayOps.Zsteps);
else
    I = plotSTORM(mlist, imaxes,'filter',infilter,'dotsize',DisplayOps.DotScale);
end
update_imcolor(hObject,handles); % converts I, applys contrast, to RBG
guidata(hObject, handles);
plottime = toc;
disp(['total time to render image: ',num2str(plottime)]);













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
global mlist infilter filts max_sat min_off
filts = struct('custom',[]); % empty structure to store filters
Cs = length(mlist);
    infilter = cell(Cs,1);
    channels = find(1-cellfun(@isempty,mlist))';
    for i=channels
        infilter{i} = true(size([mlist{i}.xc]))';
    end
    
channel_active = zeros(1,4);
channel_active(1:Cs) = 1; 
set(handles.chn1,'Value',channel_active(1));
set(handles.chn2,'Value',channel_active(2));
set(handles.chn3,'Value',channel_active(3));
set(handles.chn4,'Value',channel_active(4));
    
max_sat = .0003*ones(Cs,1); % default values
min_off = 0*ones(Cs,1);  % default values
loadim(hObject,eventdata, handles); % calls plotdata function
 
 

% --- Executes on button press in ApplyFilter.
function ApplyFilter_Callback(hObject, eventdata, handles)
% chose filter
  global infilter filts ScratchPath
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
  [newfilter,filts] = applyfilter(vlist,local_filter, filts, channels, par, myfilt); 
  
  
  for c=1:channels
    infilter{c}(vlist{c}.inbox & vlist{c}.infilter') =  newfilter{c};
  end
  loadim(hObject,eventdata, handles); % calls plotdata function

% --- Executes on button press in ShowFilters.
function ShowFilters_Callback(hObject, eventdata, handles)
% hObject    handle to ShowFilters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('this function still under development'); 



 
 
function update_imcolor(hObject,handles)
global I Ic Io max_sat min_off fnames DisplayOps imaxes ScratchPath
guidata(hObject, handles);
channels(1) = get(handles.chn1,'Value');
channels(2) = get(handles.chn2,'Value');
channels(3) = get(handles.chn3,'Value');
channels(4) = get(handles.chn4,'Value');
active_channels = find(channels);

if DisplayOps.ColorZ  
    n=0;
    Cs = length(I); 
    [h,w,Zs] = size(I{1});
    Ic = zeros(h,w,Zs*length(active_channels),'uint16'); 
    active_channels(active_channels>Cs) = []; 
    for c=active_channels
        %load([ScratchPath,'test.mat']);
       for k=1:DisplayOps.Zsteps
           n=n+1;
            Ic(:,:,n) = mycontrast(I{c}(:,:,k),max_sat(c),min_off(c));   
       end
   end
else
    [~,~,Cs] = size(I);
    for c=1:Cs
          Ic = I; % incase Ic doesn't exist.  
          % Ic(:,:,c) = mycontrast(I(:,:,c),max_sat(c),min_off(c));
          Ic(:,:,c) = imadjust(I(:,:,c),[min_off(c),max_sat(c)],[0,1]);
    end
    Ic(:,:,logical(1-channels)) = cast(0,'uint16'); 
end

%  save([ScratchPath,'test.mat'],'Ic','handles','I','DisplayOps','max_sat','min_off','active_channels','channels');
% load([ScratchPath,'test.mat']);

Io = Ncolor(Ic,[]); 
axes(handles.axes2); cla; axis off;
imagesc(Io); 
shading interp;
axes(handles.axes2);
set(handles.imtitle,'String',fnames(:)); % interpreter, none
colorbar; colormap(hsv(Cs));

if imaxes.updatemini
    axes(handles.axes1); cla; axis off;
    imagesc(Io); 
    imaxes.updatemini = false;
end
guidata(hObject, handles);


% save('C:\Users\Alistair\Documents\Projects\General_STORM\Test_data\test.mat','Ic','I','Io');
 





% --------------------------------------------------------------------
function ManualContrastTool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to ManualContrastTool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global max_sat min_off 
max_sat = input('enter a vector for max intensity for each channel: ');
min_off = input('enter a vector for min intensity for each channel: ');
 update_imcolor(hObject,handles);
 guidata(hObject, handles);
 
% --------------------------------------------------------------------
function AutoContrastTool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to AutoContrastTool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global max_sat min_off
    max_sat = [.01,.01,.01,.01];
    min_off = [.0,.0,.0,.0];
 update_imcolor(hObject,handles);
 guidata(hObject, handles);

% ------
 function scalecolor(hObject,handles)
 global I max_sat min_off DisplayOps ScratchPath
    channels(1) = get(handles.fchn1,'Value');
    channels(2) = get(handles.fchn2,'Value');
    channels(3) = get(handles.fchn3,'Value');
    channels(4) = get(handles.fchn4,'Value');
    channels = find(channels);
  
    c = channels(1); 
   
    set(handles.levelpanel,'Title',['channel ',num2str(c)]);
    
   maxin = get(handles.MaxIntSlider,'Value');
   minin = get(handles.MinIntSlider,'Value'); 
   set(handles.MaxIntBox,'String',num2str(maxin));
   set(handles.MinIntBox,'String',num2str(minin));
   
   logscalecolor = logical(get(handles.logscalecolor,'Value'));
   
     save([ScratchPath,'test.mat']);
%     % load([ScratchPath,'test.mat']);
   
   max_sat(c) = maxin;
   min_off(c) = minin;
    
        if DisplayOps.ColorZ 
            raw_ints  = double(I{c}(:));     
        else
            raw_ints = double(I(:,:,c));
            
        end
        raw_ints = raw_ints(:);
        max_int = max(raw_ints);
        
       axes(handles.axes3); cla;
       if ~logscalecolor
           xs = linspace(0,max_int,1000); 
            hi1 = hist(nonzeros(raw_ints)./max_int,xs);
            hist(nonzeros(raw_ints),xs); hold on;
            inrange = nonzeros(raw_ints( raw_ints/max_int>minin & raw_ints/max_int<maxin))./max_int;
            hist(inrange,xs);
            h2 = findobj('type','patch'); 
            xlim([min(xs),max(xs)]);
       else
           xs = linspace(-5,0,100);
           hi1 = hist(log10(nonzeros(raw_ints)/(max_int)),xs);
           hist(log10(nonzeros(raw_ints)/(max_int)),xs); hold on;
           xlim([min(xs),max(xs)]);
    
           inrange = nonzeros(raw_ints( raw_ints/max_int>minin & raw_ints/max_int<maxin))./max_int;
           hist(log10(inrange),xs);
           xlim([min(xs),max(xs)]);
           h2 = findobj('type','patch'); 
       end
        ylim([0,1.2*max(hi1)]);
       set(h2(1),'FaceColor','b','EdgeColor','b');
       set(h2(2),'FaceColor','r','EdgeColor','r');
       alpha .5;
       
       clear raw_ints; 
       
      update_imcolor(hObject,handles);
      guidata(hObject, handles);

function MinIntBox_Callback(hObject, eventdata, handles) %#ok<*INUSL>
 minin = str2double(get(handles.MinIntBox,'Value'));
 set(handles.MinIntSlider,'Value',minin);
 scalecolor(hObject,handles);
 guidata(hObject, handles); 

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



% color controls
function chn1_Callback(hObject, eventdata, handles)
update_imcolor(hObject,handles);
guidata(hObject, handles);

function chn2_Callback(hObject, eventdata, handles)
update_imcolor(hObject,handles);
guidata(hObject, handles);


function chn3_Callback(hObject, eventdata, handles)
update_imcolor(hObject,handles);
guidata(hObject, handles);

function chn4_Callback(hObject, eventdata, handles)
update_imcolor(hObject,handles);
guidata(hObject, handles);



% --- Executes on button press in MoreDisplayOps.
function MoreDisplayOps_Callback(hObject, eventdata, handles)
% hObject    handle to MoreDisplayOps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global default_Dopts Dprompt DisplayOps

dlg_title = 'More Display Options';
num_lines = 1;
Dprompt = {
    'Display Z as color',...
    'Number of Z-steps',...
    'Dot scale',...
    'hide poor z-fits'};
default_Dopts{1} = num2str(DisplayOps.ColorZ);
default_Dopts{2} = num2str(DisplayOps.Zsteps);
default_Dopts{3} = num2str(DisplayOps.DotScale);
default_Dopts{4} = num2str(DisplayOps.HidePoor);

% if the menu is screwed up, reset 
try
default_Dopts = inputdlg(Dprompt,dlg_title,num_lines,default_Dopts);
catch er
    disp(er.message)
    default_Dopts = {
    'false',...
    '3',...
    '4',...
    'false'};
end
DisplayOps.ColorZ = eval(default_Dopts{1}); 
DisplayOps.Zsteps = eval(default_Dopts{2});
DisplayOps.DotScale = eval(default_Dopts{3});
DisplayOps.HidePoor = eval(default_Dopts{4});



















%========================================================================%
%% GUI buttons for manipulating zooming, scrolling, recentering etc
%========================================================================%
function zoomin_Callback(hObject, eventdata, handles)
% hObject    handle to zoomin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global imaxes
imaxes.zm = imaxes.zm*2; 
if imaxes.zm > 64
    imaxes.zm = 64;
    disp('max zoom reached...');
end
set(handles.displayzm,'String',num2str(imaxes.zm,2));
loadim(hObject,eventdata, handles);
guidata(hObject, handles);


% --- Executes on button press in zoomout.
function zoomout_Callback(hObject, eventdata, handles)
% hObject    handle to zoomout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global imaxes
imaxes.zm = imaxes.zm/2; 
if imaxes.zm < 1
    imaxes.zm = 1; % all the way out
    imaxes.cx = imaxes.W/2; % recenter
    imaxes.cy = imaxes.H/2;
end
set(handles.displayzm,'String',num2str(imaxes.zm,2));
guidata(hObject, handles);
UpdateSliders(hObject,eventdata,handles);
% save('C:\Users\Alistair\Documents\Projects\General_STORM\Test_data\test.mat','imaxes','handles');
% load('C:\Users\Alistair\Documents\Projects\General_STORM\Test_data\test.mat');
loadim(hObject,eventdata, handles);
guidata(hObject, handles);


function displayzm_Callback(hObject, eventdata, handles)
% Execute on direct user input specific zoom value
global imaxes
imaxes.zm = str2double(get(handles.displayzm,'String')); 
if imaxes.zm < 1
    imaxes.zm = 1; % all the way out
    imaxes.cx = imaxes.W/2; % recenter
    imaxes.cy = imaxes.H/2;
end
set(handles.displayzm,'String',num2str(imaxes.zm,2));
guidata(hObject, handles);
UpdateSliders(hObject,eventdata,handles);
loadim(hObject,eventdata, handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function zoomtool_ClickedCallback(hObject, eventdata, handles)
% Zoom in on the boxed region specified by user selection of upper left and
% lower right coordinates.
% Inputs:
% hObject    handle to zoomtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global imaxes ScratchPath
handles = guidata(hObject);
% user specifies box:
axes(handles.axes2); 
disp(['curr zoom=',num2str(imaxes.zm)]);
disp(['curr cx=',num2str(imaxes.cx)]);
disp(['curr cy=',num2str(imaxes.cy)]); 

disp(['curr minx=',num2str(imaxes.xmin)]);
disp(['curr miny=',num2str(imaxes.ymin)]); 
% getedges(hObject, eventdata, handles)
[x,y] = ginput(2);  % These are relative to the current axis
disp('x,y grabbed');
disp([x,y]);
xim = imaxes.xmin + x/imaxes.scale/imaxes.zm;
yim = imaxes.ymin + y/imaxes.scale/imaxes.zm;
disp('x,y converted');
disp([xim,yim]);
imaxes.cx = mean(xim);  % this is relative to the whole image
imaxes.cy = mean(yim); % y is indexed bottom to top for plotting
xdiff = abs(xim(2) - xim(1));
ydiff = abs(yim(2) - yim(1));
disp('xdiff,ydiff');
disp([xdiff,ydiff]);
imaxes.zm =   min(imaxes.W/xdiff, imaxes.H/ydiff); 
if imaxes.zm > 64
    imaxes.zm = 64;
    disp('max zoom reached...');
end
disp(['new zoom=',num2str(imaxes.zm)]);
set(handles.displayzm,'String',num2str(imaxes.zm,2));

axes(handles.axes1);
hold on;
hside= imaxes.H*imaxes.scale/imaxes.zm;
wside = imaxes.W*imaxes.scale/imaxes.zm;
lower_x = imaxes.scale*imaxes.cx-wside/2;
lower_y = imaxes.scale*imaxes.cy-hside/2;

rectangle('Position',[lower_x,lower_y,wside,hside],...
    'EdgeColor','w','linewidth',1); 
hold off;

guidata(hObject, handles);
UpdateSliders(hObject,eventdata,handles)

 save([ScratchPath,'test.mat']);
  % load([ScratchPath,'test.mat']);

% plot box
axes(handles.axes2); hold on;
rectangle('Position',[min(x),min(y),abs(x(2)-x(1)),abs(y(2)-y(1))],'EdgeColor','w'); hold off;
% rectangle('Position',[imaxes.cx-xdiff/2,imaxes.cy-ydiff/2,xdiff,ydiff],'EdgeColor','c');
guidata(hObject, handles);
pause(.1); 
loadim(hObject,eventdata, handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function recenter_ClickedCallback(hObject, eventdata, handles)
% Recenter image over clicked location
% hObject    handle to recenter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global imaxes
handles = guidata(hObject);
axes(handles.axes2); 
[x,y] = ginput(1); % these are relative to the current frame
xim = imaxes.xmin + x/imaxes.scale/imaxes.zm;
yim = imaxes.ymin + y/imaxes.scale/imaxes.zm;
imaxes.cx = xim;  % these are relative to the whole image
imaxes.cy = yim;
guidata(hObject, handles);
loadim(hObject,eventdata, handles);
guidata(hObject, handles);

function UpdateSliders(hObject,eventdata,handles)
global imaxes
handles = guidata(hObject);
set(handles.Xslider,'Value',imaxes.cx);
set(handles.Yslider,'Value',imaxes.H-imaxes.cy);
guidata(hObject, handles);

% --- Executes on slider movement.
function Yslider_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global imaxes
imaxes.cy = imaxes.H - get(handles.Yslider,'Value');
loadim(hObject,eventdata, handles);
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
global imaxes
imaxes.cx = get(handles.Xslider,'Value');
loadim(hObject,eventdata, handles);
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

global imaxes I DisplayOps

% currently hard-coded, should be user options 
npp = 160; 
zrange = [-600,600];

if DisplayOps.ColorZ
disp('use cell arrays of parameters for multichannel rendering'); 
disp('see help Im3D for more options'); 

dlg_title = 'Render3D';
num_lines = 1;

    Dprompt = {
    'threshold (blank for auto)',...
    'downsample',...
    'smoothing (must be odd integer)',...
    'color'};
    default_Dopts = {
    '[]',...
    '3',...
    '3',...
    'blue'};

opts = inputdlg(Dprompt,dlg_title,num_lines,default_Dopts);
Zs = DisplayOps.Zsteps;

xyp = npp/imaxes.scale/imaxes.zm; % nm per x/y pixel
zstp = (zrange(2)-zrange(1))/Zs;

theta = eval(opts{1});
stp = eval(opts{2});
res = eval(opts{3});
colr = opts{4}; 

channels(1) = get(handles.chn1,'Value');
channels(2) = get(handles.chn2,'Value');
channels(3) = get(handles.chn3,'Value');
channels(4) = get(handles.chn4,'Value');
active_channels = find(channels);
Cs = length(I);
active_channels(active_channels>Cs) = [];


figure; clf; 
Im3D(I(active_channels),'resolution',res,'zStepSize',zstp,'xyStepSize',xyp,...
    'theta',theta,'downsample',stp,'color',colr);
set(gcf,'color','w');
camlight left;
xlabel('nm');
ylabel('nm');
zlabel('nm');
xlim([0,(imaxes.xmax-imaxes.xmin)*npp]);
ylim([0,(imaxes.ymax-imaxes.ymin)*npp]);

else
    disp('must set Display Ops color Z to true for 3D rendering'); 
    disp('Go to "More Display Ops" and set first field as "true"');
end

% save('C:\Users\Alistair\Documents\Projects\General_STORM\Test_data\test.mat')
% load('C:\Users\Alistair\Documents\Projects\General_STORM\Test_data\test.mat')


% --------------------------------------------------------------------
function Rotate3Dslices_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Rotate3Dslices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global imaxes I DisplayOps

% currently hard-coded, should be user options 
npp = 160; 
zrange = [-600,600];

if DisplayOps.ColorZ
dlg_title = 'Render3D';
num_lines = 1;

    Dprompt = {
    'threshold (blank for auto)',...
    'downsample'};
    default_Dopts = {
    '[]',...
    '3'};

opts = inputdlg(Dprompt,dlg_title,num_lines,default_Dopts);

Zs = DisplayOps.Zsteps;
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

global plt3Dfig  ScratchPath
npp = 160; % should be a global in imageops or something
vlist = MolsInView(handles);
chns = find(cellfun(@(x) ~isempty(x),vlist))
Cs = length(chns); 
cmap = hsv(Cs);
lab = cell(Cs,1);

if ~isempty(plt3Dfig)
    try
    close(plt3Dfig);
    catch er
        disp(er.message);
    end
end
plt3Dfig = figure; 
save([ScratchPath,'testdat.mat']);
load([ScratchPath,'testdat.mat']);

for c = chns
    plot3(vlist{c}.x*npp,vlist{c}.y*npp,vlist{c}.z*npp,'.','color',cmap(c,:),...
        'MarkerSize',5);
    lab{c} = ['channel ',num2str(c)', ' # loc:',num2str(length(vlist{c}.x))];
    hold on;
end
xlabel('x (nm)'); ylabel('y (nm)'); zlabel('z (nm)'); 
title(lab); 

save([ScratchPath,'testdat.mat']);

% --------------------------------------------------------------------
function plot2Ddots_ClickedCallback(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>


    
    
function vlist = MolsInView(handles)
% return just the portion of the molecule list in the fied of view; 
    
    global mlist imaxes infilter 
    channels(1) = get(handles.chn1,'Value');
    channels(2) = get(handles.chn2,'Value');
    channels(3) = get(handles.chn3,'Value');
    channels(4) = get(handles.chn4,'Value');
    
    
    all_channels = 1:4;
    active_channels = intersect(all_channels(logical(channels)),1:length(mlist));
    Cs = length(mlist); 
    
    % initialize variables
    vlist = cell(Cs,1);
    x = cell(Cs,1); 
    y = cell(Cs,1); 
    
    for c=active_channels;
        x{c} = mlist{c}.xc;
        y{c} = mlist{c}.yc;
      if length(x{c}) >1
         inbox = x{c}>imaxes.xmin & x{c} < imaxes.xmax & y{c}>imaxes.ymin & y{c}<imaxes.ymax;
         vlist{c}.x = (x{c}(inbox & infilter{c}')-imaxes.xmin);
         vlist{c}.y = (y{c}(inbox & infilter{c}')-imaxes.ymin);
         vlist{c}.z = (mlist{c}.z(inbox & infilter{c}'));
         vlist{c}.a= (mlist{c}.a(inbox & infilter{c}'));
         vlist{c}.i= (mlist{c}.i(inbox & infilter{c}'));
         vlist{c}.h= (mlist{c}.h(inbox & infilter{c}'));
         vlist{c}.frame= (mlist{c}.frame(inbox & infilter{c}'));
         vlist{c}.length= (mlist{c}.length(inbox & infilter{c}'));
         vlist{c}.w= (mlist{c}.w(inbox & infilter{c}'));
         vlist{c}.xc = vlist{c}.x;
         vlist{c}.yc = vlist{c}.y;
         vlist{c}.zc = vlist{c}.z;
         vlist{c}.channel = c; 
         vlist{c}.inbox = inbox; 
         vlist{c}.infilter = infilter{c};
         vlist{c}.locinfilter = infilter{c}(infilter{c}' & inbox)';
      end
    end  
  
%=========================================================================%









%==========================================================================
%% Overlays / Image Context 
%==========================================================================




% --- Executes on button press in AddOverlay.
function AddOverlay_Callback(hObject, eventdata, handles)
global I Ozoom imaxes Overlay_prompt Overlay_opts max_sat min_off fnames

% ------------- load image
% open dialog box to decide whether image should be flipped or rotated
dlg_title = 'Set Load Options';
num_lines = 1;
try
Overlay_opts = inputdlg(Overlay_prompt,dlg_title,num_lines,Overlay_opts);
catch er 
    % reset 
    disp(er.message)
    Overlay_prompt = {
    'Image selected (leave blank to select with getfile prompt)',...
    'Flip Vertical',...
    'Flip Horizontal',...
    'Rotate by N degrees'...
    'horizontal shift'...
    'vertical shift'...
    'channels'};
    Overlay_opts = {
    '',...
    'false',...
    'false',...
    '0',...
    '0',...
    '0',...
    ''};
    Overlay_opts = inputdlg(Overlay_prompt,dlg_title,num_lines,Overlay_opts);
end

if isempty(Overlay_opts{1})
[filename,pathname] = uigetfile({'*.jpg;*.png;*.tif','Image files (*.jpg, *.png, *.tif)';
    '*.jpg', 'JPEGS (*.jpg)';
    '*.tif', 'TIFF (*.tif)';
    '*.png', 'PNG (*.png)';
    '*.*', 'All Files (*.*)'},'Choose an image file to overlay'); % prompts user to select directory 
sourcename = [pathname,filesep,filename];
Overlay_opts{1} = sourcename;
end

O = imreadfast(Overlay_opts{1}); % load image file;
Ozoom = fxn_AddOverlay(O,I,imaxes,'flipV',eval(Overlay_opts{2}),'flipH',eval(Overlay_opts{3}),...
    'rotate',eval(Overlay_opts{4}),'xshift',eval(Overlay_opts{5}),'yshift',eval(Overlay_opts{6}),...
    'channels',eval(Overlay_opts{7}) );
[~,~,cin] = size(Ozoom);
[~,~,Cs] = size(I);

%------------- Set Contrasts
 % this contrast should be optional in FUTURE version
for k=1:cin
    Ozoom(:,:,k) = mycontrast(Ozoom(:,:,k),.001,.01); 
end
It = Ncolor(Ozoom,'');
figure; clf; imagesc(It); % display contrasted image
Ic = I; 
for k=1:Cs
      Ic(:,:,k) = mycontrast(I(:,:,k),max_sat(k),min_off(k));
end

%----------- Combine with Choice colormap
I2 = cat(3,Ic,uint16(.8*Ozoom));  
title('isolated overlay'); 
% choose color map; (could make into a menu option in FUTURE version)
%Io = Ncolor(I2,[hsv(Cs);hsv(cin)]); % match colors
Io = Ncolor(I2,hsv(Cs+cin)); % unique colors
figure; clf; imagesc(Io);
set(gcf,'color','w'); 
title(fnames(:),'interpreter','none');
shading interp;





% --- Executes on button press in ImageContext.
function ImageContext_Callback(hObject, eventdata, handles)
% Loads multicolor mosaic created with the Steve application.
% Marks location of current image on mosaic. 
global Im fnames stage

pathin = get(handles.datapath,'String');
f = strfind(pathin,filesep); % go up one directory
pathroot = pathin(1:f(end));


% % optional, get position list
% fname = 'positions.txt';
% Pfolder = findfile(pathin,fname,1);
% positionlist = [Pfolder,filesep,fname];  % full directory to positions

Mfolder = 'Mosaic';
shrk = 1; 
% Load the mosaic file
  % This has potential to kill the memory; 
  if isempty(stage)  % Don't want to rebuild the mosaic everytime.  
    [Im,stage] = fxn_rebuild_mosaic([pathroot,filesep,Mfolder],'shrink',shrk);
  end
   figure; clf; imagesc(Im);
  
  % get location of current image on mosaic
  info = ReadInfoFile('path',[pathin,filesep],'files',[fnames{1},'.inf']);
  info.Stage_X, info.Stage_Y
  Stage_Y =(stage.sy*info.Stage_X - stage.ymin + 256)/shrk; 
  Stage_X =(stage.sx*info.Stage_Y - stage.xmin + 256)/shrk; 
  
  % HIGHLIGHT IMAGE LOCATION ON MOSAIC
    zn = 256*6; % number of pixels to incude on each side (6 more frames eachway)
    [ih,iw,~] = size(Im);
      my1 = floor( max(Stage_Y-zn,1) );
      my2 = floor( min(Stage_Y+zn,ih) );
      mx1 = floor( max(Stage_X-zn,1) );
      mx2 = floor( min(Stage_X+zn,iw) );
      Im_zoom = Im(my1:my2,mx1:mx2,:);
    Im_zoom(:,:,1) = mycontrast(Im_zoom(:,:,1),.00025,0);

    % Save zoomed in version of mosaic
    mosaic_zoom = figure; clf; 
    imagesc(Im_zoom);
    rectangle('Position',[zn-127,zn-127,256,256],'EdgeColor','c');    
      
 



     
        


% --------------------------------------------------------------------
function saveimage_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to saveimage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Io
[filename,pathname] = uiputfile;
tiffwrite(Io,[pathname,filesep,filename]);




function datapath_Callback(hObject, eventdata, handles)
global Im
clear global Im;
clear global stage;
% if source folder is changed, clear mosaic

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

