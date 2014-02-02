function handles = FilterChromatinClusters(handles)

global CC


%% Load data
vlists = CC{handles.gui_number}.vlists;
npp = CC{handles.gui_number}.pars0.npp;

% 2D subcluster vlist image
boxSize = CC{handles.gui_number}.pars6.boxSize;     % boxSize in nm
regionSize = CC{handles.gui_number}.pars5.regionSize/npp;  % region size in pixels 
zrescale = 1; % CC{handles.gui_number}.pars5.zrescale;

startframe = CC{handles.gui_number}.pars6.startFrame; %  1;
minLoc = CC{handles.gui_number}.pars6.minLoc; % 1;
minSize = CC{handles.gui_number}.pars6.minSize; % 30; 
 % 30; 
% zm = 10 => boxsize = npp/zm = 16nm


%% 'Loop' over clusters 
n = round(get(handles.DotSlider,'Value'));

   % Histogram localizations on tunable scale
    infilt = vlists{n}.frame > startframe;  
    vlist = IndexStructure(vlists{n},infilt);
    
    steps = regionSize*npp/boxSize;
    bins2D = linspace(0,regionSize,steps); 
    [mapBW,mapIdx,props2D] = Stats2DScatter(vlist,'xBins',bins2D,'yBins',bins2D,'minLoc',minLoc,'minSize',minSize,'pixelSize',boxSize);
    flist = MaskMoleculeList(vlist,mapBW,'xBins',bins2D,'yBins',bins2D); 
 
    % zBins = linspace(-300,300,steps)/npp*zrescale;
    zBins = linspace(-1200,1200,steps)/npp*zrescale;
    xzlist = vlist;
    xzlist.yc = vlist.zc/npp*zrescale;
    mapXZ =  Stats2DScatter(xzlist,'xBins',bins2D,'yBins',zBins,'minLoc',minLoc,'minSize',minSize,'pixelSize',boxSize);
    flistXZ = MaskMoleculeList(xzlist,mapXZ,'xBins',bins2D,'yBins',zBins);
    
    yzlist = vlist;
    yzlist.xc = yzlist.yc;
    yzlist.yc = vlist.zc/npp*zrescale;
    mapYZ = Stats2DScatter(yzlist,'xBins',bins2D,'yBins',zBins,'minLoc',minLoc,'minSize',minSize,'pixelSize',boxSize);
    flistYZ = MaskMoleculeList(yzlist,mapYZ,'xBins',bins2D,'yBins',zBins);
    
    % histogram variability
    hvs = mapIdx(props2D.PixelIdxList);% histgram values over main dot
    cvDensity = std(hvs)/mean(hvs);
  
   % 3D volume and 3D Moment of Inertia
    xc = vlists{n}.xc*npp;    
    yc = vlists{n}.yc*npp;  
    zc = vlists{n}.zc;      
    [mainVolume, mI3] = Stats3DScatter(xc,yc,zc,'minDots',minLoc);
    
%% Some images
 % Saturate the ROI to show the connectivity.  
        imaxes.zm = npp/boxSize;
        imaxes.xmin = 0;
        imaxes.ymin = 0;
        imaxes.xmax = regionSize;
        imaxes.ymax = regionSize;
    stormXYfilt = list2img(flist,imaxes);
    areaMap = 15*stormXYfilt{1};
  
% Filtered versions of main images
imaxes.ymin = zBins(1);
imaxes.ymax = zBins(end);
stormXZfilt = list2img(flistXZ,imaxes);
stormYZfilt = list2img(flistYZ,imaxes);

  
% Quantile Density Map
regMap = mapIdx;
regMap(~mapBW) = 0;
figure(5); clf; imagesc(regMap); colormap jet;
qs = quantile(nonzeros(regMap(:)),[.2,.7,.85]);
qMap = cat(3, regMap <= qs(1) , 2*(regMap > qs(1) & regMap <= qs(2)) ,...
     3*(regMap>qs(2) & regMap <= qs(3)), 4*(regMap > qs(3)) );
figure(5); clf; subplot(1,2,1); Ncolor(qMap);
subplot(1,2,2); imagesc(mapBW);

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
CC{handles.gui_number}.tempData.mainArea = props2D.mainArea;
CC{handles.gui_number}.tempData.mainVolume = mainVolume;
CC{handles.gui_number}.tempData.mainLocs = props2D.mainLocs;
CC{handles.gui_number}.tempData.allLocs = props2D.allLocs;
CC{handles.gui_number}.tempData.allArea = props2D.allArea;
CC{handles.gui_number}.tempData.mI = props2D.mI;
CC{handles.gui_number}.tempData.mI3 = mI3;
CC{handles.gui_number}.tempData.cvDensity = cvDensity;
CC{handles.gui_number}.tempData.props2D = props2D;


CC{handles.gui_number}.tempData.vlist = CC{handles.gui_number}.vlists{n};
CC{handles.gui_number}.tempData.imaxes = CC{handles.gui_number}.imaxes{n};
CC{handles.gui_number}.tempData.binname = CC{handles.gui_number}.currBinfiles;
CC{handles.gui_number}.tempData.dotnum = n;

% Images of our work
CC{handles.gui_number}.tempData.convImages = CC{handles.gui_number}.Iconv{n};
CC{handles.gui_number}.tempData.cellImages = CC{handles.gui_number}.Icell{n};
CC{handles.gui_number}.tempData.stormImages = CC{handles.gui_number}.Istorm{n};
CC{handles.gui_number}.tempData.timeMaps = CC{handles.gui_number}.Itime{n};
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


