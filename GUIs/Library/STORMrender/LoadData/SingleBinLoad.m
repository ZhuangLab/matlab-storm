function handles = SingleBinLoad(hObject,eventdata,handles)
% Loads single bin files
global binfile SR 
[pathname,filename] = extractpath(binfile); 
mlist = ReadMasterMoleculeList(binfile);
SR{handles.gui_number}.LoadOps.pathin = pathname;
SR{handles.gui_number}.fnames{1} = filename; 

% Load info file
% strip off final '_mlist.bin _alist.bin _list.bin etc
try 
    k = strfind(filename,'_');  
    infofileName = [pathname,filesep,filename(1:k(end)-1),'.inf'];
    SR{handles.gui_number}.infofile = ReadInfoFile(infofileName);
catch er
    warning(['Unable to read infofile: ',infofileName]);
    disp(er.message); 
    disp(er.getReport);
end

SR{handles.gui_number}.mlist = {mlist}; 
ImSetup(hObject,eventdata, handles);
handles = RunClearFilter(hObject,eventdata,handles);
guidata(hObject, handles);