function GetDotNum(hObject, eventdata, handles)
% --- Executes when DotNum Edit text is updated
% hObject    handle to AutoCycle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global CC
CC{handles.gui_number}.dotnum = str2double(get(handles.DotNum,'String'));
try
    set(handles.DotSlider,'Value',CC{handles.gui_number}.dotnum);
    guidata(hObject,handles); 
    GetDotSlider(hObject, eventdata, handles); 
catch er
    disp(er.message);
    warning('value out of range.');
end
guidata(hObject,handles); 
