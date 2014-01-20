function handles = CCstartup(handles)
% Default parameter values for Chromatin Cropper

% Initialize Global GUI Parameters
    global CC
    if isempty(CC) % Build GUI instance ID 
        CC = cell(1,1);
    else
        CC = [CC;cell(1,1)];
    end
    handles.gui_number = length(CC);
   

% Cleanup Axes
axes(handles.axes1);
set(gca,'color','k');
set(gca,'XTick',[],'YTick',[]);

axes(handles.axes2);
set(gca,'color','k');
set(gca,'XTick',[],'YTick',[]);

% update instance ID#     
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
     
% Default Parameters for GUI
   % General control parameters
    CC{handles.gui_number}.auto = false; % autocycle
   % widely used parameters
    CC{handles.gui_number}.pars0.H = 256;
    CC{handles.gui_number}.pars0.W = 256;
    CC{handles.gui_number}.pars0.npp = 160;
    CC{handles.gui_number}.pars0.cmin = [0 0];
    CC{handles.gui_number}.pars0.cmax = [1 1];
    % step1 parameters
    CC{handles.gui_number}.pars1.BeadFolder = '';
    CC{handles.gui_number}.pars1.overlays = {};  
    CC{handles.gui_number}.pars1.chns = {'750','647','561','488'};
    % step 2 parameters
     CC{handles.gui_number}.pars2.saturate = [0.001 0.001];
     CC{handles.gui_number}.pars2.makeblack = [0.998 0.998]; 
     CC{handles.gui_number}.pars2.beadDilate = 2;
     CC{handles.gui_number}.pars2.beadThresh = .3;
     CC{handles.gui_number}.pars2.channel = '647';
    % step 3 parameters
     CC{handles.gui_number}.pars3.boxSize = [32 32]; % linear dimension in nm of box
     CC{handles.gui_number}.pars3.maxsize = [1.2E5 1.2E5]; % 1E4 at 10nm boxsize, 1.2 um x 1.2 um 
     CC{handles.gui_number}.pars3.minsize= [20 20]; % eg. minsize is 100 10x10 nm boxes.  400 is 200x200nm
     CC{handles.gui_number}.pars3.mindots = [500 500]; % min number of localizations per STORM dot
     CC{handles.gui_number}.pars3.mindensity = [0 0]; % min density of localizations per STORM dot
     CC{handles.gui_number}.pars3.startFrame = [1 1]; 
     % step 4 parameters
    CC{handles.gui_number}.pars4.maxDrift = [3 3];
    CC{handles.gui_number}.pars4.fmin = [.5 .5];
    CC{handles.gui_number}.pars4.startFrame = [1 1];
    CC{handles.gui_number}.pars4.showPlots = [1 1]; 
    CC{handles.gui_number}.pars4.showExtraPlots = [0 0]; 
    % step 5 parameters
    CC{handles.gui_number}.pars5.scale = 2048;
    CC{handles.gui_number}.pars5.zm = 1; 
    CC{handles.gui_number}.pars5.showColorTime = true; % This is useful but slow
    % step 6 parameters
    CC{handles.gui_number}.pars6.boxSize = 32;
    CC{handles.gui_number}.pars6.startFrame= 1; % 
	CC{handles.gui_number}.pars6.minloc = 2; % min number of localization per box
	CC{handles.gui_number}.pars6.minSize = 30; % min size in number of boxes
    % step 7 parameters
    CC{handles.gui_number}.pars7.saveColorTime = true; % This is useful but slow
    CC{handles.gui_number}.pars7.saveroot = '';
    % step X parameters for X-correlation drift correction
    CC{handles.gui_number}.parsX.stepFrame = [8000 8000]; % 'stepframe' / double / 10E3 -- number of frames to average
    CC{handles.gui_number}.parsX.scale  = [5 5]; % 'scale' / double / 5 -- upsampling factor for binning localizations
    CC{handles.gui_number}.parsX.showPlots = [1 1];   % 'showplots' / logical / true -- plot computed drift?
    CC{handles.gui_number}.parsX.local = [0 0];  
    % colormap
    CC{handles.gui_number}.clrmap = hot(256); 
