function RunNextStep(hObject, eventdata, handles)
% --- Executes on button press in NextStep.
% hObject    handle to NextStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global CC
Dirs = CC{handles.gui_number}.Dirs;
CC{handles.gui_number}.step = CC{handles.gui_number}.step +1;
step = CC{handles.gui_number}.step;
if step>6
    RunNextImage(hObject, eventdata, handles);
    step = 1;
end
set(handles.DirectionsBox,'String',Dirs{step});
guidata(hObject,handles);