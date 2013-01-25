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
%
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
infoFile.localPath = [infFilePath '\'];
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
    display(['Loaded ' infFilePath name]);
end
