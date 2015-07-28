
function RunDotFinder(varargin)
%--------------------------------------------------------------------------
%% RunDotFinder(folder)
% RunDotFinder('daxfile',value,'parsfile',value)
% RunDotFinder('path',value)
% RunDotFinder('path',value,'method',value,'batchsize',value,...
%     ('overwrite',value,'minsize',value,'daxroot',value,'parsroot',value);
%--------------------------------------------------------------------------
%% Required Inputs
% at least 'path' or 'daxfile' and 'parsfile'
%
%--------------------------------------------------------------------------
%% Outputs
%               -- InsightM generates files _list.bin and .drift in the
%                   target directory. ('method','insight')
%               -- DaoSTORM generates _mlist.bin files
%               ('method','DaoSTORM')
%               -- GPUmultifit generates glist.bin files
%                ('method','GPUmultifit');   
%--------------------------------------------------------------------------
%% Optional Inputs
% parsfile / string / '' 
%               - use this parameter file to analyze the specified dax
%               files.  
% daxfile / string / ''
%               - full name and path of .dax file to analyze
% daxnames / cell / {}
%               - cell array of daxnames to analyze.  Also requires the
%               'path' flag to specify the folder containing these files.
% binname / string / ''
%               - alternate name for the _mlist.bin (only in DaoSTORM).
%                 myname# will replace # with _0001 (where 0001 increases
%                 by 1 for each movie found by the batch launcher).  
%               - mynameDAX will replace DAX with the daxname of the movie.
%                (e.g. mynameDAX -> myname_movie_0001_mlist.bin)
% path / string / ''
%               - directory containing .dax files to be analyzed
% batchsize / integer / 1
%               - max number of versions of analysis to run in parallel
% overwrite / double / 2     
%               - Skip files for which bin files already exist (0),
%               Overwrite any existing bin files without asking (1), Ask
%               the user what to do if file exists (4):  
%               0 - cancel, 1-overwrite, 2-skip, 3-resume.  
% method / string / DaoSTORM
%               - method to use for dotfinding analysis.  
%               Options: insight, DaoSTORM, GPUmultifit
% minsize / double / 1E6 
%               - Minimum size in bytes of dax file 
% daxroot / string / ''    
%               - only grab dax files which contain this string
%                   in the name. leave blank to grab all dax files      
% parsroot / string / ''    
%               - uses parameter files in same folder as dax file which
%               contain this string in their file name.
% verbose / logical / true
%               - print comments and progress to screen?
% runinMatlab / logical / false
%               - Run in matlab command line (single instance only).
% printprogress / logical / false
%               - when running in matlab, print progress to terminal?
% hideterminal / logical / false
%               - run in a "hidden" external terminal (good for rapidly
%               launching 100s of processes to keep them from all popping
%               up on your screen).  
% maxCPU / double / 95
%               - if more than this percent of CPU is already in use,
%               RunDotFinder will pause and wait for it to drop below
%               before adding lanuching new tasks.  
%--------------------------------------------------------------------------
% Examples
% RunDotFinder('method','insight','daxfile','D:\movie.dax',...
%       'parsfile','D:\pars.ini')
%     -- runs insight on daxfile 'D:\movie.dax' using parameter file 
%           'D:\pars.ini'.  If using default method, 'method' can be
%           omitted.
% RunDotFinder('path','D:\data')
%     -- runs default dotfinding program on all dax files found in
%           'D:\data' using the parameter file in that folder that matches
%           the default dotfinding program.  If no parameter files exist or
%           multiple parameter files exist, it will bring up a GUI to
%           prompt you to chose which file you want to use.
% RunDotFinder(... 'hideterminal',true)
%     - run "silently" in a "hidden" external terminal (good for rapidly
%           launching 100s of processes to keep them from all popping
%           up on your screen).  Or if you are doing a lot of Ctrl+C
%           copying while RunDotFinder is launching stuff it won't
%           cancel by accident.  
% RunDotFinder(... 'maxCPU',80)
%     - Function will pause and wait for free CPU if more than 80% of CPU
%           is currently in use.  
%--------------------------------------------------------------------------
%
% Alistair Boettiger
% boettiger@fas.harvard.edu
% February 9, 2013
% Copyright Creative Commons 3.0 CC BY.    
%
% Version 1.4
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Global variables 
%--------------------------------------------------------------------------
global insightExe
global daoSTORMexe
%--------------------------------------------------------------------------
% Hardcoded Variables
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Define default parameters
%--------------------------------------------------------------------------
% this makes it easy to change default values
batchsize = 2;
overwrite = 4; % ask user
minsize = 20E6;
daxroot = '';
parsroot = '';
method = 'DaoSTORM';
daxfile = '';
daxnames = {};
parsfile = '';
dpath = ''; 
verbose = true; 
hideterminal = false; 
runinMatlab = false;
printprogress = false;
batchwait = false;
maxCPU = 95;
binname = ''; 
binnames = {};

%--------------------------------------------------------------------------
%% Parse Variable Input Arguments
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
                dpath = CheckParameter(parameterValue, 'string', 'path');
            case 'batchsize'
                batchsize = CheckParameter(parameterValue, 'positive', 'batchsize');
            case 'parsroot'
                parsroot = CheckParameter(parameterValue, 'string', 'parsroot');
            case 'daxroot'
                daxroot = CheckParameter(parameterValue, 'string', 'daxroot');
            case 'daxnames'
                daxnames = CheckParameter(parameterValue, 'cell', 'daxnames');
            case 'binnames'
                binnames = CheckParameter(parameterValue, 'cell', 'binnames');
            case 'method'
                method = CheckParameter(parameterValue, 'string', 'method');
            case 'minsize'
                minsize = CheckParameter(parameterValue, 'positive', 'minsize');
            case 'overwrite'
                overwrite = CheckParameter(parameterValue, 'nonnegative', 'overwrite');
            case 'parsfile'
                parsfile = CheckParameter(parameterValue, 'string', 'parsfile');
            case 'daxfile'
                daxfile  = CheckParameter(parameterValue, 'string', 'daxfile');
            case 'binname'
                binname  = CheckParameter(parameterValue, 'string', 'binname');
            case 'verbose'
                verbose = CheckParameter(parameterValue, 'boolean', 'verbose');
            case 'hideterminal'
                hideterminal = CheckParameter(parameterValue, 'boolean', 'hideterminal');
            case 'runinMatlab'
                runinMatlab = CheckParameter(parameterValue, 'boolean', 'runinMatlab');
            case 'printprogress'
                printprogress = CheckParameter(parameterValue, 'boolean', 'printprogress');
            case 'maxCPU'
                maxCPU = CheckParameter(parameterValue, 'positive', 'maxCPU');
            otherwise
                error(['The parameter ''', parameterName,...
                    ''' is not recognized by the function, ''',...
                    mfilename '''.' '  See help ' mfilename]);
        end
    end
end

%% main function code 
%------------------------------------------------------------------------

time_run = tic;

%~~~~~~~~~~~~~~~~~~~~~~~ Find all dax files ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if isempty(daxnames)
    if isempty(daxfile)
        % Get all dax files in folder        
        alldax = dir([dpath,'*',daxroot,'*.dax']);
        daxnames = {alldax(:).name};
        % remove all short dax files from list
        daxsizes = [alldax(:).bytes];
        daxnames(daxsizes < minsize) = [];
        daxroots = regexprep(daxnames,'.dax',''); % strip off file endings
    else  % parse out file path and daxfile name
        k = strfind(daxfile,filesep);
        dpath = daxfile(1:k(end));
        daxnames = {daxfile(k(end)+1:end)};
        daxroots = {regexprep(daxfile(k(end)+1:end),'.dax','')};
    end
else
    [~,daxroots,~] = cellfun(@(x) fileparts(x),daxnames,'UniformOutput',false);
end

% make sure daxroots and daxnames don't contain extra copies of filepath
[~,daxroots,~] = cellfun(@(x) fileparts(x),daxroots,'UniformOutput',false);
[folders,daxnames,filetype] = cellfun(@(x) fileparts(x),daxnames,'UniformOutput',false);
daxnames = strcat(daxnames,filetype);

if ~isempty(folders{1})
    dpath = [folders{1},filesep];
end



%% ~~~~~~~~~~~~~~~ Set method specific flags ~~~~~~~~~~~~~~~~~~~~~~~
if ~isempty(parsfile)
    parstype = parsfile(end-3:end);
    if strcmp(parstype,'.ini')
        method = 'insight';
    elseif strcmp(parstype,'.xml')
        method = 'DaoSTORM';
    end
end

switch method
    case 'insight'
        datatype = '_list.bin'; 
        parstype = '.ini';
    case 'DaoSTORM'
        datatype = '_mlist.bin';
        parstype = '.xml';
    otherwise
        error(['method ',method,' not recognized.  Available methods:',...
            ' insight, DaoSTORM']);
end


%% ~~~~~~~~~~~~~~~~~~~ Find binfiles ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if isempty(binnames) % a cell array of binnames passed (equal to length daxnames)
     binnames = strcat(dpath,daxroots,datatype);
   if ~isempty(binname) && strcmp(method,'DaoSTORM') % insight does not allow changing the binname
        binNumbers = cellfun(@(x) ['_',sprintf('%04d',x) ], num2cell(1:length(daxroots)),'UniformOutput',false)' ;
        binnames  = strcat(cell(length(daxroots),1),binname); 
        binnames = cellfun(@(x,y) regexprep(x,'#',y),binnames,binNumbers,'UniformOutput',false);
        binnames = cellfun(@(x,y) regexprep(x,'DAX',y),Column(binnames),Column(daxroots),'UniformOutput',false);
        binnames = strcat(dpath,binnames,datatype);
   end
   
elseif length(binnames) ~= length(daxnames)
    error('length binnames must equal length daxnames');
end

[binfolder,binfilenames,~] = cellfun(@(x) fileparts(x),binnames,'UniformOutput',false);
if isempty(binfolder)
    binnames = strcat(dpath,binfilenames);
elseif isempty(binfolder{1})
    binnames = strcat(dpath,binfilenames);
end



% ~~~~~~~~~~~~ check for parameter files ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if isempty(parsfile)
    parsname = dir([dpath,'*',parsroot, '*',parstype]);
    if length(parsname) > 1 || isempty(parsname)
        disp(['Too many or no ',parstype,...
            ' files in directory.  Please chose a parameters file for']);
        disp(daxnames(1));
       getfileprompt = {['*',parstype],[method,' pars (*',parstype,')']};
       [filename, filepath] = uigetfile(getfileprompt,...
           'Select Parameter File',dpath);
       parsfile = [filepath,filename];
    else
        parsfile = [dpath, parsname.name];
        disp('No parameters specified: RunDotFinder found parameters ');
        disp(parsfile);
        disp('using these parameters ... '); 
    end
end     

if isempty(strfind(parsfile,parstype))
    error([parsfile, ' is not a valid ', parstype, ' parameter file for ',method]);
end

%% ~~~~ Decide if existing data files should be skipped or overwritten ~~~~~%    
    hasbin = cellfun(@(x) exist(x,'file'), binnames) > 0;
    
% index of all dax files which have bin files associated 
    txtout = {['warning: found existing ',datatype,' data files for '],...
        daxnames(logical(hasbin))};
    
% don't analyze movies which have _list.bin files
if sum(hasbin) ~= 0 
    if overwrite == 4   
        disp(txtout);
        overwritefiles = input('Please select: 3=resume, 2=skip, 1=overwrite, 0=cancel:  ');
    elseif overwrite == 1
        overwritefiles = 1;
        if verbose
        disp(txtout);
        disp('these files will be overwritten.  ');
        end
    elseif overwrite == 0
        overwritefiles = 2; 
              disp(txtout);
        disp('these files will be skipped.  ');
    elseif overwrite == 3
        overwritefiles = overwrite;
        disp('these files will resume from last fit frame...')
    else
        error([num2str(overwrite), ' is not a valid value for overwrite']); 
    end
    if overwritefiles==1    
        % files must be physically deleted to enable a fresh daoSTORM
        % analysis.  
        if strcmp(method,'DaoSTORM')
            disp('overwritefiles = 1');
            for a = find(logical(hasbin))';
                disp(['deleting ',binnames{a}]);          
                delete(binnames{a});
                alistname = regexprep(binnames{a},'_mlist\.bin','_alist\.bin');
                if exist(alistname,'file')>0
                    delete(alistname);
                end
            end
        end
    elseif overwritefiles == 2 || (overwritefiles == 3 && strcmp(method,'insight'))
            disp('skipping these movies...'); 
            % DaoSTORM defaults to 'pick up where it left off' analysis
        daxnames(logical(hasbin))=[]; % actually removes from que      
    elseif overwritefiles == 3
        disp('DaoSTORM will attempt to resume from where it left off');
    elseif overwritefiles == 0
        disp('RunDaoSTORM canceled');
        return
    end
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

%% ~~~~~~~~~~~~~~~~~ Call analysis commands in batch ~~~~~~~~~~~~~~~~~~~~~~~%
Sections = length(daxnames);
prc = cell(Sections,1); % cell array to store system process structures for each process launched
for s=1:Sections % loop through all dax movies in que
    daxfile = [dpath,daxnames{s}]; 
    binfile = binnames{s}; 
    
    if ~isempty(maxCPU)
        waitforfreecpu('MaxLoad',maxCPU,'RefreshTime',10,'verbose',verbose);
    end
    
   if verbose
        disp(['running ',method,' on:']);
        disp(daxfile); 
        disp(parsfile); 
        disp('...');
   end 
    
   
    switch method
        case 'insight'
         % display command split up onto multiple lines  
         % Actually launch insightM and poll computer for number of processes
            if runinMatlab % 
                if printprogress  % Print fitting progress to command line
                    system([insightExe,' "',daxfile,'" "',parsfile,'" "',parsfile,'"']);  
                else  % Don't print to command line (save output in text file)
                    system([insightExe,' "',daxfile,'" "',parsfile,'" "',parsfile,'" >' dpath,'\newlog',num2str(s),'.txt']); 
                end
            else
               system_command = [insightExe,' "',daxfile,'" "',parsfile,'" "',parsfile, '" && exit &']; 
               prc{s} = SystemRun(system_command,'Hidden',hideterminal); 
               batchwait = true;
            end
        case 'DaoSTORM'
            if runinMatlab % 
                if printprogress  % Print fitting progress to command line
                    system([daoSTORMexe,' "',daxfile,'" "',binfile,'" "',parsfile,'"']);  
                else  % Don't print to command line (save output in text file)
                    system([daoSTORMexe,' "',daxfile,'" "',binfile,'" "',parsfile,'" >' dpath,'\newlog',num2str(s),'.txt']); 
                end
            else  % Launch silently in the background
                % binfile
                system_command = [daoSTORMexe,' "',daxfile,'" "',binfile,'" "',parsfile, '" && exit &']; 
                prc{s} = SystemRun(system_command,'Hidden',hideterminal); 
                batchwait = true;
            end          
    end   
    WriteParsTxt(binfile,parsfile);
     
    if batchwait
    Nrunning = inf; 
       while Nrunning >= batchsize
           prcActive = prc(logical(1-cellfun(@isempty, prc)));
           hasexited = cellfun(@(x) x.HasExited,prcActive);
           Nrunning = s-sum(hasexited);
           pause(1); 
       end 
    end
end

time_run = toc(time_run);
if verbose
disp(['RunDotFinder finished processing ',num2str(Sections),' dax movies',...
    ' Total time=',num2str(time_run/(60*60)),' hours']); 
end
