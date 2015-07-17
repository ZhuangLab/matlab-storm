function mList = MovieToMlist(dax,varargin)

% global parameters
global scratchPath;
global insightExe; % System executable command for Insight
global daoSTORMexe; % System executable command for 3d DaoSTORM
global defaultXmlFile; % path and name of default DaoSTORM parameters
global defaultIniFile;  % path and name of default insight parameters


 insightFullName = {
            'min height=',...
            'max height=',...
            'default background=',...
            'min width=',...
            'max width=',...
            'default width=',...
            'axial ratio tolerance=',...
            'Fit ROI=',...
            'displacement=',...
            'start frame='...
            'allow drift=',...
            'number of molecules in each correlation time step (XY)=',...
            'number of molecules in each correlation time step (Z)=',...
            'minimum time step size (frame)=',...
            'maximum time step size (frame)=',...
            'xy grid size (nm) in xy correlation=',...
            'xy grid size (nm) in z correlation=',...
            'points for moving average in generating drift correlation (XY)=',...
            'points for moving average in generating drift correlation (Z)=',...
            'z method=',...
            'z calibration expression=',...
            'z calibration outlier rejection percentile=',...
            'z calibration start=',...
            'z calibration end=',...
            'z calibration step=',...
            'ROI Valid=',...
            'ROI_x0=',...
            'ROI_x1=',...
            'ROI_y0=',...
            'ROI_y1=',...
            };

 insightPars = {'minheight','maxheight','bkd','minwidth','maxwidth',...
                'initwidth','maxaxratio','fitROI','displacement','startFrame','CorDrift',...
                'xymols','zmols','minframes','maxframes','xygridxy','xygridz',...
                'movAxy','movAz','Fit3D','zcaltxt','zop','zstart','zend','zstep',...
                'useROI','xmin','xmax','ymin','ymax'};
 
daostormFullName = {
         '<model type="string">',...    method
        '<threshold type="float">'...  threshold
        '<iterations type="int">',...  maxits
        '<baseline type="float">',...   bkd
        '<pixel_size type="float">',... ppnm
        '<sigma type="float">',...      initwidth
        '<descriptor type="string">',... descriptor
        '<radius type="float">',...  displacement
        '<start_frame type="int">',... startFrame
        '<max_frame type="int">',... endFrame
        '<drift_correction type="int">',... %  CorDrift
        '<frame_step type="int">',... dframes
        '<d_scale type="int">',...dscales
        '<do_zfit type="int">',... Fit3D
        '<cutoff type="float">',... zcutoff
        '<min_z type="float">',...  zstart 
        '<max_z type="float">',...  zend
        '<wx_wo type="float">',...  wx0
        '<wx_c type="float">',...  gx
        '<wx_d type="float">',...  zrx
        '<wxA type="float">',...  Ax
        '<wxB type="float">',... Bx
        '<wxC type="float">',...  Cx
        '<wxD type="float">',...  Dx
        '<wy_wo type="float">',...  wy0
        '<wy_c type="float">',...  gy
        '<wy_d type="float">',...  zry
        '<wyA type="float">',...  Ay
        '<wyB type="float">',...  By
        '<wyC type="float">',...  Cy
        '<wyD type="float">',...  Dy
        '<x_start type="int">',... xmin
        '<x_stop type="int">',... xmax
        '<y_start type="int">',... ymin
        '<y_stop type="int">',... ymax
        };
        
  daostormPars = {'method','threshold','maxits','bkd','ppnm','initwidth',...
  'descriptor','displacement','startFrame','endFrame','CorDrift',...
  'dframes','dscale','Fit3D','zcutoff','zstart','zend','wx0','gx',...
  'zrx','Ax','Bx','Cx','Dx','wy0','gy','zry','Ay','By','Cy','Dy',...
  'xmin','xmax','ymin','ymax'};
            
% default parameters
defaults = cell(0,3);
defaults(end+1,:) = {'fitMethod','integer',2};
defaults(end+1,:) = {'insightPars',insightPars,''};
defaults(end+1,:) = {'insightValues','freeType',[]};
defaults(end+1,:) = {'daostormPars',daostormPars,''};
defaults(end+1,:) = {'daostormValues','freeType',[]};
defaults(end+1,:) = {'xmlFile', 'string', defaultXmlFile}; %  defaultXmlFile
defaults(end+1,:) = {'iniFile', 'string', defaultIniFile}; % defaultIniFile
parameters = ParseVariableArguments(varargin, defaults, mfilename);

infoFile = WriteDax(dax);
daxName = [infoFile.localPath,filesep,regexprep(infoFile.localName,'\.inf','\.dax')];
%%



% insight

% daostorm


%%
if parameters.fitMethod == 1 % InsightM  
    if length(parameters.insightPars) ~= length(parameters.insightValues)
        error('must provide equal number of insight parameters and parameter values');
    end
    parfile = [scratchPath,'tempPars.ini']; % new file name to save
    parIdx = StringFind(insightPars,parameters.insightPars); % determine which parameter was asked for 
    parNames = insightFullName(parIdx); 
    modify_script(parameters.iniFile,parfile,parNames,parameters.insightValues,'');  
    
    if isempty(insightExe)
        error(['insightExe not found.  ',...
            'Please set the global variable insightExe ',...
            'to specify the location of insightM.exe in the ',...
            'Insight3 folder on your computer.']);
    end
    insight = insightExe; 
    
    
    % call insight 
    ccall = ['!', insight,' "',daxName,'" ',...
        ' "',parfile,'" ',...
        ' "',parfile,'" '];
    disp(ccall); 
    eval(ccall); 
    binfile = regexprep(daxName,'\.dax','_list.bin');


elseif  parameters.fitMethod == 2  
    if length(parameters.daostormPars) ~= length(parameters.daostormValues)
        error('must provide equal number of insight parameters and parameter values');
    end
    parfile = [scratchPath,'tempPars.xml'];
    parIdx = StringFind(daostormPars,parameters.daostormPars); % determine which parameter was asked for 
    parNames = daostormFullName(parIdx); 
    modify_script(parameters.xmlFile,parfile,parNames,parameters.daostormValues,'<');
    
    if isempty(daoSTORMexe)
        error(['daoSTORMexe not found.  ',...
            'Please set the global variable daoSTORMexe ',...
            'to specify the location of mufit_analysis.py in the ',...
            'DaoSTORM folder on your computer and its dll paths.',...
            'See startup_example in \Templates folder']);
    end                     
    % need to delete any existing bin menufile before we overwrite, or
    % DaoSTORM tries to pick up analysis where it left off.  
     binfile = regexprep(daxName,'\.dax','_mlist.bin');
     if exist(binfile,'file')
        delete(binfile);
     end    
    % Call DaoSTORM.    
    disp('locating dots by DaoSTORM');
    ccall = [daoSTORMexe,' "',daxName,'" "',binfile,'" "',parfile,'"'];
    disp(ccall);
    disp(daxName);
    disp(binfile);
    disp(parfile);
    system(ccall);
end

mList = ReadMasterMoleculeList(binfile); 