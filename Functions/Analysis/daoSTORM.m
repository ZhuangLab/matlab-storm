function parameters = daoSTORM(filePaths, configFilePaths, varargin)
% ------------------------------------------------------------------------
% daoSTORM(filePaths, configFilePath, ...) is a light weight wrapper around daoSTORM
%--------------------------------------------------------------------------
% Necessary Inputs: 
%   filePath -- A cell array of filePaths to analyze or a single file path. 
%   configFilePaths -- The path to a daoSTORM configuration file or a cell
%   array of such paths. If a cell array is provided it must match the
%   length of the cell array of filePaths. 
%--------------------------------------------------------------------------
% Outputs: 
%--------------------------------------------------------------------------
% Variable Inputs (Flag/ data type /(default)):
% 
%--------------------------------------------------------------------------
% Jeffrey Moffitt
% jeffmoffitt@gmail.com
% March 11, 2016
%--------------------------------------------------------------------------
% Creative Commons License CC BY NC SA
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Global Variables
%--------------------------------------------------------------------------
global daoSTORMexe;
if isempty(daoSTORMexe)
    error('matlabFunctions:invalidPath', 'The daoSTORM exe path does not appear to be defined.');
end

% -------------------------------------------------------------------------
% Default variables
% -------------------------------------------------------------------------
defaults = cell(0,3);

% Parameters for saving mLists
defaults(end+1,:) = {'mListType', 'string', ''};        % A prefix to add before the mList tag
defaults(end+1,:) = {'savePath', 'fileDir', ''};        % The path where mLists will be saved (default, same path as filePath)
defaults(end+1,:) = {'overwrite', 'boolean', true};     % Overwrite existing files?

% Parameters for batch processing
defaults(end+1,:) = {'numParallel', 'positive', 1};     % The number of parallel processes to launch
defaults(end+1,:) = {'hideterminal', 'boolean', false}; % Hide the analysis terminal
defaults(end+1,:) = {'waitTime', 'nonnegative', 15};    % The number of seconds to pause between pooling job queue

% Parameters for displaying progress
defaults(end+1,:) = {'verbose', 'boolean', true};       % Report progress?
defaults(end+1,:) = {'outputInMatlab', 'boolean', false}; % Useful for debug. Display output in matlab command window.
% -------------------------------------------------------------------------
% Parse necessary input
% -------------------------------------------------------------------------
if nargin < 2 
    error('matlabFunctions:invalidArguments', 'A path and a configuration file must be provided.');
end

% -------------------------------------------------------------------------
% Parse variable input
% -------------------------------------------------------------------------
parameters = ParseVariableArguments(varargin, defaults, mfilename);

% -------------------------------------------------------------------------
% Coerce file paths to cell arrays
% -------------------------------------------------------------------------
if ~iscell(filePaths)
    filePaths = {filePaths};
end
if ~iscell(configFilePaths)
    configFilePaths = {configFilePaths};
end
if length(configFilePaths) == 1
    configFilePaths = repmat(configFilePaths, [1 length(filePaths)]);
end
if length(configFilePaths) ~= length(filePaths)
    error('matlabFunctions:invalidArguments', 'The number of configuration files does not match the number of requested files');
end

% -------------------------------------------------------------------------
% Confirm that requested paths exist
% -------------------------------------------------------------------------
if ~all(cellfun(@exist, filePaths))
    error('matlabFunctions:invalidArguments', 'Some requested file paths do not exist');
end
if ~all(cellfun(@exist, configFilePaths))
    error('matlabFunctions:invalidArguments', 'Some requested configuration files do not exist');
end

% -------------------------------------------------------------------------
% Handle prefix formatting
% -------------------------------------------------------------------------
if isempty(parameters.mListType)
    parameters.mListType = 'mList';
end
    
% -------------------------------------------------------------------------
% Create bin file paths
% -------------------------------------------------------------------------
binFilePaths = {};
indsToKeep = true(1, length(filePaths)); 
for f=1:length(filePaths)
    % Strip parts
    [filePath, fileName, fileExt] = fileparts(filePaths{f});
    
    % Check for correct file extension
    if ~ismember(fileExt, {'.dax', '.tif', '.tiff'})
        warning('matlabFunctions:invalidFileExtension', [filePaths{f} ' contains an invalid extension.']);
    end
    
    % Create bin file path
    binFilePaths{f} = [filePath filesep fileName '_' parameters.mListType '.bin'];
    
    % Check if it exists
    if exist(binFilePaths{f})
        if parameters.overwrite
            delete(binFilePaths{f});
            if parameters.verbose
                display(['... deleted: ' binFilePaths{f}]);
            end
        else
            indsToKeep(f) = false;
            if parameters.verbose
                display(['... found and ignoring: ' binFilePaths{f}]);
            end
        end
    end
end

% Update list of data files and configuration files
filePaths = filePaths(indsToKeep);
binFilePaths = binFilePaths(indsToKeep);
configFilePaths = configFilePaths(indsToKeep);

%--------------------------------------------------------------------------
% Create command strings
%--------------------------------------------------------------------------
commands = {};
jobNames = {};
for i=1:length(filePaths)
    displayCommand = ['echo ' 'Analyzing: ' filePaths{i} ' && '];            
    commands{i} = [displayCommand daoSTORMexe ' ' '"' filePaths{i} '" ' ... 
        ' "' binFilePaths{i} '" ' ...
        ' "' configFilePaths{i} '"'];
    jobNames{i} = ''; 
end

%--------------------------------------------------------------------------
% Start STORM Analysis
%--------------------------------------------------------------------------
startTime = now;
doneFlag = false(1, length(commands));
processes = cell(1, length(commands));
while any(~doneFlag)
    if ~parameters.outputInMatlab
        %----------------------------------------------------------------------
        % Start a batch of commands
        %----------------------------------------------------------------------
        while sum(~cellfun(@isempty, processes)) < parameters.numParallel
            nextInd = find(~doneFlag & cellfun(@isempty, processes), 1);
            if isempty(nextInd)
                break;
            end
            processes{nextInd} = SystemRun(commands{nextInd},'Hidden',parameters.hideterminal);
            if parameters.verbose
                display(['... analyzing ' filePaths{nextInd}]);
            end
        end

        %----------------------------------------------------------------------
        % Find the files that are done
        %----------------------------------------------------------------------
        for i=find(~doneFlag & ~cellfun(@isempty, processes))
            doneFlag(i) = processes{i}.HasExited;
            if doneFlag(i)
                processes{i} = []; % Clear process
            end
            if doneFlag(i) && parameters.verbose
                display(['...completed ' filePaths{i}]);
            end
        end

        %----------------------------------------------------------------------
        % Wait to poll status again
        %----------------------------------------------------------------------
        pause(parameters.waitTime);
    else
        for i=1:length(commands)
            dos(commands{i});
        end
    end
end
