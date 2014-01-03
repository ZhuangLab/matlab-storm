function handles = FliterChromatinClusters(handles)

global CC

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
       mI = m'*(xy(:,1).^2+xy(:,2).^2);
              
       CC{handles.gui_number}.M2{nn} = M2;
       CC{handles.gui_number}.map{nn} = map;
       
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