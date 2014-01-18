function RunBackStep(hObject, eventdata, handles)
% --- Executes on button press in BackStep.
% hObject    handle to BackStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CC
Dirs = CC{handles.gui_number}.Dirs;
CC{handles.gui_number}.step = CC{handles.gui_number}.step -1;
step = CC{handles.gui_number}.step;
set(handles.DirectionsBox,'String',Dirs{step});
guidata(hObject,handles); 