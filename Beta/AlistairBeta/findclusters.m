
function Clust = findclusters(mlist,nuc_chn,clust_chn,varargin)
% Clust = clusters_per_nucleus(mlist)
% Clust = clusters_per_nucleus(mlist,'min density',value,'cluster scale',...
%         value, 'nuclei scale',value, 'min nuc size',value)
% Clusters dots in channel nuc_chn using a course grid that groups all dots
%    from one nucleus into a single cluster.  Parameter 'nuclei scale',
%    determines this grid size.  Then all dots in channel clust_chn are
%    clustered using a fine grid (modify as 'cluster scale'). 
%--------------------------------------------------------------------------
% inputs 
%--------------------------------------------------------------------------
% molist / cell 
%                   -- contains a cell for each channel, which contains a
%                   molecule list structure
% nuc_chn / scalar  
%                   -- which channel in molist contains the nuclei
%                   localizations to be used to make the mask
% clust_chn / scalar 
%                   -- which channel in molist contains the data to be
%                   clustered per nucleus
%
%--------------------------------------------------------------------------
% outputs
%--------------------------------------------------------------------------
% Prints results to current figure 
%                   -- best to call a cleared figure before this function
% Clust / struct
%                   -- contains nuclear properties:   
%                   --  and for each nucleus the clusters inside:
%                   .Counts - number of localization in each cluster
%                   .Sizes  - number of upsampled pixels covered by each
%                   cluster. 
%                   .Area - area of nuclei occupied region of image
%                   .cinds indexes of molecules in channel clust_chn that
%                   are in the 'valid region' (nuclei occupied image)
%                   .ninds indexes of molecules in channel nuc_chn that are
%                   in the the 'valid region' (nuclei occupied image)
%
%
%--------------------------------------------------------------------------
% optional inputs
%--------------------------------------------------------------------------
% cluster_scale / scalar / 10
%                             -- upsampling factor on which to bin
%                             molecules for culstering.
% nuc_scale / scalar / 1
%                             -- up or downsampling factor on which to bin
%                             molecules for determining nuclear regions
% min_nuc / scalar / 50
%                             -- min number of pixels in downsampled image
%                             to be considered a nucleus and not a stray
%                             set of localizations.  
% minD / scalar / 1 
%                            -- min density of localizations to be
%                            considered 'nuclear' region
% minC / scalar / 0 
%                            -- number of localization per 'background
%                            pixel' between clusters.
%-------------------------------------------------------------------------
% Alistair Boettiger
% boettiger.alistair@gmail.com
% October 13, 2012
% Version 1.1 
%-------------------------------------------------------------------------
% Copyright Creative Commons 3.0 CC BY 
%-------------------------------------------------------------------------



%--------------------------------------------------------------------------
% default inputs
%--------------------------------------------------------------------------
cluster_scale = 40; % nm - pixel size at which to discritize clusters
nuc_scale = 1; 
min_nuc = 50; % minimum size (in downsampled pixeles) to be considered a nucleus
minD = 1;
minC = 0; 
mask = [];
%--------------------------------------------------------------------------
% parse variable inputs
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
            case 'cluster scale'
                cluster_scale = parameterValue;
            case 'nuclei scale'
                nuc_scale = parameterValue;
            case 'min nuc size'
                min_nuc = parameterValue;  
            case 'min density'
                minD = parameterValue;
            case 'bkd density'
                minC = parameterValue; 
            case 'mask'
                mask = parameterValue;
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end
%--------------------------------------------------------------------------
% Hard coded variables
%--------------------------------------------------------------------------
H = 256;
W=256;
npp = 160; % nm per pixel
% addpath(genpath('C:\Users\Alistair\Documents\Projects\General_STORM\Matlab_STORM'))

%--------------------------------------------------------------------------
%% Main Function
%--------------------------------------------------------------------------

if isempty(nuc_chn)
    x = mlist.xc;
    y = mlist.yc;
else
    xr = [mlist{nuc_chn}.xc]'; 
    yr = [mlist{nuc_chn}.yc]';
    x = [mlist{clust_chn}.xc]'; 
    y = [mlist{clust_chn}.yc]';
end

%% get region mask
if isempty(mask) 
% Generate a nulcear mask using localizations from nuc channel
   M = hist3([yr,xr],{1:1/nuc_scale:H,1:1/nuc_scale:W});
   figure(3); clf; imagesc(M); colormap(hot); caxis([0,5]); 
    mask = M>=minD; 
    mask = imfill(mask,'holes');
    mask = imresize(mask,[H,W]); 
    mask = bwareaopen(mask,min_nuc);
    figure(3); clf; 
    imagesc(mask);
    hold on;
    plot(xr,yr,'r.');
    plot(x,y,'m.');
end

    % use a mask that is passed to the function
    figure(3); clf; imagesc(mask); 
    R = regionprops(mask,'PixelIdxList','Area');
    allIdx = cat(1,R.PixelIdxList);
    allArea = sum([R.Area]);
    
    if ~isempty(nuc_chn)
        yind = round(yr); 
        yind(yind>H) = H; 
        yind(yind<1) = 1;
        xind = round(xr); 
        xind(xind>W) = W; 
        xind(xind<1) = 1;
        allN = sub2ind([H,W],yind,xind);
        Ninds = ismember(allN,allIdx);
        figure(3); hold on; plot(xr(Ninds),yr(Ninds),'ro');
    end
    
    yind = round(y); 
    yind(yind>H) = H;
    yind(yind<1) = 1;
    xind = round(x); 
    xind(xind>W) = W;
    xind(xind<1) = 1;
    allD = sub2ind([H,W],yind,xind);
    inds = ismember(allD,allIdx);
    figure(3); hold on; plot(x(inds),y(inds),'g.');
    

 %% cluster molecules 

        x_good = x(inds);
        y_good = y(inds);
        
        M = hist3([y_good,x_good],{1:1/cluster_scale:H,1:1/cluster_scale:W});
        % figure(4); clf; imagesc(M); colormap(hot); caxis([0,5]);
        mask = M>minC;
        R = regionprops(mask,M,'PixelValues','PixelList','PixelIdxList'); 
        Nclusters = length(R);

        Clust.Counts = zeros(Nclusters,1);
        Clust.Sizes = zeros(Nclusters,1);
        for n=1:Nclusters
            Clust.Counts(n) = sum(R(n).PixelValues);
            Clust.Sizes(n) = length(R(n).PixelValues);% *(npp/cluster_scale)^2;
        end
        
        Clust.Area = allArea;
        Clust.cinds = inds;
        if ~isempty(nuc_chn)
            Clust.ninds = Ninds;
        end
%         valid = Clust.Counts > 10; 
%         figure(1); clf; hist(Clust.Counts(valid),linspace(10,1000,100)); xlim([10,1000]);
%         figure(2); clf; hist(Clust.Sizes(valid),linspace(100,10000,100)); xlim([100,10000]);
  
