function handles = FilterChromatinClusters(handles)

global CC


%% Load data
vlists = CC{handles.gui_number}.vlists;
npp = CC{handles.gui_number}.pars0.npp;

% 2D subcluster vlist image

regionSize = CC{handles.gui_number}.pars5.regionSize/npp;  % region size in pixels 
zrescale = 1; % CC{handles.gui_number}.pars5.zrescale;

%% 'Loop' over clusters 
n = round(get(handles.DotSlider,'Value'));
%%
   % Histogram localizations on tunable scale
   boxSize = CC{handles.gui_number}.pars6.boxSize(1);     % boxSize in nm
   steps = round(regionSize*npp/boxSize);
   bins2D = linspace(0,regionSize,steps); 
   
   numChns = length(vlists{n});
   mapBW = zeros(steps,steps,numChns); 
   mapXZ = zeros(steps,steps,numChns); 
   mapYZ = zeros(steps,steps,numChns); 
   mapIdx = zeros(steps,steps,numChns);
   
   for i=1:numChns
        % Channel specific threshold parameters 
        startframe = CC{handles.gui_number}.pars6.startFrame(i); %  1;
        minLoc = CC{handles.gui_number}.pars6.minLoc(i); % 1;
        minSize = CC{handles.gui_number}.pars6.minSize(i); % 30; 
        infilt = vlists{n}{i}.frame > startframe;  
        vlist = IndexStructure(vlists{n}{i},infilt);
        
        [mapBW(:,:,i),mapIdx(:,:,i),props2D{i}] = Stats2DScatter(vlist,'xBins',bins2D,'yBins',bins2D,'minLoc',minLoc,'minSize',minSize,'pixelSize',boxSize); %#ok<*AGROW>
        flist{i} = MaskMoleculeList(vlist,mapBW(:,:,i),'xBins',bins2D,'yBins',bins2D); 
   
        % zBins = linspace(-300,300,steps)/npp*zrescale;
        zBins = linspace(-1200,1200,steps)/npp*zrescale;
        xzlist = vlist;
        xzlist.yc = vlist.zc/npp*zrescale;
        mapXZ(:,:,i) =  Stats2DScatter(xzlist,'xBins',bins2D,'yBins',zBins,'minLoc',minLoc,'minSize',minSize,'pixelSize',boxSize);
        flistXZ{i} = MaskMoleculeList(xzlist,mapXZ(:,:,i),'xBins',bins2D,'yBins',zBins);

        yzlist = vlist;
        yzlist.xc = yzlist.yc;
        yzlist.yc = vlist.zc/npp*zrescale;
        mapYZ(:,:,i) = Stats2DScatter(yzlist,'xBins',bins2D,'yBins',zBins,'minLoc',minLoc,'minSize',minSize,'pixelSize',boxSize);
        flistYZ{i} = MaskMoleculeList(yzlist,mapYZ(:,:,i),'xBins',bins2D,'yBins',zBins);

        % histogram variability
        hvs = mapIdx(props2D{i}.PixelIdxList);% histgram values over main dot
        cvDensity(i) = std(hvs)/mean(hvs);

       % 3D volume and 3D Moment of Inertia
        xc = vlists{n}{i}.xc*npp;    
        yc = vlists{n}{i}.yc*npp;  
        zc = vlists{n}{i}.zc;      
        [mainVolume(i), mI3(i)] = Stats3DScatter(xc,yc,zc,'minDots',minLoc);
    end
%% Some images
 % Saturate the ROI to show the connectivity.  
        imaxes.zm = npp/boxSize;
        imaxes.xmin = 0;
        imaxes.ymin = 0;
        imaxes.xmax = regionSize;
        imaxes.ymax = regionSize;
    stormXYfilt = list2img(flist,imaxes);
    areaMap = stormXYfilt;
    for i=1:numChns
        areaMap{i} = 15*areaMap{i};
    end
    
    
    overlapMap = zeros(steps,steps,2);
    if numChns ==2
    overlapMap(:,:,1) = mapBW(:,:,1)>0;
    overlapMap(:,:,2) = 2*(mapBW(:,:,2)>0);
    figure(6); clf; Ncolor(overlapMap);
    mapSum = sum(overlapMap,3);
    figure(6); clf; Ncolor(mapSum); colorbar;
    area1only = sum(mapSum(:)==1)*boxSize^2;
    area2only = sum(mapSum(:)==2)*boxSize^2;
    area1and2 = sum(mapSum(:)==3)*boxSize^2;
    area1or2 = sum(mapSum(:)>0)*boxSize^2;
    [[area1only area2only area1and2]/area1or2  area1and2./[props2D{1}.mainArea props2D{2}.mainArea]]
    end
    
% Filtered versions of main images
imaxes.ymin = zBins(1);
imaxes.ymax = zBins(end);
stormXZfilt = list2img(flistXZ,imaxes);
stormYZfilt = list2img(flistYZ,imaxes);

  
% Quantile Density Map
regMap = mapIdx(:,:,1);
regMap(~mapBW(:,:,1)) = 0;
figure(5); clf; imagesc(regMap); colormap jet;
qs = quantile(nonzeros(regMap(:)),[.2,.7,.85]);
qMap = cat(3, regMap <= qs(1) , 2*(regMap > qs(1) & regMap <= qs(2)) ,...
     3*(regMap>qs(2) & regMap <= qs(3)), 4*(regMap > qs(3)) );
figure(5); clf; subplot(1,2,1); Ncolor(qMap);
subplot(1,2,2); imagesc(mapBW(:,:,1));

% figure(10); clf; 
% subplot(1,3,1); imagesc(mapBW);
% subplot(1,3,2); imagesc(mapXZ);
% subplot(1,3,3); imagesc(mapYZ);
% 
% figure(11); clf; 
% subplot(1,3,1); imagesc(stormXYfilt{1});
% subplot(1,3,2); imagesc(stormXZfilt{1});
% subplot(1,3,3); imagesc(stormYZfilt{1});

%%

% Temporary storage of dot stats
for i=1:numChns
CC{handles.gui_number}.tempData.mainArea(i) = props2D{i}.mainArea;
CC{handles.gui_number}.tempData.mainVolume(i) = mainVolume(i);
CC{handles.gui_number}.tempData.mainLocs(i) = props2D{i}.mainLocs;
CC{handles.gui_number}.tempData.allLocs(i) = props2D{i}.allLocs;
CC{handles.gui_number}.tempData.allArea(i) = props2D{i}.allArea;
CC{handles.gui_number}.tempData.mI(i) = props2D{i}.mI;
CC{handles.gui_number}.tempData.mI3(i) = mI3(i);
CC{handles.gui_number}.tempData.cvDensity(i) = cvDensity(i);
CC{handles.gui_number}.tempData.props2D{i} = props2D{i};

CC{handles.gui_number}.tempData.vlist = CC{handles.gui_number}.vlists{n};
CC{handles.gui_number}.tempData.imaxes = CC{handles.gui_number}.imaxes{n};
CC{handles.gui_number}.tempData.binname = CC{handles.gui_number}.currBinfiles;
CC{handles.gui_number}.tempData.dotnum = n;
end

if numChns > 1
    CC{handles.gui_number}.tempData.area1only = area1only;
    CC{handles.gui_number}.tempData.area2only = area2only;
    CC{handles.gui_number}.tempData.area1or2 = area1or2;
    CC{handles.gui_number}.tempData.area1and2 = area1and2;
    CC{handles.gui_number}.tempData.overlapMap = overlapMap;
end

% Images of our work
CC{handles.gui_number}.tempData.convImages = CC{handles.gui_number}.Iconv{n};
CC{handles.gui_number}.tempData.cellImages = CC{handles.gui_number}.Icell{n};
CC{handles.gui_number}.tempData.stormImages = CC{handles.gui_number}.Istorm{n};
CC{handles.gui_number}.tempData.timeMaps = CC{handles.gui_number}.Itime{n,:};
CC{handles.gui_number}.tempData.stormImagesXZ = CC{handles.gui_number}.ImgZ{n}{1}; 
CC{handles.gui_number}.tempData.stormImagesYZ = CC{handles.gui_number}.ImgZ{n}{2}; 
CC{handles.gui_number}.tempData.stormImagesXY = CC{handles.gui_number}.ImgZ{n}{3};
CC{handles.gui_number}.tempData.stormImagesXZfilt = stormXZfilt; 
CC{handles.gui_number}.tempData.stormImagesYZfilt = stormYZfilt; 
CC{handles.gui_number}.tempData.stormImagesXYfilt = stormXYfilt;
CC{handles.gui_number}.tempData.areaMaps = areaMap;   
CC{handles.gui_number}.tempData.densityMaps = qMap;

%%
 %% Plot data for all dots so far and show where this spot lines up;
    
figure(4); clf; 
subplot(2,3,1); 
maxX = 11E4;
hist(CC{handles.gui_number}.data.mainArea,linspace(0,maxX,50));
hold on; plot(CC{handles.gui_number}.tempData.mainArea,9.5,'r.','MarkerSize',20); 
title(['Area = ',num2str(CC{handles.gui_number}.tempData.mainArea,3)]); 
xlim([0,maxX]);

subplot(2,3,2); 
maxX = 8E8;
hist(CC{handles.gui_number}.data.mainVolume,linspace(0,maxX,50));
hold on; plot(CC{handles.gui_number}.tempData.mainVolume,9.5,'r.','MarkerSize',20); 
title(['Volume = ',num2str(CC{handles.gui_number}.tempData.mainVolume,3)]); 
xlim([0,maxX]); 

subplot(2,3,3); 
maxX = 30;
hist(CC{handles.gui_number}.data.mI,linspace(0,maxX,50));
hold on; plot(CC{handles.gui_number}.tempData.mI,9.5,'r.','MarkerSize',20); 
title(['mI = ',num2str(CC{handles.gui_number}.tempData.mI,3)]); 
xlim([0,maxX]);

subplot(2,3,4); 
maxX = 5E4;
hist(CC{handles.gui_number}.data.mI3,linspace(0,maxX,50));
hold on; plot(CC{handles.gui_number}.tempData.mI3,9.5,'r.','MarkerSize',20); 
title(['mI3 = ',num2str(CC{handles.gui_number}.tempData.mI3,3)]); 
xlim([0,maxX]);

subplot(2,3,5); 
maxX = 20E3;
hist(CC{handles.gui_number}.data.mainLocs,linspace(0,maxX,50));
hold on; plot(CC{handles.gui_number}.tempData.mainLocs,9.5,'r.','MarkerSize',20); 
title(['Localizations = ',num2str(CC{handles.gui_number}.tempData.mainLocs,3)]);
xlim([0,maxX]);

subplot(2,3,6); 
maxX =3;
hist(CC{handles.gui_number}.data.cvDensity,linspace(0,maxX,50));
hold on; plot(CC{handles.gui_number}.tempData.cvDensity,9.5,'r.','MarkerSize',20); 
title(['Density Variation = ',num2str(CC{handles.gui_number}.tempData.cvDensity,3)]);
xlim([0,maxX]);

ChromatinPlots2(handles, n);


