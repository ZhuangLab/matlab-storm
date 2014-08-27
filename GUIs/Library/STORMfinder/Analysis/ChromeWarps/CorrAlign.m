function [xshift,yshift,parameters] = CorrAlign(Im1,Im2,varargin)
% Compute xshift and yshift to align two images based on maximizing
% cross-correlation.  

% -------------------------------------------------------------------------
% Default variables
% -------------------------------------------------------------------------
defaults = cell(0,3);
defaults(end+1,:) = {'region', 'nonnegative', 200};
defaults(end+1,:) = {'showplot', 'boolean', false};

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
 corrM = xcorr2(single(Im1),single(Im2)); % The correlation map
   Hc = min(H,parameters.region);    
   Wc = min(W,parameters.region); 
 % Just the center of the correlation map  
   corrMmini = corrM(H-Hc/2+1:H+Hc/2,W-Wc/2+1:W+Wc/2);
   [~,indmax] =  max(corrMmini(:));
   [cy,cx] = ind2sub([Hc,Wc],indmax );
   xshift = (cx-Wc/2);
   yshift = (cy-Hc/2);
   
   if parameters.showplot
       subplot(1,2,1); Ncolor(cat(3,Im1,Im2));
       subplot(1,2,2); imagesc(corrMmini);
 
   end