function [xshift,yshift,parameters] = CorrAlign(Im1,Im2,varargin)
% Compute xshift and yshift to align two images based on maximizing
% cross-correlation.  

% -------------------------------------------------------------------------
% Default variables
% -------------------------------------------------------------------------
defaults = cell(0,3);
defaults(end+1,:) = {'region', 'nonnegative', 200};
defaults(end+1,:) = {'showplot', 'boolean', false};
defaults(end+1,:) = {'upsample', 'positive', 1};

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

if parameters.upsample ~= 1
Im1 = imresize(Im1,parameters.upsample);
Im2 = imresize(Im2,parameters.upsample);
end

[H,W] = size(Im1);
corrM = xcorr2(single(Im1),single(Im2)); % The correlation map
Hc = min(H,parameters.region*parameters.upsample);    
Wc = min(W,parameters.region*parameters.upsample); 
% Just the center of the correlation map  
corrMmini = corrM(H-Hc/2+1:H+Hc/2,W-Wc/2+1:W+Wc/2);
[~,indmax] =  max(corrMmini(:));
[cy,cx] = ind2sub([Hc,Wc],indmax );
xshift = (cx-Wc/2);
yshift = (cy-Hc/2);

if parameters.showplot
   subplot(1,3,1); Ncolor(cat(3,Im1,Im2));
   Im2 = TranslateImage(Im2,xshift,yshift);
   size(Im1)
   size(Im2)
   subplot(1,3,2); Ncolor(cat(3,Im1,Im2)); freezeColors;
   subplot(1,3,3); imagesc(corrMmini); colormap(jet(256));
end

xshift = xshift/parameters.upsample;
yshift = yshift/parameters.upsample;

