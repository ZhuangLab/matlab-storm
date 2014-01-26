function [mapBW,mapIdx,props2D] = Stats2DScatter(vlist,varargin)
% [mapBW,mapIdx,props2D] = Stats2DScatter(vlist)
% 
% bins
% pixelSize
% minLoc
% minSize
% 
% Set minSize to 1 and minLoc to 0 to remove nothing
% Set minSize to 0 to return only the largest object in the image

%-------------------------------------------------------------------------
% Default Parameters
%-------------------------------------------------------------------------
bMin = min( [vlist.xc; vlist.yc]);
bMax = max( [vlist.xc; vlist.yc]);
bins = linspace(bMin,bMax,(bMax-bMin)/10);
xBins = bins;
yBins = bins; 

pixelSize = 1; 
minLoc = 0;
minSize = 0;


%-------------------------------------------------------------------------
% Parse variable input
%-------------------------------------------------------------------------

if nargin > 1
    if (mod(length(varargin), 2) ~= 0 ),
        error(['Extra Parameters passed to the function ''' mfilename ''' must be passed in pairs.']);
    end
    parameterCount = length(varargin)/2;

    for parameterIndex = 1:parameterCount,
        parameterName = varargin{parameterIndex*2 - 1};
        parameterValue = varargin{parameterIndex*2};
        switch parameterName
            case 'xBins'
                xBins = CheckParameter(parameterValue, 'array', 'xBins');
            case 'yBins'
                yBins = CheckParameter(parameterValue, 'array', 'yBins');
            case 'pixelSize'
                pixelSize = CheckParameter(parameterValue, 'positive', 'pixelSize');  
            case 'minSize'
                minSize  = CheckParameter(parameterValue, 'nonnegative', 'minSize');  
            case 'minLoc'
                minLoc  = CheckParameter(parameterValue, 'nonnegative', 'minLoc');   
            otherwise
                error(['The parameter ''', parameterName,...
                    ''' is not recognized by the function, ''',...
                    mfilename '''.' '  See help ' mfilename]);
        end
    end
end

%% Main Function

mapIdx = hist3([vlist.yc,vlist.xc],{yBins,xBins});  
%       figure(3); clf; imagesc(M2); colorbar; caxis([0,80]); colormap hot;

mapBW = mapIdx>=minLoc;  
mapBW = imfill(mapBW,'holes'); 
mapBW = bwareaopen(mapBW,minSize);  % small regions removed

props = regionprops(mapBW,mapIdx,'PixelIdxList','Area','PixelValues',...
   'Eccentricity','BoundingBox','WeightedCentroid','PixelList');
[maxArea,mainIdx] = max([props.Area]);
props2D = props(mainIdx); 

if minSize == 0;
    mapBW = bwareaopen(mapBW,floor(maxArea*.95));
end

% Area and locallizations
props2D.mainArea  = maxArea*pixelSize;
props2D.mainLocs  = sum(props(mainIdx).PixelValues);
props2D.allArea = sum([props.Area])*pixelSize^2;
props2D.allLocs = sum(cat(1,props.PixelValues));

% 2D Moment of Inertia
m = cat(1,props(mainIdx).PixelValues); 
xy = cat(1,props(mainIdx).PixelList)*pixelSize;
xy(:,1) = xy(:,1) - props(mainIdx).WeightedCentroid(1);
xy(:,2) = xy(:,2) - props(mainIdx).WeightedCentroid(2);
mI = m'*(xy(:,1).^2+xy(:,2).^2)/sum(m);
props2D.mI = mI;




% allObjIdx = ismember(allpix,cat(1,props.PixelIdxList));
% 
% flist = IndexStructure(vlist,mainObjIdx);
% 
% imaxes.zm = 1/ystep;
% imaxes.xmin = min(xBins);
% imaxes.ymin = min(yBins);
% imaxes.xmax = max(xBins);
% imaxes.ymax = max(yBins);
% I = list2img(flist,imaxes);
% figure(4); clf; imagesc(I{1});
% colormap(CC{handles.gui_number}.clrmap);



