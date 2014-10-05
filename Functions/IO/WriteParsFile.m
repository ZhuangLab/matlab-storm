function WriteParsFile(parsfile,fitPars,varargin)
% WriteParsFile('C:/example.xml',fitPars)
% 
% 


global defaultIniFile defaultXmlFile 

[~,~,parsType] = fileparts(parsfile);
parsType = regexprep(parsType,'\.','');

if strcmp(parsType,'ini')
    parameterNames = IniParameterNames;
    newValues = struct2cell(fitPars)';
    modify_script(defaultIniFile,parsfile,parameterNames,newValues,'');   
elseif strcmp(parsType,'xml')
    parameterNames = DaoParameterNames;
    newValues = struct2cell(fitPars)';
    modify_script(defaultXmlFile,parsfile,parameterNames,newValues,'<')
else
    disp(['Parameter type ',parsType,' is not a recongized parameter file type']);
end