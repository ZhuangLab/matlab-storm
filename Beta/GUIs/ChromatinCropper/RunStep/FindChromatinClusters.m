function handles = FindChromatinClusters(handles)

global CC



%% Load step data

% Load user selected / default parameters

H = CC{handles.gui_number}.pars0.H;
W = CC{handles.gui_number}.pars0.W;
npp = CC{handles.gui_number}.pars0.npp;
cluster_scale= npp/CC{handles.gui_number}.pars3.boxSize(1); 
regionSize = CC{handles.gui_number}.pars5.regionSize/npp;  
zm = npp/CC{handles.gui_number}.pars5.boxSize;

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

% Update fields for 2 color data
if isempty(CC{handles.gui_number}.mlist1)
    mlists = {mlist};
    filters = {infilt}; 
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
ImgZ= cell(Nclusters,1); 
cmp = cell(Nclusters,1); 
vlists = cell(Nclusters,1); 
allImaxes = cell(Nclusters,1); 

figure(2); clf; Ncolor(convI); 
for n=1:Nclusters % n=3    
        % For dsiplay and judgement purposes 
        imaxes.zm = zm;
        imaxes.scale = 1;
        imaxes.cx = R(n).Centroid(1)/cluster_scale; % convert from histogram coordinates to image coordinates. 
        imaxes.cy = R(n).Centroid(2)/cluster_scale;
        imaxes.xmin = max(imaxes.cx - regionSize/2,1);
        imaxes.xmax = min(imaxes.cx + regionSize/2,W);
        imaxes.ymin = max(imaxes.cy - regionSize/2,1);
        imaxes.ymax = min(imaxes.cy + regionSize/2,H);
        allImaxes{n} = imaxes; 

   % Add dot labels to overview image           
        axes(handles.axes2); hold on; text(imaxes.cx+6,imaxes.cy,...
         ['dot ',num2str(n)],'color','w'); %#ok<*LAXES>
     figure(2);  hold on; text(imaxes.cx+6,imaxes.cy,...
         ['dot ',num2str(n)],'color','w');

   % Get STORM image      
        I = list2img(mlists,imaxes,'filter',filters,...
           'scalebar',500,'correct drift',true); 
        Istorm{n} = I;  % save image;           
       %  figure(1); clf; STORMcell2img(I);
       
      % Conventional Image of Spot 
        convCrop = convI(ceil(imaxes.ymin):floor(imaxes.ymax),...
            ceil(imaxes.xmin):floor(imaxes.xmax),:);
        Iconv{n} = convCrop; 
        
     % STORM image of whole cell
       cellaxes = imaxes;
       cellaxes.zm = 4; % zoom out to cell scale;
       cellaxes.W = W;
       cellaxes.H = H;
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
                  
     %  Indicate color as time. 
        [cmp{n},dxc,dyc] =  ColorByFrame(vlist);  
        Itime{n} = [dxc,dyc,cmp{n}];
        vlists{n} = vlist; 
        
     % XZ and YZ plots
         figure(3); clf; 
         [stormXZ,stormYZ,stormXY] = List2ImgXYZ(vlist,'colormap',...
             CC{handles.gui_number}.clrmap); 
         ImgZ{n} = {stormXZ,stormYZ,stormXY}; 
end  % end loop over dots
   
% ----------------  Export Plotting data
CC{handles.gui_number}.vlists = vlists;
CC{handles.gui_number}.Nclusters = Nclusters;
CC{handles.gui_number}.R = R;
CC{handles.gui_number}.imaxes = allImaxes;
CC{handles.gui_number}.Istorm = Istorm;
CC{handles.gui_number}.Iconv = Iconv;
CC{handles.gui_number}.Icell = Icell;
CC{handles.gui_number}.Itime = Itime;
CC{handles.gui_number}.ImgZ = ImgZ;
CC{handles.gui_number}.cmp = cmp;
for n=1:Nclusters
      ChromatinPlots(handles, n);
      pause(.5); 
end

if Nclusters > 1
    CC{handles.gui_number}.dotnum = 1;
    set(handles.DotNum,'String',num2str(1)); 
    set(handles.DotSlider,'Value',1);
    set(handles.DotSlider,'Min',1);
    set(handles.DotSlider,'Max',Nclusters);  
    set(handles.DotSlider,'SliderStep',[1/(Nclusters-1),3/(Nclusters-1)]);
end
    