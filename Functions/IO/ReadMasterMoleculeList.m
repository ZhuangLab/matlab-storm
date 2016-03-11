function [MList, memoryMap] = ReadMasterMoleculeList(varargin)
%--------------------------------------------------------------------------
% MList = ReadMasterMoleculeList(fileInfo, varargin)
% This function loads a .bin file containing a molecule list and converts
% it into a matlab structure. This function only loads a master list, i.e.
% the list corresponding to frame 0.
%
%--------------------------------------------------------------------------
% Outputs:
%
% MList/structure array: This array contains a structure element for each
% molecule.  
%
% memoryMap/memory map structure: This structure contains information on
% the dynamic link between matlab and the memory containing the given file
%
%--------------------------------------------------------------------------
% Inputs:
%
% fileName/string or structure: fileName can be a string containing the
% name of the file with its path or it can be a infoFile structure
%
%--------------------------------------------------------------------------
% Variable Inputs:
%
% 'verbose'/boolean (true): Display or hide function progress
%
% 'compact'/boolean (false): Toggles between a array of structures or a
%   structure of arrays.  The later is much more memory efficient. 
%
% 'ZScale'/positive (1): The value by which the Z data will be rescaled. 
%    Useful for converting nm to pixels. 
%
% 'transpose/boolean (false): Change the entries from Nx1 to 1xN.
%
% 'fieldsToLoad'/cell (all fields): Load only the subset of fields provided
%   in this option. 
%
% 'loadAsStructArray'/boolean (false): Load the mList as a structure array
%   object, which provides the convenience of the non-compact format
%   without the memory overhead. See StructureArray.m for details. 
%--------------------------------------------------------------------------
% Jeffrey Moffitt
% jeffmoffitt@gmail.com
% September 11, 2012
%
% Version 1.0
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Hardcoded variables
%--------------------------------------------------------------------------
format = {...
    'single' [1 1] 'x'; ...
    'single' [1 1] 'y'; ...
    'single' [1 1] 'xc'; ...
    'single' [1 1] 'yc'; ...
    'single' [1 1] 'h'; ...
    'single' [1 1] 'a'; ...
    'single' [1 1] 'w'; ...
    'single' [1 1] 'phi'; ...
    'single' [1 1] 'ax'; ...
    'single' [1 1] 'bg'; ...
    'single' [1 1] 'i'; ...
    'int32' [1 1] 'c'; ...
    'int32' [1 1] 'density'; ...
    'int32' [1 1] 'frame'; ...
    'int32' [1 1] 'length'; ...
    'int32' [1 1] 'link'; ...
    'single' [1 1] 'z'; ...
    'single' [1 1] 'zc';};
headerSize = 16;
numEntries = 18;
entrySize = 4;

%--------------------------------------------------------------------------
% Global Variables
%--------------------------------------------------------------------------
global defaultDataPath;

%--------------------------------------------------------------------------
% Define default parameters
%--------------------------------------------------------------------------
transpose = false;
verbose = true;
compact = true;
ZScale = 1;
fieldsToLoad = format(:,3);
loadAsStructArray = false;

%--------------------------------------------------------------------------
% Parse Variable Input
%--------------------------------------------------------------------------
if nargin >= 1 && mod(nargin, 2)
    fileName = varargin{1};
    varargin = varargin(2:end);
else
    fileName = [];
end
if isempty(fileName)
    error('matlabSTORM:invalidArguments', 'A valid path must be provided');
end
if isstruct(fileName)
    fileName = [infoFile.localPath infoFile.localName(1:(end-4)) '*_list.bin'];
end

%--------------------------------------------------------------------------
% Parse Variable Input Arguments
%--------------------------------------------------------------------------
if length(varargin)>1
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
            case 'compact'
                compact = CheckParameter(parameterValue, 'boolean', parameterName);
            case 'ZScale'
                ZScale = CheckParameter(parameterValue, 'positive', parameterName);
            case 'transpose'
                transpose = CheckParameter(parameterValue, 'boolean', parameterName);
            case 'fieldsToLoad'
                fieldsToLoad = CheckParameter(parameterValue, 'cell', parameterName);
            case 'loadAsStructArray'
                loadAsStructArray = CheckParameter(parameterValue, 'boolean', parameterName);
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

fseek(fid, 4, 'bof'); 
numFrames = fread(fid, 1, '*int32');
fseek(fid, 12, 'bof');
numMoleculesFrame0 = fread(fid, 1, '*int32');

if verbose
    frewind(fid);
    display('-------------------------------------------------------------');
    display(['Opening file ' fileName]);
    display(['Version ' char(fread(fid,4,'*char'))' ]);
    display(['Contains ' num2str(numFrames) ' field']);% 
    display(['Status: ' num2str(fread(fid,1,'*int32')) ]);
    display(['Number of molecules in Frame 0: ' num2str(numMoleculesFrame0)]);
    display(['Compact Representation: ' num2str(compact)]);
    display('-------------------------------------------------------------');
end

fclose(fid);

DoThis = true;
if numMoleculesFrame0 >  20E6
    userChoice = input(['File contains more than 20 million molecules.  ',...
        'Are you sure you want to load it? y/n '],'s');
    if strcmp(userChoice,'y')
        DoThis = true;
    else
        error('User aborted loading mlist due to memory considerations ');
    end
end

%--------------------------------------------------------------------------
% Confirm provided fields are valid
%--------------------------------------------------------------------------
fieldIndsToLoad = find(ismember(format(:,3), fieldsToLoad));

%--------------------------------------------------------------------------
% Handle empty MList case
%--------------------------------------------------------------------------
if numMoleculesFrame0 == 0
    if transpose
        emptyArray = zeros([0,1]);
    else
        emptyArray = zeros([1,0]);
    end
    for f=1:length(fieldsToLoad)
        MList.(fieldsToLoad{f}) = cast(emptyArray, ...
            format{fieldIndsToLoad(f), 1});
    end
    return % Exit function
end

%--------------------------------------------------------------------------
% Create memory map
%--------------------------------------------------------------------------
try
    if ~loadAsStructArray % Load via the built in matlab structure objects
        if ~compact
            memoryMap = memmapfile(fileName, ...
                    'Format', format, ...
                    'Writable', false, ...
                    'Offset', headerSize, ...
                    'Repeat', numMoleculesFrame0);

            MList = memoryMap.Data;
        else %compact
            MList = CreateMoleculeList(numMoleculesFrame0, 'compact', true, 'fieldsToLoad', fieldsToLoad); %Allocate memory
            memoryMap = memmapfile(fileName, ...
                    'Format', 'int32', ...
                    'Writable', false, ...
                    'Offset', headerSize, ...
                    'Repeat', inf);

            for i=1:length(fieldIndsToLoad)
                memoryMap.Format = format{fieldIndsToLoad(i),1};
                memoryMap.Offset = headerSize + (fieldIndsToLoad(i)-1)*entrySize;
                MList.(format{fieldIndsToLoad(i),3}) = memoryMap.Data(1:numEntries:(numEntries*numMoleculesFrame0));
            end
        end
    else % Load as a StructureArray object
        memoryMap = memmapfile(fileName, ...
            'Format', 'int32', ...
            'Writable', false, ...
            'Offset', headerSize, ...
            'Repeat', inf);
        for i=1:length(fieldIndsToLoad)
            memoryMap.Format = format{fieldIndsToLoad(i),1};
            memoryMap.Offset = headerSize + (fieldIndsToLoad(i)-1)*entrySize;
            if i==1
                MList = StructureArray(format{fieldIndsToLoad(i),3}, ...
                    memoryMap.Data(1:numEntries:(numEntries*numMoleculesFrame0)));
            else
                MList.(format{fieldIndsToLoad(i),3}) = memoryMap.Data(1:numEntries:(numEntries*numMoleculesFrame0));
            end
        end
    end
catch % Handle corrupt file
    warning(['matlabSTORM:corruptMlist', 'Could not map mlist. The file ',fileName,' is likely corrupt']);
    memoryMap = [];
    MList = CreateMoleculeList(0, 'compact', compact);
end

%--------------------------------------------------------------------------
% Rescale Z if necessary
%--------------------------------------------------------------------------
if ~(ZScale == 1) 
    if compact 
        if isfield(MList, 'z') && ~isempty(MList.z) 
            MList.z = MList.z/ZScale;
            if isfield(MList, 'zc')
                MList.zc = MList.zc/ZScale;
            end
        end
    else
        if isfield(MList, 'z') && ~isempty(MList)
            tempZ = num2cell([MList(:).z]/ZScale);
            [MList.z] = deal(tempZ{:});
            if isfield(MList, 'zc')
                tempZc = num2cell([MList(:).zc]/ZScale);
                [MList.zc] = deal(tempZc{:});
            end
        end
    end
end

%--------------------------------------------------------------------------
% Transpose entries
%--------------------------------------------------------------------------
if compact & transpose
    foundFields = fields(MList);
    for i=1:length(foundFields)
        MList.(foundFields{i}) = MList.(foundFields{i})';
    end
end

%--------------------------------------------------------------------------
% Organization of the _list.bin files
%--------------------------------------------------------------------------
%{
4 byte "M425" string tag
4 byte integer number of frames N
4 byte integer status 
Frame 0
 |  |__4 byte integer number of molecules M
 |  |__variable size M molecule structures
 |      |__72 bytes structure Molecule_1
 |      |   |__4 byte float X in pixels from the middle of top left pixel
 |      |   |__4 byte float Y in pixels from the middle of top left pixel
 |      |   |__4 byte float Xc same as X but corrected for drift
 |      |   |__4 byte float Yc same as Y but corrected for drift
 |      |   |__4 byte float h peak height in first frame
 |      |   |__4 byte float a integrated area
 |      |   |__4 byte float w width
 |      |   |__4 byte float phi (for 3D data distance from calibration curve in WxWy space)
 |      |   |__4 byte float Ax axial ratio Wx/Wy
 |      |   |__4 byte float b local background
 |      |   |__4 byte float i direct intensity
 |      |   |__4 byte integer channel number
 |      |   |    (0: non-specific, 1-3: specific, 4-8: crosstalk, 9: Z rejected)
 |      |   |__4 byte integer valid (not used) (overwritten with density)
 |      |   |__4 byte integer frame where the molecule first appeared
 |      |   |__4 byte integer length of the molecule trace in frames
 |      |   |__4 byte integer link index of the molecule in the next frame list
 |      |   |    (or -1 for link end)
 |      |   |__4 byte float Z in nanometers from cover glass
 |      |   |__4 byte float Zc same as Z but corrected for drift
 |      |__72 bytes structure Molecule_2
 |      |__72 bytes structure Molecule_i
 |      |__72 bytes structure Molecule_M
 |  |__
 |__
%}
