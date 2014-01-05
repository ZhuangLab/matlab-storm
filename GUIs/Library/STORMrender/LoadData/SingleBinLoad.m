function handles = SingleBinLoad(hObject,eventdata,handles)
% Loads single bin files
global binfile SR 
[pathname,filename] = extractpath(binfile); 
disp('reading binfile...');
SR{handles.gui_number}.mlist{1} = ReadMasterMoleculeList(binfile);
SR{handles.gui_number}.LoadOps.pathin = pathname;
SR{handles.gui_number}.fnames{1} = filename; 
disp('file loaded'); 

k = strfind(filename,'_');
SR{handles.gui_number}.infofile = ReadInfoFile(...
    [pathname,filesep,filename(1:k(end)-1),'.inf']);
disp('setting up image options...');
ImSetup(hObject,eventdata, handles);
disp('drawing data...');

handles = RunClearFilter(hObject, eventdata, handles); 
% ClearFilters_Callback(hObject, eventdata, handles); 
guidata(hObject, handles);