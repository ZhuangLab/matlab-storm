function [x_drift,y_drift] = XcorrDriftCorrect(mlist,varargin)
%--------------------------------------------------------------------------
% [x_drift,y_drift] =  XcorrDriftCorrect(binfile)
% [x_drift,y_drift] =  XcorrDriftCorrect(mlist)
% 
% [x_drift,y_drift] =  XcorrDriftCorrect(mlist,'imagesize',value,...
%    'scale',value,'stepframe',value,'nm per pixel',value,'showplots',...
%     value)
% mlist.xc = mlist.x + x_drift(mlist.frame)';
% mlist.yc = mlist.y + y_drift(mlist.frame)';
%--------------------------------------------------------------------------
% Required Inputs
% mlist (molecule list structure)
% OR
% binfile (string)
% 
%
%--------------------------------------------------------------------------
% Optional Inputs
% 'imagesize' / double 2-vector / [256 256] -- size of image
% 'scale' / double / 5 -- upsampling factor for binning localizations
% 'stepframe' / double / 10E3 -- number of frames to average
% 'nm per pixel' / double / 158 -- nm per pixel in original data
% 'showplots' / logical / true -- plot computed drift?
%--------------------------------------------------------------------------
% Outputs
% mlist (molecule list structure) 
%           -- mlist.xc and mlist.yc are overwritten with the new drift
%           corrected values.  
% 
%--------------------------------------------------------------------------
% Alistair Boettiger
% boettiger.alistair@gmail.com
% June 27th, 2013
%
% Version 1.0
%--------------------------------------------------------------------------
% Creative Commons License 3.0 CC BY  
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%% default parameters
%--------------------------------------------------------------------------
imagesize = [256,256];
scale = 4;
stepframe = 10000; 
npp = 158;
showplots = true; 

if ischar(mlist)
    mlist = ReadMasterMoleculeList(mlist);
end

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
            case 'imagesize'
                imagesize = CheckParameter(parameterValue,'positive','imagesize');
            case 'stepframe'
                stepframe = CheckParameter(parameterValue,'positive','stepframe');
            case 'nm per pixel'
                npp = CheckParameter(parameterValue,'positive','nm per pixel');
            case 'showplots'
                showplots = CheckParameter(parameterValue,'boolean','showplots');
            case 'scale'
                scale = CheckParameter(parameterValue,'positive','scale');
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end

%% Main Function

H = imagesize(1);
W = imagesize(2);
Nframes = double(max(mlist.frame));
startframe = double(min(mlist.frame)); 
T = double(floor( (Nframes-startframe)/stepframe));

% Initial localizations
Im = cell(T,1); 
inframe = mlist.frame >= startframe & mlist.frame < startframe + stepframe; 
Im{1} = hist3([mlist.y(inframe),mlist.x(inframe)],{0:1/scale:H,0:1/scale:W});
[h,w] = size(Im{1});

Hc = 50;
Wc = 50; 

% jump through frames computing image correlation maps
drift_x = zeros(1,T+1);
drift_y = zeros(1,T+1);
t = 1; 
for i=startframe+1:stepframe:Nframes  ;% i=4
    t = t+1;
    inframe = mlist.frame >= i & mlist.frame < i + stepframe; 
    Im{t} = hist3([mlist.y(inframe),mlist.x(inframe)],{0:1/scale:H,0:1/scale:W});
    % figure(2); clf; imagesc(Im{t}); caxis([0,5]);

   corrM = xcorr2(single(Im{1}),single(Im{t})); % The correlation map
   
 % Just the center of the correlation map  
   corrMmini = corrM(h-Hc/2+1:h+Hc/2,w-Wc/2+1:w+Wc/2);
   [~,indmax] =  max(corrMmini(:));
   [cy,cx] = ind2sub([Hc,Wc],indmax );
   drift_x(t-1) = (cx-Wc/2);
   drift_y(t-1) = (cy-Hc/2);
     %  figure(2); clf; imagesc(corrMmini);

% Compute with the whole correlation map (may lead to errors)
%    [~,indmax] =  max(corrM(:));
%    [cy,cx] = ind2sub([2*h-1,2*w-1],indmax ); % convert to x,y indices
%    drift_x(t-1) = (cx-w);
%    drift_y(t-1) = (cy-h);
   
   if showplots
     figure(1); clf; imagesc(corrM);
     figure(2); clf; imagesc(corrMmini)
   end
end

f = linspace(1,Nframes,T+1);
allframes = double(1:Nframes);
x_drift = spline(f,drift_x,allframes)/scale;
y_drift = spline(f,drift_y,allframes)/scale;

%  figure(1); clf; plot(drift_y); hold on; plot(drift_x); 

if showplots
    z = zeros(size(x_drift));
    col = [double(1:length(x_drift)-1),NaN];  % This is the color, vary with x in this case.
    figure(3); clf;
    surface([x_drift;x_drift]/scale*npp,...
            [y_drift;y_drift]/scale*npp,...
            [z;z],[col;col],...
            'facecol','no',...
            'edgecol','interp',...
            'linew',2);    
        set(gcf,'color','w'); 
        xlabel('nm'); 
        ylabel('nm'); 

figure(1); clf; 
plot(mlist.x,mlist.y,'k.','MarkerSize',1);
hold on;
plot(mlist.xc,mlist.yc,'ro','MarkerSize',1);
pause(1);

end





%%
