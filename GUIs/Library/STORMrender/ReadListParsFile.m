function parsfile = ReadListParsFile(binfile)
%-------------------------------------------------------------------------
% parsfile = ReadListParsFile(binfile) searches for a _pars.txt file
% associated with the passed binfile, which records the name of the
% parameter file used to analyze the daxfile which produced this binfile.  
%
%-------------------------------------------------------------------------
% Alistair Boettiger

%% To become optional parameters
verbose = true;

%% Main Function

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