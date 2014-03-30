function [flist,molIdx] = MaskMoleculeList(vlist,mask,varargin)
% [flist,molIdx] = MaskMoleculeList(vlist,mask)

bMin = min( [vlist.xc; vlist.yc]);
bMax = max( [vlist.xc; vlist.yc]);
bins = linspace(bMin,bMax,(bMax-bMin)/10);
xBins = bins;
yBins = bins; 

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
            otherwise
                error(['The parameter ''', parameterName,...
                    ''' is not recognized by the function, ''',...
                    mfilename '''.' '  See help ' mfilename]);
        end
    end
end

[h,w] = size(mask); 

ystep = ( max(yBins) - min(yBins) )/h;
xstep = ( max(xBins) - min(xBins) )/w;
xcoords = round( (vlist.xc - min(xBins))/xstep );
ycoords = round( (vlist.yc - min(yBins))/ystep );
allpix = sub2indFast([h,w],ycoords,xcoords);
maskProps = regionprops(mask,'PixelIdxList'); 
maskIdx = cat(1,maskProps.PixelIdxList); 
molIdx = ismember(allpix,maskIdx);
flist = IndexStructure(vlist,molIdx); 