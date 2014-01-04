function SpecifyOverlays(handles)

global CC
sourcefolder = CC{handles.gui_number}.source; 
[fileNames,filePath,notCancel] = uigetfile('*.dax','select conventional images',...
    sourcefolder,'MultiSelect','on');
if notCancel
overlays = cell(length(fileNames),1);
for i = 1:length(fileNames)
    overlays{i} = [filePath,filesep,fileNames{i}];
end
    CC{handles.gui_number}.pars1.overlays = overlays; 
end