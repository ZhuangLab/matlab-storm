function ExportVlist(vlist,savename)
% write a binfile and info file for the indicated molecule list

% global phData
% savePath = [phData,'2014-01-30_images\'];

global defaultXmlFile defaultIniFile

verbose = true;



[savePath,saveFile] = extractpath(savename);
saveFile = regexprep(saveFile,{'_list.bin','_alist.bin','_mlist.bin'},''); 

fmt = 'list.bin';

% Getting the names of all the necessary fields 
fieldNames = {'x','y','xc','yc','h','a','w','phi','ax','bg','i','c','density',...
    'frame','length','link','z','zc'};
fieldTypes = {'single','single','single','single','single','single','single',...
    'single','single','single','single','int32','int32','int32','int32',...
    'int32','single','single','single'};
daoParameters = DaoParameterNames;
iniParameters = IniParameterNames;

numChns = 1;
if iscell(vlist)
    numChns = length(vlist);
    chns = cellstr(num2str( (1:numChns)' ));
    chnNames = strcat('_chn',chns);
else
    vlist = {vlist};
    chnNames = ''; 
end


% Get image boundaries
xmin = inf; xmax = 0; ymin = inf; ymax = 0; 
for n=1:numChns
    xmin =  min([vlist{n}.xc; xmin]) ;
    xmax =  max([vlist{n}.xc; xmax]) ;
    ymin =  min([vlist{n}.yc; ymin]) ;
    ymax =  max([vlist{n}.yc; ymax]) ;
end
% xmin = uint16(xmin); xmax = uint16(xmax);
% ymin = uint16(ymin); ymax = uint16(ymax); 

for n=1:numChns  % n = 2
    vlistOut = vlist{n};
    % Ensure the structure contains all the necessary fields.  
    for i=1:length(fieldNames)
        if ~isfield(vlistOut,fieldNames{i})
            vlistOut.(fieldNames{i}) = zeros(length(vlistOut.x),1,fieldTypes{i});
        end
    end
    
    if strcmp(fmt,'list.bin')
        binfile = [savePath,saveFile,chnNames{n},'_list.bin'];
        parsfile = [savePath,saveFile,chnNames{n},'.ini'];
        modify_script(defaultIniFile,parsfile,...
            iniParameters(26:30),{'1',xmin,xmax,ymin,ymax},'verbose',verbose);
        WriteMoleculeList(vlistOut,binfile);

    elseif strcmp(fmt,'alist.bin');
        binfile = [savePath,saveFile,chnNames{n},'_alist.bin'];
        parsfile = [savePath,saveFile,chnNames{n},'.xml'];
         modify_script(defaultXmlFile,parsfile,...
            daoParameters(32:35),{xmin,xmax,ymin,ymax},'verbose',verbose);
        WriteMoleculeList(vlistOut,binfile);
    end
    WriteParsTxt(binfile,parsfile);
    
end



% Write pars.txt and ROI  file



