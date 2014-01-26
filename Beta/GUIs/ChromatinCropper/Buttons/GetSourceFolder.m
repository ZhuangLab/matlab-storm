function GetSourceFolder(hObject, eventdata, handles)
% Executes when Source Folder Edit-text is updated
% hObject    handle to SourceFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global CC
CC{handles.gui_number}.step = 1;
CC{handles.gui_number}.source = get(handles.SourceFolder,'String');
CC{handles.gui_number}.binfiles = ...
         dir([CC{handles.gui_number}.source,filesep,'*_alist.bin']);
set(handles.DirectionsBox,'String',CC{handles.gui_number}.Dirs{1});
CC{handles.gui_number}.imnum = 1;
if isempty(CC{handles.gui_number}.binfiles)
 error(['error, no alist.bin files found in folder ',...
     CC{handles.gui_number}.source]);
end
binfile = CC{handles.gui_number}.binfiles(CC{handles.gui_number}.imnum);    
set(handles.ImageBox,'String',binfile.name);

RunStepParameters(hObject, eventdata, handles)
RunRunStep(hObject, eventdata, handles)

% Clear current data
cleardata = input('New folder selected.  Clear current data? y/n? ','s');
if strcmp(cleardata,'y');
     ResetCCdata(handles);
     CC{handles.gui_number}.pars7.saveroot ='';
     disp('data cleared'); 
end