function [subcluster,fig3d] = findclusters3D(x,y,z,varargin) 
%--------------------------------------------------------------------------
% subcluster = findclusters3D(x,y,z)
%  data is binned into a 3d 'image', a gaussian smoothing is applied,
%  followed by a watershed algorithm.  Add more smoothing if there are too
%  many clusters (small local maximum), and or shrink bin sizes.  
%
%  It is recommend that large images are first parsed into 2D clusters and
%  subcluster be run only on subsets of the images to see if any of these
%  can be broken apart in 3D.  
%  
%--------------------------------------------------------------------------
% Required Inputs:
% x,y,z  -- 3 vectors containing the positions of data
% 
%-------------------------------------------------------------------------- 
% Outputs:
% subcluster / struct
%     -- structure contains the following: fields (size) explanation
%           subcluster.Nsubclusters = (1,1)      Number of subclusters 
%           subcluster.sigma  (Nsubclusters,3)   Gauss-fit: sigX,sigY,sigZ
%           subcluster.counts  (Nsubclusters,1)  total points in subcluster
%           subcluster.Nvoxels (Nsubclusters,1)  total voxels in subcluster
%           subcluster.maxvox  (Nsubclusters,1)  points in densist voxel
%           subcluster.medianvox (Nsubclusters,1)median points per voxel
%           subcluster.meanvox  (Nsubclusters,1) mean points per voxel
% 
%--------------------------------------------------------------------------
% Optional Inputs: 
% 'name' / datatype / default-value
% 'bins' / 3-vector / [128,128,40]
%                   -- number of bins in x, y, and z. 
% 'minvoxels' / double / 0.25% of total bins
%                   -- min number of voxels in a region for it to be kept. 
% 'sigmablur' / 3-vector / [6,6,3]
%                   -- amount of gaussian blurring of 3D image prior to
%                   applying watershed.  see help fspecial3 for more
%                   details.  This is its second argument.
% 'datarange' / cell / 
%                   -- {xrange,yrange,zrange} determines min and max to
%                   plot.  
% 'fitGauss' / logical / false
% 'plotson' / logical / true
%                   -- 3D colored plot of clustering
%--------------------------------------------------------------------------
% Required custom functions
% hist4.m           (essential)
% fspecial3.m       (essential)
% fitgauss3D.m      (only to get data for subcluster.sigma)
% CheckParameter.m (replace x = CheckParameter with x=parameterValue
%                   to remove dependency).  
% rectangle3d.m    (only for boxplot)
%
%--------------------------------------------------------------------------
% Alistair Boettiger
% boettiger.alistair@gmail.com
% February 19th, 2013
%
% Version 1.0
%--------------------------------------------------------------------------
% Creative Commons License 3.0 CC BY  
%--------------------------------------------------------------------------



%--------------------------------------------------------------------------
%% Default Parameters
%--------------------------------------------------------------------------
datarange = cell(1,3);
bins = [128,128,40];
sigmablur=[6,6,3];
minvoxels = [];      
plotson = true;
plotboundingbox = false;
fitGauss = false;
figh = [];


%--------------------------------------------------------------------------
%% Parse Variable Input Parameters
%--------------------------------------------------------------------------
if nargin > 3
    if (mod(length(varargin), 2) ~= 0 ),
        error(['Extra Parameters passed to the function ''' mfilename ''' must be passed in pairs.']);
    end
    parameterCount = length(varargin)/2;

    for parameterIndex = 1:parameterCount,
        parameterName = varargin{parameterIndex*2 - 1};
        parameterValue = varargin{parameterIndex*2};
        switch parameterName
            case 'bins'
                bins = CheckParameter(parameterValue, 'positive', 'bins');
            case 'minvoxels'
                minvoxels = CheckParameter(parameterValue, 'positive', 'minvoxels');
            case 'datarange'
                datarange = CheckParameter(parameterValue, 'cell', 'datarange');
            case 'sigmablur'
                sigmablur = CheckParameter(parameterValue, 'positive', 'sigmablur');
            case 'fitGauss'
                fitGauss = CheckParameter(parameterValue, 'boolean', 'fitGauss'); 
            case 'figh'
                figh = CheckParameter(parameterValue, 'nonnegative', 'figh');
            case 'plotson'
                plotson = CheckParameter(parameterValue, 'boolean', 'plotson');
            otherwise
                error(['The parameter ''', parameterName,...
                    ''' is not recognized by the function, ''',...
                    mfilename '''.' '  See help ' mfilename]);
        end
    end
end

% autocalc for optional parameters
[xrange,yrange,zrange] = datarange{:};
if isempty(zrange)
    zrange = [min(z),max(z)]; 
end
if isempty(yrange)
    yrange = [min(y),max(y)];
end
if isempty(xrange)
    xrange = [min(x),max(x)];
end


if isempty(minvoxels)
    minvoxels = .0025*prod(bins);
end


if ~isempty(figh)
    fig3d = figh;
else
    if plotson
        fig3d = figure; 
    end
end

%--------------------------------------------------------------------------
%% Main Function
%--------------------------------------------------------------------------

if plotson
   figure(fig3d);  clf;
   plot3(x,y,z,'.','color',[.8,.8,.8],'MarkerSize',1);
   axis square;
   hold on;
end

% Bin data in 3D, 
%--------------------------------------------------------------------------
voxel = [xrange(2)/bins(1),yrange(2)/bins(2),(zrange(2)-zrange(1))/bins(3)];
M4 = hist4(x,y,z,'bins',bins,'datarange',{xrange,yrange,zrange});
% % for troubleshooting
% figure(4); clf; Ncolor(1000*M4); 
    
%   %  Old way -- threshold the map, reject small clusters
%     M5 = M4>6; % 10
%     M5 = bwareaopen(M5,50); % 50
%     R3 = regionprops(M5,M4,'PixelValues','WeightedCentroid','BoundingBox','PixelList');
 

% smooth data and apply watershed filter   
%-----------------------------------------------------------
gaussblur = fspecial3('gaussian',sigmablur);
M4s = imfilter(M4,gaussblur,'replicate');
 
 % classic watershed filter
 W = max(M4s(:)); 
 L = watershed(double(W-M4s));  
 M4seg = M4s;
 M4seg(L==0) = 0;
       
%       %   Just for troubleshooting
%         [h,w,zs] = size(M4);
%         figure(10);
%         k=0;
%         for j=1:zs
%             k=k+1;
%             subplot(8,5,k); imagesc(M4seg(:,:,j)); colormap gray;
%         end

% threshold and get region props (just the big ones); 
bw = M4seg>0; 
R3 = regionprops(bw,M4,'PixelValues','WeightedCentroid','BoundingBox','PixelList');
lengths = cellfun(@length, {R3.PixelValues});
R3 = R3(lengths>minvoxels);
Nsubclusters = length(R3);

cmap = hsv(Nsubclusters+1);
cent = cat(1,R3.WeightedCentroid);
if plotson
    for s=1:Nsubclusters;
        figure(fig3d);
        plot3(voxel(1)*cent(s,1),voxel(2)*cent(s,2),...
           voxel(3)*cent(s,3)+zrange(1),'k.','MarkerSize',20); hold on;
    end
end
   %%    
   
% Plot bounding boxes
if plotson && plotboundingbox
    for nn = 1:Nsubclusters;
      figure(fig3d); 
       mins = [voxel(1)*R3(nn).BoundingBox(1);
           voxel(2)*R3(nn).BoundingBox(2);
           voxel(3)*R3(nn).BoundingBox(3)+zrange(1)];
       lengths = [voxel(1)*R3(nn).BoundingBox(4);
           voxel(2)*R3(nn).BoundingBox(5);
           voxel(3)*R3(nn).BoundingBox(6)];
       rectangle3d(mins,lengths,'color',cmap(nn,:),'linewidth',3);
    end
end
    
     
% get just the pixels that are in the regions. 
%--------------------------------------------------------------------
  
  % initialize some variables
  vi =cell(Nsubclusters,1); 
  subcluster.Nsubclusters = Nsubclusters; 
  subcluster.sigma = zeros(Nsubclusters,3);
  subcluster.counts = zeros(Nsubclusters,1);
  subcluster.Nvoxels = zeros(Nsubclusters,1);
  subcluster.maxvox = zeros(Nsubclusters,1);
  subcluster.medianvox = zeros(Nsubclusters,1);
  subcluster.meanvox = zeros(Nsubclusters,1);
    
  % color pixels in each subcluster 
  % (good visual/manual check on segmentation). 
  counts = cell(Nsubclusters,1); 
   for nn=1:Nsubclusters 
      rX = voxel(1)*R3(nn).PixelList(:,1);
      rY = voxel(2)*R3(nn).PixelList(:,2);
      rZ = voxel(3)*R3(nn).PixelList(:,3);
      vX = voxel(1)*round(x/voxel(1));
      vY = voxel(2)*round(y/voxel(2));
      vZ = voxel(3)*round((z-zrange(1))/(voxel(3)));
      vi{nn} = ismember([vX,vY,vZ],[rX,rY,rZ],'rows'); 
      xp = x(vi{nn});
      yp = y(vi{nn});
      zp = z(vi{nn});
      % Gaussian fit to each subcluster
      if fitGauss
        Gfxn = fit3Dgauss(xp,yp,zp,'showplot',false);
      else
          Gfxn = zeros(6,1);
      end
      
      % Save some stats on clusters
      subcluster.sigma(nn,:) = [Gfxn(4),Gfxn(5),Gfxn(6)];
      subcluster.counts(nn) = length(xp);
      subcluster.Nvoxels(nn) = length(rX);
      allpix = single(R3(nn).PixelValues);
      subcluster.maxvox(nn) = max(allpix);
      subcluster.medianvox(nn) = median(allpix(allpix>0));
      subcluster.meanvox(nn) = mean(allpix(allpix>0));  
      
      if plotson
          figure(fig3d);    hold on;
          plot3(xp,yp,zp,'o','color',cmap(nn,:),'MarkerSize',1);
          plot3(Gfxn(1),Gfxn(2),Gfxn(3),'b+','MarkerSize',30);
          counts{nn} = ['counts=' num2str(length(xp))]; 
          if nn==Nsubclusters
          title(counts);
          end
      end
        

   end
   axis square;
   xlabel('x (nm)'); ylabel('y (nm)'); zlabel('z (nm)');