function handles = FliterChromatinClusters(handles)

global CC


%% Load data
Nclusters = CC{handles.gui_number}.Nclusters;
vlists = CC{handles.gui_number}.vlists;
npp = CC{handles.gui_number}.pars0.npp;

% 2D subcluster vlist image
boxSize = CC{handles.gui_number}.pars6.boxSize;    
cluster_scale = CC{handles.gui_number}.pars0.npp/boxSize;
startframe = CC{handles.gui_number}.pars6.startFrame; %  1;
minloc = CC{handles.gui_number}.pars6.minloc; % 1;
minSize = CC{handles.gui_number}.pars6.minSize; % 30; 
        



% 'Loop' over clusters
n = get(handles.DotSlider,'Value');

   % Histogram localizations on tunable scale
    infilt = vlists{n}.frame > startframe;  
    H = max([vlists{n}.yc(infilt);vlists{n}.xc(infilt)]);
    W = H;
   M2 = hist3([vlists{n}.yc(infilt),vlists{n}.xc(infilt)],...
   {0:1/cluster_scale:H,0:1/cluster_scale:W});  
%       figure(3); clf; imagesc(M2); colorbar; caxis([0,80]); colormap hot;

   map = M2>=minloc;  
   map = imfill(map,'holes'); 
   map = bwareaopen(map,minSize);  % small regions removed
   %       figure(3); clf; imagesc(map); 

   props2D = regionprops(map,M2,'PixelIdxList','Area','PixelValues',...
       'Eccentricity','BoundingBox','WeightedCentroid','PixelList');
   
   % Area and locallizations
   [maxArea,mainIdx] = max([props2D.Area]);
   mainArea = maxArea*boxSize^2;
   mainLocs = sum(props2D(mainIdx).PixelValues);
   allArea = sum([props2D.Area])*boxSize^2;
   allLocs = sum(cat(1,props2D.PixelValues));

   % 2D Moment of Inertia
   m = cat(1,props2D(mainArea).PixelValues); 
   xy = cat(1,props2D(mainArea).PixelList);
   xy(:,1) = xy(:,1) - props2D(mainArea).Centroid(1);
   xy(:,2) = xy(:,2) - props2D(mainArea).Centroid(2);
   mI = m'*(xy(:,1).^2+xy(:,2).^2);

    % histogram variability
    hvs = M2(props2D(mainIdx).PixelIdxList);% histgram values over main dot
    cvDensity = std(hvs)/mean(hvs);
  
   % 3D volume and 3D Moment of Inertia
    xc = vlists{n}.xc*npp;    
    yc = vlists{n}.yc*npp;  
    zc = vlists{n}.zc;      
    [mainVolume, mI3] = Stats3DScatter(xc,yc,zc,varargin);

    % Plot data for all dots so far and show where this spot lines up;
    
figure(3); clf; 
subplot(2,2,1); 
hist(CC{handles.gui_number}.data.mainArea,linspace(0,15E5,100));
subplot(2,2,1); 
hist(CC{handles.gui_number}.data.mainArea,linspace(0,15E5,100));

CC{handles.gui_number}.data.mI3
    
CC{handles.gui_number}.data.mI3 = NaN*zeros(maxDots,1);
CC{handles.gui_number}.data.mainVolume = NaN*zeros(maxDots,1);
CC{handles.gui_number}.data.mI = NaN*zeros(maxDots,1);
CC{handles.gui_number}.data.mainArea = NaN*zeros(maxDots,1);
CC{handles.gui_number}.data.mainLocs = NaN*zeros(maxDots,1);
CC{handles.gui_number}.data.allArea= NaN*zeros(maxDots,1);
CC{handles.gui_number}.data.allLocs= NaN*zeros(maxDots,1);
CC{handles.gui_number}.data.cvDensity= NaN*zeros(maxDots,1); 
CC{handles.gui_number}.data.eccent= NaN*zeros(maxDots,1);



parData{1} = CC{handles.gui_number}.pars1;
parData{2} = CC{handles.gui_number}.pars2;
parData{3} = CC{handles.gui_number}.pars3;
parData{4} = CC{handles.gui_number}.pars4;
parData{5} = CC{handles.gui_number}.pars5;
parData{6} = CC{handles.gui_number}.pars6;
parData{7} = CC{handles.gui_number}.pars7;
parData{8} = CC{handles.gui_number}.pars0;
parData{9} = CC{handles.gui_number}.parsX;

    % We only want to do this when we save the data.  

 % Update plots
    ChromatinPlots2(handles,n);
end


   CC{handles.gui_number}.saveNs = saveNs;
  if max(saveNs) > 1
    set(handles.DotSlider,'Value',max(saveNs));
  end
      
    % Record statistics  
    dotnum = find(~isempty(CC{handles.gui_number}.data),1,'first');
    % dot statistics
    CC{handles.gui_number}.data{dotnum} =...
    CC{handles.gui_number}.imdata{n};
    
    
    figure(1); clf; colordef white; 
    subplot(3,2,1); hist( [data.MainArea{:}] ); title('Area');
    subplot(3,2,2); hist( [data.Dvar{:}] ); title('Intensity Variation')
    subplot(3,2,3); hist( [data.MainDots{:}]./[data.MainArea{:}] ); title('localization density');
    subplot(3,2,4); hist( [data.Tregions{:}] ); title('number of regions'); 
    subplot(3,2,5); hist( [data.TregionsW{:}] ); title('Weighted number of regions')
    subplot(3,2,6); hist( [data.mI{:}] ); title('moment of Inertia'); 
    % hist( [data.MainEccent{:}] ); title('eccentricity'); 
