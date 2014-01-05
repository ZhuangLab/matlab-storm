function RunSaveImage(handles)
% saves a tif image of the curent field of view in STORMrender

global SR
Io = SR{handles.gui_number}.Io;
if ~isfield(SR{handles.gui_number},'savepath')
    SR{handles.gui_number}.savepath = '';    
end
savepath=SR{handles.gui_number}.savepath;

if ischar(savepath)
    [savename,savepath] = uiputfile(savepath);
else
    [savename,savepath] = uiputfile;
end
if savename ~= 0
    imwrite(Io,[savepath,filesep,savename,'.tif']); 
    disp(['wrote ', savepath,filesep,savename,'.tif']);
end