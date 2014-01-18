function RunYslider(hObject,eventdata,handles)
global SR
imaxes = SR{handles.gui_number}.imaxes;
imaxes.cy = imaxes.H - get(handles.Yslider,'Value');
% imaxes.cy = imaxes.ymax - get(handles.Yslider,'Value')+imaxes.ymin;
SR{handles.gui_number}.imaxes = imaxes;
ImLoad(hObject,eventdata, handles);
guidata(hObject, handles);