  %%    % Bin data in 3D, 
       % xcm = imaxes.cx - imaxes.xmin;
       % ycm = imaxes.cy - imaxes.ymin;
        xrange =  [0,16]*npp ;  % [xcm-8,xcm+8]*npp; % <- centers histogram but not scatterplot 
        yrange = [0,16]*npp ; %  [ycm-8,ycm+8]*npp; %   
        bins = [128,128,40];
        voxel = [xrange(2)/bins(1),yrange(2)/bins(2),(zrange(2)-zrange(1))/bins(3)];
        M4 = hist4(vlist.xc(filt)*npp,vlist.yc(filt)*npp,vlist.z(filt),...
         'bins',bins,'datarange',{xrange,yrange,zrange});
       % figure(4); clf; Ncolor(1000*M4); 
         
    %    M5 = M4>6; % 10
    %    M5 = bwareaopen(M5,50); % 50
   %     R3 = regionprops(M5,M4,'PixelValues','WeightedCentroid','BoundingBox','PixelList');
%%        
   
       
   % smoothe and find local maxima
       gaussblur = fspecial3('gaussian',[6,6,3]);
       M4s = imfilter(M4,gaussblur,'replicate');
       
       bw = imregionalmax(M4s);
       R3 = regionprops(bw,M4s,'PixelValues','WeightedCentroid','BoundingBox','PixelList');
       maxpvs = cellfun(@max, {R3.PixelValues});
       R3 = R3(maxpvs>5);  
       figure(3); clf; hist(double(maxpvs(maxpvs>4)));
  
       gaussblur2 = fspecial3('gaussian',[3,3,1.5]);
       Ms2 = imfilter(M4,gaussblur2,'replicate');
        localmin = imregionalmin(Ms2);
        Rmin = regionprops(localmin,Ms2,'PixelValues','Centroid','BoundingBox','PixelList');
       
       fig3d = figure(15); clf; 
       xp = vlist.xc;
       yp = vlist.yc;
       zp = vlist.z; 
       plot3(xp(filt)*npp,yp(filt)*npp,vlist.z(filt),'.','color',[.8,.8,.8],'MarkerSize',1);
       hold on;
       
 W = max(M4s(:)); 
 L = watershed(double(W-M4s));  %  figure(2); clf; imagesc(L); colormap lines; shading flat;
 M4seg = M4s;
 M4seg(L==0) = 0;
 
 %         % Just for troubleshooting
        [h,w,zs] = size(M4);
        figure(10);
        k=0;
        for j=1:zs
            k=k+1;
            subplot(8,5,k); imagesc(M4seg(:,:,j)); colormap gray;
        end
bw = M4seg>0;
R3 = regionprops(bw,M4,'PixelValues','WeightedCentroid','BoundingBox','PixelList');
lengths = cellfun(@length, {R3.PixelValues});
 %figure(3); clf; hist(double(lengths(lengths>minvoxels)));
  
minvoxels = 1500;     
R3 = R3(lengths>minvoxels);
Nsubclusters = length(R3);

%        centmin = cat(1,Rmin.Centroid);
%        for s=1:length(Rmin);
%            plot3(voxel(1)*centmin(s,1),voxel(2)*centmin(s,2),...
%                voxel(3)*centmin(s,3)+zrange(1),'r.','MarkerSize',20); hold on;
%        end
%        
       cent = cat(1,R3.WeightedCentroid);
       for s=1:length(R3);
           plot3(voxel(1)*cent(s,1),voxel(2)*cent(s,2),...
               voxel(3)*cent(s,3)+zrange(1),'k.','MarkerSize',100); hold on;
       end
   %%    
       % Plot bounding boxes
       cmap = hsv(length(R3)+1);
       for nn = 1:length(R3);
           mins = [voxel(1)*R3(nn).BoundingBox(1);
               voxel(2)*R3(nn).BoundingBox(2);
               voxel(3)*R3(nn).BoundingBox(3)+zrange(1)];
           lengths = [voxel(1)*R3(nn).BoundingBox(4);
               voxel(2)*R3(nn).BoundingBox(5);
               voxel(3)*R3(nn).BoundingBox(6)];
           rectangle3d(mins,lengths,'color',cmap(nn,:),'linewidth',3);
       end
       axis square;
       
%        figure(16); clf;
%        plot3(rX,rY,rZ,'k.');
 %     
  % get just the pixels that are in the regions. 
  vi =cell(Nsubclusters,1); 
  Im(d,b).subcluster(n).Nsubclusters = Nsubclusters; 
  Im(d,b).subcluster(n).sigma = zeros(Nsubclusters,3);
  Im(d,b).subcluster(n).counts = zeros(Nsubclusters,1);
  Im(d,b).subcluster(n).voxels = zeros(Nsubclusters,1);
  Im(d,b).subcluster(n).maxvox = zeros(Nsubclusters,1);
  Im(d,b).subcluster(n).medianvox = zeros(Nsubclusters,1);
  Im(d,b).subcluster(n).meanvox = zeros(Nsubclusters,1);
   for nn=1:Nsubclusters % nn=1;
       % color pixels in each subcluster (manual check on segmentation). 
      rX = voxel(1)*R3(nn).PixelList(:,1);
      rY = voxel(2)*R3(nn).PixelList(:,2);
      rZ = voxel(3)*R3(nn).PixelList(:,3);
      vX = voxel(1)*round(vlist.xc*npp/voxel(1));
      vY = voxel(2)*round(vlist.yc*npp/voxel(2));
      vZ = voxel(3)*round((vlist.z-zrange(1))/(voxel(3)));
      vi{nn} = ismember([vX,vY,vZ],[rX,rY,rZ],'rows'); %vi = vii(:,1) & vii(:,2) & vii(:,3);
      xp = vlist.xc(vi{nn})*npp;
      yp = vlist.yc(vi{nn})*npp;
      zp = vlist.z(vi{nn});
      figure(fig3d);    hold on;
      plot3(xp,yp,zp,'o','color',cmap(nn,:),'MarkerSize',1);
      
      % Gaussian fit to each subcluster
      Gfxn = fit3Dgauss(xp,yp,zp,'showplot',false);
      figure(fig3d);
      plot3(Gfxn(1),Gfxn(2),Gfxn(3),'b+','MarkerSize',30);
      
      % Save some data
      Im(d,b).subcluster(n).sigma(nn,:) = [Gfxn(4),Gfxn(5),Gfxn(6)];
      Im(d,b).subcluster(n).counts(nn) = length(xp);
      Im(d,b).subcluster(n).voxels = length(rX);
      allpix = single(R3(nn).PixelValues);
      Im(d,b).subcluster(n).maxvox = max(allpix);
      Im(d,b).subcluster(n).medianvox = median(allpix(allpix>0));
      Im(d,b).subcluster(n).meanvox = mean(allpix(allpix>0)); 
   end
   axis square
   xlabel('x (nm)'); ylabel('y (nm)'); zlabel('z (nm)');