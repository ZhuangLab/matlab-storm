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
% mListType -- A prefix that will be added before the mList tag (default is
%   empty)
% savePath -- The file path in which molecule lists will be saved (default
%   is the data directory)
% overwrite -- A boolean determining if existing files will be overwritten
%   or ignored. 
% numParallel -- The number of parallel processes to launch. Default is 1.
% hideterminal -- Hide the command windows that are launched?
% waitTime -- The number of seconds to pause before querying the job queue
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
defaults(end+1,:) = {'veryVerbose', 'boolean', false};   % Display all commands being called?
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
% Confirm that the same file is not analyzed twice (not yet supported)
% -------------------------------------------------------------------------
if length(filePaths) ~= length(unique(filePaths))
    error('matlabFunctions:invalidArguments', 'Analysis of the same file twice is not yet supported.');
end
% -------------------------------------------------------------------------
% Handle prefix formatting
% -------------------------------------------------------------------------
if isempty(parameters.mListType)
    parameters.mListType = 'mList';
end

% -------------------------------------------------------------------------
% Handle formatting of savePath
% -------------------------------------------------------------------------
if ~isempty(parameters.savePath) && strcmp(parameters.savePath(end), filesep)
    parameters.savePath(end+1) = filesep;
end

% -------------------------------------------------------------------------
% Display progress
% -------------------------------------------------------------------------
if parameters.verbose
    PageBreak();
    display(['Analyzing ' num2str(length(filePaths)) ' files']);
    uniqueConfigFiles = unique(configFilePaths);
    if length(uniqueConfigFiles) == 1
        display(['...configuration file: ' uniqueConfigFiles{1}]);
    else
        display(['...with ' num2str(length(uniqueConfigFiles)) ' unique configuration files']);
    end
    display(['...saving as ' parameters.mListType ' bin files']);
    if isempty(parameters.savePath)
        display(['...in the original data location']);
    else
        display(['...here: ' parameters.savePath]);
    end
end

% -------------------------------------------------------------------------
% Create bin file paths
% -------------------------------------------------------------------------
binFilePaths = {};
indsToKeep = true(1, length(filePaths)); 
numDeleted = 0;
for f=1:length(filePaths)
    % Strip parts
    [filePath, fileName, fileExt] = fileparts(filePaths{f});
    
    % Check for correct file extension
    if ~ismember(fileExt, {'.dax', '.tif', '.tiff'})
        warning('matlabFunctions:invalidFileExtension', [filePaths{f} ' contains an invalid extension.']);
    end
    
    % Create bin file path
    if isempty(parameters.savePath)
        binFilePaths{f} = [filePath filesep fileName '_' parameters.mListType '.bin'];
    else
        binFilePaths{f} = [parameters.savePath fileName '_' parameters.mListType '.bin'];
    end
    
    % Check if it exists
    if exist(binFilePaths{f})
        if parameters.overwrite
            delete(binFilePaths{f});
            numDeleted = numDeleted + 1;
            if parameters.veryVerbose
                display(['... deleted: ' binFilePaths{f}]);
            end
        else
            indsToKeep(f) = false;
            if parameters.veryVerbose
                display(['... found and ignoring: ' binFilePaths{f}]);
            end
        end
    end
end

% Update list of data files and configuration files
filePaths = filePaths(indsToKeep);
binFilePaths = binFilePaths(indsToKeep);
configFilePaths = configFilePaths(indsToKeep);

% -------------------------------------------------------------------------
% Display progress
% -------------------------------------------------------------------------
if parameters.verbose
    display(['...overwriting ' num2str(numDeleted) ' files']);
    display(['...ignoring ' num2str(sum(~indsToKeep)) ' files']);
end

%--------------------------------------------------------------------------
% Create command strings
%--------------------------------------------------------------------------
commands = {};
for i=1:length(filePaths)
    displayCommand = ['echo ' 'Analyzing: ' filePaths{i} ' && '];            
    commands{i} = [displayCommand daoSTORMexe ' ' '"' filePaths{i} '" ' ... 
        ' "' binFilePaths{i} '" ' ...
        ' "' configFilePaths{i} '"'];
    if parameters.outputInMatlab
        commands{i} = [commands{i} ' &'];
    end
end

% -------------------------------------------------------------------------
% Display progress
% -------------------------------------------------------------------------
if parameters.verbose
    PageBreak();
    display(['Staring analysis: ' datestr(now)]);
    batchTimer = tic;
end

%--------------------------------------------------------------------------
% Batch process commands
%--------------------------------------------------------------------------
startTime = now;
doneFlag = false(1, length(commands));
processes = cell(1, length(commands));
if ~parameters.outputInMatlab
    while any(~doneFlag)
        %----------------------------------------------------------------------
        % Start a batch of commands
        %----------------------------------------------------------------------
        while sum(~cellfun(@isempty, processes)) < parameters.numParallel
            nextInd = find(~doneFlag & cellfun(@isempty, processes), 1);
            if isempty(nextInd)
                break;
            end
            processes{nextInd} = SystemRun(commands{nextInd},'Hidden',parameters.hideterminal);
            if parameters.veryVerbose
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
            if doneFlag(i) && parameters.veryVerbose
                display(['...completed ' filePaths{i}]);
            end
        end

        %----------------------------------------------------------------------
        % Wait to poll status again
        %----------------------------------------------------------------------
        pause(parameters.waitTime);
    end
else
    for i=1:length(commands)
        dos(commands{i});
    end
end

% -------------------------------------------------------------------------
% Display progress
% -------------------------------------------------------------------------
if parameters.verbose
    display(['...completed ' datestr(now)]);
    display(['...in ' num2str(toc(batchTimer)) ' s']);
end
