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

% Last Modified by GUIDE v2.5 02-Oct-2013 16:26:24

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
        'Step 3: load STORM image';
        'Step 4: Perform drift correction, Crop STORM-image, and Quantify structural features';
        'Step 5: Save data'};
    
% Cleanup Axes
    axes(handles.axes2);
    set(gca,'color','k');
    set(gca,'XTick',[],'YTick',[]);

    axes(handles.axes2);
    set(gca,'color','k');
    set(gca,'XTick',[],'YTick',[]);
    
% Default Parameters for GUI
% widely used parameters
    CC{handles.gui_number}.pars0.H = 256;
    CC{handles.gui_number}.pars0.W = 256;
    CC{handles.gui_number}.pars0.npp = 160;

    % step 2 parameters
     CC{handles.gui_number}.pars2.saturate = 0.001;
     CC{handles.gui_number}.pars2.makeblack = 0.998; 
    % step 3 parameters
     CC{handles.gui_number}.pars3.boxSize = 16; % linear dimension in nm of box
     CC{handles.gui_number}.pars3.maxsize = 1.2E5; % 1E4 at 10nm boxsize, 1.2 um x 1.2 um 
     CC{handles.gui_number}.pars3.minsize= 20; % eg. minsize is 100 10x10 nm boxes.  400 is 200x200nm
     CC{handles.gui_number}.pars3.mindots = 500; % min number of localizations per STORM dot
     CC{handles.gui_number}.pars3.startFrame = 1; 
     % step 4 parameters
    CC{handles.gui_number}.pars4.maxDrift = 6;
    CC{handles.gui_number}.pars4.fmin = .35;
    CC{handles.gui_number}.pars4.startFrame = 1;
    CC{handles.gui_number}.pars4.showPlots = true; 
    CC{handles.gui_number}.pars4.showExtraPlots = false; 

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
global CC

% Common Parameters
     H = CC{handles.gui_number}.pars0.H;
     W = CC{handles.gui_number}.pars0.W;
     npp = CC{handles.gui_number}.pars0.npp;

     % 3D clustering parameters    [Not Currently Used]
        minvoxels = 200;
        gblur = [7,7,3.5];
        bins3d = [128,128,40];
        Zs=10;
        zrange = [-500,500];

     % Image properties 
        imaxes.H = H;
        imaxes.W = W;
        imaxes.scale = 1;
        



% If first time running, find all bin files in folder        
if isempty(CC{handles.gui_number}.source)
    CC{handles.gui_number}.source = get(handles.SourceFolder,'String'); 
       
    CC{handles.gui_number}.binfiles = ...
         dir([CC{handles.gui_number}.source,filesep,'*_alist.bin']);
     
     if isempty(CC{handles.gui_number}.binfiles)
         disp(['error, no alist.bin files found in folder ',...
             CC{handles.gui_number}.source]);
     end
end

% Parse bin name and dax name for current image
    binfile = CC{handles.gui_number}.binfiles(CC{handles.gui_number}.imnum);
    folder = CC{handles.gui_number}.source;
    daxname = [binfile.name(1:end-10),'.dax'];    
    set(handles.ImageBox,'String',binfile.name);


% Actual Step Commands
step = CC{handles.gui_number}.step;
if step == 1
    
    % MaxProjection of Conventional Image    
         convname = regexprep([folder,filesep,daxname],'storm','conv*');
         convname = dir(convname);
         convZs = length(convname);
         dax = zeros(H,W,1,'uint16');
         for z=1:convZs
             try
                 daxtemp = sum(ReadDax([folder,filesep,convname(z).name]),3);
                 dax = max(cat(3,dax,daxtemp),[],3);
             catch er
                 disp(er.message);
             end
         end
             
         figure(11); clf; imagesc(dax); colorbar;
         title('conventional image projected');
         try
            conv0 =  regexprep([folder,filesep,daxname],'storm','conv_z0');
            conv0 = sum(ReadDax(conv0),3);
         catch er
            disp(er.message);
            conv0 = dax;  
         end
         axes(handles.axes1);
         set(gca,'color','k');
         set(gca,'XTick',[],'YTick',[]);
         imagesc(conv0);
         colormap hot;
         xlim([0,W]); ylim([0,H]);
         
         axes(handles.axes2);
         imagesc(conv0); colormap hot;
         set(gca,'color','k');
         set(gca,'XTick',[],'YTick',[]);

         % Save step data into global; 
        CC{handles.gui_number}.conv = conv0; 
   
elseif step == 2
        % load variables from previous step
        conv0 = CC{handles.gui_number}.conv;
        
        % load parameters
         saturate =  CC{handles.gui_number}.pars2.saturate; % 0.001;
         makeblack = CC{handles.gui_number}.pars2.makeblack; %  0.998; 
        
        % Step 2: Threshold to find spots  [make these parameter options]
         try
             daxMask = mycontrast(uint16(conv0),saturate,makeblack); 
         catch er
             disp(er.message)
         end
         % figure(2); clf; imagesc(dax_mask); colorbar;
         daxMask = daxMask > 1;
         axes(handles.axes1); cla;
         set(gca,'color','k');
         set(gca,'XTick',[],'YTick',[]);
         imagesc(daxMask); 
         xlim([0,W]); ylim([0,H]);
         
        % Save step data into global
        CC{handles.gui_number}.daxMask = daxMask; 
        
elseif step == 3
     % load variables from previous steps
     daxMask = CC{handles.gui_number}.daxMask;
    
  
     
     
     cluster_scale = CC{handles.gui_number}.pars0.npp/CC{handles.gui_number}.pars3.boxSize; 
     maxsize = CC{handles.gui_number}.pars3.maxsize;
     minsize = CC{handles.gui_number}.pars3.minsize;
     mindots = CC{handles.gui_number}.pars3.mindots; 
     startframe = CC{handles.gui_number}.pars3.startFrame; 
         
     % Step 3: Load molecule list and bin it to create image
        mlist = ReadMasterMoleculeList([folder,filesep,binfile.name]);
        infilt = mlist.frame>startframe;
        
        M = hist3([mlist.yc(infilt),mlist.xc(infilt)],...
             {0:1/cluster_scale:H,0:1/cluster_scale:W});
        [h,w] = size(M);
        
%         figure(13); clf; 
%              imagesc(M); 
%              colorbar; 
%              caxis([0,10]);
%              
%         figure(14); clf;
%         imagesc(conv0); hold on;
%         plot(mlist.xc(infilt),mlist.yc(infilt),'w.');
             
        mask = M>1;  %        figure(3); clf; imagesc(mask); 
        mask = imdilate(mask,strel('disk',3)); %       figure(3); clf; imagesc(mask);
        toobig = bwareaopen(mask,maxsize);  % figure(3); clf; imagesc(mask);
        mask = logical(mask - toobig) & imresize(daxMask,[h,w]); 
        mask = bwareaopen(mask,minsize);    % figure(3); clf; imagesc(mask);
        R = regionprops(mask,M,'PixelValues','Eccentricity',...
            'BoundingBox','Extent','Area','Centroid','PixelIdxList'); 
        aboveminsize = cellfun(@sum,{R.PixelValues}) > mindots;
        R = R(aboveminsize);   
        
        
        allpix = cat(1,R(:).PixelIdxList);
        mask = double(mask); 
        mask(allpix) = 3;
        
        axes(handles.axes1); cla;
        set(gca,'color','k');
        set(gca,'XTick',[],'YTick',[]);
        imagesc(mask); title('dot mask'); 
        xlim([0,w]); ylim([0,h]);
        
        % Export step data
        CC{handles.gui_number}.mlist = mlist; 
        CC{handles.gui_number}.infilt = infilt; 
        CC{handles.gui_number}.R = R; 
        CC{handles.gui_number}.M = M; 
        
elseif step == 4
    % Load variables
    mlist = CC{handles.gui_number}.mlist;
    infilt = CC{handles.gui_number}.infilt;
    R = CC{handles.gui_number}.R;
    M = CC{handles.gui_number}.M; 
    Nclusters = length(R);
    conv0 = CC{handles.gui_number}.conv;
    CC{handles.gui_number}.handles = handles;
      
    % Load user defined parameters
    maxDrift = CC{handles.gui_number}.pars4.maxDrift;
    fmin = CC{handles.gui_number}.pars4.fmin;
    startFrame = CC{handles.gui_number}.pars4.startFrame;
    showPlots = CC{handles.gui_number}.pars4.showPlots; 
    showExtraPlots = CC{handles.gui_number}.pars4.showExtraPlots; 
    
    cluster_scale = CC{handles.gui_number}.pars0.npp/CC{handles.gui_number}.pars3.boxSize; 
    
    % Apply Drift Correction
    beadname = regexprep(daxname,{'647quad','.dax'},{'561quad','_list.bin'});
    beadbin = [folder,filesep,beadname];
     [dxc,dyc] = feducialDriftCorrection(beadbin,'maxdrift',maxDrift,...
         'showplots',showPlots,'fmin',fmin,'startframe',startFrame,...
         'showextraplots',showExtraPlots);
     missingframes = max(mlist.frame) - length(dxc);
     dxc = [dxc; zeros(missingframes,1)];
     dyc = [dyc; zeros(missingframes,1)];
     length(dxc)
     max(mlist.frame)
    mlist.xc = mlist.x - dxc(mlist.frame);
    mlist.yc = mlist.y - dyc(mlist.frame); 
    CC{handles.gui_number}.mlist = mlist; % update in global data
     
    % Conventional image in finder window
     axes(handles.axes2); cla;
     imagesc(conv0); colormap hot;
     set(gca,'color','k');
     set(gca,'XTick',[],'YTick',[]);

     % STORM plots in main figure window
     S = 2*W + 1;
     Imap = 2^16*ones(513,513,1,'uint16');
     p0 = 1; p1 = floor(S/2); p2 = p1+2; p3=S;
     reg = {p0:p1,p0:p1;p0:p1,p2:p3;p2:p3,p0:p1;p2:p3,p2:p3};
    
     % auxilliary plots in new figures
     convIm = figure; clf; set(gcf,'color','w');
     dottime = figure; clf; set(gcf,'color','w');
     cellIm = figure; clf;  set(gcf,'color','w');
     dotHist = figure; clf; set(gcf,'color','w');
     if Nclusters > 4
         stormAux  = figure; clf; set(gcf,'color','w');
         convAux  = figure; clf; set(gcf,'color','w');
         dottimeAux  = figure; clf; set(gcf,'color','w');
         cellAux  = figure; clf; set(gcf,'color','w');
         dotHistAux = figure; clf; set(gcf,'color','w'); 
     end
     
      % Arrays to store image data in
       Istorm = cell(Nclusters,1);
       Iconv = cell(Nclusters,1); 
       Itime = cell(Nclusters,1);
       Ihist = cell(Nclusters,1);
       Icell = cell(Nclusters,1); 
       
     for n=1:Nclusters % n=3    
           % For dsiplay and judgement purposes 
           TCounts = sum(R(n).PixelValues);
           DotSize = length(R(n).PixelValues);
           MaxD = max(R(n).PixelValues);
           MeanD = mean(R(n).PixelValues); 
            
            imaxes.zm = 20;
            imaxes.cx = R(n).Centroid(1)/cluster_scale;
            imaxes.cy = R(n).Centroid(2)/cluster_scale;
            imaxes.xmin = imaxes.cx - imaxes.W/2/imaxes.zm;
            imaxes.xmax = imaxes.cx + imaxes.W/2/imaxes.zm;
            imaxes.ymin = imaxes.cy - imaxes.H/2/imaxes.zm;
            imaxes.ymax = imaxes.cy + imaxes.H/2/imaxes.zm;
            
            
           I = plotSTORM_colorZ({mlist},imaxes,'filter',{infilt'},...
               'Zsteps',Zs,'scalebar',500,'correct drift',true,'Zsteps',1); 
           Istorm{n} = I{1};  % save image; 
           
           if n<=4
          % subplot(2,2,n); % n=1
                Imap(reg{n,1:2}) = I{1}; 
           elseif n>4 && n<8
               figure(stormAux);
               subplot(2,2,n-4);
               imagesc(Istorm{n});
               colormap hot;
               title(['dot',num2str(n)]);
           end

         
           
% %  some more images

    % Zoom in on histogram (determines size / density etc)
    x1 = ceil(imaxes.xmin*cluster_scale);
    x2 = floor(imaxes.xmax*cluster_scale);
    y1 = ceil(imaxes.ymin*cluster_scale);
    y2 = floor(imaxes.ymax*cluster_scale);
    Ihist{n} = M(y1:y2,x1:x2); 
    if n<=4
        figure(dotHist);
        subplot(2,2,n);
        imagesc(Ihist{n}); 
        colormap hot; caxis([0,10]);
    elseif n>4 && n<8
           figure(dotHistAux);
           subplot(2,2,n-4);
           imagesc(Ihist{n});
           colormap hot; caxis([0,10]);
           title(['dot',num2str(n)]);
    end

      % Conventional Image of Spot 
        Iconv{n} = conv0(ceil(imaxes.ymin):floor(imaxes.ymax),...
            ceil(imaxes.xmin):floor(imaxes.xmax));
        if n<=4
            figure(convIm);
            subplot(2,2,n); 
            imagesc(Iconv{n});
            colormap hot;
            title(['dot',num2str(n),' counts=',num2str(TCounts),' size=',...
                num2str(DotSize),' maxD=',num2str(MaxD)]);
        elseif n>4 && n<8
           figure(convAux);
           subplot(2,2,n-4);
           imagesc(Iconv{n});
           colormap hot; 
           title(['dot',num2str(n),' counts=',num2str(TCounts),' size=',...
                num2str(DotSize),' maxD=',num2str(MaxD)]);
        end

     % STORM image of whole cell
       cellaxes = imaxes;
       cellaxes.zm = 4; % zoom out to cell scale;
       cellaxes.xmin = cellaxes.cx - cellaxes.W/2/cellaxes.zm;
       cellaxes.xmax = cellaxes.cx + cellaxes.W/2/cellaxes.zm;
       cellaxes.ymin = cellaxes.cy - cellaxes.H/2/cellaxes.zm;
       cellaxes.ymax = cellaxes.cy + cellaxes.H/2/cellaxes.zm;
       Izmout = plotSTORM_colorZ({mlist},cellaxes,'Zsteps',1,'scalebar',500);
       Icell{n} = sum(Izmout{1},3);
       if n<=4;
           figure(cellIm);
           subplot(2,2,n);
           imagesc(Icell{n});  
           title(['dot',num2str(n),'  ','STORM image 4x zoom']); 
           caxis([0,2^15]); colormap(hot);
       elseif n>4 && n<8
           figure(cellAux);
           subplot(2,2,n-4);
           imagesc(Icell{n});
           colormap hot; 
            title(['dot',num2str(n),'  ','STORM image 4x zoom']); 
           caxis([0,2^15]); colormap(hot);
       end
       
   % Add dot labels to overview image           
    axes(handles.axes2); hold on; text(imaxes.cx+6,imaxes.cy,...
         ['dot ',num2str(n)],'color','w');

    
%    % Gaussian Fitting and Cluster
       % Get subregion, exlude distant zs which are poorly fit
        vlist = msublist(mlist,imaxes);
        vlist.c( vlist.z>=480 | vlist.z<-480 ) = 9;    
        filt = (vlist.c~=9) ;
%        
     %  Indicate color as time. 
        dxc = vlist.xc;
        dyc = max(vlist.yc)-vlist.yc;
        Nframes = length(vlist.frame);
        cmp = jet(Nframes); % create the color maps changed as in jet color map
        
        Itime{n} = [dxc*npp,dyc*npp];
        if n<=4;
            figure(dottime);
            subplot(2,2,n);
            colormap hot; caxis([0,2^16]); hold on;
            scatter(dxc*npp, dyc*npp, 5, cmp, 'filled');
            set(gca,'color','k'); set(gcf,'color','w'); 
            xlabel('nm');     ylabel('nm'); 
            title(['dot',num2str(n),' counts=',num2str(TCounts),' size=',...
                num2str(DotSize),' maxD=',num2str(MaxD)]); 
        elseif n>4 && n<8
           figure(cellAux);
           subplot(2,2,n-4);
           colormap hot; caxis([0,2^16]); hold on;
           scatter(dxc*npp, dyc*npp, 5, cmp, 'filled');
            set(gca,'color','k'); set(gcf,'color','w'); 
            xlabel('nm');     ylabel('nm'); 
            title(['dot',num2str(n),' counts=',num2str(TCounts),' size=',...
                num2str(DotSize),' maxD=',num2str(MaxD)]);
        end
     end  % end loop over dots
    
 
     % Show STORM images of dots in 2x2 panel in main figure axes
        axes(handles.axes1); cla; hold on;
        set(gca,'color','k');
        set(gca,'XTick',[],'YTick',[]);
        xlim([0,512]); ylim([0,512]);
        imagesc(Imap); 
        regS = [p0+5,p0+5;p2+5,p0+5;p0+5,p2+5;p2+5,p2+5];
        for n=1:4
         text(regS(n,1),regS(n,2),['dot ',num2str(n)],'color','w');
        end

  
        % Save all data now
        % In the next step discard the images we don't actually want to
 %       keep.  
    imnum = CC{handles.gui_number}.imnum;
    savefolder = get(handles.SaveFolder,'String');
    s1 = strfind(daxname,'quad_'); 
    s2 = strfind(daxname,'_storm');
    saveroot = daxname(s1+5:s2);
   if ~isempty(savefolder)
       saveas(handles.axes2,[savefolder,filesep,saveroot,'_','ImOverview','_',num2str(imnum),'.png']);
       imwrite(Imap,[savefolder,filesep,saveroot,'_Istorm_',num2str(imnum),'.png']);
       saveas(convIm,[savefolder,filesep,saveroot,'_Iconv_',num2str(imnum),'.png']);
       saveas(cellIm,[savefolder,filesep,saveroot,'_Icell_',num2str(imnum),'.png']);
       saveas(dotHist,[savefolder,filesep,saveroot,'_Ihist_',num2str(imnum),'.png']);
       saveas(dottime,[savefolder,filesep,saveroot,'_Itime_',num2str(imnum),'.png']);
  end
        
        % Export data
        CC{handles.gui_number}.Nclusters = Nclusters;
        CC{handles.gui_number}.Imap = Imap;
        CC{handles.gui_number}.Istorm = Istorm;
        CC{handles.gui_number}.Iconv = Iconv;
        CC{handles.gui_number}.Icell = Icell;
        CC{handles.gui_number}.Ihist = Ihist;
        CC{handles.gui_number}.Itime = Itime;
        CC{handles.gui_number}.cmp = cmp;
        CC{handles.gui_number}.fighandles = {convIm,dottime,cellIm};
          

          
elseif step == 5
    % Load variables
    Nclusters = CC{handles.gui_number}.Nclusters;
    Imap = CC{handles.gui_number}.Imap;
    Istorm = CC{handles.gui_number}.Istorm ;
    Iconv = CC{handles.gui_number}.Iconv;
    Itime = CC{handles.gui_number}.Itime;
    Icell = CC{handles.gui_number}.Icell;
    Ihist = CC{handles.gui_number}.Ihist;
    
        saveas(handles.axes2,[savefolder,filesep,saveroot,'_','ImOverview','_',num2str(imnum),'.png']);
       [savefolder,filesep,saveroot,'_Istorm_',num2str(imnum),'.png'];
       [savefolder,filesep,saveroot,'_Iconv_',num2str(imnum),'.png'];
       [savefolder,filesep,saveroot,'_Icell_',num2str(imnum),'.png'];
       [savefolder,filesep,saveroot,'_Ihist_',num2str(imnum),'.png'];
       [savefolder,filesep,saveroot,'_Itime_',num2str(imnum),'.png'];
    

end
    


% --- Executes on button press in StepParameters.
function StepParameters_Callback(hObject, eventdata, handles)
% hObject    handle to StepParameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CC
step = CC{handles.gui_number}.step;

if step == 1

elseif step == 2
    dlg_title = 'Step 2 Pars: Conv. Segmentation';  num_lines = 1;
    Dprompt = {
    'fraction to saturate',... 1
    'fraction to make black',... 2
     };     %5 

    Opts{1} = num2str(CC{handles.gui_number}.pars2.saturate);
    Opts{2} = num2str(CC{handles.gui_number}.pars2.makeblack);
    Opts = inputdlg(Dprompt,dlg_title,num_lines,Opts);
    
     CC{handles.gui_number}.pars2.saturate = str2double(Opts{1});
     CC{handles.gui_number}.pars2.makeblack = str2double(Opts{2}); 
    
elseif step == 3
    dlg_title = 'Step 3 Pars: Filter Clusters';  num_lines = 1;
    Dprompt = {
    'box size (nm)',... 1
    'max dot size (boxes)',... 2
    'min dot size (boxes)',... 3
    'min localizations',...  4
    'start frame'};     %5 

    Opts{1} = num2str(CC{handles.gui_number}.pars3.boxSize);
    Opts{2} = num2str(CC{handles.gui_number}.pars3.maxsize);
    Opts{3} = num2str(CC{handles.gui_number}.pars3.minsize);
    Opts{4} = num2str(CC{handles.gui_number}.pars3.mindots);
    Opts{5} = num2str(CC{handles.gui_number}.pars3.startFrame);
    Opts = inputdlg(Dprompt,dlg_title,num_lines,Opts);

    CC{handles.gui_number}.pars3.boxSize = str2double(Opts{1}); % for 160npp, 16 -> 10nm boxes
    CC{handles.gui_number}.pars3.maxsize = str2double(Opts{2}); % 1E4 at 10nm cluster_scale, 1.2 um x 1.2 um 
    CC{handles.gui_number}.pars3.minsize = str2double(Opts{3}); % eg. minsize is 100 10x10 nm boxes.  400 is 200x200nm
    CC{handles.gui_number}.pars3.mindots = str2double(Opts{4}); % min number of localizations per STORM dot
    CC{handles.gui_number}.pars3.startFrame = str2double(Opts{5});   
    
elseif step == 4
    dlg_title = 'Step 4 Pars: Drfit Correction';  num_lines = 1;
    Dprompt = {
    'max drift (pixels)',... 1
    'min fraction of frames',... 2
    'start frame (1 = auto detect)',...        3
    'show drift correction plots?',...  4
    'show extra drift correction plots?'};     %5 

    Opts{1} = num2str(CC{handles.gui_number}.pars4.maxDrift);
    Opts{2} = num2str(CC{handles.gui_number}.pars4.fmin);
    Opts{3} = num2str(CC{handles.gui_number}.pars4.startFrame);
    Opts{4} = num2str(CC{handles.gui_number}.pars4.showPlots);
    Opts{5} = num2str(CC{handles.gui_number}.pars4.showExtraPlots);
    Opts = inputdlg(Dprompt,dlg_title,num_lines,Opts);
    
    CC{handles.gui_number}.pars4.maxDrift = str2double(Opts{1});
    CC{handles.gui_number}.pars4.fmin = str2double(Opts{2});
    CC{handles.gui_number}.pars4.startFrame= str2double(Opts{3});
    CC{handles.gui_number}.pars4.showPlots = str2double(Opts{4}); 
    CC{handles.gui_number}.pars4.showExtraPlots = str2double(Opts{5});
    
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


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function SourceFolder_Callback(hObject, eventdata, handles)
% hObject    handle to SourceFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SourceFolder as text
%        str2double(get(hObject,'String')) returns contents of SourceFolder as a double


% --- Executes during object creation, after setting all properties.
function SourceFolder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SourceFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ImageBox_Callback(hObject, eventdata, handles)
% hObject    handle to ImageBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ImageBox as text
%        str2double(get(hObject,'String')) returns contents of ImageBox as a double


% --- Executes during object creation, after setting all properties.
function ImageBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImageBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SaveFolder_Callback(hObject, eventdata, handles)
% hObject    handle to SaveFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SaveFolder as text
%        str2double(get(hObject,'String')) returns contents of SaveFolder as a double


% --- Executes during object creation, after setting all properties.
function SaveFolder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SaveFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
