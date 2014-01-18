function RunMenuViewMosaic(hObject, eventdata, handles)
global  SR
if ~isfield(SR{handles.gui_number}, 'Mosaicfolder')
    SR{handles.gui_number}.Mosaicfolder = [];
end
infofile = SR{handles.gui_number}.infofile;
if isempty(SR{handles.gui_number}.Mosaicfolder)
    SR{handles.gui_number}.Mosaicfolder = [infofile.localPath,filesep,'..',filesep,'Mosaic'];
    if ~exist(SR{handles.gui_number}.Mosaicfolder,'dir')
        SR{handles.gui_number}.Mosaicfolder = uigetdir(infofile.localPath);
    end
end    
position = [infofile.Stage_X,infofile.Stage_Y];


try
    figure;
    viewSteveMosaic(SR{handles.gui_number}.Mosaicfolder,position,'showbox',true,'Ntiles',100);
catch er
    disp(er.message); 
    disp('trying old MosaicViewer...');
    MosaicViewer(SR{handles.gui_number}.Mosaicfolder,position,'showbox',true,'Ntiles',6);
    figure;
    MosaicViewer(SR{handles.gui_number}.Mosaicfolder,position,'showbox',true,'Ntiles',36);
end