function [rgbImage, parameters] = Gray2RGB(grayImage, colorMap)
% ------------------------------------------------------------------------
% [rgbImage, parameters] = Gray2RGB(grayImage, colorMap)
% This function converts a grayscale image to an RGB image using the
% specified colormap. 
%--------------------------------------------------------------------------
% Necessary Inputs
% grayImage/NxM double array. The grayscale image. If the array is not of
%   type double it will be converted to a double. 
% colorMap/1x3 array. The colormap. See colormap().  If empty, defaults to
%    [1 0 0].
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
% Check class
% -------------------------------------------------------------------------
if ~strcmp(class(grayImage), 'double')
    grayImage = double(grayImage);
end

% -------------------------------------------------------------------------
% Check colormap
% -------------------------------------------------------------------------
if isempty(colorMap)
    colorMap = [1 0 0];
elseif ~all(size(colorMap) == [1 3])
    error('matlabSTORM:invalidArguments', 'The colorMap must have dimensions 1x3');
end

% -------------------------------------------------------------------------
% Convert to RGB
% -------------------------------------------------------------------------
rgbImage = repmat(grayImage, [1 1 3]);
for i=1:length(colorMap)
    rgbImage(:,:,i) = grayImage*colorMap(i);
end

