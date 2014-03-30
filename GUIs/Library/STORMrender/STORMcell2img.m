function Io = STORMcell2img(I,varargin)
% converts the cell array output of list2img into a RBG image. 

%--------------------------------------------------------------------------
% Default Parameters
%--------------------------------------------------------------------------
overlays = {}; 
numChns = length(I); 

[h,w,Zs] = size(I{1});
active_channels = 1:numChns;
cmin = zeros(1,numChns);
cmax = ones(1,numChns); 
omin = 0;
omax = 0;
active_overlays = 0; 
numClrs = [];
clrmap = [];  % Default will be hot for 1 

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
            case 'overlays'
                overlays = CheckParameter(parameterValue,'cell','overlays');
            case 'active channels'
                active_channels = CheckParameter(parameterValue,'nonnegative','active channels');
            case 'active overlays'
                active_overlays = CheckParameter(parameterValue,'nonnegative','active overlays');
            case 'cmin'
                cmin = CheckParameter(parameterValue,'nonnegative','cmin');
            case 'cmax'
                cmax = CheckParameter(parameterValue,'nonnegative','cmax');
            case 'omin'
                omin = CheckParameter(parameterValue,'nonnegative','omin');
            case 'omax'
                omax = CheckParameter(parameterValue,'nonnegative','omax');
            case 'numClrs'
                 numClrs = CheckParameter(parameterValue,'nonnegative','numClrs');
            case 'colormap'
                clrmap = CheckParameter(parameterValue,'colormap','colormap');
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end
    

%--------------------------------------------------------------------------
% Automatically complete missing inputs:
%--------------------------------------------------------------------------
numOverlays = length(overlays);
if active_overlays == 0
    active_overlays = 1:numOverlays;
end
if omin == 0
    omin = zeros(1,numOverlays);
end
if omax == 0
    omax = ones(1,numOverlays); 
end

if isempty(numClrs)
    numClrs = length(I);
end

if isempty(clrmap)
    if length(numClrs) <= 1
        cMap = 'hot'; 
    else
        cMap = hsv(numClrs); 
    end
else
    if length(numClrs) <= 1
        cMap = clrmap;
    elseif ischar(clrmap)
        cMap = eval([clrmap,'(',num2str(numClrs),')']);
    else
        cMap = clrmap; 
    end
end

numOverlays = length(active_overlays);

%--------------------------------------------------------------------------
%% Main Function
%--------------------------------------------------------------------------
Ic = zeros(h,w,Zs*length(active_channels)+numOverlays,'uint16'); 
if Zs > 1;   
    n=0;  
    % In 3D mode, only render the active channels 
    active_channels(active_channels>numChns) = [];  % should no longer be nessary in our variable # channel buttons approach
    for c=active_channels
       Zs = size(I{c},3);
       for k=1:Zs
           n=n+1;
           if isempty(cmin) || isempty(cmax)
            Ic(:,:,n) =  imadjust(I{c}(:,:,k));   
           else               
            Ic(:,:,n) =  imadjust(I{c}(:,:,k),[cmin(c),cmax(c)],[0,1]);
           end
       end
   end
else
    for n=active_channels
           if isempty(cmin) || isempty(cmax)
            Ic(:,:,n) =  imadjust(I{n});   
           else               
            Ic(:,:,n) =  imadjust(I{n},[cmin(n),cmax(n)],[0,1]);
           end
    end
end
if ~isempty(active_overlays)
    for n=active_overlays  % add overlays, if they exist
        Ic(:,:,numChns+n) = imadjust(overlays{n},[omin(n),omax(n)]);
    end
end


if nargout ~= 0
    Io = Ncolor(Ic,cMap); % Actually builds the RGB picture
else
     Ncolor(Ic,cMap); % Actually builds the RGB picture
end

