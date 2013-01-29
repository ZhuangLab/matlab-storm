
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
% batchsize / integer / 3
%               - max number of versions of analysis to run in parallel
% overwrite / logical / true     
%               - set true to overwrite existing .bin files
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
global defaultMultiFitPath PythonPath DaoSTORMPathSetup
%--------------------------------------------------------------------------
% Hardcoded Variables
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Define default parameters
%--------------------------------------------------------------------------
% this makes it easy to change default values
batchsize = 1;
overwrite = true;
minsize = 1E6;
daxroot = '';
parsroot = '';
method = 'insight';
daxfile = '';
parsfile = '';
dpath = ''; 
verbose = true; 

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
                overwrite = CheckParameter(parameterValue, 'boolean', 'overwrite');
            case 'parsfile'
                parsfile = CheckParameter(parameterValue, 'string', 'parsfile');
            case 'daxfile'
                daxfile  = CheckParameter(parameterValue, 'string', 'daxfile');
            case 'verbose'
                verbose =  CheckParameter(parameterValue, 'boolean', 'daxfile');
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

% ~~~~~~~~~~~~~~~ Set method specific flags ~~~~~~~~~~~~~~~~~~~~~~~
switch method
    case 'insight'
        datatype = '_list.bin'; 
        parstype = '.ini';
        processName = 'InsightM.exe';
    case 'DaoSTORM'
        datatype = '_mlist.bin';
        parstype = '.xml';
        processName = 'mufit_analysis.py';
    case 'GPUmultifit'
        datatype = '_glist.bin';
        parstype = '.mat';
        processName = ''; % GPU scripts can't be launched in batch
    otherwise
        error(['method ',method,' not recognized.  Available methods:',...
            ' insight, DaoSTORM, GPUmultifit.']);
end

% ~~~~~~~~~~~~ check for parameter files ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if isempty(parsfile)
    parsfile = dir([dpath,'*',parsroot, '*',parstype]);
    if length(parsfile) > 1
        error(['Too many ',parstype,...
            ' files in directory.  Please specify specific file.']);
    elseif isempty(parsfile)
        error(['No ',parstype,' file in directory.']);
    end
    parsfile = [dpath, parsfile.name];
end     


%~~~~ Decide if existing data files should be skipped or overwritten ~~~~~%    
% structure containing names of all bin files in folder 
    all_prev_bin = dir([dpath,'\','*',daxroot,'*',datatype]);
    binnames = {all_prev_bin(:).name};
    binroots = regexprep(binnames,datatype,''); % strip off file endings

% index of all dax files which have bin files associated 
    hasbin = sum(cell2mat(cellfun(@(x) strcmp(x,daxroots),...
        binroots,'UniformOutput',false)'));
    
% don't analyze movies which have _list.bin files
if sum(hasbin) ~= 0 
   txtout = ['warning: found existing ',datatype,' data files for ',...
       daxnames(logical(hasbin))];
    if verbose
       disp(char(txtout));
    end
    if overwrite
        disp('these files will be overwritten.  ');
        cont = input('type 1 to continue, 0 to cancel:  ');
        if cont == 1
            % files must be physically deleted to enable a fresh daoSTORM
            % analysis.  
            if strcmp('method','daoSTORM')
                allextra = daxroots(logical(hasbin));
                for a = 1:length(allextra)
                    deletebin = ['del ', allextra(a),datatype];
                    dos(deletebin);
                end
            end
        else
            disp('skipping these movies...'); 
            daxnames(logical(hasbin))=[]; % actually removes from que  
        end
    else
        disp('skipping these movies...'); 
        daxnames(logical(hasbin))=[]; % actually removes from que     
    end
end
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

%~~~~~~~~~~~~~~~~~ Call analysis commands in batch ~~~~~~~~~~~~~~~~~~~~~~~%
Sections = length(daxnames);
for s=1:Sections % loop through all dax movies in que
    daxfile = [dpath,filesep,daxnames{s}];          
    switch method
        case 'insight'
         % display command split up onto multiple lines  
        % Actually launch insightM and poll computer for number of processes
        dos([defaultInsightPath,' ',daxfile,' ',parsfile, ' && exit &']); 
        case 'DaoSTORM'
            k = strfind(defaultMultiFitPath,filesep);
            mufit_folder = defaultMultiFitPath(1:k(end));
            binfile = [dpath,filesep,daxroots{s},datatype];
            dir_setup = ['! cd ',mufit_folder]; 
            ccall = [' ',PythonPath,' ',defaultMultiFitPath,' ',...
                     daxfile,' ',binfile,' ',parsfile];                     
            eval([dir_setup, ' && ', DaoSTORMPathSetup, ' && ', ccall,' && exit &']);          
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

%~~~~~  Regulate number of instances of analysis running in parallel. ~~~~~~~~ 
    if ~isempty(processName)
         [~, result] = dos(['wmic process where (name="',...
             processName,'") list brief']); 
         running = strfind(result,processName);

           % Don't launch more than 'batchsize' number of scripts at once:
           waitT = 0; 
           batchwait = tic;
                while length(running) >= batchsize
                    pause(1); 
                     waitT = waitT + 1; % Process time-out counter
                    % Watch for appearance of completed bin file 
                    [~, result] = dos(['wmic process where (name="',...
                        processName,'") list brief']); 
                    running = strfind(result,processName);  
                end      
           batchwait = toc(batchwait);
           disp(['time elapsed = ',num2str(batchwait/60),' min']); 
    end
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
end

time_run = toc(time_run);
if verbose
disp(['RunDotFinder finished processing ',num2str(Sections),' dax movies',...
    ' Total time=',num2str(time_run/(60*60)),'hours']); 
end
