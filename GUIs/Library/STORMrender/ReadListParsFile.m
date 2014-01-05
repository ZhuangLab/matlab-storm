function parsfile = ReadListParsFile(binfile,varargin)
%-------------------------------------------------------------------------
% parsfile = ReadListParsFile(binfile)
%                                       searches for a _pars.txt file
% associated with the passed binfile, which records the name of the
% parameter file used to analyze the daxfile which produced this binfile.  
%
%-------------------------------------------------------------------------
% Alistair Boettiger

%--------------------------------------------------------------------------
% Default optional parameters
%--------------------------------------------------------------------------
verbose = true;

%--------------------------------------------------------------------------
% Parse Variable Input Parameters
%--------------------------------------------------------------------------
if nargin < 1
   error([mfilename,' expects inputs: cell of binnames, cell of channels, and string to a chromewarps.mat warp file']);
end
if nargin > 1
    if (mod(length(varargin), 2) ~= 0 ),
        error(['Extra Parameters passed to the function ''' mfilename ''' must be passed in pairs.']);
    end
    parameterCount = length(varargin)/2;
    for parameterIndex = 1:parameterCount,
        parameterName = varargin{parameterIndex*2 - 1};
        parameterValue = varargin{parameterIndex*2};
        switch parameterName    
            case 'verbose'
                verbose = CheckParameter(parameterValue,'boolean','verbose');                
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end

%--------------------------------------------------------------------------
%% Main Function
%--------------------------------------------------------------------------
binfile = regexprep(binfile,'alist','mlist'); % for DaoSTORM
listpars = regexprep(binfile,'.bin','_pars.txt');
if exist(listpars,'file') == 2
    fid = fopen(listpars);
    T = textscan(fid,'%s','Delimiter','\n');
    T = T{1}{1}; 
    fclose(fid); 
    eqsym = strfind(T,'=');
    parsfile = strtrim(T(eqsym+1:end));
else
    parsfile = '';
    if verbose
        disp(['no _pars.txt file found for ',binfile]);
    end
end