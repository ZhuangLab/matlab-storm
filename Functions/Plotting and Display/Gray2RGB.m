function [rgbImage, colorMap, parameters] = Gray2RGB(grayImage, colorMap)
% ------------------------------------------------------------------------
% [rgbImage, parameters] = Gray2RGB(grayImage, colorMap)
% This function converts a grayscale image to an RGB image using the
% specified colormap. 
%--------------------------------------------------------------------------
% Necessary Inputs
% grayImage/NxMxL double array. The grayscale image. If the array is not of
%   type double it will be converted to a double. 
% colorMap/Lx3 array. The colormap. See colormap().  If empty, defaults to
%    hsv(L).
%--------------------------------------------------------------------------
% Outputs
% rgbImage/An NxMx3 array representing the RGB image.
%--------------------------------------------------------------------------
% Variable Inputs (Flag/ data type /(default)):
%--------------------------------------------------------------------------
% Jeffrey Moffitt
% jeffmoffitt@gmail.com
% May 8, 2014
%--------------------------------------------------------------------------
% Creative Commons License CC BY NC SA
%--------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Parse necessary input
% -------------------------------------------------------------------------
if nargin < 2
    error('matlabSTORM:invalidArguments', 'A gray scale image and color map are required');
end

% -------------------------------------------------------------------------
% Check input image class
% -------------------------------------------------------------------------
if ~strcmp(class(grayImage), 'double')
    grayImage = double(grayImage);
end

% -------------------------------------------------------------------------
% If single frame, make stack
% -------------------------------------------------------------------------
dim = size(grayImage);
if length(dim) < 3
    grayImage = repmat(grayImage, [1 1 1 3]);
    L = 1;
else
    grayImage(:,:,:,1) = grayImage;
    grayImage = repmat(grayImage, [1 1 1 3]);
    L = dim(3);
end

% -------------------------------------------------------------------------
% Check colormap
% -------------------------------------------------------------------------
if isempty(colorMap)
    colorMap = hsv(L);
elseif ~all(size(colorMap) == [L 3])
    error('matlabSTORM:invalidArguments', 'The colorMap must have dimensions Lx3');
end

% -------------------------------------------------------------------------
% Convert to RGB
% -------------------------------------------------------------------------
fourDColorMap(1,1,:,:) = colorMap;
fourDColorMap = repmat(fourDColorMap, [dim(1) dim(2) 1 1]);

rgbImage = squeeze(sum( grayImage.*fourDColorMap, 3));
