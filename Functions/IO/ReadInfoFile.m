function infoFile = ReadInfoFile(varargin)
%--------------------------------------------------------------------------
% infoFile = ReadInfoFile(fileName, varargin)
% This function returns a structure, info, containing the elements of an
% .inf file.
%--------------------------------------------------------------------------
% Outputs: 
% info/struct: A structure array containing the elements of the info file
%
%--------------------------------------------------------------------------
% Inputs:
% fileName/string or cell array of strings ([]): A path to a .dax or .ini
%   file
% Field: explanation
%                  localName: inf filename matlab found / should save as 
%                  localPath: where matlab found / should save this file
%                   uniqueID: ?
%                       file: full path to daxfile. 
%               machine_name: e.g. 'storm2'
%            parameters_file: Full pathname of pars file used in Hal
%              shutters_file: e.g. 'shutters_default.xml'
%                   CCD_mode: e.g. 'frame-transfer'
%                  data_type: '16 bit integers (binary, big endian)'
%           frame_dimensions: [256 256]
%                    binning: [1 1]
%                 frame_size: 262144
%     horizontal_shift_speed: 10
%       vertical_shift_speed: 3.3000
%                 EMCCD_Gain: 20
%                Preamp_Gain: 5
%              Exposure_Time: 0.1000
%          Frames_Per_Second: 9.8280
%         camera_temperature: -70
%           number_of_frames: 10
%                camera_head: 'DU897_BV'
%                     hstart: 1
%                       hend: 256  
%                     vstart: 1
%                       vend: 256
%                  ADChannel: 0
%                    Stage_X: 0
%                    Stage_Y: 5
%                    Stage_Z: 0
%                Lock_Target: 0
%                   scalemax: 4038
%                   scalemin: 0
%                      notes: ''
%--------------------------------------------------------------------------
% Variable Inputs:
% 'file'/string or cell array: The file name(s) for the .ini file(s) to load
%   Path must be included. 
%
% 'verbose'/boolean(true): Determines if the function hides progress
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Jeffrey Moffitt
% September 5, 2012
% jeffmoffitt@gmail.com
%
% Version 1.0
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Hardcoded variables
%--------------------------------------------------------------------------
quiet = 1;
flags = {'file', 'verbose', 'path'};

%--------------------------------------------------------------------------
% Global Variables
%--------------------------------------------------------------------------
global defaultDataPath;

%--------------------------------------------------------------------------
% Define default parameters
%--------------------------------------------------------------------------
infFileName = [];
dataPath = defaultDataPath;
verbose = false;

%--------------------------------------------------------------------------
% Parse Required Input
%--------------------------------------------------------------------------
if nargin >= 1
    if ~ismember(varargin{1}, flags)
        infFileName =varargin{1};
        varargin = varargin(2:end);
    end
end

%--------------------------------------------------------------------------
% Parse Variable Input Arguments
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
            infFileName = CheckParameter(parameterValue, 'string', 'file'); 
        case 'path'
            dataPath = CheckParameter(parameterValue, 'string', 'path'); 
        case 'verbose'
            verbose = CheckParameter(parameterValue, 'boolean', 'verbose');
        otherwise
            error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
    end
end

%--------------------------------------------------------------------------
% Get file if needed
%--------------------------------------------------------------------------
if isempty(infFileName)
    [infFileName infFilePath] = uigetfile([dataPath '*.inf']);
    if isempty(infFileName)
        display('Loading canceled');
        infoFile = [];
        return;
    end
    if infFilePath(end) ~= '\'
        infFilePath = [infFilePath '\']; % All paths must end in '\'
    end
    infFileName = [infFilePath infFileName];
end

%--------------------------------------------------------------------------
% Open Inf File
%--------------------------------------------------------------------------
if strcmp(infFileName((end-3):end), '.dax')
    infFileName = [infFileName(1:(end-4)) '.inf'];
end

% Open file
fid = fopen(infFileName);
if fid == -1
    error([infFileName ' is not a valid .inf file']);
end

%--------------------------------------------------------------------------
% Read Inf File
%--------------------------------------------------------------------------
count = 1;
text = {};
while ~feof(fid)
    text{count} = fgetl(fid);
    count = count + 1;
end
fclose(fid);

%--------------------------------------------------------------------------
% Create Info File
%--------------------------------------------------------------------------
infoFile = CreateInfoFileStructure();
[infFilePath, name, extension] = fileparts(infFileName);
infoFile.localName = [name extension];
infoFile.localPath = [infFilePath, filesep];
infoFile.uniqueID = now;

%--------------------------------------------------------------------------
% Parse each line and build ini structure
%--------------------------------------------------------------------------
for j=1:length(text)

    % Does the line contain a definition
    posEqual = strfind(text{j}, '=');
    if ~isempty(posEqual)

        %Parse value
        value = strtrim(text{j}((posEqual+1):end)); % Read value
        posX = strfind(value, ' x '); % Find a potential 'X'--a flag of a 2 element entry
        posColon = strfind(value, ':'); % Is there a colon?
        if ~isempty(posX) && isempty(posColon)% Parse both elements
            value1 = value(1:(posX-1));
            value2 = value((posX+2):end);
        end

        %Prepare field name
        fieldName = CoerceFieldName(text{j}(1:(posEqual-1)));

        %Prepare value
        if ~isempty(posX) && isempty(posColon)
            infoFile.(fieldName) = [str2num(value1) str2num(value2)];
        else
            fieldValue = str2num(value);
            if isempty(fieldValue) %The value is a string
                fieldValue = value;
            end
            infoFile.(fieldName) = fieldValue;
        end

    elseif strcmp(text{j}, 'information file for')  %If the line does not contain a definition, then the next line is the file name
        infoFile.file = text{j+1};
    end
end

if verbose
    display(['Loaded ' infFilePath, filesep, name, '.inf']);
end

%--------------------------------------------------------------------------
% Check frame dimensions
%--------------------------------------------------------------------------
if any(infoFile.frame_dimensions == 0)
    warning('matlabSTORM:corruptedInfoFile', 'Unexpected frame dimensions');
    infoFile.frame_dimensions = [infoFile.hend - infoFile.hstart + 1, ...
        infoFile.vend - infoFile.vstart + 1];
end

