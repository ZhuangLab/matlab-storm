function [xshift,yshift,parameters] = CorrAlign(Im1,Im2,varargin)
%  [xshift,yshift,parameters] = CorrAlign(Im1,Im2)
% Inputs
% {'region', 'nonnegative', 200}; max number of pixels to use 
% {'showplot', 'boolean', false}; show image of before and after  
% {'upsample', 'positive', 1}; upsample to get subpixel alignment
% 
% Compute xshift and yshift to align two images based on maximizing
% cross-correlation.  

% -------------------------------------------------------------------------
% Default variables
% -------------------------------------------------------------------------
defaults = cell(0,3);
defaults(end+1,:) = {'region', 'nonnegative', 200};
defaults(end+1,:) = {'showplot', 'boolean', false};
defaults(end+1,:) = {'upsample', 'positive', 1};
defaults(end+1,:) = {'subregion', 'boolean', true};

% -------------------------------------------------------------------------
% Parse necessary input
% -------------------------------------------------------------------------
if nargin < 2
    error('matlabSTORM:invalidArguments', 'two 2D image matrices are required');
end

% -------------------------------------------------------------------------
% Parse variable input
% -------------------------------------------------------------------------
parameters = ParseVariableArguments(varargin, defaults, mfilename);

[H,W] = size(Im1);

if parameters.subregion && parameters.region < H
    hs = round(H/2)-parameters.region/2+1:round(H/2)+parameters.region/2;
    ws = round(W/2)-parameters.region/2+1:round(W/2)+parameters.region/2;
    Im1 = Im1(hs,ws);
    Im2 = Im2(hs,ws);
end
if parameters.upsample ~= 1
    Im1 = imresize(Im1,parameters.upsample);
    Im2 = imresize(Im2,parameters.upsample);
end

[H,W] = size(Im1);
corrM = xcorr2(single(Im1),single(Im2)); % The correlation map
Hc = min(H,parameters.region*parameters.upsample);    
Wc = min(W,parameters.region*parameters.upsample); 
Hc2 = round(Hc/2);
Wc2 = round(Wc/2); 
% Just the center of the correlation map  
corrMmini = corrM(H-Hc2+1:H+Hc2,W-Wc2+1:W+Wc2);
[parameters.corrPeak,indmax] =  max(corrMmini(:));
[cy,cx] = ind2sub([Hc,Wc],indmax );
xshift = (cx-Wc2);
yshift = (cy-Hc2);

if parameters.showplot
   subplot(1,3,1); Ncolor(cat(3,Im1,Im2));
   Im2 = TranslateImage(Im2,xshift,yshift);
   subplot(1,3,2); Ncolor(cat(3,Im1,Im2)); freezeColors;
   subplot(1,3,3); imagesc(corrMmini); colormap(jet(256));
end

xshift = xshift/parameters.upsample;
yshift = yshift/parameters.upsample;

