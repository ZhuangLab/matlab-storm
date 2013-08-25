function [movie, infoFile] = ReadDax(varargin)
%--------------------------------------------------------------------------
% [movie, infoFiles] = ReadDax(fileName, varargin)
% This function loads a STORM movies from the dax file associated with the
% provided .inf file
%--------------------------------------------------------------------------
% Outputs:
% movies/LxMxN array: A 3D array containing the specified movie
%--------------------------------------------------------------------------
% Input:
% fileName/string or structure: Either a path to the dax or inf file or an
%   infoFile structure specifying the dax file to load
%
%--------------------------------------------------------------------------
% Variable Inputs:
%
% 'file'/string ([]): A path to the associated .inf file
%
% 'path'/string ([]): Default path to look for .inf files
%
% 'startFrame'/double  (1): first of movie to load.  
%
% 'endFrame'/double ([]): last frame of the movie to load.  If empty will
% be max. 
%
% 'infoFile'/info file structure ([]): An info file for
% the files to be loaded.  
%
% 'imageDimensions'/3x1 integer array ([]): The size of the movies to be
% loaded.  
%
% 'verbose'/boolean (true): Display or hide function progress
%
% 'orientation'/string ('normal'): Control the relative rotation of the data
%   structure
%--------------------------------------------------------------------------
% Jeffrey Moffitt
% jeffmoffitt@gmail.com
% September 7, 2012
%
% Version 1.1
%-------------------Updates:
% Updated 01/19/13 to allow arbitrary start and end frame to be specified
% by the user.  Removed 'image_dimension' flag (this was non-functional)
% and removed allFrames (this has become redundant);  
% Alistair Boettiger
%-------------------
% 2/14/13: JRM
% Minor fix to dax data type
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Hardcoded Variables
%--------------------------------------------------------------------------
quiet = 0;
orientationValues = {'normal'};
flags = {'file', 'infoFile', 'startFrame','endFrame', 'verbose', ...
    'orientation', 'path','allFrames'};

%--------------------------------------------------------------------------
% Global Variables
%--------------------------------------------------------------------------
global defaultDataPath;

%--------------------------------------------------------------------------
% Default Variables
%--------------------------------------------------------------------------
dataPath = defaultDataPath;
allFrames = [];
startFrame = 1;
endFrame = []; 
fileName = [];
infoFile = [];
verbose = true;
orientation = 'normal';

%--------------------------------------------------------------------------
% Parse Required Input
%--------------------------------------------------------------------------
if nargin >= 1
    if isstruct(varargin{1})
        infoFile = varargin{1};
        varargin = varargin(2:end);
    elseif ~ismember(varargin{1}, flags)
        fileName =varargin{1};
        varargin = varargin(2:end);
    end
end

%--------------------------------------------------------------------------
% Parse Variable Input
%--------------------------------------------------------------------------
if (mod(length(varargin), 2) ~= 0 ),
    error(['Extra Parameters passed to the function ''' mfilename ''' must be passed in pairs.']);
end
parameterCount = length(varargin)/2;

for parameterIndex = 1:parameterCount,
    parameterName = varargin{parameterIndex*2 - 1};
    parameterValue = varargin{parameterIndex*2};
    switch parameterName
        case 'file'
            fileName = CheckParameter(parameterValue, 'string', 'file');
        case 'allFrames'
             allFrames = CheckParameter(parameterValue, 'boolean', 'allFrames');
        case 'startFrame'
            startFrame = CheckParameter(parameterValue, 'positive', 'startFrame');
        case 'endFrame'
            endFrame = CheckParameter(parameterValue, 'positive', 'endFrame');
        case 'infoFile'
            infoFile = CheckParameter(parameterValue, 'struct', 'infoFile');
        case 'verbose'
            verbose = CheckParameter(parameterValue, 'boolean', 'verbose');
        case 'orientation'
            orientation = CheckList(parameterValue, orientationValues, 'orientation');
        case 'path'
            dataPath = CheckParameter(parameterValue, 'string', 'path');
        otherwise
            error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
    end
end

%--------------------------------------------------------------------------
% Check parameter consistency
%--------------------------------------------------------------------------
if ~isempty(infoFile) && ~isempty(fileName)
    error('You cannot specify info files and file names');
end

%--------------------------------------------------------------------------
% Load info files if needed
%--------------------------------------------------------------------------
if isempty(infoFile)
    if isempty(fileName)
        infoFile = ReadInfoFile('path', dataPath, 'verbose', verbose);
    else
        infoFile = ReadInfoFile(fileName, 'verbose', verbose);
    end
    
    if isempty(infoFile)
        display('Canceled');
        movie = {};
        return;
    end 
end

%--------------------------------------------------------------------------
% Load Dax Files
%--------------------------------------------------------------------------

TFrames = infoFile.number_of_frames;
frameSize = infoFile.frame_size;
frameDim = infoFile.frame_dimensions;

% Determine number of frames to load

% parse now outdated 'allFrames' for backwards compatability
if ~isempty(allFrames) 
    if allFrames
        endFrame = TFrames;
    else % first frame only 
        endFrame = 1;
        startFrame = 1; 
    end
end
    
if isempty(endFrame)
    endFrame = TFrames;
end
if endFrame > TFrames;
    if verbose
        warning('input endFrame greater than total frames in dax_file.  Using all available frames after startFrame');
    end
    endFrame = TFrames;  
end
numFrames = endFrame - startFrame + 1;

fileName = [infoFile.localName(1:(end-4)) '.dax'];
if verbose
    display(['Loading ' infoFile.localPath fileName ]);
end

% Read File
fid = fopen([infoFile.localPath fileName]);
if fid < 0
    error('Invalid file');
end

fseek(fid,(frameSize*(startFrame - 1))*16/8,'bof'); % bits/(bytes per bit) 
dataSize = frameSize*numFrames;
movie = fread(fid, dataSize, '*uint16', 'b');
fclose(fid);


try % Catch corrupt files
    if numFrames == 1
        movie = reshape(movie, frameDim)';
    else
        switch orientation % Change orientation
            case 'normal'
                movie = permute(reshape(movie, [frameDim numFrames]), [2 1 3]);
            otherwise
                
        end
    end
catch
    display('Serious error somewhere here...check file for corruption');
    movie = zeros(frameDim);
end

if verbose
    display(['Loaded ' infoFile.localPath fileName ]);
    display([num2str(numFrames) ' ' num2str(frameDim(1)) ' x ' num2str(frameDim(2)) ...
        ' frames loaded']);
end

