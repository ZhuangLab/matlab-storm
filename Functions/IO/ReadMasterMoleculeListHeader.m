function [header, isCorrupt] = ReadMasterMoleculeListHeader(fileName)
% ------------------------------------------------------------------------
% ReadMasterMoleculeListHeader(fileName) loads the fixed header of a
% molecule list bin file
%--------------------------------------------------------------------------
% Necessary Inputs: 
%   fileName -- A string to valid molecule list file. 
%   
%--------------------------------------------------------------------------
% Outputs: 
%   header -- A structure with a fields corresponding to entries in the
%   molecule list header
%--------------------------------------------------------------------------
% Jeffrey Moffitt
% jeffmoffitt@gmail.com
% August 18, 2017
%--------------------------------------------------------------------------
% Creative Commons License CC BY NC SA
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Define header properties
%--------------------------------------------------------------------------
headerSize = 16;
numEntries = 18;
entrySize = 4;

%--------------------------------------------------------------------------
% Open File, read header, and determine file properties
%--------------------------------------------------------------------------
fid = fopen([fileName]);

if fid < 1
    error(['Problem opening file ' fileName]);
end

% Build header structure
header.fileName = fileName;

% Load the number of frames
fseek(fid, 4, 'bof'); 
header.numFrames = fread(fid, 1, '*int32');

% Load the number of molecules
fseek(fid, 12, 'bof');
header.numMoleculesFrame0 = fread(fid, 1, '*int32');

% Load the version
frewind(fid);
header.version = char(fread(fid,4,'*char'))';

% Load the status
header.status = fread(fid,1,'*int32');

% Close the file
fclose(fid);

%--------------------------------------------------------------------------
% Determine if the file is corrupt
%--------------------------------------------------------------------------
isCorrupt = isempty(header.status);



