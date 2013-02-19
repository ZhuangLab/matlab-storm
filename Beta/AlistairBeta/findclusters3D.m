 
function findclusters3D()

% function in development


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
         
        M5 = M4>6; % 10
        M5 = bwareaopen(M5,50); % 50
        R3 = regionprops(M5,M4,'PixelValues','WeightedCentroid','BoundingBox','PixelList');
        Nsubclusters = length(R3); 
%         % Just for troubleshooting
%         [h,w,zs] = size(M4);
%         figure(10);
%         k=0;
%         for j=1:zs
%             k=k+1;
%             subplot(6,6,k); imagesc(M5(:,:,j)); colormap gray;
%         end

       fig3d = figure(15); clf; 
       xp = vlist.xc;
       yp = vlist.yc;
       zp = vlist.z; % shorthand
     %  plot3(xp*npp,yp*npp,vlist.z,'r.','MarkerSize',1);
     %  
       plot3(xp(filt)*npp,yp(filt)*npp,vlist.z(filt),'.','color',[.8,.8,.8],'MarkerSize',1);
       alpha .3;
       hold on;
       cent = cat(1,R3.WeightedCentroid);
       for s=1:Nsubclusters
           plot3(voxel(1)*cent(s,1),voxel(2)*cent(s,2),...
               voxel(3)*cent(s,3)+zrange(1),'k.','MarkerSize',20); hold on;
       end
       
%        % Plot bounding boxes
%        cmap = hsv(length(R3)+1);
%        for nn = 1:length(R3);
%            mins = [voxel(1)*R3(nn).BoundingBox(1);
%                voxel(2)*R3(nn).BoundingBox(2);
%                voxel(3)*R3(nn).BoundingBox(3)+zrange(1)];
%            lengths = [voxel(1)*R3(nn).BoundingBox(4);
%                voxel(2)*R3(nn).BoundingBox(5);
%                voxel(3)*R3(nn).BoundingBox(6)];
%            rectangle3d(mins,lengths,'color',cmap(nn,:),'linewidth',3);
%        end
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
       % color pixels
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
      figure(fig3d);
      hold on; plot3(xp,yp,zp,'o','color',cmap(nn,:),'MarkerSize',1);
      
      Gfxn = fit3Dgauss(xp,yp,zp,'showplot',false);
      figure(fig3d);
      plot3(Gfxn(1),Gfxn(2),Gfxn(3),'b+','MarkerSize',30);
   end
   axis square
   xlabel('x (nm)'); ylabel('y (nm)'); zlabel('z (nm)');