function SetWorkingDir(hObject, eventdata, handles)
% Executes on Menu selection: Set Working Dir
% hObject    handle to MenuSetWorkingDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global CC
CC{handles.gui_number}.source = uigetdir;
set(handles.SourceFolder,'String',CC{handles.gui_number}.source);
SourceFolder_Callback(hObject, eventdata, handles);