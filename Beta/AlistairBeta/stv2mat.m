global PythonPath
PythonPath = 'C:\Python27\';
Mosaics = {
   'H:\2013-08-25_AbdA\Mosaic',...
   };


cd(basePath)

for i=1:length(Mosaics)
    Mosaic_folder = Mosaics{i}; 
    Mosaic_folder = regexprep(Mosaic_folder,'\','/'); 
    mosaicName = dir([Mosaic_folder,'/','*.msc']);
    
    stv1 =mosaicName.name; %  'mosaic_352.stv';
    dir([pwd,'\Beta\AlistairBeta\lib\mosaic_to_matlab.py'])

    disp(['Converting folder ',num2str(i),': ',Mosaic_folder]); 
    ccall = [PythonPath,'python.exe ',...
        pwd,'\Beta\AlistairBeta\lib\mosaic_to_matlab.py',...
        ' ',Mosaic_folder,'/',stv1,' &'];

    disp(ccall);
    system(ccall);

end