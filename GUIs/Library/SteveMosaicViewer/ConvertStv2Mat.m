function ConvertStv2Mat
% convert all .stv files to .mat files so they can be read.
% if files have already been converted, do nothing. 

global PythonPath matlabStormPath stvfile

mosaic_to_matlab =[matlabStormPath,'\GUIs\Library\STORMrender\mosaic_to_matlab.py'];
runLocation = ''; %  Local
% runLocation = ' &'; % External

mosaicFolder = [fileparts(stvfile),'/'];
mosaicFolder = regexprep(mosaicFolder,'\','/'); % python prefers linux slashes 
mosaicName = dir([mosaicFolder,'/','*.msc']);

stvFiles = dir([mosaicFolder,'*.stv']);
matFiles = dir([mosaicFolder,'*.mat']); 

if isempty(stvFiles)
    disp('no .stv files found in folder');
    disp(mosaicFolder);
end

if length(matFiles) < length(stvFiles);
    stv1 =mosaicName.name; %  'mosaic_352.stv';
    dir(mosaic_to_matlab)

    ccall = [PythonPath,'python.exe ',...
        mosaic_to_matlab,...
        ' ',mosaicFolder,'/',stv1,runLocation];

    disp(ccall);
    system(ccall);
end

