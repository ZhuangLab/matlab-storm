
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
% path / string / ''
%               - directory containing .dax files to be analyzed
% batchsize / integer / 1
%               - max number of versions of analysis to run in parallel
% overwrite / double / 2     
%               - Skip files for which bin files already exist (0),
%               Overwrite any existing bin files without asking (1), Ask
%               the user what to do if file exists (2). 
% method / string / insightM
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
%--------------------------------------------------------------------------
%
% Alistair Boettiger
% boettiger@fas.harvard.edu
% January 20, 2013
% Copyright Creative Commons 3.0 CC BY.    
%
% Version 1.2
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Global variables 
%--------------------------------------------------------------------------
global defaultInsightPath
global defaultDaoSTORM
%--------------------------------------------------------------------------
% Hardcoded Variables
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Define default parameters
%--------------------------------------------------------------------------
% this makes it easy to change default values
batchsize = 1;
overwrite = 2; % ask user
minsize = 1E6;
daxroot = '';
parsroot = '';
method = 'DaoSTORM';
daxfile = '';
parsfile = '';
dpath = ''; 
verbose = true; 
hideterminal = false; 
runinMatlab = false;
printprogress = false;
batchwait = false;

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
                dpath = CheckParameter(parameterValue, 'positive', 'path');
            case 'batchsize'
                batchsize = CheckParameter(parameterValue, 'positive', 'batchsize');
            case 'parsroot'
                parsroot = CheckParameter(parameterValue, 'string', 'parsroot');
            case 'daxroot'
                daxroot = CheckParameter(parameterValue, 'string', 'daxroot');
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
            case 'verbose'
                verbose = CheckParameter(parameterValue, 'boolean', 'verbose');
            case 'hideterminal'
                hideterminal = CheckParameter(parameterValue, 'boolean', 'hideterminal');
            case 'runinMatlab'
                runinMatlab = CheckParameter(parameterValue, 'boolean', 'runinMatlab');
            case 'printprogress'
                printprogress = CheckParameter(parameterValue, 'boolean', 'printprogress');
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
if isempty(daxfile)
    % Get all dax files in folder        
    alldax = dir([dpath,'\','*',daxroot,'*.dax']);
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

%% ~~~~~~~~~~~~~~~ Set method specific flags ~~~~~~~~~~~~~~~~~~~~~~~
switch method
    case 'insight'
        datatype = '_list.bin'; 
        parstype = '.ini';
    case 'DaoSTORM'
        datatype = '_mlist.bin';
        parstype = '.xml';
    case 'GPUmultifit'
        datatype = '_glist.bin';
        parstype = '.mat';
        if batchsize > 1
            disp('Batch task execution not available for GPU');
        end
    otherwise
        error(['method ',method,' not recognized.  Available methods:',...
            ' insight, DaoSTORM, GPUmultifit.']);
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
        disp('using these parameters ...'); 
    end
end     
if isempty(strfind(parsfile,parstype))
    error([parsfile, ' is not a valid ', parstype, ' parameter file for ',method]);
end

%% ~~~~ Decide if existing data files should be skipped or overwritten ~~~~~%    
% structure containing names of all bin files in folder 
    all_prev_bin = dir([dpath,'\','*',daxroot,'*',datatype]);
    binnames = {all_prev_bin(:).name};
    binroots = regexprep(binnames,datatype,''); % strip off file endings

% index of all dax files which have bin files associated 
    hasbin = sum(cell2mat(cellfun(@(x) strcmp(x,daxroots),...
        binroots,'UniformOutput',false)'));
    txtout = ['warning: found existing ',datatype,' data files for ',...
        daxnames(logical(hasbin))];
    
% don't analyze movies which have _list.bin files
if sum(hasbin) ~= 0 
    if overwrite == 2   
        disp(char(txtout));
        disp('these files will be overwritten.  ');
        overwritefiles = input('type 2 to skip, 1 to overwrite, 0 to cancel:  ');
    elseif overwrite == 1
        overwritefiles = 1;
        if verbose
        disp(char(txtout));
        disp('these files will be overwritten.  ');
        end
    elseif overwrite == 0
        overwritefiles = 0; 
    else
        disp(overwrite)
        disp('is not a valid value for overwrite'); 
    end
    if overwritefiles==1
        % files must be physically deleted to enable a fresh daoSTORM
        % analysis.  
        if strcmp('method','daoSTORM')
            allextra = daxroots(logical(hasbin));
            for a = 1:length(allextra)
                delete(strcat(allextra{a},datatype));
                alist = dir(strcat(allextra{a},'_alist.bin'));
                if length(alist)>1
                    delete(strcat(allextra{a},'_alist.bin'));
                end
            end
        end
    else
        disp('skipping these movies...'); 
        daxnames(logical(hasbin))=[]; % actually removes from que     
    end
end
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

%% ~~~~~~~~~~~~~~~~~ Call analysis commands in batch ~~~~~~~~~~~~~~~~~~~~~~~%
Sections = length(daxnames);
prc = cell(Sections,1); % cell array to store system process structures for each process launched
for s=1:Sections % loop through all dax movies in que
    daxfile = [dpath,filesep,daxnames{s}];          
    switch method
        case 'insight'
         % display command split up onto multiple lines  
         % Actually launch insightM and poll computer for number of processes
            if runinMatlab % 
                if printprogress  % Print fitting progress to command line
                    system([defaultInsightPath,' ',daxfile,' ',parsfile]);  
                else  % Don't print to command line (save output in text file)
                    system([defaultInsightPath,' ',daxfile,' ',parsfile,' >' dpath,'\newlog',num2str(s),'.txt']); 
                end
            else
               system_command = [defaultInsightPath,' ',daxfile,' ',parsfile, ' && exit &']; 
               prc{s} = SystemRun(system_command,'Hidden',hideterminal); 
               batchwait = true;
            end
        case 'DaoSTORM'
            binfile = [dpath,filesep,daxroots{s},datatype];
            if runinMatlab % 
                if printprogress  % Print fitting progress to command line
                    system([defaultDaoSTORM,' ',daxfile,' ',binfile,' ',parsfile]);  
                else  % Don't print to command line (save output in text file)
                    system([defaultDaoSTORM,' ',daxfile,' ',binfile,' ',parsfile,' >' dpath,'\newlog',num2str(s),'.txt']); 
                end
            else  % Launch silently in the background
                system_command = [defaultDaoSTORM,' ',daxfile,' ',binfile,' ',parsfile, ' && exit &']; 
                prc{s} = SystemRun(system_command,'Hidden',hideterminal); 
                batchwait = true;
            end          
        case 'GPUmultifit'
            load(parsfile);
            gpuclock = tic;
            mlist = GPUmultifitDax(daxfile,GPUmultiPars);
            WriteMoleculeList(mlist,[dpath,filesep,daxroots{s},datatype]);
            gputime = toc(gpuclock)/60;
            disp(['GPU found and fit ',num2str(length(mlist.x)),' molecules']);
            disp(['in ',num2str(gputime),' minutes']); 
    end    

    if verbose
        disp(['running ',method,' on:']);
        disp(daxfile); 
        disp(parsfile); 
    end 
  
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
    ' Total time=',num2str(time_run/(60*60)),'hours']); 
end
