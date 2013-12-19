function uiopen(type,direct)
% UIOPEN overloaded for custom Files. Do not change the file name of this
% file. Remember you are overloading uiopen inside toolbox/matlab/uitools
%

global myImage daxfile inffile inifile xmlfile mlist binfile
warning off all
%---- dax file -----v
if ((~isempty(findstr(type,'.dax'))) && (direct))
    %-------------------------------------------------
    % Your function that will open/run this file type
    %-------------------------------------------------
    disp('reading dax file into global var "daxfile"...');
    disp(type);
     daxfile = type;
     inffile = regexprep(type,'.dax','.inf');  
    if ~isempty(daxfile)
       OpenNew = input('Open in new instance of STORMfinder? 1=yes, 0=no:  ');
       if OpenNew ==1
            STORMfinder;      
       end
    end
    
%---- ini file -----v
elseif ((~isempty(findstr(type,'.ini'))) && (direct))
    %-------------------------------------------------
    % Your function that will open/run this file type
    %-------------------------------------------------
    disp('reading ini file into global var "inifile"...');
    disp(type);
    inifile = type;
 
%---- xml file -----v
elseif ((~isempty(findstr(type,'.xml'))) && (direct))
    %-------------------------------------------------
    % Your function that will open/run this file type
    %-------------------------------------------------
    disp('reading xml file into global var "xmlfile"...');
    disp(type);
    xmlfile = type;

elseif  ((~isempty(findstr(type,'.bin'))) && (direct))
    disp(type);
    binfile = type;
    dispresults = input('display image in STORMrenderer? 1=yes, 0=no:  ');
    if dispresults
        STORMrender;
    else
        disp(['reading ',binfile,' into mlist']); 
        mlist = ReadMasterMoleculeList(binfile);
    end
    
%---- tif file -----v
elseif ((~isempty(findstr(type,'.tif'))) && (direct))
    %-------------------------------------------------
    % Your function that will open/run this file type
    %-------------------------------------------------
    disp('reading tif file into global var "myImage"...');
    myImage = imread(type);
    figure; imagesc(myImage);
    % TiffViewer;  % not yet out of Beta
    %-------------------------------------------------
    
else
  % %   Matlab gets confused by finding these function names
    %----------DO NOT CHANGE---------------------------
warning off all
    presentPWD = pwd;
    cd([matlabroot '/toolbox/matlab/uitools']);
    strn = ['uiopen(''' type ''',' num2str(direct) ')'];
    eval(strn);
    cd(presentPWD);
    %----------DO NOT CHANGE---------------------------
end
warning on all
%-------------------------------------------------------------------------