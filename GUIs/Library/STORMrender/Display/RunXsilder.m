function RunXsilder(hObject,eventdata,handles)
global SR
SR{handles.gui_number}.imaxes.cx = get(handles.Xslider,'Value');
ImLoad(hObject,eventdata, handles);
guidata(hObject, handles);
