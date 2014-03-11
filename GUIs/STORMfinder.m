function varargout = STORMfinder(varargin)
% STORMFINDER MATLAB code for STORMfinder.fig
%      STORMFINDER, by itself, creates a new STORMFINDER or raises the existing
%      singleton*.
%
%      H = STORMFINDER returns the handle to a new STORMFINDER or the handle to
%      the existing singleton*.
%
%      STORMFINDER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STORMFINDER.M with the given input arguments.
%
%      STORMFINDER('Property','Value',...) creates a new STORMFINDER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before STORMfinder_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to STORMfinder_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% -------------------------------------------------------------------------
% Outputs
% parfile_temp.ini  -- .ini parameters being used by the system 
% parfile_temp.xml 
% parfile_temp_1frame.xml
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help STORMfinder

% Last Modified by GUIDE v2.5 29-Dec-2013 17:25:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @STORMfinder_OpeningFcn, ...
                   'gui_OutputFcn',  @STORMfinder_OutputFcn, ...
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


% --- Executes just before STORMfinder is made visible.
function STORMfinder_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to STORMfinder (see VARARGIN)

global daxfile SF
if isempty(SF)
    SF = cell(1,1);
else
    SF = [SF;cell(1,1)];
end

gui_number = length(SF);
set(handles.SFinstance,'String',['inst id',num2str(gui_number)]);
handles.gui_number = gui_number;

SF{handles.gui_number}.daxfile = daxfile; 
% initialize other variables as empty
SF{handles.gui_number}.inifile = ''; 
SF{handles.gui_number}.xmlfile = ''; 
SF{handles.gui_number}.gpufile = ''; 
SF{handles.gui_number}.mlist = []; 
SF{handles.gui_number}.FitPars = []; 
SF{handles.gui_number}.impars = []; 
SF{handles.gui_number}.fullmlist = []; 

% Default Analysis options
SF{handles.gui_number}.defaultAopts{1} = 'true';
SF{handles.gui_number}.defaultAopts{2} = 'false';
SF{handles.gui_number}.defaultAopts{3} = '2';
SF{handles.gui_number}.defaultAopts{4} = '60';
SF{handles.gui_number}.defaultAopts{5} = '95';
SF{handles.gui_number}.defaultAopts{6}= 'true';
SF{handles.gui_number}.defaultAopts{7}= '';



% Choose default command line output for STORMfinder
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% If any daxfile has been loaded, open it along with opening the GUI.  
try
UpdateDax_Callback(hObject, eventdata, handles)
catch 
    disp('please load a dax file into matlab');
    disp('drag and drop a .dax file in the command window, then press Update Dax File');
    disp('Or select File > Load Dax File'); 
end

% set(handles.FitMethod,'Value',2); % set default method to DaoSTORM
% 1 = InsightM, 3 = GPUmultifit
axes(handles.axes1); axis off; 
% UIWAIT makes STORMfinder wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = STORMfinder_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function FindDots_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to FindDots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global  SF insightExe daoSTORMexe scratchPath

    FitMethod = get(handles.FitMethod,'Value');
   
%     k = strfind(daxfile,filesep);
%     fpath = daxfile(1:k(end));
  %  daxroot = regexprep(daxfile(k(end)+1:end),'.dax','');
    
    if FitMethod == 1 % InsightM  
        if isempty(insightExe)
            error(['insightExe not found.  ',...
                'Please set the global variable insightExe ',...
                'to specify the location of insightM.exe in the ',...
                'Insight3 folder on your computer.']);
        end
        insight = insightExe; 
        
        % InsightM /.ini files don't have a max frames parameter, so
        % instead we write a new dax menufile that has only 1 frame.  
        
        % if no inifile has been loaded, use default values 
        if isempty(SF{handles.gui_number}.inifile)
            ReadParameterFile(FitMethod,handles); % make default file the inifile
        end
        
       % write temp daxfile
        mov_temp = 'mov_temp.dax';
        daxtemp = [scratchPath, mov_temp];
        ftemp = fopen(daxtemp,'w+');
        fwrite(ftemp,SF{handles.gui_number}.impars.Im(:),'*uint16',0,'b');
        fclose(ftemp);

        % write temp inf file 
        InfoFile_temp = SF{handles.gui_number}.impars.infofile;
        InfoFile_temp.number_of_frames = 1;
        InfoFile_temp.localName = 'mov_temp.inf';
        InfoFile_temp.localPath = scratchPath;
        WriteInfoFiles(InfoFile_temp,'verbose',false);
        % call insight 
        ccall = ['!', insight,' "',daxtemp,'" ',...
            ' "',SF{handles.gui_number}.inifile,'" ',...
            ' "',SF{handles.gui_number}.inifile,'" '];
        disp(ccall); 
        eval(ccall); 
        binfile = regexprep([scratchPath,'mov_temp.dax'],'\.dax','_list.bin');
            
        
	elseif FitMethod == 2    
        % load parameter files if missing
        if isempty(SF{handles.gui_number}.xmlfile)
            ReadParameterFile(FitMethod,handles) % make default file the 'xmlfile'
        end
        if isempty(daoSTORMexe)
            error(['daoSTORMexe not found.  ',...
                'Please set the global variable daoSTORMexe ',...
                'to specify the location of mufit_analysis.py in the ',...
                'DaoSTORM folder on your computer and its dll paths.',...
                'See startup_example in \Templates folder']);
        end          
        % update xmlfile to current frame 
            % save a new xmlfile which has 1frame appended onto the default one.
            xmlfile_temp = make_temp_parameters(handles,'1frame');
            parameters = {'<start_frame type="int">',...
                            '<max_frame type="int">',...
                            '<drift_correction type="int">'};
            new_values = {num2str(SF{handles.gui_number}.impars.cframe-1),...
                          num2str(SF{handles.gui_number}.impars.cframe),...
                          '0'}; 
            modify_script(SF{handles.gui_number}.xmlfile,xmlfile_temp,...
                parameters,new_values,'<');             
        % need to delete any existing bin menufile before we overwrite, or
        % DaoSTORM tries to pick up analysis where it left off.  
         binfile = regexprep([scratchPath,'mov_temp.dax'],'\.dax','_mlist.bin'); 
         if exist(binfile,'file')
            delete(binfile);
         end    
        % Call DaoSTORM.    
        disp('locating dots by DaoSTORM');
        disp(SF{handles.gui_number}.daxfile)
        disp(xmlfile_temp);
        system([daoSTORMexe,' "',...
            SF{handles.gui_number}.daxfile,...
            '" "',binfile,'" "',xmlfile_temp,'"']);
        
            
	elseif FitMethod == 3
        TempPars = SF{handles.gui_number}.FitPars;
        TempPars.startFrame = mat2str(SF{handles.gui_number}.impars.cframe);
        TempPars.endFrame = mat2str(SF{handles.gui_number}.impars.cframe+1); 
        SF{handles.gui_number}.mlist = ...
            GPUmultifitDax(SF{handles.gui_number}.daxfile,TempPars);           
    end 
    
    if FitMethod~=3
        try
        SF{handles.gui_number}.mlist = ...
            ReadMasterMoleculeList(binfile,'verbose',false);
        catch %#ok<*CTCH>
            disp('no molecules found to display!');
            disp('Try changing fit pars');  
            clear mlist;
            SF{handles.gui_number}.mlist.x = []; 
            SF{handles.gui_number}.mlist.y = [];
        end
    end
handles.axes1;  cla; 
imagesc(SF{handles.gui_number}.impars.Im(:,:,1)'); 
caxis([SF{handles.gui_number}.impars.cmin,...
    SF{handles.gui_number}.impars.cmax]); colormap gray;
set(handles.title1,'String',SF{handles.gui_number}.daxfile); % ,'interpreter','none'); 
hold on;  
plot(SF{handles.gui_number}.mlist.x(:),...
    SF{handles.gui_number}.mlist.y(:),'yo','MarkerSize',20);
axis off;
% rectangle(mlist.x(:),mlist.y(:),mlist.w(:),mlist.w(:));


% --------------------------------------------------------------------
function Plotdots3D_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Plotdots3D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SF
try
    figure(2); clf; 
    plot3(SF{handles.gui_number}.mlist.y(:),...
        SF{handles.gui_number}.mlist.x(:),...
        SF{handles.gui_number}.mlist.z(:),'k.','MarkerSize',10);
    grid on;
    xlabel('y'); ylabel('x'); zlabel('z'); 
    xlim([0,SF{handles.gui_number}.impars.w]);
    ylim([0,SF{handles.gui_number}.impars.h]);
catch er
    disp(er.message);
    disp('no molecules found to plot!');
end




% --------------------------------------------------------------------
function MenuLoadDax_Callback(hObject, eventdata, handles)
% hObject    handle to MenuLoadDax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SF
if ~isempty(SF{handles.gui_number}.daxfile)
    startfolder = ExtractPath(SF{handles.gui_number}.daxfile); 
else
     startfolder = pwd;
end
[FileName,PathName,FilterIndex] = uigetfile({'*.dax','Dax file (*.dax)';...
    '*.*','All Files (*.*)'},'Select dax file',startfolder);
if FilterIndex ~= 0 % loading operation was not canceled
    SF{handles.gui_number}.daxfile = [PathName,FileName];
    LoadDax(hObject,handles);
end

% --------------------------------------------------------------------
function MenuLoadBin_Callback(hObject, eventdata, handles)
global SF
if ~isempty(SF{handles.gui_number}.daxfile)
    startfolder = ExtractPath(SF{handles.gui_number}.daxfile); 
else
     startfolder = pwd;
end
[FileName,PathName,FilterIndex] = uigetfile({'*.bin','Bin file (*.bin)';...
    '*.*','All Files (*.*)'},'Select molecule list',startfolder);
if FilterIndex ~= 0 % loading operation was not canceled
    SF{handles.gui_number}.binpath = [PathName,FileName];
    try
    SF{handles.gui_number}.fullmlist = ...
        ReadMasterMoleculeList(SF{handles.gui_number}.binpath); 
    catch er
       disp(er.message); 
       disp(['loading failed.  Is ',[PathName,FileName],...
           ' a valid .bin file?']); 
    end
end


% --------------------------------------------------------------------
function MenuClearBin_Callback(hObject, eventdata, handles)
global SF
    SF{handles.gui_number}.fullmlist = []; 



% --- Executes on button press in UpdateDax.
function UpdateDax_Callback(hObject, eventdata, handles)
global SF daxfile
% reads in global daxfile from 
SF{handles.gui_number}.daxfile = daxfile;
LoadDax(hObject,handles);


function LoadDax(hObject,handles)
global SF
% Read info menufile
    iminfo = ReadInfoFile(SF{handles.gui_number}.daxfile);
    SF{handles.gui_number}.impars.h = iminfo.frame_dimensions(2);
    SF{handles.gui_number}.impars.w = iminfo.frame_dimensions(1);
    SF{handles.gui_number}.impars.infofile = iminfo; 
% setup default intensities
    fid = fopen(SF{handles.gui_number}.daxfile);
    Im = fread(fid, SF{handles.gui_number}.impars.h*SF{handles.gui_number}.impars.w, '*uint16',0,'b');
    fclose(fid);
    SF{handles.gui_number}.impars.cmax = max(Im(:));
    SF{handles.gui_number}.impars.cmin = min(Im(:));
% set up framer slider
    SF{handles.gui_number}.impars.cframe = 1; % reset to 1
    set(handles.currframe,'String',num2str(SF{handles.gui_number}.impars.cframe));
    % str2double(get(handles.currframe,'String'));
    fid = fopen(SF{handles.gui_number}.daxfile);
    fseek(fid,0,'eof');
    fend = ftell(fid);
    fclose(fid);
    TFrames = fend/(16/8)/(SF{handles.gui_number}.impars.h*SF{handles.gui_number}.impars.w);  % total number of frames
    set(handles.FrameSlider,'Min',1);
    set(handles.FrameSlider,'Max',TFrames);
    set(handles.FrameSlider,'Value',SF{handles.gui_number}.impars.cframe); 
    set(handles.FrameSlider,'SliderStep',[1/TFrames,50/TFrames]);
    UpdateFrame(hObject, handles);

function UpdateFrame(hObject,handles)
    global SF
    % shorthand, load 
    cframe = SF{handles.gui_number}.impars.cframe; 
    h = SF{handles.gui_number}.impars.h;
    w = SF{handles.gui_number}.impars.w;
    fid = fopen(SF{handles.gui_number}.daxfile);
    L = 1; % number of frames to read in
    fseek(fid,(h*w*(cframe-1))*16/8,'bof'); % bits/(bytes per bit) 
    Im = fread(fid, h*w*L, '*uint16',0,'b');
    fclose(fid);
    Im = reshape(Im,w,h,L);
    handles.axes1; cla;
    imagesc(Im(:,:,1)'); caxis([SF{handles.gui_number}.impars.cmin,SF{handles.gui_number}.impars.cmax]); colormap gray;
     axis off; 
    set(handles.title1,'String',SF{handles.gui_number}.daxfile);
    set(handles.FrameSlider,'Value',SF{handles.gui_number}.impars.cframe); % update slider
    axis image;
    
    
    % If a binfile has been loaded, plot the localizations in this frame; 
    if ~isempty(SF{handles.gui_number}.fullmlist)
        hold on;  
        inframe = (SF{handles.gui_number}.fullmlist.frame == cframe); 
        plot(SF{handles.gui_number}.fullmlist.x(inframe),...
            SF{handles.gui_number}.fullmlist.y(inframe),'yo','MarkerSize',20);
        axis off;
    end
    
    guidata(hObject, handles);
    % the transpose here is merely to match insight.  
    SF{handles.gui_number}.impars.Im = Im; 

 
    
    
    

function [FitPars,parameters] = ReadParameterFile(FitMethod,handles)
% loads contents of inifile or xmlfile into data structure FitPars
% depending on whether fit method is insightM or DaoSTORM respectively.  
% if no inifile or xmlfile has been loaded yet, load default files.  
% 
global SF defaultIniFile defaultXmlFile defaultGPUmFile
  % clear fitPars  
if FitMethod == 1
    if isempty(SF{handles.gui_number}.inifile)
        SF{handles.gui_number}.inifile = defaultIniFile; % '..\Parameters\647zcal_storm2.ini';
         disp('no inifile found to load, using default file ');
         disp(SF{handles.gui_number}.inifile); 
        disp('to load a file, drag and drop it into matlab'); 
    end
        parameters = {
            'min height=',...
            'max height=',...
            'default background=',...
            'min width=',...
            'max width=',...
            'default width=',...
            'axial ratio tolerance=',...
            'Fit ROI=',...
            'displacement=',...
            'start frame='...
            'allow drift=',...
            'number of molecules in each correlation time step (XY)=',...
            'number of molecules in each correlation time step (Z)=',...
            'minimum time step size (frame)=',...
            'maximum time step size (frame)=',...
            'xy grid size (nm) in xy correlation=',...
            'xy grid size (nm) in z correlation=',...
            'points for moving average in generating drift correlation (XY)=',...
            'points for moving average in generating drift correlation (Z)=',...
            'z method=',...
            'z calibration expression=',...
            'z calibration outlier rejection percentile=',...
            'z calibration start=',...
            'z calibration end=',...
            'z calibration step=',...
            'ROI Valid=',...
            'ROI_x0=',...
            'ROI_x1=',...
            'ROI_y0=',...
            'ROI_y1=',...
            };

        % Get values from loaded inifile
            target_values = read_parameterfile(SF{handles.gui_number}.inifile,parameters,'');
        % save these values into global FitPars;   
            Pfields = {'minheight','maxheight','bkd','minwidth','maxwidth',...
                'initwidth','maxaxratio','fitROI','displacement','startFrame','CorDrift',...
                'xymols','zmols','minframes','maxframes','xygridxy','xygridz',...
                'movAxy','movAz','Fit3D','zcaltxt','zop','zstart','zend','zstep',...
                'useROI','xmin','xmax','ymin','ymax'};
            FitPars = cell2struct(target_values,Pfields,2);
            parsfile = SF{handles.gui_number}.inifile;
            
elseif FitMethod == 2
    if isempty(SF{handles.gui_number}.xmlfile)
        SF{handles.gui_number}.xmlfile = defaultXmlFile; %  ;
        disp('no xmlfile parameter file found to load.')
        disp(['using default file',SF{handles.gui_number}.xmlfile]);
        disp('to load a file, drag and drop into matlab'); 
    end
    parameters = {
        '<model type="string">',...    method
        '<threshold type="float">'...  threshold
        '<iterations type="int">',...  maxits
        '<baseline type="float">',...   bkd
        '<pixel_size type="float">',... ppnm
        '<sigma type="float">',...      initwidth
        '<descriptor type="string">',... descriptor
        '<radius type="float">',...  displacement
        '<start_frame type="int">',... startFrame
        '<max_frame type="int">',... endFrame
        '<drift_correction type="int">',... %  CorDrift
        '<frame_step type="int">',... dframes
        '<d_scale type="int">',...dscales
        '<do_zfit type="int">',... Fit3D
        '<cutoff type="float">',... zcutoff
        '<min_z type="float">',...  zstart 
        '<max_z type="float">',...  zend
        '<wx_wo type="float">',...  wx0
        '<wx_c type="float">',...  gx
        '<wx_d type="float">',...  zrx
        '<wxA type="float">',...  Ax
        '<wxB type="float">',... Bx
        '<wxC type="float">',...  Cx
        '<wxD type="float">',...  Dx
        '<wy_wo type="float">',...  wy0
        '<wy_c type="float">',...  gy
        '<wy_d type="float">',...  zry
        '<wyA type="float">',...  Ay
        '<wyB type="float">',...  By
        '<wyC type="float">',...  Cy
        '<wyD type="float">',...  Dy
        '<x_start type="int">',... xmin
        '<x_stop type="int">',... xmax
        '<y_start type="int">',... ymin
        '<y_stop type="int">',... ymax
         };
     
    % Read in current parameter values from xmlfile
      target_values = read_parameterfile(SF{handles.gui_number}.xmlfile,parameters,'<');
    % save these values into global FitPars;
      Pfields = {'method','threshold','maxits','bkd','ppnm','initwidth',...
          'descriptor','displacement','startFrame','endFrame','CorDrift',...
          'dframes','dscale','Fit3D','zcutoff','zstart','zend','wx0','gx',...
          'zrx','Ax','Bx','Cx','Dx','wy0','gy','zry','Ay','By','Cy','Dy',...
          'xmin','xmax','ymin','ymax'};
      FitPars = cell2struct(target_values,Pfields,2);  
      parsfile = SF{handles.gui_number}.xmlfile;
      
elseif FitMethod == 3  
    if isempty(SF{handles.gui_number}.gpufile)
        disp('no gpu parameter file found, loading defaults');
        SF{handles.gui_number}.gpufile = defaultGPUmFile;
    end
    load(SF{handles.gui_number}.gpufile);
    parsfile = SF{handles.gui_number}.gpufile;
    FitPars = GPUmultiPars;
    parameters = ''; 
end      
    set(handles.CurrentPars,'String',parsfile);
% save('C:\Users\Alistair\Documents\Projects\General_STORM\Test_data\test3.mat');




function parfile = make_temp_parameters(handles,temp)
% append '_temp' to parameterfile, save in scratch directory
global SF
FitMethod = get(handles.FitMethod,'Value');
if FitMethod == 1
    parflag = '.ini';
   parfile = scratch_parameters(SF{handles.gui_number}.inifile,temp,parflag); 
elseif FitMethod == 2
    parflag = '.xml';
   parfile = scratch_parameters(SF{handles.gui_number}.xmlfile,temp,parflag);
elseif FitMethod == 3
    parflag = '.mat';
   parfile = scratch_parameters(SF{handles.gui_number}.gpufile,temp,parflag);
end
    
function parfile = scratch_parameters(parfile,temp,parflag)
global scratchPath
 [currpath,currpar] = ExtractPath(parfile);
    if isempty(strfind(currpar,temp)) || isempty(strfind(scratchPath,currpath))
        parfile = [scratchPath,currpar(1:end-4),'_',temp,parflag];
    else
        % no change needed 
    end



% --- Executes on button press in FitParameters.
function FitParameters_Callback(hObject, eventdata, handles)
% hObject    handle to FitParameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SF scratchPath
% disp('loading inifile');
% disp(inifile);
 FitMethod = get(handles.FitMethod,'Value');
[SF{handles.gui_number}.FitPars,parameters] = ReadParameterFile(FitMethod,handles); 
parfile = make_temp_parameters(handles,'temp'); % if _temp.ini / .xml parameter files have not been made, make them.
SF{handles.gui_number}.FitPars.OK = false;

 if FitMethod == 1 % InsightM
    f = GUIFitParameters(handles.gui_number);
    waitfor(f); % need to wait until parameter selection is closed. 
    if SF{handles.gui_number}.FitPars.OK 
        new_values = struct2cell(SF{handles.gui_number}.FitPars)';
        modify_script(SF{handles.gui_number}.inifile,parfile,parameters,new_values,'');   
        SF{handles.gui_number}.inifile = parfile;
    end
 %   disp(inifile);
 elseif FitMethod == 2    % DaoSTORM   
     disp(['SF instanceID = ', num2str(handles.gui_number)]);
    f = GUIDaoParameters(handles.gui_number);
    waitfor(f); % need to wait until parameter selection is closed.   
    if SF{handles.gui_number}.FitPars.OK % only update parameters if user presses save button
        new_values = struct2cell(SF{handles.gui_number}.FitPars)';
        modify_script(SF{handles.gui_number}.xmlfile,parfile,parameters,new_values,'<');
        SF{handles.gui_number}.xmlfile = parfile;
    end
 elseif FitMethod == 3
    f = GUIgpuParameters(handles.gui_number);
    waitfor(f);
    if SF{handles.gui_number}.FitPars.OK
        GPUmultiPars = SF{handles.gui_number}.FitPars; %#ok<NASGU>
        SF{handles.gui_number}.gpufile = parfile; 
        save(SF{handles.gui_number}.gpufile,'GPUmultiPars');
    end
 end
    set(handles.CurrentPars,'String',parfile);
% save([scratchPath 'test10.mat']);
% load([scratchPath 'test10.mat']);


% --- Executes on selection change in FitMethod.
function FitMethod_Callback(hObject, eventdata, handles)
% hObject    handle to FitMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SF
 FitMethod = get(handles.FitMethod,'Value');
 SF{handles.gui_number}.FitPars = ReadParameterFile(FitMethod,handles);
% Important that FitPars matches the current Fitting method.  



% --- Executes on slider movement.
function FrameSlider_Callback(hObject, eventdata, handles)
% hObject    handle to FrameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global SF
SF{handles.gui_number}.impars.cframe = round(get(handles.FrameSlider,'Value'));
set(handles.currframe,'String',num2str(SF{handles.gui_number}.impars.cframe));
UpdateFrame(hObject, handles);


% --------------------------------------------------------------------
function ManualContrast_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to ManualContrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SF

dlg_title = 'Manual Contrast';
num_lines = 1;
prompt = {
    'Min Intensity',...
    'Max Intensity'};

default_opts = {
     num2str(SF{handles.gui_number}.impars.cmin),...
     num2str(SF{handles.gui_number}.impars.cmax)};
 
default_opts = inputdlg(prompt,dlg_title,num_lines,default_opts);
if ~isempty(default_opts) % was not canceled
SF{handles.gui_number}.impars.cmin = str2double(default_opts{1});
SF{handles.gui_number}.impars.cmax = str2double(default_opts{2});
UpdateFrame(hObject, handles);
end

% --------------------------------------------------------------------
function AutoContrast_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to AutoContrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SF
SF{handles.gui_number}.impars.cmax = max(SF{handles.gui_number}.impars.Im(:));
SF{handles.gui_number}.impars.cmin = min(SF{handles.gui_number}.impars.Im(:));
UpdateFrame(hObject, handles);



function currframe_Callback(hObject, eventdata, handles)
% hObject    handle to currframe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SF
SF{handles.gui_number}.impars.cframe = str2double(get(handles.currframe,'String'));
UpdateFrame(hObject, handles);





% --------------------------------------------------------------------
function MenuSavePars_Callback(hObject, eventdata, handles)
% hObject    handle to MenuSavePars (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
global SF
    FitMethod = get(handles.FitMethod,'Value');
 % setup starting folder for uigetfile

    if ~isempty(SF{handles.gui_number}.daxfile)
        startfolder = ExtractPath(SF{handles.gui_number}.daxfile); 
    else
         startfolder = pwd;
    end
    
    
    [FitPars,parameters] = ReadParameterFile(FitMethod,handles);  % load current parameters in FitPars
    [savename, savepath,hadinput] = uiputfile(...
    {'*.ini;*.xml;*.mat','Parameter Files (*.ini, *.xml, *.mat)'},...
        'Save Parameter File',startfolder); % get file path and save name
    if hadinput > 0
        k = strfind(savename,'.');
        if ~isempty(k);
            savename = savename(1:k-1);
        end
        % save current parameters with menufile name / directory specified above
        if FitMethod == 1
            savename = [savename,'.ini'];
            modify_script(SF{handles.gui_number}.inifile,...
                [savepath,savename],parameters,...
                struct2cell(FitPars),'');   
        elseif FitMethod == 2
            savename = [savename,'.xml'];
            modify_script(SF{handles.gui_number}.xmlfile,...
                [savepath,savename],parameters,...
                struct2cell(FitPars),'<'); 
        elseif FitMethod == 3
            savename = [savename,'.mat'];
            GPUmultiPars = FitPars;  %#ok<NASGU>
            SF{handles.gui_number}.gpufile =[savepath,filesep,savename]; 
            save(SF{handles.gui_number}.gpufile,'GPUmultiPars');
        end
    end
    set(handles.CurrentPars,'String',[savepath,filesep,savename]);

    % --------------------------------------------------------------------
function MenuLoadPars_Callback(hObject, eventdata, handles)
% hObject    handle to MenuLoadPars (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global SF
    
    % setup starting folder for uigetfile
    if ~isempty(SF{handles.gui_number}.daxfile)
        startfolder = ExtractPath(SF{handles.gui_number}.daxfile);
    else
        startfolder = pwd;
    end

    
    [filename,filepath,hadinput] = uigetfile(...
        {'*.ini;*.xml;*.mat','Parameter Files (*.ini, *.xml, *.mat)'},...
        'Select Parameter File',startfolder); % get file path and save name
    if hadinput > 0
        k = strfind(filename,'.');
        if strcmp(filename(k:end),'.ini');
            SF{handles.gui_number}.inifile = [filepath,filename];
            parsfile = SF{handles.gui_number}.inifile;
            method = 1;
        elseif strcmp(filename(k:end),'.xml');
            SF{handles.gui_number}.xmlfile = [filepath,filename];
            parsfile = SF{handles.gui_number}.xmlfile;
            method = 2;
        elseif strcmp(filename(k:end),'.mat');
            SF{handles.gui_number}.gpufile = [filepath,filename];
            parsfile = SF{handles.gui_number}.gpufile;
            method = 3;
        else
            disp([filename,' is not a recognized parameter file']); 
        end
        set(handles.CurrentPars,'String',parsfile);
        set(handles.FitMethod,'Value',method);
    end
    
    


% --------------------------------------------------------------------
function MenuAnalyzeCurrent_Callback(hObject, eventdata, handles)
% hObject    handle to MenuAnalyzeCurrent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SF 
 FitMethod = get(handles.FitMethod,'Value');
 runinMatlab = ~eval(SF{handles.gui_number}.defaultAopts{1});
 printprogress = ~eval(SF{handles.gui_number}.defaultAopts{1});
 hideterminal = eval(SF{handles.gui_number}.defaultAopts{2});
 overwrite = eval(SF{handles.gui_number}.defaultAopts{3});
 minsize = eval(SF{handles.gui_number}.defaultAopts{4})*1E6;
 maxCPU  = eval(SF{handles.gui_number}.defaultAopts{5});
 verbose = eval(SF{handles.gui_number}.defaultAopts{6});
 binname = SF{handles.gui_number}.defaultAopts{7};
 
if FitMethod == 1
    method = 'insight';
    parsfile = SF{handles.gui_number}.inifile;
elseif FitMethod == 2
    method= 'DaoSTORM'; 
    parsfile = SF{handles.gui_number}.xmlfile;
end
 RunDotFinder('daxfile',SF{handles.gui_number}.daxfile,'parsfile',...
      parsfile,'method',method,'maxCPU',maxCPU,'verbose',verbose,...
     'runinMatlab',runinMatlab,'printprogress',printprogress,...
     'hideterminal',hideterminal,'overwrite',overwrite,'minsize',minsize,...
     'binname',binname);

% --------------------------------------------------------------------
function MenuAnalyzeAll_Callback(hObject, eventdata, handles)
% hObject    handle to MenuAnalyzeAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SF

 
 maxCPU  = eval(SF{handles.gui_number}.defaultAopts{5});
 verbose = eval(SF{handles.gui_number}.defaultAopts{6});
FitMethod = get(handles.FitMethod,'Value');
if FitMethod == 1
    parsfile = SF{handles.gui_number}.inifile;
    method = 'insight';
    partype = '.ini';
elseif FitMethod == 2
    parsfile = regexprep(SF{handles.gui_number}.xmlfile,'_1frame',''); % remove temp flag.  
    method = 'DaoSTORM';
    partype = '.xml';
elseif FitMethod == 3
    parsfile = SF{handles.gui_number}.gpufile;
    method = 'GPUmultifit';
    partype = '.mat';
end

if isempty(parsfile)
    parsfile = '';
end


dlg_title = 'Run all dax files in folder';
num_lines = 1;
Dprompt = {
    'batch size (number of jobs to run at once)';
    'all dax files containing string'; %  
    'parameter file name or unique part of name'; % 
    'overwrite existing? (1=yes all, 0=no all, 2=ask me)';
    'min file size (Mb)';
    'run silently? (no cmd windows will be opened)';
    'new mlist name  (''=current, DAX = append daxfile, # = index)'};
Dopts = {
    '3',...
    '',...
    parsfile,...
    'false',...
    '60',...
    'false',...
    ''}; 
Dopts = inputdlg(Dprompt,dlg_title,num_lines,Dopts);

% If a parameter file with file ending is specified, call RunDotFinder with
% that specific parameter file.  Otherwise, assume it is parameter root and
% find automatically any parameter file with that root in the name. 
if ~isempty(Dopts)  % dealing with cancel
    if isempty(strfind(Dopts{3},partype))
        parflag = 'parsroot';
    else
        parflag = 'parsfile';
    end

    k = strfind(SF{handles.gui_number}.daxfile,filesep);
    fpath = SF{handles.gui_number}.daxfile(1:k(end));
    RunDotFinder('path',fpath,'batchsize',eval(Dopts{1}),'daxroot',Dopts{2},...
         parflag,Dopts{3},'overwrite',eval(Dopts{4}),'method',method,...
         'minsize',eval(Dopts{5})*1E6,'hideterminal',eval(Dopts{6}),...
         'binname',Dopts{7},'maxCPU',maxCPU,'verbose',verbose);
end





% --- Executes during object creation, after setting all properties.
function FrameSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function currframe_CreateFcn(hObject, eventdata, handles)
% hObject    handle to currframe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function FitMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FitMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------
function MenuFile_Callback(hObject, eventdata, handles)
% hObject    handle to MenuFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MenuAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to MenuAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MenuComputeZcal_Callback(hObject, eventdata, handles)
% hObject    handle to MenuComputeZcal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global SF scratchPath
daxfile = SF{handles.gui_number}.daxfile;
FitMethod = get(handles.FitMethod,'Value');
if FitMethod == 1
    parsfile = SF{handles.gui_number}.inifile;
    method = 'insight';
elseif FitMethod == 2
    parsfile = SF{handles.gui_number}.xmlfile;
    method = 'DaoSTORM';
elseif FitMethod == 3
    disp('Z-fitting not available for GPU multifit');
end
if isempty(parsfile)
    disp('warning no parameter file selected');
    disp('perhaps Fit Method does not match current parameter type?');
end

dlg_title = 'Compute Z-calibration';
num_lines = 1;
Zprompt = {
    'New Parameter file name (will have daxname if blank)'; % 
    'Template Parameter file name (type "open" to get file selection window)';
    'Run in Matlab?';
    'Run Silently?';
    'overwrite? (1=y,0=n,2=ask me)';
    'Show plots?';
    'Show extra plots?';
    'Edit calibration parameters?'};

try
    Zopts = inputdlg(Zprompt,dlg_title,num_lines,...
                    SF{handles.gui_number}.Zopts);
catch % Reset defaults if nothing is loaded
    Zopts = {
        '',...
        '',...
        'true',...
        'false',...
        '2',...
        'true',...
        'false',...
        'false'};   
Zopts = inputdlg(Zprompt,dlg_title,num_lines,Zopts);
end

if ~isempty(Zopts)  % If Options was canceled, do nothing
    if ~isfield(SF{handles.gui_number},'Zpars')
        SF{handles.gui_number}.Zpars = {...
                                        '1'
                                        '1'
                                        '0.8'
                                        '300'
                                        '0.1'
                                        '1500'
                                        '[100 600]'
                                        '[100 700]'
                                        '[-600 600]'
                                        };
    end
    Zpars = SF{handles.gui_number}.Zpars;

    if strcmp(Zopts{2},'open')
        startfolder = ExtractPath(daxfile);
        [filename,pathname,okay] = uigetfile({'*.xml','DaoSTORM pars (*.xml)';...
        '*.ini','Insight pars (*.ini)'},'Select parameter file',startfolder);
        if okay~=0
            Zopts{2} = [pathname,filesep,filename]; 
        end
    end

    if eval(Zopts{8})
        dlg_title = 'Set Z-calibration parameters';
        num_lines = 1;
        parameterDescriptions = {...
            'start frame to ID feducials'
            'max allowed drift of feducial during movie'
            'molecule on for at least this fraction of frames'
            'max outlier from preliminary z-fit (nm)'
            'fraction of ends of curve to ignore'
            'max width of beads PSF (nm)'
            'range of allowed w0'
            'range of allowed zr'
            'range of allowed g'
        };
        Zpars = inputdlg(parameterDescriptions,dlg_title,num_lines,...
                        SF{handles.gui_number}.Zpars);
    end
    if ~isempty(Zpars) % 
 
     RunDotFinder('daxfile',daxfile,'parsfile',parsfile,'method',method,...
     'runinMatlab',eval(Zopts{3}),'hideterminal',eval(Zopts{4}),...
     'overwrite',eval(Zopts{5}),'printprogress',eval(Zopts{4}),'verbose',false);
 
    CalcZcurves(daxfile,'newFile',Zopts{1},'templateFile',Zopts{2},...
    'startframe',eval(Zpars{1}),'maxdrift',eval(Zpars{2}),'fmin',eval(Zpars{3}),...
    'maxOutlier',eval(Zpars{4}),'endTrim',eval(Zpars{5}),'maxWidth',eval(Zpars{6}),...
    'w0Range',eval(Zpars{7}),'zrRange',eval(Zpars{8}),'gRange',eval(Zpars{9}),...
    'showPlots',eval(Zopts{6}),'showExtraPlots',eval(Zopts{7}),'verbose',true);

    SF{handles.gui_number}.Zopts = Zopts; 
    SF{handles.gui_number}.Zpars = Zpars; 
    end
end


% --------------------------------------------------------------------
function MenuChromeWarp_Callback(hObject, eventdata, handles) %#ok<*INUSL>
% hObject    handle to MenuChromeWarp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SF chromeWarpPars

FitMethod = get(handles.FitMethod,'Value');
if FitMethod == 1
    method = 'insight';
elseif FitMethod == 2
    method = 'DaoSTORM';
elseif FitMethod == 3
    method = 'GPUmultifit';
end

chromeWarpPars.OK = false; 
pathin = ExtractPath(SF{handles.gui_number}.daxfile);
f = ChromeWarpParameters; 
waitfor(f);
SF{handles.gui_number}.chromeWarpPars = chromeWarpPars;   
  
if SF{handles.gui_number}.chromeWarpPars.OK
    M = SF{handles.gui_number}.chromeWarpPars.NMovieSets;
    beadset(M).chns =[];
    for m=1:M 
        beadset(m).chns = SF{handles.gui_number}.chromeWarpPars.Chns{m};
        beadset(m).refchn = SF{handles.gui_number}.chromeWarpPars.ReferenceChannel{m};
        beadset(m).daxroot = SF{handles.gui_number}.chromeWarpPars.DaxfileRoots{m};
        beadset(m).parsroot = SF{handles.gui_number}.chromeWarpPars.ParameterRoots{m};
        beadset(m).quadview = SF{handles.gui_number}.chromeWarpPars.Quadview{m};
    end
    chromeWarpPars = SF{handles.gui_number}.chromeWarpPars;
    CalcChromeWarp(pathin,'beadset',beadset,'method',method,...
        'QVorder',chromeWarpPars.QVorder,'overwrite',chromeWarpPars.OverwriteBin,...
        'save root',chromeWarpPars.SaveNameRoot,'affine match radius',chromeWarpPars.AffineRadius,...
        'polyfit match radius',chromeWarpPars.PolyRadius,'verbose',chromeWarpPars.VerboseOn,...
        'hideterminal',chromeWarpPars.HideTerminal,'Noclass9',chromeWarpPars.ExcludePoorZ,...
        'frames per Z',chromeWarpPars.FramesPerZ,'exportData',chromeWarpPars.ExportDataOn,...
        'fit3D',chromeWarpPars.is3D); 
end



% --------------------------------------------------------------------
function zcalini2xml_Callback(hObject, eventdata, handles) %#ok<*DEFNU,*INUSD>
% hObject    handle to zcalini2xml (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global SF defaultXmlFile

SF{handles.gui_number}.inifile = char(SF{handles.gui_number}.inifile);
SF{handles.gui_number}.xmlfile = char(SF{handles.gui_number}.xmlfile);

if ~isempty(SF{handles.gui_number}.daxfile)
    [dpath,filename] = ExtractPath(SF{handles.gui_number}.daxfile);
else
    [dpath,filename] = ExtractPath(SF{handles.gui_number}.inifile);
end

if isempty(SF{handles.gui_number}.xmlfile);
   SF{handles.gui_number}.xmlfile = defaultXmlFile;
end

xmlout = [dpath,filename(1:end-4),'.xml'];

dlg_title = 'convert ini z-calibration to xml file';
num_lines = 1;
prompt = {
    'inifile',...
    'xml reference file',...
    'xml save file'};
i2xopts = {
    SF{handles.gui_number}.inifile,...
    SF{handles.gui_number}.xmlfile,...
    xmlout}; 
i2xopts = inputdlg(prompt,dlg_title,num_lines,i2xopts);

if ~isempty(i2xopts) % Dialogue was not canceled or closed
    zcal_ini2xml(i2xopts{1},i2xopts{2},i2xopts{3});
    
    % set this to the current xmlfile and switch to DaoSTORM
    SF{handles.gui_number}.xmlfile = i2xopts{3}; 
    set(handles.CurrentPars,'String',SF{handles.gui_number}.xmlfile);
    set(handles.FitMethod,'Value',2);
end







% --------------------------------------------------------------------
function MenuOptions_Callback(hObject, eventdata, handles)
% hObject    handle to MenuOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MenuAnalysisOptions_Callback(hObject, eventdata, handles)
% hObject    handle to MenuAnalysisOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SF

dlg_title = 'Analysis options';
num_lines = 1;
    Aprompt = {
    'run externally (set false for troubeshooting)',...
    'run in background (or in new cmd prompt)',...
    'overwrite? (1=y,0=n,2=ask me)',...
    'min daxfile size (Mb)',...
    'max CPU % (reserve system resources)'...
    'verbose',...
    'new binfile name (DAX = daxfile name, # = index num)'; 
    };
defaultAopts = SF{handles.gui_number}.defaultAopts;
defaultAopts = inputdlg(Aprompt,dlg_title,num_lines,defaultAopts);
if ~isempty(defaultAopts)
    SF{handles.gui_number}.defaultAopts = defaultAopts;
end
