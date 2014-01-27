function [stormXZ,stormYZ,stormXY] = List2ImgXYZ(mlist,varargin)


% Default Parameters
npp = 160; 
zrange = [-300,300]; 
zm = 10;
fontSize = 15;
showPlots = true;
clrmap = hot(256);
zrescale = 1; 
xrange = [];
yrange = []; 
% imaxes.zm = zm;
% imaxes.H = 15; % zrange of -300 to 300 *4 is 15 160nm pixels.  
% imaxes.W = 15;



%--------------------------------------------------------------------------
%% Parse variable input
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
            case 'zrescale'
                zrescale = CheckParameter(parameterValue,'positive','zrescale');
            case 'colormap'
                clrmap = CheckParameter(parameterValue,'colormap','clrmap');
            case 'zoom'
                zm = CheckParameter(parameterValue,'positive','zoom');
            case 'xrange'
                xrange = CheckParameter(parameterValue,'array','xrange');
            case 'yrange'
                yrange = CheckParameter(parameterValue,'array','yrange');
            case 'zrange'
                zrange = CheckParameter(parameterValue,'array','zrange');
            case 'showPlots'
                showPlots = CheckParameter(parameterValue,'boolean','showPlots');
            case 'fontSize'
                fontSize = CheckParameter(parameterValue,'positive','fontSize');
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end
    
%-------------------------------------------------------------------------
%% Main function
%-------------------------------------------------------------------------   

% mlist = CC{1}.vlists{1};
% figure(3); clf; hist(mlist.zc,100);

%% Main Function

imaxes.zm = zm;

if ~isempty(xrange)
    imaxes.xmin = xrange(1);
    imaxes.xmax = xrange(2);
    imaxes.ymin = zrange(1)/(npp)*zrescale; 
    imaxes.ymax = zrange(2)/(npp)*zrescale;
end
xzlist = mlist;
xzlist.yc = mlist.zc/(npp)*zrescale;
inbox = xzlist.zc > zrange(1) & xzlist.zc < zrange(2);
xzlist = IndexStructure(xzlist,inbox);
stormXZ = list2img(xzlist,imaxes);



if ~isempty(yrange)
    imaxes.xmin = yrange(1);
    imaxes.xmax = yrange(2);
    imaxes.ymin = zrange(1)/(npp)*zrescale; 
    imaxes.ymax = zrange(2)/(npp)*zrescale;
end
yzlist = mlist;
yzlist.xc = mlist.yc;
yzlist.yc = mlist.zc/(npp)*zrescale;
inbox = yzlist.zc > zrange(1) & yzlist.zc < zrange(2);
yzlist = IndexStructure(yzlist,inbox);
stormYZ = list2img(yzlist,imaxes);



if ~isempty(xrange)
    imaxes.xmin = xrange(1);
    imaxes.xmax = xrange(2);
end
if ~isempty(yrange)
    imaxes.ymin = yrange(1);
    imaxes.ymax = yrange(2);
end
xylist = mlist;
inbox = xylist.zc > zrange(1) & xylist.zc < zrange(2);
xylist = IndexStructure(xylist,inbox);
stormXY = list2img(xylist,imaxes);


% figure(1); clf; 
if showPlots
    colordef black;
    
    subplot(1,3,1); 
    STORMcell2img(stormXY,'colormap',clrmap);
    axis image;
    xlabel('X','FontSize',fontSize);
    ylabel('Y','FontSize',fontSize);
    set(gca,'XTick',[],'YTick',[],'FontSize',fontSize);
    
    subplot(1,3,2);
    STORMcell2img(stormXZ,'colormap',clrmap);
    axis image;
    xlabel('X','FontSize',fontSize);
    ylabel('Z','FontSize',fontSize);
    set(gca,'XTick',[],'YTick',[],'FontSize',fontSize);

    subplot(1,3,3); 
    STORMcell2img(stormYZ,'colormap',clrmap);
    axis image;
    xlabel('Y','FontSize',fontSize);
    ylabel('Z','FontSize',fontSize);
    set(gca,'XTick',[],'YTick',[]);

    set(gcf,'color','k');
end
