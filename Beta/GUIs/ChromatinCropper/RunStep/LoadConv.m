function handles = LoadConv(handles)

global CC

% clear start
axes(handles.axes1); 
set(gca,'color','k');
set(gca,'XTick',[],'YTick',[]);

% Previously common parameters
%-------------------------------------------------------
H = CC{handles.gui_number}.pars0.H;
W = CC{handles.gui_number}.pars0.W;
     
%      % Image properties 
%         imaxes.H = H;
%         imaxes.W = W;
%         imaxes.scale = 1;
        
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
folder = CC{handles.gui_number}.source;
imnum = CC{handles.gui_number}.imnum;
binfile = CC{handles.gui_number}.binfiles(imnum).name;
daxname = [binfile(1:end-10),'.dax'];    
set(handles.ImageBox,'String',binfile);
CC{handles.gui_number}.daxname = daxname;

% Guess that the Bead-data is in the subfolder 'Beads' inside the
% current directory. 
% If this directory does not exist or exists but does not contain a
% chromewarps.mat file, the user will be asked to locate a different
% one.  
if isempty(CC{handles.gui_number}.pars1.BeadFolder)
    CC{handles.gui_number}.pars1.BeadFolder = ...
        [folder,filesep,'Beads',filesep];
end  


% % No longer matches filenames.  Would be better as a multichannel option.
%  
% % MaxProjection of Conventional Image    
%  convname = regexprep([folder,filesep,daxname],'storm','conv*');
%  convname = dir(convname);
%  convZs = length(convname);
%  dax = zeros(H,W,1,'uint16');
%  for z=1:convZs
%      try
%          daxtemp = mean(ReadDax([folder,filesep,convname(z).name],'verbose',false),3);
%          dax = max(cat(3,dax,daxtemp),[],3);
%      catch er
%          disp(er.message);
%      end
%  end   
%  figure(11); clf; imagesc(dax); colorbar; colormap hot;
%  title('conventional image projected');


%-------------------------------------------------------------------------
% Load Conventional images 
%--------------------------------------------------------------------------
% searches for all channels 
% uses only data taken in the STORM imaging plane (z=0).     
% automatically tries to guess the file names 

 if isempty(CC{handles.gui_number}.pars1.overlays)
    if isempty(strfind(daxname,'647quad')) % new defaults
        fileNum = strfind(daxname,'_0_');
        fileNum = daxname(fileNum:end);
        overlays = dir([folder,'\splitdax\*','_z0',fileNum]);
        CC{handles.gui_number}.pars1.overlays = strcat([folder,'\splitdax\'],{overlays.name});
    else
        fileNum = strfind(daxname,'_0_');
        fileNum = daxname(fileNum:end);
        overlays = dir([folder,'\*','_z0',fileNum]);
        CC{handles.gui_number}.pars1.overlays = strcat([folder,'\splitdax\'],{overlays.name});
    end
 end
  if isempty(CC{handles.gui_number}.pars1.overlays) % still empty
      disp('automatic overlay detection failed.  Please select manually'); 
      SpecifyOverlays(handles)
  end
 
 
 name488 = ~cellfun(@isempty,strfind(CC{handles.gui_number}.pars1.overlays,'488'));
 if sum(name488) 
    laminaName = CC{handles.gui_number}.pars1.overlays{name488};
 end
 name561 = ~cellfun(@isempty,strfind(CC{handles.gui_number}.pars1.overlays,'561'));
 if sum(name561) 
    beadsName = CC{handles.gui_number}.pars1.overlays{name561};
 end
 name647 = ~cellfun(@isempty,strfind(CC{handles.gui_number}.pars1.overlays,'647'));
 if sum(name647) 
    conv0Name = CC{handles.gui_number}.pars1.overlays{name647};
 end
 name750 = ~cellfun(@isempty,strfind(CC{handles.gui_number}.pars1.overlays,'750'));
 if sum(name750)
    conv1Name = CC{handles.gui_number}.pars1.overlays{name750};
 end


% Load the conventional images
 try 
     conv0 = uint16(mean(ReadDax(conv0Name,'verbose',false,'endFrame',100),3));
 catch er
    disp(er.message);
    conv0 = zeros(H,W,'uint16');  
 end

 try 
     conv1 = uint16(mean(ReadDax(conv1Name,'verbose',false,'endFrame',100),3));
 catch er
    disp(er.message);
    conv1 = zeros(H,W,'uint16');  
 end

 try
    lamina = uint16(mean(ReadDax(laminaName,'verbose',false,'endFrame',100),3));
 catch er
    disp(er.message);
    lamina = zeros(H,W,'uint16');  
 end

 try
     beads = uint16(mean(ReadDax(beadsName,'verbose',false,'endFrame',100),3));
 catch er
    disp(er.message);
    beads = zeros(H,W,'uint16');  
 end

 % ----- Attempt Chromatic alignment of conventional images ---------
 BeadFolder = CC{handles.gui_number}.pars1.BeadFolder;
 warpfile = [BeadFolder,filesep,'chromewarps.mat'];
 % If the file does not exist and the value is not set to  skip,
 % open a dialogue box to find the chromewarps file.
 if isempty(dir(warpfile)) && ~strcmp(BeadFolder,'skip')
     [~,BeadFolder,loadCanceled] = uigetdir('chromewarps.mat','Find chromewarps',folder);
 % If the warpfile load is aborted, set value to skip.  
     if loadCanceled == 0
        BeadFolder = 'skip';
     end 
     CC{handles.gui_number}.pars1.BeadFolder = BeadFolder;
     warpfile = [BeadFolder,filesep,'chromewarps.mat'];
     CC{handles.gui_number}.pars1.warpfile = warpfile;
 end

 if ~strcmp(BeadFolder,'skip')
     warpedLamina = uint16(WarpImage(lamina,'488',warpfile));
     warpedBeads = uint16(WarpImage(beads,'561',warpfile));
     warpedConv1 = uint16(WarpImage(conv1,'750',warpfile));
 else
     warpedLamina = lamina;
     warpedBeads = beads;
     warpedConv1 = conv1;
 end

% -------- Combine into multicolor image ------------

conv0 = imadjust(conv0,stretchlim(conv0,0)); 
warpedConv1 = imadjust(warpedConv1,stretchlim(warpedConv1,0));
warpedBeads = imadjust(warpedBeads,stretchlim(warpedBeads,0));
warpedLamina = imadjust(warpedLamina,stretchlim(warpedLamina,0));
[H,W] = size(conv0);
convI = zeros(H,W,4,'uint16');
convI(:,:,1) = conv0;
convI(:,:,2) = warpedBeads;
convI(:,:,3) = warpedLamina; 
convI(:,:,4) = warpedConv1;

% -------- Plot results ----------
axes(handles.axes1);
Ncolor(convI);
xlim([0,W]); 
ylim([0,H]);
axes(handles.axes1);
set(gca,'color','k');
set(gca,'XTick',[],'YTick',[]);

axes(handles.axes2);
Ncolor(convI); 
set(gca,'color','k');
set(gca,'XTick',[],'YTick',[]);

% if conv1 is empty (all zero), save as empty; 
if sum(conv1(:)) == 0
    warpedConv1 = [];
end
% Save step data into global; 
CC{handles.gui_number}.conv = conv0;  
CC{handles.gui_number}.conv1 = warpedConv1;  
CC{handles.gui_number}.maskBeads = warpedBeads;
CC{handles.gui_number}.convI = convI;
CC{handles.gui_number}.pars0.H = H;
CC{handles.gui_number}.pars0.W = W;
