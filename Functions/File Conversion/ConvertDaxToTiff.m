function ConvertDaxToTiff(varargin)
%--------------------------------------------------------------------------
% ConvertDaxToTiff(varargin)
% This function converts dax images to .tiff files for use with downstream
% applications such as ImageJ or MicrobeTracker
%--------------------------------------------------------------------------
% Variable Inputs:
%
% 'path'/string(dataDefaultPath): The path in which Dax to Tiff coversion will be conducted.
% Subfolders will be included it the appropriate option is selected
%
% 'includeSubdir'/boolean(true): Determine if STORM analysis is run on
% all folders within the default directory
%
% 'numFrames'/int(1): The maximum number of frames in a dax file for
% conversion to tiff
% 
% 'verbose'/boolean(true): Display commentary on function progress
%--------------------------------------------------------------------------
% Jeffrey Moffitt
% September 23, 2012
% jeffmoffitt@gmail.com
%
% Version 1.0
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Hardcoded Variables
%--------------------------------------------------------------------------
quiet = 0;

%--------------------------------------------------------------------------
% Global Variables
%--------------------------------------------------------------------------
global defaultDataPath;

%--------------------------------------------------------------------------
% Default Variables
%--------------------------------------------------------------------------
analysisPath = [];
numFrames = 1;
verbose = true;
includeSubdir = true;

%--------------------------------------------------------------------------
% Parse Variable Input
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
            case 'path'
                analysisPath = parameterValue;
                if ~ischar(parameterValue) || ~iscell(parameterValue)
                    error(['Not a valid path for ' parameterName]);
                end
            case 'verbose'
                verbose = parameterValue;
                if ~islogical(verbose) 
                    error(['Not a valid value for ' parameterName]);
                end
            case 'includeSubdir'
                includeSubdir = parameterValue;
                if ~islogical(includeSubdir)
                    error(['Not a valid value for ' parameterName]);
                end
            case 'numFrames'
                numFrames = parameterValue;
                if numFrames <= 0
                    error(['Not a valid value for ' parameterName]);
                end
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end

%--------------------------------------------------------------------------
% Get path if needed
%--------------------------------------------------------------------------
if isempty(analysisPath)
    if isempty(dir(defaultDataPath))
        defaultDataPath = [pwd '\'];
    end
    [analysisPath] = uigetdir(defaultDataPath);
    if isempty(analysisPath)
        display('Loading canceled');
        info = [];
        return;
    end
    if analysisPath(end) ~= '\'
        analysisPath = [analysisPath '\']; % All paths must end in '\'
    end
end

%--------------------------------------------------------------------------
% Find subdirectories
%--------------------------------------------------------------------------
dataPaths = {};
if includeSubdir
    dirContents = dir(analysisPath);
    dataPaths = {dirContents([dirContents.isdir]).name};
    dataPaths = dataPaths(~ismember(dataPaths, {'.', '..'}));
    % Build full path
    for i=1:length(dataPaths)
        dataPaths{i} = [analysisPath dataPaths{i} '\'];
    end
end
dataPaths{end+1} = analysisPath; % Append analysisPath

if verbose 
    display('-------------------------------------------------------------');
    display(['Found ' num2str(length(dataPaths)-1) ' subdirectories']);
    for i=1:length(dataPaths)
        display(['Analzying data in ' dataPaths{i}]);
    end
end

%--------------------------------------------------------------------------
% Find and read .inf files 
%--------------------------------------------------------------------------
infoFiles = [];
for i=1:length(dataPaths)
    files = dir([dataPaths{i} '*.inf']);
    if isempty(files)
        if verbose
            display(['No .inf files in ' dataPaths{i}]);
        end
    else
        infoFiles = [infoFiles ReadInfoFile('files', {files.name}, 'path', dataPaths{i})];
    end
end

if isempty(infoFiles)
    error('No .inf files were found');
end

%--------------------------------------------------------------------------
% Find files that satisfy the frame number restrictions
%--------------------------------------------------------------------------
ind = [infoFiles.number_of_frames] <= numFrames;
infoFiles = infoFiles(ind);

if verbose
    display('-------------------------------------------------------------');
    display(['Found ' num2str(length(infoFiles)) ' files for conversion']);
    for i=1:length(infoFiles)
        display([infoFiles(i).localPath infoFiles(i).localName]);
    end
end

%--------------------------------------------------------------------------
% Convert names to .dax and .tiff
%--------------------------------------------------------------------------
fileNames = {};
tiffFileNames = {};
filePaths = {};
for i=1:length(infoFiles)
    fileNames{i} =  [infoFiles(i).localName(1:(end-4)) '.dax'];
    tiffFileNames{i} =[infoFiles(i).localName(1:(end-4)) '.tiff'];
    filePaths{i} = infoFiles(i).localPath;
end

%--------------------------------------------------------------------------
% Convert .dax to .tiff
%--------------------------------------------------------------------------
for i=1:length(infoFiles)
    %----------------------------------------------------------------------
    % Read Dax
    %----------------------------------------------------------------------
    movie = ReadDax('infoFiles', infoFiles(i));
    im = movie{1};
    
    %----------------------------------------------------------------------
    % Build Tiff Tags
    %----------------------------------------------------------------------
    tiffTagStruct.ImageLength = size(im,1);
    tiffTagStruct.ImageWidth = size(im,2);
    tiffTagStruct.Photometric = Tiff.Photometric.MinIsBlack;
    tiffTagStruct.BitsPerSample = 16;
    tiffTagStruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tiffTagStruct.Software = 'MATLAB';

    %----------------------------------------------------------------------
    % Open Tiff File
    %----------------------------------------------------------------------
    t = Tiff([filePaths{i} tiffFileNames{i}], 'w');
    
    %----------------------------------------------------------------------
    % Write Tiff File Tags
    %----------------------------------------------------------------------
    t.setTag(tiffTagStruct);
    
    %----------------------------------------------------------------------
    % Write Tiff Image Data
    %----------------------------------------------------------------------
    t.write(uint16(im));
    
    %----------------------------------------------------------------------
    % Close Tiff File
    %----------------------------------------------------------------------
    t.close;
    
    %----------------------------------------------------------------------
    % Update algorithm status
    %----------------------------------------------------------------------
    if verbose
        display(['Writing ' filePaths{i} tiffFileNames{i}]);
    end
end