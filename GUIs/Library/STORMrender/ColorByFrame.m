function [cmp,dxc,dyc] = ColorByFrame(vlist,varargin)
%--------------------------------------------------------------------------
% ColorByFrame(vlist)
%
%--------------------------------------------------------------------------
% Inputs
% mlist - molecule list structure
%
%--------------------------------------------------------------------------
% Outputs
%--------------------------------------------------------------------------
% cmp Nx3 array 
%     - colormap of length data in mlist.  
%       To plot, call scatter(mlist.xc, mlist.yc, sizeData, cmp, 'filled');
%
% no output requested
%     - ColorByFrame will produce a scatterplot in the current figure.
% 
%--------------------------------------------------------------------------
% Optional Inputs
% 'npp' / double / 160        - nm per pixel (scaling factor for x,y data)
% 'colormap' / string / 'hsv' - string name of colormape to use.  
% 
%--------------------------------------------------------------------------
% Alistair Boettiger
% boettiger.alistair@gmail.com
% December 31st, 2013
% CC-BY
%--------------------------------------------------------------------------



%--------------------------------------------------------------------------
% Default inputs
%--------------------------------------------------------------------------
npp = 160;
clrmap = 'jet';
sizeData = 5;
showPlot = false; 

%--------------------------------------------------------------------------
% Parse variable input
%--------------------------------------------------------------------------
if nargin > 1
    if (mod(length(varargin), 2) ~= 0 ),
        error(['Extra Parameters passed to the function ''' mfilename ''' must be passed in pairs.']);
    end
    parameterCount = length(varargin)/2;
    for parameterIndex = 1:parameterCount,
        parameterName = varargin{parameterIndex*2 - 1};
        parameterValue = varargin{parameterIndex*2};
        switch parameterName
            case 'npp'
                npp = CheckParameter(parameterValue,'positive','npp');
            case 'colormap'
                clrmap = CheckParameter(parameterValue,'string','colormap');
            case 'SizeData'
                sizeData = CheckParameter(parameterValue,'positive','SizeData');
            case 'showPlot'
                showPlot = CheckParameter(parameterValue,'boolean','showPlot');
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end

%% Main Function
dxc = vlist.xc*npp;
dyc = vlist.yc*npp;
numDots = length(vlist.frame);
normFrames = vlist.frame - min(vlist.frame);
normFrames = normFrames*numDots/(max(normFrames))+1;
cmp = eval([clrmap,'(',num2str(numDots+1),')']);
cmp = cmp(normFrames,:);

if nargout == 0 || showPlot
    scatter(dxc, dyc, sizeData, cmp, 'filled');
    set(gcf,'color','w'); 
    xlabel('nm'); 
    ylabel('nm');
end