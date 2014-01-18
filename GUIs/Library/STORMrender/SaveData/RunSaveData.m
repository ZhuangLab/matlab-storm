function RunSaveData(hObject, eventdata, handles)
% save Data from current field of view in STORMrender (.mat file)
% also saves a PNG of the current view

global SR  

I = SR{handles.gui_number}.I;
Io = SR{handles.gui_number}.Io;
Oz = SR{handles.gui_number}.Oz; 
if ~isfield(SR{handles.gui_number},'savepath')
    SR{handles.gui_number}.savepath = '';    
end
savepath=SR{handles.gui_number}.savepath;
vlist = MolsInView(handles); %#ok<NASGU>

try
[savename,savepath] = uiputfile(savepath);
catch %#ok<CTCH>
    disp(['unable to open savepath ',savepath]);
    [savename,savepath] = uiputfile;
end
SR{handles.gui_number}.savepath = savepath;

% strip extra file endings, the script will put these on appropriately. 
k = strfind(savename,'.');
if ~isempty(k)
    savename = savename(1:k-1); 
end

if isempty(I) || isempty(SR{handles.gui_number}.cmax) || isempty(SR{handles.gui_number}.cmin)
    disp('no image data to save');
end
if isempty(Oz)
    disp('no overlay(s) to save');
end

if savename ~= 0 % save was not 'canceled'
    fnames = SR{handles.gui_number}.fnames; %#ok<NASGU>
    save([savepath,filesep,savename,'.mat'],'vlist','I','Oz','fnames');
    disp([savepath,filesep,savename,'.mat' ' saved successfully']);
    imwrite(Io,[savepath,filesep,savename,'.png']); 
    disp(['wrote ', savepath,filesep,savename,'.png']);
end