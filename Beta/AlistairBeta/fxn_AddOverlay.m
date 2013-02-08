function Ozoom = fxn_AddOverlay(O,I,imaxes,varargin)
% Ozoom = fxn_AddOverlay(O,I,imaxes);
% Ozoom = fxn_AddOverlay(O,I,'flipV',value,'flipH',value,'theta',value'...
%          'chns',value,'xshift',value,'yshift',value);
% overlay a portion of the image O onto I.  The original images O and I may
% be different sizes, and I generally corresponds only to a particular
% field within O.  The position of O in I is indicated by imaxes.  
%--------------------------------------------------------------------------
%% Required Inputs
%--------------------------------------------------------------------------
% O / matrix 
%                   -- overlay to add to image I (e.g. a conventional
%                   image)
% I / matrix 
%                   -- image on which to add overlay (e.g. a zoom in region
%                   on STORM image)
% imaxes / struct 
%                   -- contains fields .xmin .xmax, .ymin .ymax, .zm and
%                   .scale which portions of image O to add to I. .zm is
%                   the magnification factor of O to get to I.  I may be
%                   additionally upscaled by a factor of .scale.  (i.e.
%                   imresize(O,imaxes.scale*imaxes.zm) makes O the same
%                   size as the full image which I is a fragment of.)
%
%--------------------------------------------------------------------------
%% Outputs
%--------------------------------------------------------------------------
% Ozoom / matrix 
%                   -- image of size I corresponding to the section of
%                   image O specified by imaxes
%
%--------------------------------------------------------------------------
%% Optional Inputs
%--------------------------------------------------------------------------
% flipV / logical / false   -- does O need to be vertically flipped
% flipH / logical / falise  -- does O need to be horizontal flipped
% theta / double / 0        -- O will be rotated CW by this angle
% chns / vector / []        -- only these channels in O will be used.
%                           leave empty to use all channels
% xshift / double / 0       -- O will be shifted this many units to the
%                           right relative to imaxes.xmin/.xmax
% yshift / double /0        -- O will be shifted this many units to the
%                           top relative to imaxes.ymin/.ymax
%--------------------------------------------------------------------------
% Alistair Boettiger
% boettiger.alistair@gmail.com
% October 11th, 2012
%
% Version 1.0
%--------------------------------------------------------------------------
% Version update information
%--------------------------------------------------------------------------
% Creative Commons License 3.0 CC BY  
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
%% Default Parameters
%--------------------------------------------------------------------------
flipV = false;
flipH = false;
theta = 0;
chns = [];
xshift = 0;
yshift = 0; 

%--------------------------------------------------------------------------
%% Parse mustHave variables
%--------------------------------------------------------------------------
if nargin < 3
   error([mfilename,' expects 2 inputs, filename to overlay, bead_folder and binnames']);
end


%--------------------------------------------------------------------------
%% Parse variable input
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
            case 'flipV'
                flipV = parameterValue;
                if ~islogical(parameterValue)
                    error(['Not a valid value for ' parameterName,' must be logical']);
                end
                         
            case 'flipH'
                flipH = parameterValue;
                if ~islogical(parameterValue)
                    error(['Not a valid value for ' parameterName,' must be logical']);
                end
                
            case 'rotate'
                theta = parameterValue;
                if length(theta)>1
                    error(['Not a valid value for ' parameterName]);
                end     
                
            case 'channels'
                chns = parameterValue;
                
            case 'xshift'
                xshift = parameterValue;
                
            case 'yshift'
                yshift = parameterValue;
                
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end



%--------------------------------------------------------------------------
%% Main Function
%--------------------------------------------------------------------------


% ------------------ Read in the image and flip/rotate as directed

vflip = 0;  % default is no vertical flip
hflip = 0;  % default is no horizonal flip
if flipV
    vflip = 2;
end
if flipH
    hflip = 1;
end
O2 = imrotate(imflip(imflip(O,hflip),vflip),theta);

[hin,~,~] = size(O2);
[Hfull,Wfull,~] = size(I);

% Display the reoriented full image (i.e. full conventional image)
figure(3); clf; 
It = Ncolor(O2,''); imagesc(It); 
title('image loaded for overlay');

% if specific channels are selected, display only those channels
if ~isempty(chns)
   O2 = O2(:,:,chns); 
   It = Ncolor(O2,'');
   figure(2); clf; imagesc(It);
   title('channels selected for overlay');
end


% -------------- rescale the image so it can be overlayed on these axes
% convert coordinates of current figure into coordinates of loaded image
% (i.e. we are possibly zoomed in on a subregion of the larger STORM image,
% and we want to get the same part of the loaded image).  

O = imresize(O2,hin/imaxes.H);

% highlight region on full color version (i.e. full color conventional image)
figure(3); hold on;
rectangle('position',[imaxes.xmin,imaxes.ymin,imaxes.xmax-imaxes.xmin,imaxes.ymax-imaxes.ymin],'EdgeColor','w');

% scale and then cut (more precise but more memory)
sc = imaxes.zm*imaxes.scale;
Oz = imresize(O,sc,'nearest');
x1 = round(imaxes.xmin*sc)+xshift;
x2 = round(imaxes.xmax*sc)+xshift;
y1 = round(imaxes.ymin*sc)+yshift;
y2 = round(imaxes.ymax*sc)+yshift;

[Hmax,Wmax,C] = size(Oz);
h1 = max(1,y1);
h2 = min([y2,y1+Hfull-1,Hmax]);
w1 = max(x1,1);
w2 = min([x2,x1+Wfull-1,Wmax]);   
Ozoom = uint16(Oz(h1:h2,w1:w2,:));
% if array is smaller than the size of I (because the region box goes off
% the edge), pad with zeros
[ht,wt,C] = size(Ozoom);
if wt < Wfull && w2 == Wmax; % at the right edge
    Ozoom = [zeros(ht,Wfull-(w2-w1),C,'uint16'),Ozoom];
    [ht,wt,C] = size(Ozoom);
end
if wt < Wfull && w2 ~= Wmax; % at the left edge
    Ozoom = [Ozoom,zeros(ht,Wfull-(w2-w1)-1,C,'uint16')];
    [ht,wt,C] = size(Ozoom);
end
if ht < Hfull && h2 == Hmax; % at the bottom edge
    Ozoom = [ zeros(Hfull-(h2-h1),wt,C,'uint16'); Ozoom];
    [ht,wt,C] = size(Ozoom);
end
if ht < Hfull && h2 ~= Hmax; % at the top edge
    Ozoom = [Ozoom; zeros(Hfull-(h2-h1)-1,wt,C,'uint16')];
end
Ozoom = imresize(Ozoom,[Hfull,Wfull]);  % check size

% % cut and then scale, (slightly less precise but less memory)
% Ozoom = O(round(imaxes.ymin):round(imaxes.ymax),round(imaxes.xmin):round(imaxes.xmax),:);
% Ozoom = uint16(imresize(Ozoom,[Hfull,Wfull],'nearest'));