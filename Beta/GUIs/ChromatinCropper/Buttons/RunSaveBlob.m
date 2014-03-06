function RunSaveBlob(hObject,eventdata,handles)

global CC

if CC{handles.gui_number}.step == 6

%--------------- Get saveroot and target folder  
    daxname = CC{handles.gui_number}.daxname;
    saveroot = CC{handles.gui_number}.pars6.saveroot;
    savefolder = get(handles.SaveFolder,'String');
    
    % Automatically get saveroot (whatever comes before _storm).  
    %  strip off any automatically generated prefixes.   
    if isempty(saveroot)
        s1 = strfind(daxname,'quad_'); 
        s2 = strfind(daxname,'_storm');
        saveroot = daxname(s1+5:s2);   
        if isempty(s1)
            s1 = 1;
            saveroot = daxname(s1:s2);
        end
        CC{handles.gui_number}.pars6.saveroot = saveroot;
    end
    
    % Check for a target folder. 
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
    
    
    
%--------------- Sort and Save Data
dotnum = find(~isnan(CC{handles.gui_number}.data.mainArea(:,1)),1,'last')+1;
if (isempty(dotnum))
    dotnum = 1;
end

% dotnum = find(~isnan(CC{handles.gui_number}.data.mainArea),1,'last'); CC{handles.gui_number}.data.mainArea(dotnum,:) = NaN;   <-- backup 1   
% dotnum = find(~isnan(CC{handles.gui_number}.data.mainArea),1,'last');  CC{handles.gui_number}.data.mainArea(dotnum,:) = NaN; 

% Save current values for all parameters
parData{1} = CC{handles.gui_number}.pars1;
parData{2} = CC{handles.gui_number}.pars2;
parData{3} = CC{handles.gui_number}.pars3;
parData{4} = CC{handles.gui_number}.pars4;
parData{5} = CC{handles.gui_number}.pars5;
parData{6} = CC{handles.gui_number}.pars6;
parData{7} = CC{handles.gui_number}.pars7;
parData{8} = CC{handles.gui_number}.pars0;
parData{9} = CC{handles.gui_number}.parsX;
       

% General information about spot
CC{handles.gui_number}.data.clrmap = CC{handles.gui_number}.clrmap;
CC{handles.gui_number}.data.locusname = CC{handles.gui_number}.pars1.locusname;
[~,s,e] = ParseLocusName(CC{handles.gui_number}.pars1.locusname);
CC{handles.gui_number}.data.locuslength = (e-s)/1E3;

% Summary statistics about blobs
maxDots = 200; % 
numChns = size(CC{handles.gui_number}.tempData.mI3,2);
if size(CC{handles.gui_number}.data.mI3,2) == 1 && numChns == 2;
     ResetScalarData(handles,maxDots,numChns);
end

% --- Scalar data

% Two channel only scalar data
if numChns > 1
    CC{handles.gui_number}.data.area1only(dotnum) = CC{handles.gui_number}.tempData.area1only;
    CC{handles.gui_number}.data.area2only(dotnum) = CC{handles.gui_number}.tempData.area2only;
    CC{handles.gui_number}.data.area1or2(dotnum) = CC{handles.gui_number}.tempData.area1or2;
    CC{handles.gui_number}.data.area1and2(dotnum) = CC{handles.gui_number}.tempData.area1and2;
    CC{handles.gui_number}.data.overlapMap{dotnum} = CC{handles.gui_number}.tempData.overlapMap;
end


% universal scalar data
CC{handles.gui_number}.data.mI3(dotnum,:) = CC{handles.gui_number}.tempData.mI3;
CC{handles.gui_number}.data.mainVolume(dotnum,:) = CC{handles.gui_number}.tempData.mainVolume;
CC{handles.gui_number}.data.mI(dotnum,:) = CC{handles.gui_number}.tempData.mI;
CC{handles.gui_number}.data.mainLocs(dotnum,:) = CC{handles.gui_number}.tempData.mainLocs;
CC{handles.gui_number}.data.allArea(dotnum,:) = CC{handles.gui_number}.tempData.allArea;
CC{handles.gui_number}.data.allLocs(dotnum,:) = CC{handles.gui_number}.tempData.allLocs;
CC{handles.gui_number}.data.cvDensity(dotnum,:) = CC{handles.gui_number}.tempData.cvDensity; 
CC{handles.gui_number}.data.driftError(dotnum,:) = CC{handles.gui_number}.tempData.driftError;
CC{handles.gui_number}.data.mainArea(dotnum,:) = CC{handles.gui_number}.tempData.mainArea;

CC{handles.gui_number}.data.props2D{dotnum} = CC{handles.gui_number}.tempData.props2D;



% Raw data about blobs
CC{handles.gui_number}.data.vlists{dotnum} = CC{handles.gui_number}.tempData.vlist;
CC{handles.gui_number}.data.imaxes{dotnum} = CC{handles.gui_number}.tempData.imaxes;
CC{handles.gui_number}.data.binnames{dotnum} = CC{handles.gui_number}.tempData.binname;
CC{handles.gui_number}.data.parData{dotnum} = parData;

% Images of our work
CC{handles.gui_number}.data.convImages{dotnum} = CC{handles.gui_number}.tempData.convImages;
CC{handles.gui_number}.data.cellImages{dotnum} = CC{handles.gui_number}.tempData.cellImages;
CC{handles.gui_number}.data.stormImages{dotnum} = CC{handles.gui_number}.tempData.stormImages;   
CC{handles.gui_number}.data.timeMaps{dotnum} = CC{handles.gui_number}.tempData.timeMaps;   
CC{handles.gui_number}.data.stormImagesXZ{dotnum} = CC{handles.gui_number}.tempData.stormImagesXZ;   
CC{handles.gui_number}.data.stormImagesYZ{dotnum} = CC{handles.gui_number}.tempData.stormImagesYZ;   
CC{handles.gui_number}.data.stormImagesXY{dotnum} = CC{handles.gui_number}.tempData.stormImagesXY; 
CC{handles.gui_number}.data.stormImagesXZfilt{dotnum} = CC{handles.gui_number}.tempData.stormImagesXZfilt;
CC{handles.gui_number}.data.stormImagesYZfilt{dotnum} = CC{handles.gui_number}.tempData.stormImagesYZfilt;
CC{handles.gui_number}.data.stormImagesXYfilt{dotnum} = CC{handles.gui_number}.tempData.stormImagesXYfilt;
CC{handles.gui_number}.data.areaMaps{dotnum} = CC{handles.gui_number}.tempData.areaMaps;   
CC{handles.gui_number}.data.densityMaps{dotnum} = CC{handles.gui_number}.tempData.densityMaps;   


% save data for this spot to disk in target folder
tempData = CC{handles.gui_number}.tempData; %#ok<*NASGU>
saveName = [saveroot,'DotData_',sprintf('%03d',dotnum),'.mat'];
save([savefolder,filesep,saveName],'tempData');
disp(['wrote file: ',saveName]);
disp(['in ',savefolder]);

% Save data for all spots and current GUIstate
CCguiData = CC{handles.gui_number};  
data = CC{handles.gui_number}.data;
save([savefolder,filesep,saveroot,'data.mat'],'data','CCguiData');

%-------------- Save images 

% Side-by-side Conventional and STORM images
saveFig = figure(10); clf; colordef black;
set(gcf,'color','k');
set(saveFig, 'PaperPosition', [0 0 9 5],'Position',[0 0 800 600]);
subplot(1,2,1); Ncolor(CC{handles.gui_number}.tempData.convImages,CC{handles.gui_number}.clrmap);
subplot(1,2,2); STORMcell2img(CC{handles.gui_number}.tempData.stormImagesXYfilt,'colormap',CC{handles.gui_number}.clrmap);
spaceplots(saveFig,[.0 .0 .0 .0], [.0 .0]);
subplot(1,2,1); set(gca,'XTick',[],'YTick',[]); axis image;
subplot(1,2,2); set(gca,'XTick',[],'YTick',[]); axis image;
export_fig(saveFig,[savefolder,filesep,saveroot,'StormConv_',sprintf('%03d',dotnum),'.png']);
close(saveFig); 

% Side-by-side AreaMap and STORM images
saveFig = figure(10); clf; colordef black;
set(gcf,'color','k');
set(saveFig, 'PaperPosition', [0 0 9 5],'Position',[0 0 800 600]);
subplot(1,2,1); Ncolor(CC{handles.gui_number}.tempData.convImages,CC{handles.gui_number}.clrmap);
subplot(1,2,2); STORMcell2img(CC{handles.gui_number}.tempData.areaMaps,'colormap',CC{handles.gui_number}.clrmap);
spaceplots(saveFig,[.0 .0 .0 .0], [.0 .0]);
subplot(1,2,1); set(gca,'XTick',[],'YTick',[]); axis image;
subplot(1,2,2); set(gca,'XTick',[],'YTick',[]); axis image;
export_fig(saveFig,[savefolder,filesep,saveroot,'AreaMap_',sprintf('%03d',dotnum),'.png']);
close(saveFig); 


% STORM projections, XY, XZ, YZ
saveFig = figure(10); clf; colordef black;
set(gcf,'color','k');
set(saveFig, 'PaperPosition', [0 0 24 5],'Position',[0 50 1200 350]);
Show3DProj(handles,[]);
export_fig(saveFig,[savefolder,filesep,saveroot,'Storm3D_',sprintf('%03d',dotnum),'.png']);
close(saveFig); 

% filtered STORM projections, XY, XZ, YZ
saveFig = figure(10); clf; colordef black;
set(gcf,'color','k'); 
set(saveFig, 'PaperPosition', [0 0 24 5],'Position',[0 50 1200 350]);
Show3DProjFilt(handles);
export_fig(saveFig,[savefolder,filesep,saveroot,'Storm3Dfilt_',sprintf('%03d',dotnum),'.png']);
close(saveFig); 

% Image of cell
saveFig = figure(10); clf; colordef black;
set(gcf,'color','k');
set(saveFig, 'PaperPosition', [0 0 5 5],'Position',[0 50 500 500]);
STORMcell2img(CC{handles.gui_number}.tempData.cellImages,'colormap',CC{handles.gui_number}.clrmap);
set(gca,'XTick',[],'YTick',[]); axis image;
export_fig(saveFig,[savefolder,filesep,saveroot,'CellIm_',sprintf('%03d',dotnum),'.png']);
close(saveFig); 

else
   disp('Blobs can only be saved during Step 6');  
end