function Io = STORMcell2img(I,varargin)


%--------------------------------------------------------------------------
% Default Parameters
%--------------------------------------------------------------------------
overlays = {}; 
active_channels = [];
cmin = [];
cmax = [];
active_overlays = []; 
omin = [];
omax = [];



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
                active_channels = CheckParameter(parameterValue,'positive','active channels');
            case 'active overlays'
                active_overlays = CheckParameter(parameterValue,'positive','active overlays');
            case 'cmin'
                cmin = CheckParameter(parameterValue,'nonnegative','cmin');
            case 'cmax'
                cmax = CheckParameter(parameterValue,'nonnegative','cmax');
            case 'omin'
                omin = CheckParameter(parameterValue,'nonnegative','omin');
            case 'omax'
                omax = CheckParameter(parameterValue,'nonnegative','omax');
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end
    

%--------------------------------------------------------------------------
% Automatically complete missing inputs:
%--------------------------------------------------------------------------
numChns = length(I); 
numOverlays = length(active_overlays);
[h,w,Zs] = size(I{1});

if isempty(active_channels)
    active_channels = 1:numChns;
end
if isempty(active_overlays)
    active_overlays = 1:numOverlays;
end

if isempty(cmin)
    cmin = zeros(1,numChns);
end
if isempty(cmax)
   cmax = ones(1,numChns); 
end


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
    Io = Ncolor(Ic,[]); % Actually builds the RGB picture
else
     Ncolor(Ic,[]); % Actually builds the RGB picture
end

