function varargout = ChromatinCropper(varargin)
% CHROMATINCROPPER MATLAB code for ChromatinCropper.fig
%      CHROMATINCROPPER, by itself, creates a new CHROMATINCROPPER or raises the existing
%      singleton*.
%
%      H = CHROMATINCROPPER returns the handle to a new CHROMATINCROPPER or the handle to
%      the existing singleton*.
%
%      CHROMATINCROPPER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHROMATINCROPPER.M with the given input arguments.
%
%      CHROMATINCROPPER('Property','Value',...) creates a new CHROMATINCROPPER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ChromatinCropper_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ChromatinCropper_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ChromatinCropper

% Last Modified by GUIDE v2.5 02-Dec-2013 14:46:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ChromatinCropper_OpeningFcn, ...
                   'gui_OutputFcn',  @ChromatinCropper_OutputFcn, ...
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


% --- Executes just before ChromatinCropper is made visible.
function ChromatinCropper_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ChromatinCropper (see VARARGIN)

% Initialize Global GUI Parameters
    global CC
    if isempty(CC) % Build GUI instance ID 
        CC = cell(1,1);
    else
        CC = [CC;cell(1,1)];
    end
    handles.gui_number = length(CC);
    set(handles.CCinstance,'String',['inst id',num2str(handles.gui_number)]);

    CC{handles.gui_number}.source = '';
    CC{handles.gui_number}.imnum = 1;
    CC{handles.gui_number}.step = 1;
    CC{handles.gui_number}.Dirs = ...
       {'Step 1: load conventional image';
        'Step 2: Find all spots in conventional image';
        'Step 3: load STORM image and filter on cluster properties';
        'Step 4: Perform drift correction';
        'Step 5: Crop and plot STORM-image';
        'Step 6: Quantify structural features';
        'Step 7: Save data'};
    
% Cleanup Axes
    axes(handles.axes2);
    set(gca,'color','k');
    set(gca,'XTick',[],'YTick',[]);

    axes(handles.axes2);
    set(gca,'color','k');
    set(gca,'XTick',[],'YTick',[]);
    
% Default Parameters for GUI
   % General control parameters
    CC{handles.gui_number}.auto = false; % autocycle
   % widely used parameters
    CC{handles.gui_number}.pars0.H = 256;
    CC{handles.gui_number}.pars0.W = 256;
    CC{handles.gui_number}.pars0.npp = 160;
    CC{handles.gui_number}.pars0.cmin = 0;
    CC{handles.gui_number}.pars0.cmax = 1;
    % step1 parameters
    CC{handles.gui_number}.pars1.BeadFolder = '';
    % step 2 parameters
     CC{handles.gui_number}.pars2.saturate = 0.001;
     CC{handles.gui_number}.pars2.makeblack = 0.998; 
     CC{handles.gui_number}.pars2.beadDilate = 2;
     CC{handles.gui_number}.pars2.beadThresh = .3;
    % step 3 parameters
     CC{handles.gui_number}.pars3.boxSize = 32; % linear dimension in nm of box
     CC{handles.gui_number}.pars3.maxsize = 1.2E5; % 1E4 at 10nm boxsize, 1.2 um x 1.2 um 
     CC{handles.gui_number}.pars3.minsize= 20; % eg. minsize is 100 10x10 nm boxes.  400 is 200x200nm
     CC{handles.gui_number}.pars3.mindots = 500; % min number of localizations per STORM dot
     CC{handles.gui_number}.pars3.mindensity = 0; % min number of localizations per STORM dot
     CC{handles.gui_number}.pars3.startFrame = 1; 
     % step 4 parameters
    CC{handles.gui_number}.pars4.maxDrift = 3;
    CC{handles.gui_number}.pars4.fmin = .5;
    CC{handles.gui_number}.pars4.startFrame = 1;
    CC{handles.gui_number}.pars4.showPlots = true; 
    CC{handles.gui_number}.pars4.showExtraPlots = false; 
    % step 5 parameters
    CC{handles.gui_number}.pars5.scale = 2048;
    CC{handles.gui_number}.pars5.zm = 1; 
    CC{handles.gui_number}.pars5.showColorTime = true; % This is useful but slow
    % step 6 parameters
    CC{handles.gui_number}.pars6.boxSize = 32;
    CC{handles.gui_number}.pars6.startFrame= 1; % 
	CC{handles.gui_number}.pars6.minloc = 1; % min number of localization per box
	CC{handles.gui_number}.pars6.minSize = 30; % min size in number of boxes
    % step 7 parameters
    CC{handles.gui_number}.pars7.saveColorTime = true; % This is useful but slow
    CC{handles.gui_number}.pars7.saveroot = '';
    % step X parameters for X-correlation drift correction
    CC{handles.gui_number}.parsX.stepFrame = 8000; % 'stepframe' / double / 10E3 -- number of frames to average
    CC{handles.gui_number}.parsX.scale  = 5; % 'scale' / double / 5 -- upsampling factor for binning localizations
    CC{handles.gui_number}.parsX.showPlots = true;   % 'showplots' / logical / true -- plot computed drift?
    CC{handles.gui_number}.parsX.local = 0;

% Choose default command line output for ChromatinCropper
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ChromatinCropper wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ChromatinCropper_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in RunStep.
function RunStep_Callback(hObject, eventdata, handles) %#ok<*DEFNU,*INUSL,*INUSD>
% hObject    handle to RunStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% global parameters
global CC ScratchPath %#ok<*NUSED>

% Common Parameters
     H = CC{handles.gui_number}.pars0.H;
     W = CC{handles.gui_number}.pars0.W;
     npp = CC{handles.gui_number}.pars0.npp;
    cluster_scale = CC{handles.gui_number}.pars0.npp/CC{handles.gui_number}.pars3.boxSize; 
    
     % Image properties 
        imaxes.H = H;
        imaxes.W = W;
        imaxes.scale = 1;
        
    set(handles.subaxis1,'Visible','off');
    set(handles.subaxis2,'Visible','off'); 
    set(handles.subaxis3,'Visible','off');
    set(handles.subaxis4,'Visible','off'); 

% If first time running, find all bin files in folder        
if isempty(CC{handles.gui_number}.source)
    CC{handles.gui_number}.source = get(handles.SourceFolder,'String'); 
       
    CC{handles.gui_number}.binfiles = ...
         dir([CC{handles.gui_number}.source,filesep,'*_alist.bin']);
end

if isempty(CC{handles.gui_number}.binfiles)
 error(['error, no alist.bin files found in folder ',...
     CC{handles.gui_number}.source]);
end   

% Parse bin name and dax name for current image
    binfile = CC{handles.gui_number}.binfiles(CC{handles.gui_number}.imnum);
    folder = CC{handles.gui_number}.source;
    daxname = [binfile.name(1:end-10),'.dax'];    
    set(handles.ImageBox,'String',binfile.name);
    imnum = CC{handles.gui_number}.imnum;

    if isempty(CC{handles.gui_number}.pars1.BeadFolder)
        CC{handles.gui_number}.pars1.BeadFolder = ...
            [folder,filesep,'..',filesep,'Beads',filesep];
    end
    
    
% Actual Step Commands
step = CC{handles.gui_number}.step;
if step == 1
          
         goOn = true;
    % MaxProjection of Conventional Image    
         convname = regexprep([folder,filesep,daxname],'storm','conv*');
         convname = dir(convname);
         convZs = length(convname);
         dax = zeros(H,W,1,'uint16');
         for z=1:convZs
             try
                 daxtemp = mean(ReadDax([folder,filesep,convname(z).name],'verbose',false),3);
                 dax = max(cat(3,dax,daxtemp),[],3);
             catch er
                 disp(er.message);
             end
         end
             
         figure(11); clf; imagesc(dax); colorbar; colormap hot;
         title('conventional image projected');
         try
            % get conventional image name, 
            if isempty(strfind(daxname,'647quad'))
            conv0Name = ['splitdax\647quad_',regexprep(daxname,'storm','conv_z0')];
            conv0Name = [folder,filesep,conv0Name];
            else
            conv0Name = regexprep([folder,filesep,daxname],'storm','conv_z0');
            end
            conv0 = mean(ReadDax(conv0Name,'verbose',false),3);
         catch er
            disp(er.message);
            disp(['could not find file ',conv0Name]);
            conv0 = dax;  
         end

          %%% try to load lamina and beads
         try
            laminaName =  regexprep(conv0Name,'647','488');
            lamina = mean(ReadDax(laminaName,'verbose',false),3);
         catch er
            disp(er.message);
            lamina = zeros(size(dax),'uint16');  
         end
         
         try
             beadsName=regexprep(conv0Name,'647','561');
             beads= mean(ReadDax(beadsName,'verbose',false),3);
         catch er
            disp(er.message);
            beads = zeros(size(dax),'uint16');
         end
         %%% try to correct channel misfits
         BeadFolder = CC{handles.gui_number}.pars1.BeadFolder;
         
         try
             if ~strcmp(BeadFolder,'skip')
                 warpfile = [BeadFolder,filesep,'chromewarps.mat'];
                 load(warpfile);

                 chn488 = find(strcmp(chn_warp_names(:,1),'488')); %#ok<NODEF>
                warpedLamina = imtransform(lamina,tform_1_inv{chn488},...
                    'XYScale',1,'XData',[1 256],'YData',[1 256]); %#ok<USENS>
                warpedLamina = imtransform(warpedLamina,tform2D_inv{chn488},...
                    'XYScale',1,'XData',[1 256],'YData',[1 256]); %#ok<USENS>

                 chn561 = find(strcmp(chn_warp_names(:,1),'561'));
                warpedBeads = imtransform(beads,tform_1_inv{chn561},...
                    'XYScale',1,'XData',[1 256],'YData',[1 256]);
                warpedBeads = imtransform(warpedBeads,tform2D_inv{chn561},...
                    'XYScale',1,'XData',[1 256],'YData',[1 256]);
             end
         catch er
             % save([ScratchPath,'test.mat']);
             %  load([ScratchPath,'test.mat']);
             goOn = false;
             disp(er.message);
             BeadFolder = uigetdir(folder,'..');
             if BeadFolder == 0
                BeadFolder = 'skip';
             end 
             CC{handles.gui_number}.pars1.BeadFolder = BeadFolder;
             disp(BeadFolder)
             if ~strcmp(BeadFolder,'skip')
                 warpfile = [BeadFolder,filesep,'chromewarps.mat'];
                 load(warpfile);
                 disp(['found ',warpfile,' Rerun step to continue']);    
             else % skip drift correction
                  goOn = true;
             end
         end
         
%          save([ScratchPath,'test.mat']);
%          load([ScratchPath,'test.mat']);
         
         
         if goOn
             
             if  strcmp(BeadFolder,'skip')
                 warpedLamina = lamina;
                 warpedBeads = beads;
             end
             
            conv0 = uint16(conv0);
            warpedBeads = uint16(warpedBeads);
            warpedLamina = uint16(warpedLamina);           
            conv0 = imadjust(conv0,stretchlim(conv0,0));
            warpedBeads = imadjust(warpedBeads,stretchlim(warpedBeads,0));
            warpedLamina = imadjust(warpedLamina,stretchlim(warpedLamina,0));

            % save([ScratchPath,'test.mat'])
            %  load([ScratchPath,'test.mat'])

            axes(handles.axes1);
            set(gca,'color','k');
            set(gca,'XTick',[],'YTick',[]);
            [H,W] = size(conv0);
            convI = zeros(H,W,3,'uint16');
            convI(:,:,1) = conv0;
            convI(:,:,2) = warpedBeads;
            convI(:,:,3) = warpedLamina;        

            % Plot results
            axes(handles.axes1);
            set(gca,'color','k');
            set(gca,'XTick',[],'YTick',[]);
            imagesc(convI);
            colormap hot;
            xlim([0,W]); ylim([0,H]);

            axes(handles.axes2);
            imagesc(convI); colormap hot;
            set(gca,'color','k');
            set(gca,'XTick',[],'YTick',[]);

            % Save step data into global; 
            CC{handles.gui_number}.conv = conv0;  
            CC{handles.gui_number}.maskBeads = warpedBeads;
            CC{handles.gui_number}.convI = convI;
         end
         
elseif step == 2
        % load variables from previous step
        conv0 = CC{handles.gui_number}.conv;
        convI = CC{handles.gui_number}.convI;
        maskBeads = CC{handles.gui_number}.maskBeads;
        
        % load parameters
         saturate =  CC{handles.gui_number}.pars2.saturate; % 0.001;
         makeblack = CC{handles.gui_number}.pars2.makeblack; %  0.998; 
         beadDilate = CC{handles.gui_number}.pars2.beadDilate; %  2; 
         beadThresh = CC{handles.gui_number}.pars2.beadThresh; %  .3; 
         
  
        % Step 2: Threshold to find spots  [make these parameter options]
         try
             daxMask = mycontrast(uint16(conv0),saturate,makeblack); 
         catch er
             disp(er.message)
         end
         % figure(2); clf; imagesc(daxMask); colorbar;
         daxMask = daxMask > 1;
         beadMask = imdilate(maskBeads,strel('disk',beadDilate));
         beadMask = im2bw(beadMask,beadThresh);
         
%          save([ScratchPath,'test.mat']);
%          load([ScratchPath,'test.mat']);

         maskIm = convI;
         maskIm(:,:,1) = maskIm(:,:,1) + uint16(2^16*daxMask);
         maskIm(:,:,2) = maskIm(:,:,2) + uint16(2^16*beadMask);
         daxMask = daxMask - beadMask > 0; 

%           figure(1); clf; imagesc(beadMask);
%            figure(2); clf; imagesc(daxMask);
         
         % plot mask
         axes(handles.axes1); cla;
         set(gca,'color','k');
         set(gca,'XTick',[],'YTick',[]);
         imagesc(maskIm); 
         xlim([0,W]); ylim([0,H]);
         
        % Save step data into global
        CC{handles.gui_number}.daxMask = daxMask; 
        
        
        
elseif step == 3
     % load variables from previous steps
     daxMask = CC{handles.gui_number}.daxMask;
     convI = CC{handles.gui_number}.convI;
     maxsize = CC{handles.gui_number}.pars3.maxsize;
     minsize = CC{handles.gui_number}.pars3.minsize;
     mindots = CC{handles.gui_number}.pars3.mindots; 
     startframe = CC{handles.gui_number}.pars3.startFrame; 
     mindensity = CC{handles.gui_number}.pars3.mindensity;
     
     % Step 3: Load molecule list and bin it to create image
        mlist = ReadMasterMoleculeList([folder,filesep,binfile.name]);
        infilt = mlist.frame>startframe;   
        M = hist3([mlist.yc(infilt),mlist.xc(infilt)],...
             {0:1/cluster_scale:H,0:1/cluster_scale:W});
        [h,w] = size(M);             
        mask = M>1;  %        figure(3); clf; imagesc(mask); 
        mask = imdilate(mask,strel('disk',3)); %       figure(3); clf; imagesc(mask);
        toobig = bwareaopen(mask,maxsize);  % figure(3); clf; imagesc(mask);
        mask = logical(mask - toobig) & imresize(daxMask,[h,w]); 
        mask = bwareaopen(mask,minsize);    % figure(3); clf; imagesc(mask);
        R = regionprops(mask,M,'PixelValues','Eccentricity',...
            'BoundingBox','Extent','Area','Centroid','PixelIdxList'); 
        aboveminsize = cellfun(@sum,{R.PixelValues}) > mindots;
        abovemindensity = cellfun(@sum,{R.PixelValues})./[R.Area] > mindensity;
        R = R(aboveminsize & abovemindensity);           
        allpix = cat(1,R(:).PixelIdxList);
        mask = double(mask); 
        mask(allpix) = 3;
        
        keep = mask>2; 
        reject = mask<2 & mask > 0;
            
         maskIm = imresize(convI,[h,w]);
         maskIm(:,:,1) = maskIm(:,:,1) + uint16(2^16*keep);
         maskIm(:,:,3) = maskIm(:,:,3) + uint16(2^16*reject);
        
        % plot mask in main figure window
        axes(handles.axes1); cla;
        set(gca,'color','k');
        set(gca,'XTick',[],'YTick',[]);
        imagesc(maskIm); title('dot mask'); 
        xlim([0,w]); ylim([0,h]);
        
        % Export step data
        CC{handles.gui_number}.mlist = mlist; 
        CC{handles.gui_number}.infilt = infilt; 
        CC{handles.gui_number}.R = R; 
        CC{handles.gui_number}.M = M; 
        
elseif step == 4  % DRIFT CORRECTION
    % Load variables
    mlist = CC{handles.gui_number}.mlist;
    drift_err = '';
 %   CC{handles.gui_number}.handles = handles;
      
    % Load user defined parameters
    maxDrift = CC{handles.gui_number}.pars4.maxDrift;
    fmin = CC{handles.gui_number}.pars4.fmin;
    startFrame = CC{handles.gui_number}.pars4.startFrame;
    showPlots = CC{handles.gui_number}.pars4.showPlots; 
    showExtraPlots = CC{handles.gui_number}.pars4.showExtraPlots; 
    
    
    % -----------Apply Drift Correction------------------
    try
    beadname = regexprep(daxname,{'647quad','.dax'},{'561quad','_list.bin'});
    beadbin = [folder,filesep,beadname];
     [x_drift,y_drift,~,drift_err] = feducialDriftCorrection(beadbin,...
         'maxdrift',maxDrift,'showplots',showPlots,'fmin',fmin,...
         'startframe',startFrame,'showextraplots',showExtraPlots);
    missingframes = max(mlist.frame) - length(x_drift);
    x_drift = [x_drift; zeros(missingframes,1)];
    y_drift = [y_drift; zeros(missingframes,1)];
    mlist.xc = mlist.x - x_drift(mlist.frame);
    mlist.yc = mlist.y - y_drift(mlist.frame); 
    CC{handles.gui_number}.mlist = mlist; % update in global data
    goOn = true;
    retry = 0; 
    catch er
        disp(er.message);
        warning('Feducial Drift Correction Failed');
        retry = input(['Enter 1 to change parameters, 2 to attempt ',... 
            'image-based drift correction, 3 to skip. ']);
    end
    
    if retry == 2
           dlg_title = 'Step 4 Pars: Drfit Correction';  num_lines = 1;
        Dprompt = {
        'Frames per correlation step',... 1
        'upsampling factor',... 2
        'show drift correction plots?',... 3 
        'Use data from local dot # (0=use full image)'};     %4

        Opts{1} = num2str(CC{handles.gui_number}.parsX.stepFrame);
        Opts{2} = num2str(CC{handles.gui_number}.parsX.scale);
        Opts{3} = num2str(CC{handles.gui_number}.parsX.showPlots);
        Opts{4} = num2str(CC{handles.gui_number}.parsX.local);
        Opts = inputdlg(Dprompt,dlg_title,num_lines,Opts);

        if eval(Opts{4})==0
       [x_drift,y_drift] = XcorrDriftCorrect(mlist,'stepframe',eval(Opts{1}),...
            'scale',eval(Opts{2}),'showplots',eval(Opts{3}),...    
            'imagesize',[H,W],'nm per pixel',npp);
        else
          disp(['This option requires local regions to be detected first ',...
              'Run step 4 once without drift correction, then chose a dot ',...
              'and rerun step 4 using your preferred dot for calibration']); 
          vlist = CC{handles.gui_number}.vlists{ eval(Opts{4}) };
          imaxes = CC{handles.gui_number}.imaxes{ eval(Opts{4}) };
          H = imaxes.ymax - imaxes.ymin + 1;
          W = imaxes.xmax - imaxes.xmin + 1; 
          [x_drift,y_drift] = XcorrDriftCorrect(vlist,...
             'stepframe',eval(Opts{1}),...
            'scale',eval(Opts{2}),'showplots',eval(Opts{3}),...    
            'imagesize',[H,W],'nm per pixel',npp);  
                % local area may not have dots localized up through the last frame
        % of the movie.  Just assume no drift for these final frames if
        % doing local region based correction.  (They should only be a
        % couple to couple dozen of frames = a few seconds of drift at most).
        x_drift = [x_drift,zeros(1,max(mlist.frame)-max(vlist.frame))];
        y_drift = [y_drift,zeros(1,max(mlist.frame)-max(vlist.frame))];
        end
        mlist.xc = mlist.x - x_drift(mlist.frame)';
        mlist.yc = mlist.y - y_drift(mlist.frame)';
        goOn = true;
        
    elseif retry == 1;
        goOn = false;
        
    elseif retry == 3
        disp('skipping drift correction...')
        x_drift = 0;
        y_drift = 0;
        goOn = true; 
    end
    
    if goOn
             % plot mask in main figure window
        axes(handles.axes1); cla;
        Nframes = length(x_drift); 
        try
        if Nframes > 1
            buf = round(.05*Nframes); 
        z = zeros(size(x_drift')); z= [z(1:end-buf),NaN*ones(1,buf)];
        col = [double(1:Nframes-1),NaN];  % This is the color, vary with x in this case.
         surface([x_drift';x_drift']*npp,[y_drift';y_drift']*npp,...
             [z;z],[col;col],'facecol','no','edgecol','interp',...
            'linew',1);    
        colormap('jet');
        set(gcf,'color','w'); 
        xlabel('nm'); 
        ylabel('nm'); 
        xlim([min(x_drift*npp),max(x_drift*npp)]);
        ylim([min(y_drift*npp),max(y_drift*npp)]);
         text(mean(x_drift*npp),mean(y_drift*npp),...
             ['Drift Correction Uncertainty: ',num2str(drift_err,3),'nm']);
        end
        catch
        end
        
        CC{handles.gui_number}.mlist = mlist; % update mlist; 
    end
 

elseif step == 5
 %% Load step data
    scale = CC{handles.gui_number}.pars5.scale/npp;
    zm = CC{handles.gui_number}.pars5.zm;  
    mlist = CC{handles.gui_number}.mlist; 
    infilt = CC{handles.gui_number}.infilt;
    R = CC{handles.gui_number}.R;
    
    Nclusters = length(R);
    conv0 = CC{handles.gui_number}.conv;
    convI = CC{handles.gui_number}.convI;
    
    % Update M with drift correction
      M = hist3([mlist.yc(infilt),mlist.xc(infilt)],...
             {0:1/cluster_scale:H,0:1/cluster_scale:W});
      CC{handles.gui_number}.M = M; 
      
      
        % Conventional image in finder window
     axes(handles.axes2); cla;
     imagesc(convI); colormap hot;
     set(gca,'color','k'); set(gca,'XTick',[],'YTick',[]);
    
        % Initialize subplots Clean up main figure window
    set(handles.subaxis1,'Visible','on'); set(gca,'color','k'); set(gca,'XTick',[],'YTick',[]);
    set(handles.subaxis2,'Visible','on'); set(gca,'color','k'); set(gca,'XTick',[],'YTick',[]);
    set(handles.subaxis3,'Visible','on'); set(gca,'color','k'); set(gca,'XTick',[],'YTick',[]);
    set(handles.subaxis4,'Visible','on'); set(gca,'color','k'); set(gca,'XTick',[],'YTick',[]);
     
  %------------------ Split and Plot Clusters   -----------------------
      % Arrays to store plotting data in
       Istorm = cell(Nclusters,1);
       Iconv = cell(Nclusters,1); 
       Itime = cell(Nclusters,1);
       Ihist = cell(Nclusters,1);
       Icell = cell(Nclusters,1); 
       cmp = cell(Nclusters,1); 
       vlists = cell(Nclusters,1); 
       allImaxes = cell(Nclusters,1); 
       
       figure(2); clf; imagesc(convI); 
     for n=1:Nclusters % n=3    
        % For dsiplay and judgement purposes 
        imaxes.zm = 256/(scale);
        imaxes.scale = zm;
        imaxes.cx = R(n).Centroid(1)/cluster_scale;
        imaxes.cy = R(n).Centroid(2)/cluster_scale;
        imaxes.xmin = max(imaxes.cx - scale/2,1);
        imaxes.xmax = min(imaxes.cx + scale/2,W);
        imaxes.ymin = max(imaxes.cy - scale/2,1);
        imaxes.ymax = min(imaxes.cy + scale/2,H);
        allImaxes{n} = imaxes; 

   % Add dot labels to overview image           
        axes(handles.axes2); hold on; text(imaxes.cx+6,imaxes.cy,...
         ['dot ',num2str(n)],'color','w');
     figure(2);  hold on; text(imaxes.cx+6,imaxes.cy,...
         ['dot ',num2str(n)],'color','w');
     
     

   % Get STORM image      
        I = plotSTORM_colorZ({mlist},imaxes,'filter',{infilt'},...
           'Zsteps',1,'scalebar',500,'correct drift',true,'Zsteps',1); 
        Istorm{n} = I{1};  % save image; 
              
    % Zoom in on histogram (determines size / density etc)
        x1 = ceil(imaxes.xmin*cluster_scale);
        x2 = floor(imaxes.xmax*cluster_scale);
        y1 = ceil(imaxes.ymin*cluster_scale);
        y2 = floor(imaxes.ymax*cluster_scale);
        Ihist{n} = M(y1:y2,x1:x2); 

      % Conventional Image of Spot 
        Iconv{n} = conv0(ceil(imaxes.ymin):floor(imaxes.ymax),...
            ceil(imaxes.xmin):floor(imaxes.xmax));

     % STORM image of whole cell
       cellaxes = imaxes;
       cellaxes.zm = 4; % zoom out to cell scale;
       cellaxes.xmin = cellaxes.cx - cellaxes.W/2/cellaxes.zm;
       cellaxes.xmax = cellaxes.cx + cellaxes.W/2/cellaxes.zm;
       cellaxes.ymin = cellaxes.cy - cellaxes.H/2/cellaxes.zm;
       cellaxes.ymax = cellaxes.cy + cellaxes.H/2/cellaxes.zm;
       Izmout = plotSTORM_colorZ({mlist},cellaxes,...
           'filter',{infilt'},'Zsteps',1,'scalebar',500);
       Icell{n} = sum(Izmout{1},3);
   
     % Gaussian Fitting and Cluster
       % Get subregion, exlude distant zs which are poorly fit
        vlist = msublist(mlist,imaxes,'filter',infilt');
        vlist.c( vlist.z>=480 | vlist.z<-480 ) = 9;    
          % filt = (vlist.c~=9) ;        
     %  Indicate color as time. 
        dxc = vlist.xc;% max(vlist.xc)-vlist.xc; % 
        dyc = max(vlist.yc)-vlist.yc;
        Nframes = double(max(mlist.frame));
        f = double(vlist.frame);
        cmp{n} = MakeColorMap(f,Nframes);
        % [f/Nframes, zeros(length(f),1), 1-f/Nframes]; % create the color maps changed as in jet color map      
        Itime{n} = [dxc*npp,dyc*npp];
        vlists{n} = vlist; 
     end  % end loop over dots
   
        % ----------------  Export Plotting data
        CC{handles.gui_number}.vlists = vlists;
        CC{handles.gui_number}.Nclusters = Nclusters;
        CC{handles.gui_number}.R = R;
        CC{handles.gui_number}.imaxes = allImaxes;
        CC{handles.gui_number}.Istorm = Istorm;
        CC{handles.gui_number}.Iconv = Iconv;
        CC{handles.gui_number}.Icell = Icell;
        CC{handles.gui_number}.Ihist = Ihist;
        CC{handles.gui_number}.Itime = Itime;
        CC{handles.gui_number}.cmp = cmp;
      for n=1:Nclusters
              ChromatinPlots(handles, n);
              pause(.5); 
      end
      if Nclusters > 1
        CC{handles.gui_number}.dotnum = Nclusters;
        set(handles.DotSlider,'Value',Nclusters);
        set(handles.DotSlider,'Min',1);
        set(handles.DotSlider,'Max',Nclusters);  
        set(handles.DotSlider,'SliderStep',[1/(Nclusters-1),3/(Nclusters-1)]);
      end
    

elseif step == 6
    %% Load data
    Nclusters = CC{handles.gui_number}.Nclusters;
    vlists = CC{handles.gui_number}.vlists;
    npp = CC{handles.gui_number}.pars0.npp;
    
    notCancel = true;
    
    %================  Chose regions to keep
    if ~CC{handles.gui_number}.auto
        dlg_title = 'Regions to save and analyze';  num_lines = 1;
        Dprompt = {'Dots: '};  
        Opts{1} = ['[',num2str(1:Nclusters),']'];
        Opts = inputdlg(Dprompt,dlg_title,num_lines,Opts); 
        if isempty(Opts); notCancel = false; end
    if notCancel    
        saveNs = eval(Opts{1});% 
    end
    else % for autocycle, just save all images. 
        saveNs = 1:Nclusters;
    end
    
    if notCancel
    
    %================ Data Analysis
    % 2D subcluster vlist image
    boxSize = CC{handles.gui_number}.pars6.boxSize;    
    cluster_scale = CC{handles.gui_number}.pars0.npp/boxSize;
    startframe = CC{handles.gui_number}.pars6.startFrame; %  1;
    minloc = CC{handles.gui_number}.pars6.minloc; % 1;
    minSize = CC{handles.gui_number}.pars6.minSize; % 30; 
        
    % 3D subcluster
    minvoxels = 200;
    gblur = [7,7,3.5]; % 
    bins3d =[64,64,20];% number of bins per dimension  [128,128,40];
    zrange = [-500, 500];    
 
   MainArea = zeros(Nclusters,1); 
   MainLocs = zeros(Nclusters,1); 
   AllArea = zeros(Nclusters,1); 
   AllLocs = zeros(Nclusters,1); 
   % Zps = zeros(Nclusters,12); 
   CC{handles.gui_number}.M2 = [];
   CC{handles.gui_number}.map = [];
   
  
   for nn=saveNs
       n=nn; % n=4
       % Histogram localizations on tunable scale
        infilt =vlists{nn}.frame>startframe;  
        H = max([vlists{nn}.yc(infilt);vlists{nn}.xc(infilt)]);
        W = H;
           M2 = hist3([vlists{nn}.yc(infilt),vlists{nn}.xc(infilt)],...
           {0:1/cluster_scale:H,0:1/cluster_scale:W});  
 %       figure(3); clf; imagesc(M2); colorbar; caxis([0,80]); colormap hot;

       map = M2>=minloc;  
       map = imfill(map,'holes'); 
       map = bwareaopen(map,minSize);  % small regions removed
       %       figure(3); clf; imagesc(map); 
       
       Dprops = regionprops(map,M2,'PixelIdxList','Area','PixelValues',...
           'Eccentricity','BoundingBox','Extent','Centroid','PixelList');
       [MA,mainIdx] = max([Dprops.Area]);
       MainArea(n) = MA*boxSize^2;
       MainLocs(n) = sum(Dprops(mainIdx).PixelValues);
       AllArea(n) = sum([Dprops.Area])*boxSize^2;
       AllLocs(n) = sum(cat(1,Dprops.PixelValues));
       
       m = cat(1,Dprops.PixelValues); 
       xy = cat(1,Dprops.PixelList);
       % ROIcent = [m'*xy(:,1),m'*xy(:,2)]/sum(m);
       mI = m'*(xy(:,1).^2+xy(:,2).^2);
              
%        figure(3); clf; imagesc(M2); hold on;
%        plot(ROIcent(:,1),ROIcent(:,2),'c+','MarkerSize',20);
       
    %   Zps(n,:) = zernike_coeffs(M2)';
       CC{handles.gui_number}.M2{nn} = M2;
       CC{handles.gui_number}.map{nn} = map;
       
      
       
       % figure(2+n); clf; hist(log(M2(M2>0)),10); 
       % ylabel('frequency'); xlabel('log(# Localizations)'); 
      
      % % Plotting only 
      % maindotIm = 0*M2;
      % maindotIm(Dprops(mainIdx).PixelIdxList) = 1;
      % figure(2); clf; imagesc(maindotIm);
       
      % histogram variability
      hvs = M2(Dprops(mainIdx).PixelIdxList);% histgram values over main dot
      
  %--------- Cluster 3D Watershed and Fit 3D-Gaussian Spheres
        xc = vlists{nn}.xc*npp;    
        yc = vlists{nn}.yc*npp;  
        zc = vlists{nn}.zc;      
        subclusterdata.Nsubclusters = NaN;    subclusterdata.counts = NaN; 
        try       
        subclusterdata = findclusters3D(xc,yc,zc,'datarange',...
            {[0,16]*npp,[0,16]*npp,zrange},'bins',bins3d,...
            'sigmablur',gblur,'minvoxels',minvoxels,'plotson',false,...
            'fitGauss',false);
        catch er
            disp(er.message); 
            disp('error in subclustering...'); 
        end
             
    % Record statistics  
       CC{handles.gui_number}.data.mI{imnum,n} = mI;
     %  CC{handles.gui_number}.data.Zps{imnum,n} = Zps(n); 
       CC{handles.gui_number}.data.AllLocs{imnum,n} = AllLocs(n);
       CC{handles.gui_number}.data.MainLocs{imnum,n} = MainLocs(n);
       CC{handles.gui_number}.data.MainArea{imnum,n} = MainArea(n);
       CC{handles.gui_number}.data.AllArea{imnum,n} = AllArea(n); 
       CC{handles.gui_number}.data.Dvar{imnum,n} = std(hvs)/mean(hvs);
       CC{handles.gui_number}.data.Tregions{imnum,n} = subclusterdata.Nsubclusters;
       CC{handles.gui_number}.data.TregionsW{imnum,n} = sum(subclusterdata.counts/max(subclusterdata.counts));
       CC{handles.gui_number}.data.MainDots{imnum,n} = sum(Dprops(mainIdx).PixelValues);
       CC{handles.gui_number}.data.MainEccent{imnum,n} = Dprops(mainIdx).Eccentricity;
       CC{handles.gui_number}.data.vlist{imnum,n} =vlists{n}; 
       CC{handles.gui_number}.data.M{imnum,n} = M2; 
       CC{handles.gui_number}.data.R{imnum,n} = CC{handles.gui_number}.R(n); 
       
     % Update plots
        ChromatinPlots2(handles,nn);
   end
   CC{handles.gui_number}.saveNs = saveNs;
      if max(saveNs) > 1
        set(handles.DotSlider,'Value',max(saveNs));
      end
    end
  %%       
   
   
   
elseif step == 7
    % Load variables
    Icell = CC{handles.gui_number}.Icell;
    R = CC{handles.gui_number}.R;
    data = CC{handles.gui_number}.data;
    saveroot = CC{handles.gui_number}.pars7.saveroot;
    
    % save parameters
    imnum = CC{handles.gui_number}.imnum;
    saveNs = CC{handles.gui_number}.saveNs; 
    savefolder = get(handles.SaveFolder,'String');
    if isempty(saveroot)
        s1 = strfind(daxname,'quad_'); 
        s2 = strfind(daxname,'_storm');
        saveroot = daxname(s1+5:s2);
        if isempty(s1)
            s1 = 1;
            saveroot = daxname(s1:s2);
        end
        
        CC{handles.gui_number}.pars7.saveroot = saveroot;
    end
    
    if isempty(savefolder)
        error('error, no save location specified'); 
    end
    % Test if savefolder exists
    if exist(savefolder,'dir') == 0
        mk = input(['Folder ',savefolder,...
            ' does not exist.  Create it? y/n '],'s');
        if strcmp(mk,'y')
            mkdir(savefolder);
        end
    end
    
    disp(['saving data in: ',savefolder])
   
    Iout2 = figure(2); clf;
    imagesc(CC{handles.gui_number}.convI);
    colormap hot; hold on;
    
    for n=saveNs
        % summary data to print ot image
        TCounts = sum(R(n).PixelValues);
        DotSize = length(R(n).PixelValues);
        MaxD = max(R(n).PixelValues);

        % Run through figures, print out to fig 1 and save. 
        Iout = figure(1); clf; 
        showConv(handles,n);
        set(gca,'color','k'); 
        saveas(Iout,[savefolder,filesep,saveroot,...
            'Iconv_',num2str(imnum),'_d',num2str(n),'.png']);
        pause(.01);

        Iout = figure(1); clf;
        showSTORM(handles,n);
        set(gca,'color','w'); 
        title(... 
            ['dot',num2str(n),' counts=',num2str(TCounts),' size=',...
                 num2str(DotSize),' maxD=',num2str(MaxD)],...
                 'color','k');
        saveas(Iout,[savefolder,filesep,saveroot,...
            'Istorm_',num2str(imnum),'_d',num2str(n),'.png']);
        pause(.01);

        if CC{handles.gui_number}.pars7.saveColorTime
            Iout = figure(1); clf;
            showDotTime(handles,n);
            set(gca,'color','k'); set(gcf,'color','w'); 
            xlabel('nm');     ylabel('nm'); 
            saveas(Iout,[savefolder,filesep,saveroot,...
                'Itime_',num2str(imnum),'_d',num2str(n),'.png']);
            pause(.01);
        end
% 

        imwrite(makeuint(Icell{n},8),hot(256),[savefolder,filesep,saveroot,...
            'Icell_',num2str(imnum),'_d',num2str(n),'.png']);
        pause(.01);

        Iout = figure(1); clf;
        showHist(handles,n);
        set(gca,'color','k');
        saveas(Iout,[savefolder,filesep,saveroot,...
            'Ihist_',num2str(imnum),'_d',num2str(n),'.png']);
%         imwrite(Ihist{n},[savefolder,filesep,saveroot,...
%             'Ihist_',num2str(imnum),'_d',num2str(n),'.png']);
        
        imaxes = CC{handles.gui_number}.imaxes{n};
        vlist = CC{handles.gui_number}.vlists{n}; %#ok<NASGU>
        parData{1} = CC{handles.gui_number}.pars1;
        parData{2} = CC{handles.gui_number}.pars2;
        parData{3} = CC{handles.gui_number}.pars3;
        parData{4} = CC{handles.gui_number}.pars4;
        parData{5} = CC{handles.gui_number}.pars5;
        parData{6} = CC{handles.gui_number}.pars6;
        parData{7} = CC{handles.gui_number}.pars7;
        parData{8} = CC{handles.gui_number}.pars0;
        parData{9} = CC{handles.gui_number}.parsX;
        
        Imdata.Istorm = CC{handles.gui_number}.Istorm{n};
        Imdata.Iconv = CC{handles.gui_number}.Iconv{n};
        Imdata.Itime = CC{handles.gui_number}.Itime{n};
        Imdata.Ihist = CC{handles.gui_number}.Ihist{n};
        Imdata.name = CC{handles.gui_number}.binfiles(imnum).name;
        
        save([savefolder,filesep,saveroot,'DotData_',num2str(imnum),...
            '_d',num2str(n),'.mat'],'imaxes','vlist','parData','Imdata');
        
        Iout2 = figure(2); 
        text(imaxes.cx+6,imaxes.cy,...
         ['dot ',num2str(n)],'color','w'); 
     
         disp(['saving data for dot',num2str(n),'...']);  
         disp(['wrote ',savefolder,filesep,saveroot,'DotData_',...
             num2str(imnum),'_d',num2str(n),'.mat']);
         pause(.5); 
    end
    
    saveas(Iout2,[savefolder,filesep,saveroot,...
        'Overview_',num2str(imnum),'.png']);
        
    
    figure(1); clf;
    subplot(3,2,1); hist( [data.MainArea{:}] ); title('Area');
    subplot(3,2,2); hist( [data.Dvar{:}] ); title('Intensity Variation')
    subplot(3,2,3); hist( [data.MainDots{:}]./[data.MainArea{:}] ); title('localization density');
    subplot(3,2,4); hist( [data.Tregions{:}] ); title('number of regions'); 
    subplot(3,2,5); hist( [data.TregionsW{:}] ); title('Weighted number of regions')
    subplot(3,2,6); hist( [data.mI{:}] ); title('moment of Inertia'); 
    % hist( [data.MainEccent{:}] ); title('eccentricity'); 
    
    CCguiData = CC{handles.gui_number};  %#ok<NASGU>
    save([savefolder,filesep,saveroot,'data.mat'],'data','CCguiData');
    
    save([ScratchPath,'test.mat']);
    % load([ScratchPath,'test.mat']);
end % end if statement over steps
   

function ChromatinPlots(handles, n)
% plot data for cluster n in main figure window
global CC   
    axes(handles.subaxis1); cla; %#ok<*LAXES>
    showConv(handles,n);
    
    axes(handles.subaxis2); cla; %#ok<*LAXES>
    showSTORM(handles,n);
    
    axes(handles.subaxis3); hold off; cla; %#ok<*LAXES>
    showDotTime(handles,n);
    
    axes(handles.subaxis4); cla; %#ok<*LAXES>
    showHist(handles,n);

function ChromatinPlots2(handles, n)
% plot data for cluster n in main figure window 
% called during cluster stat computation
axes(handles.subaxis1); cla; %#ok<*LAXES>    
showConv(handles,n);

axes(handles.subaxis2); cla; %#ok<*LAXES>   
showSTORM(handles,n);

axes(handles.subaxis3); hold off; cla;  %#ok<*LAXES>
showAreaPlot(handles,n);

axes(handles.subaxis4); cla; %#ok<*LAXES>
showHist(handles,n);
    
    
function showDotTime(handles,n)    
global CC  
      
    if CC{handles.gui_number}.pars5.showColorTime
     hold on;
    Itime = CC{handles.gui_number}.Itime;
    cmp = CC{handles.gui_number}.cmp;
    scatter(Itime{n}(:,1),Itime{n}(:,2), 5, cmp{n}, 'filled');
    warning('off','MATLAB:hg:patch:RGBColorDataNotSupported');
    xlim([min(Itime{n}(:,1)),max(Itime{n}(:,1))]);
    ylim([min(Itime{n}(:,2)),max(Itime{n}(:,2))]);
    end
    set(gca,'color','k'); set(gcf,'color','w'); 
    set(gca,'XTick',[],'YTick',[]);

function showConv(handles,n)
global CC
    imagesc(CC{handles.gui_number}.Iconv{n}); colormap hot;
    set(gca,'color','k'); set(gca,'XTick',[],'YTick',[]);
     

function showSTORM(handles,n)
global CC
    cmin = CC{handles.gui_number}.pars0.cmin;
    cmax = CC{handles.gui_number}.pars0.cmax;
    Istorm = CC{handles.gui_number}.Istorm{n};
    Istorm = imadjust(Istorm,[cmin,cmax],[0,1]);
    R = CC{handles.gui_number}.R;
    TCounts = sum(R(n).PixelValues);
    DotSize = length(R(n).PixelValues);
    MaxD = max(R(n).PixelValues);
    cluster_scale = CC{handles.gui_number}.pars0.npp/...
                    CC{handles.gui_number}.pars3.boxSize;     
    
    imagesc(Istorm); colormap hot;
    set(gca,'color','k'); set(gca,'XTick',[],'YTick',[]);
    text(1.2*cluster_scale,2*cluster_scale,...
    ['dot',num2str(n),' counts=',num2str(TCounts),' size=',...
         num2str(DotSize),' maxD=',num2str(MaxD)],...
         'color','w');

function showAreaPlot(handles,n)
global CC
    try
    cluster_scale = CC{handles.gui_number}.pars0.npp/CC{handles.gui_number}.pars3.boxSize;     
    Area = CC{handles.gui_number}.data.AllArea{CC{handles.gui_number}.imnum,n};
    imagesc(CC{handles.gui_number}.map{n}); %
    text(1.2*cluster_scale,2*cluster_scale,...
        ['dot',num2str(n),' Area=',num2str(Area)],'color','w');
    caxis([0,1]); colormap hot;
    set(gca,'XTick',[],'YTick',[]);
    catch er
        disp(er.message); 
    end
    
function showHist(handles,n)
global CC 
    imagesc(CC{handles.gui_number}.Ihist{n}); 
    set(gca,'color','k'); set(gca,'XTick',[],'YTick',[]);



    
    
% --- Executes on button press in StepParameters.
function StepParameters_Callback(hObject, eventdata, handles)
% hObject    handle to StepParameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CC
step = CC{handles.gui_number}.step;
notCancel = true; 

if step == 1
 % just loading the image
 
  dlg_title = 'Step 1 Pars: Load Image';  num_lines = 1;
    Dprompt = {
    'Location of chromewarps.mat for chromatic correction',... 1
    };

    Opts{1} = CC{handles.gui_number}.pars1.BeadFolder;
    Opts = inputdlg(Dprompt,dlg_title,num_lines,Opts);
    if isempty(Opts); notCancel = false; end
    if notCancel
     CC{handles.gui_number}.pars1.BeadFolder = Opts{1};
    end
    
elseif step == 2
    dlg_title = 'Step 2 Pars: Conv. Segmentation';  num_lines = 1;
    Dprompt = {
    'fraction to saturate',... 1
    'fraction to make black',... 2
    'Bead area dilation',... 3 
    'Bead threshold',...  4
     };     %5 

    Opts{1} = num2str(CC{handles.gui_number}.pars2.saturate);
    Opts{2} = num2str(CC{handles.gui_number}.pars2.makeblack);
    Opts{3} =  num2str(CC{handles.gui_number}.pars2.beadDilate);
    Opts{4} =  num2str(CC{handles.gui_number}.pars2.beadThresh);
    
    Opts = inputdlg(Dprompt,dlg_title,num_lines,Opts);
    if isempty(Opts); notCancel = false; end
    if notCancel
     CC{handles.gui_number}.pars2.saturate = str2double(Opts{1});
     CC{handles.gui_number}.pars2.makeblack = str2double(Opts{2}); 
     CC{handles.gui_number}.pars2.beadDilate= str2double(Opts{3}); 
     CC{handles.gui_number}.pars2.beadThresh= str2double(Opts{4}); 
    end
elseif step == 3
    dlg_title = 'Step 3 Pars: Filter Clusters';  num_lines = 1;
    Dprompt = {
    'box size (nm)',... 1
    'max dot size (boxes)',... 2
    'min dot size (boxes)',... 3
    'min localizations',...  4
    'start frame',...  5
    'min average density',... 6
    };     

    Opts{1} = num2str(CC{handles.gui_number}.pars3.boxSize);
    Opts{2} = num2str(CC{handles.gui_number}.pars3.maxsize);
    Opts{3} = num2str(CC{handles.gui_number}.pars3.minsize);
    Opts{4} = num2str(CC{handles.gui_number}.pars3.mindots);
    Opts{5} = num2str(CC{handles.gui_number}.pars3.startFrame);
    Opts{6} = num2str(CC{handles.gui_number}.pars3.mindensity);
    Opts = inputdlg(Dprompt,dlg_title,num_lines,Opts);
    if isempty(Opts); notCancel = false; end
    if notCancel
    CC{handles.gui_number}.pars3.boxSize = str2double(Opts{1}); % for 160npp, 16 -> 10nm boxes
    CC{handles.gui_number}.pars3.maxsize = str2double(Opts{2}); % 1E4 at 10nm cluster_scale, 1.2 um x 1.2 um 
    CC{handles.gui_number}.pars3.minsize = str2double(Opts{3}); % eg. minsize is 100 10x10 nm boxes.  400 is 200x200nm
    CC{handles.gui_number}.pars3.mindots = str2double(Opts{4}); % min number of localizations per STORM dot
    CC{handles.gui_number}.pars3.startFrame = str2double(Opts{5});   
    CC{handles.gui_number}.pars3.mindensity = str2double(Opts{6});   
    end
    
elseif step == 4
    dlg_title = 'Step 4 Pars: Drift Correction';  num_lines = 1;
    Dprompt = {
    'max drift (pixels)',... 1
    'min fraction of frames',... 2
    'start frame (1 = auto detect)',...        3
    'show drift correction plots?',...  4
    'show extra drift correction plots?',...  5 
    };   % 

    Opts{1} = num2str(CC{handles.gui_number}.pars4.maxDrift);
    Opts{2} = num2str(CC{handles.gui_number}.pars4.fmin);
    Opts{3} = num2str(CC{handles.gui_number}.pars4.startFrame);
    Opts{4} = num2str(CC{handles.gui_number}.pars4.showPlots);
    Opts{5} = num2str(CC{handles.gui_number}.pars4.showExtraPlots);
    
    Opts = inputdlg(Dprompt,dlg_title,num_lines,Opts);
        if isempty(Opts); notCancel = false; end
    if notCancel
    CC{handles.gui_number}.pars4.maxDrift = str2double(Opts{1});
    CC{handles.gui_number}.pars4.fmin = str2double(Opts{2});
    CC{handles.gui_number}.pars4.startFrame= str2double(Opts{3});
    CC{handles.gui_number}.pars4.showPlots = str2double(Opts{4}); 
    CC{handles.gui_number}.pars4.showExtraPlots = str2double(Opts{5});
    
    end
elseif step == 5
    dlg_title = 'Step 5 Pars: render STORM images';  num_lines = 1;
    Dprompt = {
    'cropping box size (nm) ',...  % convert this to box size in nm
    'zm for STORM',...        % convert this to something sensible
    'show dots colored-coded by frame number? (slow)',...
    };

    Opts{1} = num2str(CC{handles.gui_number}.pars5.scale);
    Opts{2} = num2str(CC{handles.gui_number}.pars5.zm);
    Opts{3} = num2str(CC{handles.gui_number}.pars5.showColorTime);
    Opts = inputdlg(Dprompt,dlg_title,num_lines,Opts);
    if isempty(Opts); notCancel = false; end
    if notCancel
    CC{handles.gui_number}.pars5.scale = eval(Opts{1}); % 30
    CC{handles.gui_number}.pars5.zm = eval(Opts{2});  %  1;
    CC{handles.gui_number}.pars5.showColorTime = eval(Opts{3});
    end
    
    
elseif step == 6
    dlg_title = 'Step 6 Pars: Quantify Features';  num_lines = 1;
    Dprompt = {
    'Box Size (nm)',... 
    'start frame ',...        3
    'Min Localizations per box',...  4
    'Min Size (boxes)'};     %5 

    Opts{1} = num2str(CC{handles.gui_number}.pars6.boxSize);
    Opts{2} = num2str(CC{handles.gui_number}.pars6.startFrame);
    Opts{3} = num2str(CC{handles.gui_number}.pars6.minloc);
    Opts{4} = num2str(CC{handles.gui_number}.pars6.minSize);
    Opts = inputdlg(Dprompt,dlg_title,num_lines,Opts);
    if isempty(Opts); notCancel = false; end
    if notCancel
    CC{handles.gui_number}.pars6.boxSize = eval(Opts{1}); % 30
    CC{handles.gui_number}.pars6.startFrame= eval(Opts{2});  %  1;
	CC{handles.gui_number}.pars6.minloc= eval(Opts{3});  % 0;
	CC{handles.gui_number}.pars6.minSize= eval(Opts{4});  % 30; 
    end
    
elseif step == 7
        dlg_title = 'Step 7 Pars: Data Export Options';  num_lines = 1;
    Dprompt = {
    'Save dots colored-coded by frame number? (slow)'...
    'root for savename'};     %1 
     Opts{1} = num2str(CC{handles.gui_number}.pars7.saveColorTime);
     Opts{2} = CC{handles.gui_number}.pars7.saveroot;
     Opts = inputdlg(Dprompt,dlg_title,num_lines,Opts);
    if isempty(Opts); notCancel = false; end
    if notCancel
     CC{handles.gui_number}.pars7.saveColorTime = eval(Opts{1}); % 30
     CC{handles.gui_number}.pars7.saveroot = Opts{2}; 
    end
end
    

% --- Executes on button press in NextStep.
function NextStep_Callback(hObject, eventdata, handles)
% hObject    handle to NextStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CC
Dirs = CC{handles.gui_number}.Dirs;
CC{handles.gui_number}.step = CC{handles.gui_number}.step +1;
step = CC{handles.gui_number}.step;
if step>7
    NextImage_Callback(hObject, eventdata, handles);
    step = 1;
    % step = 7;
    % CC{handles.gui_number}.step = step;
end
set(handles.DirectionsBox,'String',Dirs{step});
    
% --- Executes on button press in BackStep.
function BackStep_Callback(hObject, eventdata, handles)
% hObject    handle to BackStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CC

Dirs = CC{handles.gui_number}.Dirs;
CC{handles.gui_number}.step = CC{handles.gui_number}.step -1;
step = CC{handles.gui_number}.step;
set(handles.DirectionsBox,'String',Dirs{step});



% --- Executes on button press in NextImage.
function NextImage_Callback(hObject, eventdata, handles)
% hObject    handle to NextImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CC
Nbins = length(CC{handles.gui_number}.binfiles);
CC{handles.gui_number}.imnum = CC{handles.gui_number}.imnum + 1;
if CC{handles.gui_number}.imnum <= 0
    CC{handles.gui_number}.imnum = 1;
end
if CC{handles.gui_number}.imnum > Nbins
    CC{handles.gui_number}.imnum = Nbins;
end

binfile = CC{handles.gui_number}.binfiles(CC{handles.gui_number}.imnum);    
set(handles.ImageBox,'String',binfile.name);
CC{handles.gui_number}.step = 1;
set(handles.DirectionsBox,'String',CC{handles.gui_number}.Dirs{1});
RunStep_Callback(hObject, eventdata, handles)

% --- Executes on button press in PreviousImage.
function PreviousImage_Callback(hObject, eventdata, handles)
% hObject    handle to PreviousImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CC
Nbins = length(CC{handles.gui_number}.binfiles);
CC{handles.gui_number}.imnum = CC{handles.gui_number}.imnum - 1;
if CC{handles.gui_number}.imnum <= 0
    CC{handles.gui_number}.imnum = 1;
end
if CC{handles.gui_number}.imnum > Nbins
    CC{handles.gui_number}.imnum = Nbins;
end

binfile = CC{handles.gui_number}.binfiles(CC{handles.gui_number}.imnum);    
set(handles.ImageBox,'String',binfile.name);
CC{handles.gui_number}.step = 1;
set(handles.DirectionsBox,'String',CC{handles.gui_number}.Dirs{1});


function SourceFolder_Callback(hObject, eventdata, handles)
% hObject    handle to SourceFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CC
CC{handles.gui_number}.step = 1;
CC{handles.gui_number}.source = get(handles.SourceFolder,'String');
CC{handles.gui_number}.binfiles = ...
         dir([CC{handles.gui_number}.source,filesep,'*_alist.bin']);
set(handles.DirectionsBox,'String',CC{handles.gui_number}.Dirs{1});
CC{handles.gui_number}.imnum = 1;
if isempty(CC{handles.gui_number}.binfiles)
 error(['error, no alist.bin files found in folder ',...
     CC{handles.gui_number}.source]);
end
binfile = CC{handles.gui_number}.binfiles(CC{handles.gui_number}.imnum);    
set(handles.ImageBox,'String',binfile.name);
StepParameters_Callback(hObject, eventdata, handles)
RunStep_Callback(hObject, eventdata, handles)
% Clear current data
cleardata = input('New folder selected.  Clear current data? y/n? ','s');
if strcmp(cleardata,'y');
     CC{handles.gui_number}.data = [];
     CC{handles.gui_number}.pars7.saveroot ='';
     disp('data cleared'); 
end




% --- Executes on slider movement.
function DotSlider_Callback(hObject, eventdata, handles)
% hObject    handle to DotSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CC
if CC{handles.gui_number}.step == 5
    n = round(get(hObject,'Value'));
    set(handles.DotNum,'String',num2str(n));
    CC{handles.gui_number}.dotnum = n;
    ChromatinPlots(handles, n);
end
if CC{handles.gui_number}.step >= 6
    n = round(get(hObject,'Value'));
    set(handles.DotNum,'String',num2str(n));
    CC{handles.gui_number}.dotnum = n;
    ChromatinPlots2(handles, n);
end
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% % --- Executes on slider movement.
% function Yslider_Callback(hObject, eventdata, handles)
% global CC
% if CC{handles.gui_number}.step == 4
% end

function ImageBox_Callback(hObject, eventdata, handles)


function SaveFolder_Callback(hObject, eventdata, handles)


% 
% % --- Executes during object creation, after setting all properties.
% function Yslider_CreateFcn(hObject, eventdata, handles)
% if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor',[.9 .9 .9]);
% end

% --- Executes during object creation, after setting all properties.
function DotSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function SourceFolder_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function SaveFolder_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function ImageBox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in AutoCycle.
function AutoCycle_Callback(hObject, eventdata, handles)
% hObject    handle to AutoCycle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global CC
CC{handles.gui_number}.auto = true; 
currImage = CC{handles.gui_number}.imnum;
dat = dir([handles.Source,filesep,'*_alist.bin']);
Nfiles = length(dat); 
for n=currImage:Nfiles
    disp(['Analyzing image ',num2str(1),' of ',num2str(Nfiles),' ',...
        dat.Name]); 
    for step = 1:7
        CC{handles.gui_number}.step = step;
        RunStep_Callback(hObject, eventdata, handles);
    end
    NextImage_Callback(hObject, eventdata, handles)
end
CC{handles.gui_number}.auto = false; 



function DotNum_Callback(hObject, eventdata, handles)
global CC
CC{handles.gui_number}.dotnum = str2double(get(hObject,'String'));
try
 set(handles.DotSlider,'Value',CC{handles.gui_number}.dotnum);
 DotSlider_Callback; 
catch er
    disp(er.message);
    warning('value out of range.');
end

 
% Hints: get(hObject,'String') returns contents of DotNum as text
%        str2double(get(hObject,'String')) returns contents of DotNum as a double


% --- Executes during object creation, after setting all properties.
function DotNum_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function CMaxSlider_Callback(hObject, eventdata, handles)
% hObject    handle to CMaxSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CC
CC{handles.gui_number}.pars0.cmax = get(hObject,'Value');
if CC{handles.gui_number}.step > 4
    axes(handles.subaxis2); cla;
    showSTORM(handles,CC{handles.gui_number}.dotnum);
end

% --- Executes on slider movement.
function CMinSlider_Callback(hObject, eventdata, handles)
% hObject    handle to CMinSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CC
CC{handles.gui_number}.pars0.cmin = get(hObject,'Value');
if CC{handles.gui_number}.step > 4
    axes(handles.subaxis2); cla;
    showSTORM(handles,CC{handles.gui_number}.dotnum);
end

% --- Executes during object creation, after setting all properties.
function CMaxSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end





% --- Executes during object creation, after setting all properties.
function CMinSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OptionsMenu_Callback(hObject, eventdata, handles)
% hObject    handle to OptionsMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MenuResumePrevious_Callback(hObject, eventdata, handles)
% hObject    handle to MenuResumePrevious (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CC

savefolder = get(handles.SaveFolder,'String');
[fileName,filePath,notCancel] = uigetfile(savefolder);
if notCancel ~= 0
    disp('loading data..');
    load([filePath,filesep,fileName]);
    CC{handles.gui_number}.data = data;
    CC{handles.gui_number}.pars0 = CCguiData.pars0;
    CC{handles.gui_number}.pars1 = CCguiData.pars1;
    CC{handles.gui_number}.pars2 = CCguiData.pars2;
    CC{handles.gui_number}.pars3 = CCguiData.pars3;
    CC{handles.gui_number}.pars4 = CCguiData.pars4;
    CC{handles.gui_number}.pars5 = CCguiData.pars5;
    CC{handles.gui_number}.pars6 = CCguiData.pars6;
    CC{handles.gui_number}.pars7 = CCguiData.pars7;
    CC{handles.gui_number}.parsX = CCguiData.parsX;
    CC{handles.gui_number}.imnum = CCguiData.imnum-1;
    NextImage_Callback(hObject, eventdata, handles);
    
end





% --------------------------------------------------------------------
function MenuSetWorkingDir_Callback(hObject, eventdata, handles)
% hObject    handle to MenuSetWorkingDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CC
CC{handles.gui_number}.source = uigetdir;
set(handles.SourceFolder,'String',CC{handles.gui_number}.source);
SourceFolder_Callback(hObject, eventdata, handles);
