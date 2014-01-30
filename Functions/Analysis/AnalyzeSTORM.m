function infoFiles = AnalyzeSTORM(varargin)
%--------------------------------------------------------------------------
% infoFiles = AnalyzeSTORM(varargin)
% This function starts a STORM analysis session based on insightM
%--------------------------------------------------------------------------
% Variable Inputs:
%
% 'path'/string(dataDefaultPath): The path in which STORM analysis should be conducted.
% STORM analysis will be conducted on all files in this path or in
% subfolders in this path (if this option is specified)
%
% 'info'/info: info is a structural array of info files to load
%
% 'config'/string: Path to a configuration file for STORM analysis
%
% 'numFrames'/int/(10): This number sets the minimum number of frames
% required for STORM analysis.
% 
% 'exePath'/string/(defaultInsightPath): The path to the analysis script
%
% 'method'/string/('insight'): The method for image analysis.  
% 
% 'verbose'/bool/(true): Determine if progress is printed or not.  
%
% 'overwrite'/bool/(true): Determine if _list.bin files should be
% overwritten
% 
% 'numParallel'/integer/(4): Determine the number of parallel jobs to start
%
% 'includeSubdir'/boolean(false): Determine if STORM analysis is run on
% all folders within the default directory
% 
% 'outputInMatlab'/boolean(false): Determine if the process is run in the
% matlab command line or in an extrernal dos line'
%--------------------------------------------------------------------------
% Outputs:
%
% infoFiles/structure array: A list of the info file structures of the
% created files
%--------------------------------------------------------------------------
% Jeffrey Moffitt
% September 6, 2012
% jeffmoffitt@gmail.com
%
% Version 1.0
%--------------------------------------------------------------------------
% Version 1.1; 9/21/12
% Added analysis of all files within folders within the default path
%--------------------------------------------------------------------------
% Version 1.2; 10/4/12
% Added 3DDAOSTORM and L1 Homotopy to the analysis proceedures
%
%--------------------------------------------------------------------------
% Hardcoded Variables
%--------------------------------------------------------------------------
quiet = 0;
waitTime = 15; % Determines the wait between pooling jobs to see if they are done in seconds
maxTime = 60; % Determines the maximum duration of analysis in minutes
methodList = {'insight', 'multifit', 'L1H', 'daoSTORM'};

%--------------------------------------------------------------------------
% Global Variables
%--------------------------------------------------------------------------
global defaultDataPath;
global insightExe;
global daoSTORMexe;

%--------------------------------------------------------------------------
% Default Variables
%--------------------------------------------------------------------------
analysisPath = defaultDataPath;
infoFiles = [];
exePath = insightExe;
configFile = [];
numFrames = 10;
method = 'insight';
verbose = true;
overwrite = true;
numParallel = 4;
includeSubdir = false;
hideterminal = false;
verbalize = false;
outputInMatlab = false;

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
                analysisPath = CheckParameter(parameterValue, 'string', 'path');
            case 'config'
                configFile = CheckParameter(parameterValue, 'string', 'config');
            case 'exePath'
                exePath = CheckParameter(parameterValue, 'string', 'exePath');
            case 'info'
                infoFiles = CheckParameter(parameterValue, 'struct', 'exePath');
            case 'method'
                method = CheckList(parameterValue, methodList, 'method');
            case 'verbose'
                verbose = CheckParameter(parameterValue, 'boolean', 'verbose');
            case 'overwrite'
                overwrite  = CheckParameter(parameterValue, 'boolean', 'overwrite');
            case 'numParallel'
                numParallel = CheckParameter(parameterValue, 'positive', 'numParallel');
            case 'includeSubdir'
                includeSubdir = CheckParameter(parameterValue, 'boolean', 'includeSubdir');
            case 'hideterminal'
                hideterminal = CheckParameter(parameterValue, 'boolean', 'hideterminal');
            case 'numFrames'
                numFrames = CheckParameter(parameterValue, 'positive', 'numFrames');
            case 'verbalize'
                numFrames = CheckParameter(parameterValue, 'positive', 'numFrames');
            case 'outputInMatlab'
                outputInMatlab = CheckParameter(parameterValue, 'boolean', 'outputInMatlab');
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end

%--------------------------------------------------------------------------
% Define default exePath for desired method
%--------------------------------------------------------------------------
if ~any(cellfun(@(x)strcmp(x, 'exePath'), varargin))
    switch method
        case 'insight'
            exePath = insightExe;
        case {'multifit', 'daoSTORM'}
            exePath = daoSTORMexe;
    end
end

%--------------------------------------------------------------------------
% Find configFile file
%--------------------------------------------------------------------------
if isempty(configFile)
    switch method
        case 'insight'
            configFile = dir([analysisPath '*.ini']);
            if length(configFile) > 1
                error(['Too many .ini files in directory.  Please specify specific file.']);
            elseif isempty(configFile)
                error(['No .ini file in directory.']);
            end
            configFile = [analysisPath configFile.name];
        case {'multifit', 'daoSTORM'}
            configFile = dir([analysisPath '*.xml']);
            if length(configFile) > 1
                error(['Too many .xml files in directory. Please specify desired config file.']);
            elseif isempty(configFile)
                error(['No .xml file in directory.']);
            end
            configFile = [analysisPath configFile.name];
        otherwise
    end
end

if verbose
    display('-------------------------------------------------------------');
    display('STORM Analysis');
    display('-------------------------------------------------------------');
    display(['Analysis Directory: ' analysisPath]);
    display(['Configuration File: ' configFile ]);
    display(['Analysis Method: ' method]);
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
% Find and read .inf files if necessary
%--------------------------------------------------------------------------
if isempty(infoFiles)
    for i=1:length(dataPaths)
        files = dir([dataPaths{i} '*.inf']);
        if isempty(files)
            if verbose
                display(['No .inf files in ' dataPaths{i}]);
            end
        else
            for j=1:length(files)  
                infoFiles = [infoFiles ReadInfoFile([dataPaths{i} files(j).name], 'verbose', verbose)];
            end
        end
    end
end
if isempty(infoFiles)
    error('No .inf files were found');
end

%--------------------------------------------------------------------------
% Find files that satisfy the frame number restrictions
%--------------------------------------------------------------------------
ind = [infoFiles.number_of_frames] >= numFrames;
infoFiles = infoFiles(ind);

if verbose
    display('-------------------------------------------------------------');
    display(['Found ' num2str(length(infoFiles)) ' files for analysis']);
    for i=1:length(infoFiles)
        display([infoFiles(i).localPath infoFiles(i).localName]);
    end
end

%--------------------------------------------------------------------------
% Convert names to .dax and _list.bin
%--------------------------------------------------------------------------
fileNames = {};
binFileNames = {};
filePaths = {};

prefix = [];
switch method
    case 'insight'
        fileExt = '_list.bin';
    case {'multifit', 'daoSTORM'}
        fileExt = '_mlist.bin';
end

for i=1:length(infoFiles)
    fileNames{i} =  [infoFiles(i).localName(1:(end-4)) '.dax'];
    binFileNames{i} = [infoFiles(i).localName(1:(end-4)) fileExt ];
    filePaths{i} = infoFiles(i).localPath;
end

%--------------------------------------------------------------------------
% Find Paths for Analysis 
%--------------------------------------------------------------------------
dataPaths = unique(filePaths);

%--------------------------------------------------------------------------
% Find _list.bin files
%--------------------------------------------------------------------------
for i=1:length(dataPaths)
    existingBinFiles = dir([dataPaths{i} '*.bin']);
    existingBinFileNames = {existingBinFiles.name};
    ind = ismember(binFileNames, existingBinFileNames) & strcmp(dataPaths{i}, filePaths);
    if ~isempty(existingBinFiles)
        if verbose
            display('-------------------------------------------------------------');
            display(['Found ' num2str(length(existingBinFiles)) ' existing bin files']);
        end
        if overwrite
            if verbose
                for i=find(ind)
                    display(['Overwriting ' filePaths{i} binFileNames{i}]);
                    delete([filePaths{i} binFileNames{i}]);
                end
            end
        else
            if verbose
                for i=find(ind)
                    display(['Ignoring ' filePaths{i} binFileNames{i}]);
                end
            end
            fileNames = fileNames(~ind); %Remove these files from analysis
            binFileNames = binFileNames(~ind);
            filePaths = filePaths(~ind);
        end
    end
end

%--------------------------------------------------------------------------
% Create command strings
%--------------------------------------------------------------------------
commands = {};
jobNames = {};
for i=1:length(fileNames)
    switch method
        case 'insight'
            displayCommand = ['echo ' 'Analyzing: ' filePaths{i} fileNames{i} ' && '];
            commands{i} = [displayCommand exePath ' ' '"' filePaths{i} fileNames{i} '" "' configFile '" && exit &'];
        case {'multifit', 'daoSTORM'}
            displayCommand = ['echo ' 'Analyzing: ' filePaths{i} fileNames{i} ' && '];
            commands{i} = [displayCommand exePath ' ' '"' filePaths{i} fileNames{i} '" ' ... 
                ' "' filePaths{i} binFileNames{i} '" ' ...
                ' "' configFile '"'];
    end
    jobNames{i} = ''; 
end
if verbose
    display('-------------------------------------------------------------');
end

%--------------------------------------------------------------------------
% Start STORM Analysis
%--------------------------------------------------------------------------
startTime = now;
doneFlag = false(1, length(commands));
activeFlag = false(1, length(commands));
processes = cell(1, length(commands));
while any(~doneFlag)
    if ~outputInMatlab
        %----------------------------------------------------------------------
        % Start a command
        %----------------------------------------------------------------------
        while sum(activeFlag) < numParallel
            nextInd = find(doneFlag==0 & ~activeFlag);
            if isempty(nextInd)
                break;
            end
            nextInd = nextInd(1); 
            processes{nextInd} = SystemRun(commands{nextInd},'Hidden',hideterminal);
            activeFlag(nextInd) = true;
            if verbose
                display(['Executing ' commands{nextInd}]);
            end
        end

        %----------------------------------------------------------------------
        % Find the files that are done
        %----------------------------------------------------------------------
        oldActiveFlag = activeFlag;
        for i=1:length(processes)
            if ~strcmp(class(processes{i}), 'double')
                doneFlag(i) = processes{i}.HasExited;
                activeFlag(i) = ~processes{i}.HasExited;
            end 
        end

        if verbose
            inds = find(~activeFlag & oldActiveFlag);
            for j=inds
                display(['Finished: ' commands{j}]);
            end
        end

        pause(waitTime);
    else
        for i=1:length(commands)
            dos(commands{i});
        end
    end
end

%----------------------------------------------------------------------
% Just for fun
%----------------------------------------------------------------------
if verbalize
    NET.addAssembly('System.Speech');
    speaker = System.Speech.Synthesis.SpeechSynthesizer();
    speaker.Rate = 1;
    speaker.Volume = 100;
    speaker.Speak('Analysis Complete.');
end