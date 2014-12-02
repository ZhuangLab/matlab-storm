function WriteMoleculeList(MList, newFile, varargin)
%--------------------------------------------------------------------------
% WriteMoleculeList(MList, newFile, varargin)
% This function writes a bin file from a molecule list.  
%--------------------------------------------------------------------------
% Outputs:
%
%--------------------------------------------------------------------------
% Inputs:
% MList/structure array of molecules: This array contains information on a
% list of molecules
%--------------------------------------------------------------------------
% Variable Inputs:
% 
% 'writeAllFrames'/boolean/false: This flag determines if a molecule per
% frame structure is also written in addition to the master molecule list
%
% 'version'/string ('M425'): The version number to write in the new bin
% file
%
% 'numFrames'/int (0): The number of frames to write in the bin file.  Note
% this number must be equal to the real number of frames in the
% corresponding .dax file
%
% 'status'/int (6): The status to write in the bin file
%
% 'verbose'/boolean: Display information on function progress
%
%--------------------------------------------------------------------------
% Jeffrey Moffitt
% jeffmoffitt@gmail.com
% September 12, 2012
%
% Version 1.0
%--------------------------------------------------------------------------
% Molecule List Binary File Structure
%--------------------------------------------------------------------------
% 4 byte "M425" string tag
% 4 byte integer number of frames N
% 4 byte integer status (typically has the value of 6)
% 
% variable size N Frame structures
%  |__Frame_0 (master list of all molecules)
%  |  |__4 byte integer number of molecules M
%  |  |__variable size M molecule structures
%  |      |__72 bytes structure Molecule_1
%  |      |   |__4 byte float X in pixels from the middle of top left pixel
%  |      |   |__4 byte float Y in pixels from the middle of top left pixel
%  |      |   |__4 byte float Xc same as X but corrected for drift
%  |      |   |__4 byte float Yc same as Y but corrected for drift
%  |      |   |__4 byte float h peak height in first frame
%  |      |   |__4 byte float a integrated area
%  |      |   |__4 byte float w width
%  |      |   |__4 byte float phi (for 3D data distance from calibration curve in WxWy space)
%  |      |   |__4 byte float Ax axial ratio Wx/Wy
%  |      |   |__4 byte float b local background
%  |      |   |__4 byte float i direct intensity
%  |      |   |__4 byte integer channel number
%  |      |   |    (0: non-specific, 1-3: specific, 4-8: crosstalk, 9: Z rejected)
%  |      |   |__4 byte integer valid (not used)
%  |      |   |__4 byte integer frame where the molecule first appeared
%  |      |   |__4 byte integer length of the molecule trace in frames
%  |      |   |__4 byte integer link index of the molecule in the next frame list
%  |      |   |    (or -1 for link end)
%  |      |   |__4 byte float Z in nanometers from cover glass
%  |      |   |__4 byte float Zc same as Z but corrected for drift
%  |      |__72 bytes structure Molecule_...
%  |      |__72 bytes structure Molecule_M
%  |__Frame_1 (list of molecules detected in frame 1)
%  |__Frame_...
%  |__Frame_N (list of molecules detected in frame N)
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Hardcoded Variables
%--------------------------------------------------------------------------
quiet = 0;

fieldNames = {'x','y','xc','yc','h','a','w','phi','ax','bg','i','c','density',...
    'frame','length','link','z','zc'};

fieldTypes = {'single','single','single','single','single','single','single',...
    'single','single','single','single','int32','int32','int32','int32',...
    'int32','single','single','single'};

%--------------------------------------------------------------------------
% Global Variables
%--------------------------------------------------------------------------
global defaultDataPath scratchPath;

%--------------------------------------------------------------------------
% Default Variables
%--------------------------------------------------------------------------
dataPath = defaultDataPath;
version = 'M425';
numFrames = 0;
status = 6;
verbose = true;
writeAllFrames = false;
compact = true;

%--------------------------------------------------------------------------
% Parse Required Input
%--------------------------------------------------------------------------
if nargin < 2
    [fileName, filePath] = uiputfile([dataPath '\*_list.bin']);
    if fileName == 0
        error('File selection canceled');
    end
    newFile = [filePath '\' fileName];
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
        case 'version'
            version = CheckParameter(parameterValue, 'char', parameterName);
        case 'numFrames'
            numFrames = CheckParameter(parameterValue, 'positive', parameterName);
        case 'status'
            numFrames = CheckParameter(parameterValue, 'positive', parameterName);
        case 'verbose'
            verbose = CheckParameter(parameterValue, 'boolean', parameterName);
        case 'writeAllFrames'
            writeAllFrames = CheckParameter(parameterValue, 'boolean', parameterName);
        case 'compact'
            compact = CheckParameter(parameterValue, 'boolean', parameterName);
        otherwise
            error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
    end
end

%--------------------------------------------------------------------------
% Open binFile
%--------------------------------------------------------------------------
fid = fopen(newFile, 'w');
if fid < 1
    error('Not a valid file');
end

%--------------------------------------------------------------------------
% Write header
%--------------------------------------------------------------------------
fwrite(fid, version);
fwrite(fid, numFrames, 'int32');
fwrite(fid, status, 'int32');

if verbose
    display(['Writing: ' newFile]);
end

%--------------------------------------------------------------------------
% Write master list (Frame 0)
%--------------------------------------------------------------------------
if ~compact
    fwrite(fid, length(MList), 'int32');

    for i=1:length(MList)
        for j=1:length(fieldNames)
            fwrite(fid, MList(i).(fieldNames{j}), fieldTypes{j});  %Could be faster
        end
    end
    if verbose
        display(['Wrote ' num2str(length(MList)) ' molecules to master molecule list']);
    end
else
    fwrite(fid, length(MList.x), 'int32');
    
    % Write first values
    i=1;
    for j=1:length(fieldNames)
        fwrite(fid, MList.(fieldNames{j})(i), fieldTypes{j});  
    end
    
    if length(MList.x) > 1
        for j=1:length(fieldNames)
            frewind(fid);
            fseek(fid, 4*4 +4*j, 'bof');
            fwrite(fid, MList.(fieldNames{j})(2:end), fieldTypes{j}, 4*(length(fieldNames)-1));
        end
    end
    
    if verbose
        display(['Wrote ' num2str(length(MList.x)) ' molecules to master molecule list']);
    end
end

%--------------------------------------------------------------------------
% Write additional frames (Frame 1 -> N)
%--------------------------------------------------------------------------
if ~writeAllFrames
    fwrite(fid, zeros(1, numFrames), 'int32');
else
    for i=1:numFrames
        LocalMList = MList([MList.frame] == i);
        fwrite(fid, length(LocalMList), 'int32');
        for j=1:length(fieldNames)
            fwrite(fid, MList(i).(fieldNames{j}), fieldTypes{j});  %Could be faster
        end
    end
end
% if verbose
%     display(['Wrote ' num2str(numFrames) ' frames']);
% end

%--------------------------------------------------------------------------
% Close file ID
%--------------------------------------------------------------------------
fclose(fid);

