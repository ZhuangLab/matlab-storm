function HRImage = ReadHighResImage(varargin)
%--------------------------------------------------------------------------
% HRImage = ReadHighResImage(fileName)
% This function returns a HRImage structure containing the information in
% the .hrf image specified by fileName
%
%--------------------------------------------------------------------------
% Outputs:
%
% HRImage/structure: This structure contains the image size, and a list of
% pixelIndices, frames, and intensities that correspond to every non-zero
% peak in the high res image determined by the L1 homotopy. Alternatively,
% if the 'returnForm'='image' option is selected, a full image is returned
%
%--------------------------------------------------------------------------
% Inputs:
%
% fileName/string or structure: fileName can be a string containing the
% name of the file with its path
% 
%--------------------------------------------------------------------------
% Variable Inputs:
% 'verbose'/boolean: Reserved for future use
%
% 'returnForm'/string ('compact'): A flag to specify the form of the image
%     returned. 
%    -'compact': Return a compact HRImage structure. 
%    -'image': Return an image with most pixels set to zero. 
%--------------------------------------------------------------------------
% Jeffrey Moffitt
% jeffmoffitt@gmail.com
% Started: October 7, 2012
% Last Modified: January 3, 2012
% Version 1.0
%--------------------------------------------------------------------------
% Creative Commons Liscence
% Attribution-NonCommercial-ShareAlike 3.0 Unported License
% 2013
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Hardcoded Variables
%--------------------------------------------------------------------------
headerSize = 100;
returnFormOptions = {'compact', 'image'};

%--------------------------------------------------------------------------
% Global Variables
%--------------------------------------------------------------------------
global defaultDataPath;

%--------------------------------------------------------------------------
% Define default parameters
%--------------------------------------------------------------------------
verbose = true;
returnForm = 'compact';

%--------------------------------------------------------------------------
% Parse Required Input
%--------------------------------------------------------------------------
if nargin < 1 || ~mod(nargin, 2)
    [fileName, pathName] = uigetfile([defaultDataPath '*.hrf']);
    if fileName == 0
        display('Canceled file load');
        HRImage = [];
        return;
    end
    fileName = [pathName fileName];
else
    fileName = varargin{1};
    varargin = varargin(2:end);
end

%--------------------------------------------------------------------------
% Parse Variable Input Arguments
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
            case 'verbose'
                verbose = CheckParameter(parameterValue, 'boolean', parameterName);
            case 'returnForm'
                returnForm = CheckList(parameterValue, returnFormOptions, parameterName);
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end

%--------------------------------------------------------------------------
% Open File, read header, and determine file properties
%--------------------------------------------------------------------------
fid = fopen([fileName]);

if fid < 1
    error(['Problem opening file ' fileName]);
end

imageSize = fread(fid, 2, 'int32');
frewind(fid);
fclose(fid);

%--------------------------------------------------------------------------
% Create memory map
%--------------------------------------------------------------------------
memoryMap = memmapfile(fileName, ...
        'Format', 'int32', ...
        'Writable', false, ...
        'Offset', headerSize, ...
        'Repeat', inf);

%--------------------------------------------------------------------------
% Create HRImage structure
%--------------------------------------------------------------------------
HRImage.name = fileName;
HRImage.dim = imageSize;
HRImage.frame = memoryMap.Data(1:3:end);
HRImage.pixelInd = memoryMap.Data(2:3:end);

memoryMap.Format = 'single';
HRImage.intensity = memoryMap.Data(3:3:end);

clear memoryMap

%--------------------------------------------------------------------------
% Prepare Output
%--------------------------------------------------------------------------
switch returnForm
    case 'compact'
        %HRImage is already compact
    case 'image'
        image = zeros([HRImage.dim' max(HRImage.frame)]);
        for i= unique(HRImage.frame')
            tempImage = zeros(HRImage.dim');
            pixels = HRImage.pixelInd(HRImage.frame == i) + 1; % Add 1 to adjust between C and matlab indexing
            tempImage(pixels) = HRImage.intensity(HRImage.frame==i);
            image(:,:,i) = tempImage;
        end
        HRImage = image;
    otherwise
        display(['Error: ' returnForm ' is not a valid option for returnForm']);
end

%--------------------------------------------------------------------------
% Organization of the .hrf files
%--------------------------------------------------------------------------
%{
-- 100 byte header --
4 byte integer horizontal frame size
4 byte integer vertical frame size
92 bytes reserved space
-- Data --
12 byte 'pixel' (First 'on' Pixel)
  4 byte integer frame number (starting at 1)
  4 byte integer pixel index (linear index starting at 0)
  4 byte single pixel intensity
12 byte 'pixel' (Second 'on' Pixel)
  |
  |
-- End --

%}
