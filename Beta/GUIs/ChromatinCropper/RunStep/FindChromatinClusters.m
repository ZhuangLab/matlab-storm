function handles = FindChromatinClusters(handles)

global CC



%% Load step data

    % Load user selected / default parameters
    H = CC{handles.gui_number}.pars0.H;
    W = CC{handles.gui_number}.pars0.W;
    npp = CC{handles.gui_number}.pars0.npp;
    scale = CC{handles.gui_number}.pars5.scale/npp;
    zm = CC{handles.gui_number}.pars5.zm;  
    cluster_scale= CC{handles.gui_number}.pars0.npp/...
               CC{handles.gui_number}.pars3.boxSize(1); 
    
    % Load data from previous steps
    mlist = CC{handles.gui_number}.mlist; 
    infilt = CC{handles.gui_number}.infilt;
    R = CC{handles.gui_number}.R;
    conv0 = CC{handles.gui_number}.conv;
    convI = CC{handles.gui_number}.convI;      
           
    % Update M with drift correction
      M = hist3([mlist.yc(infilt),mlist.xc(infilt)],...
             {0:1/cluster_scale:H,0:1/cluster_scale:W});
      CC{handles.gui_number}.M = M; 
    
    % 
    if isempty(CC{handles.gui_number}.mlist1)
        mlists = {mlist};
    else
        infilt1= CC{handles.gui_number}.infilt1;
        conv1 = CC{handles.gui_number}.conv1;
        mlist1 = CC{handles.gui_number}.mlist1;
        mlists = {mlist1; mlist};
        filters = {infilt1; infilt}; 
      % Update M with drift correction
      M1 = hist3([mlist1.yc(infilt1),mlist1.xc(infilt1)],...
             {0:1/cluster_scale:H,0:1/cluster_scale:W});
      CC{handles.gui_number}.M1 = M1;    
    end
     
%     figure(1); clf;
%     plot(mlist.xc,mlist.yc,'k.');
%     hold on; 
%     plot(mlist1.xc,mlist1.yc,'ro');
%     
    %%  
        % Conventional image in finder window
     axes(handles.axes2); cla;
     Ncolor(convI); colormap hot;
     set(gca,'color','k'); set(gca,'XTick',[],'YTick',[]);
    
        % Initialize subplots Clean up main figure window
    set(handles.subaxis1,'Visible','on'); set(gca,'color','k'); set(gca,'XTick',[],'YTick',[]);
    set(handles.subaxis2,'Visible','on'); set(gca,'color','k'); set(gca,'XTick',[],'YTick',[]);
    set(handles.subaxis3,'Visible','on'); set(gca,'color','k'); set(gca,'XTick',[],'YTick',[]);
    set(handles.subaxis4,'Visible','on'); set(gca,'color','k'); set(gca,'XTick',[],'YTick',[]);
     
  %------------------ Split and Plot Clusters   -----------------------
      % Arrays to store plotting data in
       Nclusters = length(R);
       Istorm = cell(Nclusters,1);
       Iconv = cell(Nclusters,1); 
       Itime = cell(Nclusters,1);
       Ihist = cell(Nclusters,1);
       Icell = cell(Nclusters,1); 
       cmp = cell(Nclusters,1); 
       vlists = cell(Nclusters,1); 
       allImaxes = cell(Nclusters,1); 
       
       figure(2); clf; Ncolor(convI); 
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
         ['dot ',num2str(n)],'color','w'); %#ok<*LAXES>
     figure(2);  hold on; text(imaxes.cx+6,imaxes.cy,...
         ['dot ',num2str(n)],'color','w');
     
     

   % Get STORM image      
        I = list2img(mlists,imaxes,'filter',filters,...
           'scalebar',500,'correct drift',true); 
        Istorm{n} = I{1};  % save image; 
              
        figure(1); clf; STORMcell2img(I);
        
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
       cellaxes.W = 256;
       cellaxes.H = 256;
       cellaxes.xmin = cellaxes.cx - cellaxes.W/2/cellaxes.zm;
       cellaxes.xmax = cellaxes.cx + cellaxes.W/2/cellaxes.zm;
       cellaxes.ymin = cellaxes.cy - cellaxes.H/2/cellaxes.zm;
       cellaxes.ymax = cellaxes.cy + cellaxes.H/2/cellaxes.zm;
       Izmout = list2img(mlists,cellaxes,...
           'filter',filters,'Zsteps',1,'scalebar',500);
       Icell{n} = sum(Izmout{1},3);
   
     % Gaussian Fitting and Cluster
       % Get subregion, exlude distant zs which are poorly fit
        vlist = msublist(mlist,imaxes,'filter',infilt);
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
    