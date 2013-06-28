function [movie, infoFile] = ReadDaxBeta(varargin)
% A faster and more flexible way to read in dax files.  
% Only those frames which we'll read data from get mapped
% Only the parts of those frames that we indicate get read into memory.  
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
% Optional Inputs:
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
% 'subregion'/double (zeros(4,1)):  [xmin, xmax, ymin, ymax] of the region
% of the dax file to load.  Pixels indexed from upper left, as in images.  
%
% 'infoFile'/info file structure ([]): An info file for
% the files to be loaded.  
%
% 'verbose'/boolean (true): Display or hide function progress
%
% 'orientation'/string ('normal'): Control the relative rotation of the data
%   structure
%
% 'Quadviewsplit'/boolean (true): return 4 movies from each quadrant of the
% specified dax file.  
%--------------------------------------------------------------------------
% Alistair Boettiger & Jeffrey Moffitt
% boettiger.alistair@gmail.com   jeffmoffitt@gmail.com
% Copyright CC BY.   February 09, 2013.  
%
% Version 1.2
%-------------------Updates:
% Version 1.2
% 02/09/13 modified to use memory map and allow arbitrary window as well as
% an arbitrary start and end frame.  This is necessary to enable processing
% a small region of a dax movie (e.g. by DaoSTORM/insight).  -- Alistair
% Version 1.1
% 01/19/13 modified to allow arbitrary start and end frame to be specified
% by the user.  Removed 'image_dimension' flag (this was non-functional)
% and removed allFrames (this has become redundant);  -- Alistair 
% Version 1.0  
% 09/07/12 original version -- Jeff 
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Hardcoded Variables
%--------------------------------------------------------------------------
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
subregion = zeros(4,1); 
Quadviewsplit = false;
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
        case 'subregion'
            subregion = CheckParameter(parameterValue,'array','subregion');
        case 'infoFile'
            infoFile = CheckParameter(parameterValue, 'struct', 'infoFile');
        case 'verbose'
            verbose = CheckParameter(parameterValue, 'boolean', 'verbose');
        case 'orientation'
            orientation = CheckList(parameterValue, orientationValues, 'orientation');
        case 'path'
            dataPath = CheckParameter(parameterValue, 'string', 'path');
        case 'Quadviewsplit'
            Quadviewsplit = CheckParameter(parameterValue,'boolean','Quadviewsplit');
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
        infoFile = ReadInfoFile('path', dataPath, 'verbose', false);
    else
        infoFile = ReadInfoFile(fileName, 'verbose', false);
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

% parse now outdated option 'allFrames' for backwards compatability
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
    warning(['input endFrame greater than total frames in dax_file.',...
        'Using all available frames after ', num2str(startFrame)]);
    endFrame = TFrames;  
end
numFrames = endFrame - startFrame + 1;

region.frame1 = uint32(1);
region.nframes = uint32(numFrames);
region.frameDim = frameDim;
region.TFrames = TFrames;

fileName = [infoFile.localName(1:(end-4)) '.dax'];
if verbose
    display(['Loading ' infoFile.localPath fileName ]);
end


if ~Quadviewsplit
% parse subregion 
%--------------------------------------------------------------------
    xi = uint32(subregion(1));
    xe = uint32(subregion(2));
    yi = uint32(subregion(3));
    ye = uint32(subregion(4));
    
    if xi == 0 
        xi = uint32(1);
    end
    if xe == 0
        xe = uint32(frameDim(1));
    end
    if yi == 0
        yi = uint32(1);
    end
    if ye == 0
        ye = uint32(frameDim(2));
    end
    

    %------------------ arbitrary region ------------------------
    memoryMap = memmapfile([infoFile.localPath fileName], ...
            'Format', 'uint16', ...
            'Writable', false, ...
            'Offset', (startFrame-1)*frameSize*16/8, ...
            'Repeat', numFrames*frameSize);  
       region.sr = [xi,xe,yi,ye];
       
       movie = multiparse(memoryMap,orientation,region);
       infoFile = UpdateInfo(infoFile,region);
       
%     [ri,ci,zi] = meshgrid(xi:xe,yi:ye,region.frame1:region.nframes);
%     ind = sub2ind([frameDim(1),frameDim(2),TFrames],ri(:),ci(:),zi(:));
%     ind = sort(ind); 
%     movie = memoryMap.Data(ind);  clear ind; %keeping memory small
%     movie = swapbytes(movie);
%     xs = xe-xi+uint32(1);
%     ys = ye-yi+uint32(1);
%     movie = reshape(movie,[xs,ys,numFrames]);
%     if strcmp(orientation,'normal')
%      movie = permute(reshape(movie, [xs,ys,numFrames]), [2 1 3]);
%     end
      % figure(9); clf; imagesc(movie(:,:,1)); colorbar;

    %--------------------------------------------------



%------------------ QuadViewRegion ------------------------
else
   
    memoryMap = memmapfile([infoFile.localPath fileName], ...
            'Format', 'uint16', ...
            'Writable', false, ...
            'Offset', (startFrame-1)*frameSize*16/8, ...
            'Repeat', numFrames*frameSize);
    region.sr = uint32([1,frameDim(1)/2,1,frameDim(2)/2]);
    upperleft = multiparse(memoryMap,orientation,region);
    region.sr = uint32([frameDim(1)/2+1,frameDim(1),1,frameDim(2)/2]);
    upperright =  multiparse(memoryMap,orientation,region);
    region.sr = uint32([1,frameDim(1)/2,frameDim(2)/2+1,frameDim(2)]);
    lowerleft = multiparse(memoryMap,orientation,region); % lowerleft
    region.sr = uint32([frameDim(1)/2+1,frameDim(1),frameDim(2)/2+1,frameDim(2)]);
    lowerright = multiparse(memoryMap,orientation,region); % lowerright
    
    movie = {upperleft,upperright,lowerleft,lowerright};
    infoFile = UpdateInfo(infoFile,region);
    %--------------------------------------------------
end

if verbose
    display(['Loaded ' infoFile.localPath fileName ]);
    display([num2str(numFrames) ' ' num2str(frameDim(1)) ' x ' num2str(frameDim(2)) ...
        ' frames loaded']);
end


function movie = multiparse(memoryMap,orientation,region)
    [ri,ci,zi] = meshgrid(region.sr(1):region.sr(2),region.sr(3):region.sr(4),region.frame1:region.nframes);
    inds = sub2ind([region.frameDim(1),region.frameDim(2),region.TFrames],ri(:),ci(:),zi(:));
    movie = memoryMap.Data(sort(inds)); 
    movie = swapbytes(movie);
    xs = region.sr(2)-region.sr(1)+uint32(1);
    ys = region.sr(4)-region.sr(3)+uint32(1);
    movie = reshape(movie,[xs,ys,region.nframes]);
    if strcmp(orientation,'normal')
     movie = permute(reshape(movie, [xs,ys,region.nframes]), [2 1 3]);
    end

function  info = UpdateInfo(info,region)
    xs = region.sr(2)-region.sr(1)+uint32(1);
    ys = region.sr(4)-region.sr(3)+uint32(1);
    info.hend = xs;
    info.vend = ys;
    info.frame_dimensions = [info.hend,info.vend];
    info.file = [info.localPath,info.localName(1:end-4),'.dax'];
    

%  % Old memory maps (to delete in later update) 
% 
% %------------------ top bottom split ------------------------
% format = {...
%     'int16' [frameDim(1),frameDim(2)/2] 'top'; ...
%     'int16' [frameDim(1),frameDim(2)/2] 'bottom';};
% Offset = startFrame-1;
% 
% memoryMap = memmapfile([infoFile.localPath fileName], ...
%         'Format', format, ...
%         'Writable', false, ...
%         'Offset', Offset, ...
%         'Repeat', numFrames);
% 
% toponly = swapbytes(memoryMap.Data(3).top');
% 
% %--------------------------------------------------
% 
% % --------------- left right split ------------------
% format = {...
%     'uint16' [frameDim(1)/2,1] 'values';};
% Offset = (startFrame-1)*frameDim(2);
% 
% memoryMap = memmapfile([infoFile.localPath fileName], ...
%         'Format', format, ...
%         'Writable', false, ...
%         'Offset', Offset, ...
%         'Repeat', numFrames*frameDim(2)*2);
% 
% Dax = memoryMap.Data(2:2:end);
% movie = cat(1,Dax.values);
% movie = swapbytes(reshape(movie,[frameDim(1)/2,frameDim(2),numFrames]));
% movie = permute(reshape(movie, [frameDim(1)/2,frameDim(2),numFrames]), [2 1 3]);
%  figure(1); clf; imagesc(movie(:,:,2))
% %------------------------------------------------------------------------
% 
% 

