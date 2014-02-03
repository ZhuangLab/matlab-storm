function WriteParsTxt(binfile,parsfile)
% write a ParsTxt file which records the parameter file (parsfile) used to
% analyze the current daxfile. 

if strcmp(parsfile(end-3:end),'.xml')
    datatype = '_mlist.bin';
elseif strcmp(parsfile(end-3:end),'.ini')
    datatype = '_list.bin';
else
    error([parsfile,' is not a recongized parameter file']); 
end
       
% Record parameter file used in the infofile notes.  
binparstype = regexprep(datatype,'\.bin','\_pars.txt'); 
binparsfile = regexprep(binfile,datatype,binparstype);
txtOut = {['parameters used = ',parsfile];
          ['binfile = ',binfile]};

fid = fopen(binparsfile,'w+');
for i=1:length(txtOut)
  str = regexprep(txtOut{i},'\\','\\\'); % convert \ to \\.  
  fprintf(fid,str,''); 
  fprintf(fid,'%s\r\n','');
end
fclose(fid);