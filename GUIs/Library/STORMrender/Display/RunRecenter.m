
function handles = RunRecenter(hObject, eventdata, handles)
global SR
imaxes = SR{handles.gui_number}.imaxes;
handles = guidata(hObject);
axes(handles.axes2); 
[x,y] = ginput(1); % these are relative to the current frame
xim = imaxes.xmin + x/imaxes.scale/imaxes.zm;
yim = imaxes.ymin + y/imaxes.scale/imaxes.zm;
imaxes.cx = xim;  % these are relative to the whole image
imaxes.cy = yim;
SR{handles.gui_number}.imaxes = imaxes;
guidata(hObject, handles);
ImLoad(hObject,eventdata, handles);
guidata(hObject, handles);
