function handles = UpdateSliders(hObject,eventdata,handles)
% Update slider positions as field of view changes

global SR
imaxes = SR{handles.gui_number}.imaxes;
handles = guidata(hObject);
set(handles.Xslider,'Value',imaxes.cx);
set(handles.Yslider,'Value',imaxes.ymax-imaxes.cy+imaxes.ymin);
set(handles.Xslider,'Min',imaxes.xmin);
set(handles.Xslider,'Max',imaxes.xmax);
set(handles.Yslider,'Min',imaxes.ymin);
set(handles.Yslider,'Max',imaxes.ymax);
SR{handles.gui_number}.imaxes = imaxes;
handles = UpdateNavigator(hObject,handles);
guidata(hObject, handles);