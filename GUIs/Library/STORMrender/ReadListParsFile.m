
function parsfile = ReadListParsFile(binfile)

verbose = true;


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