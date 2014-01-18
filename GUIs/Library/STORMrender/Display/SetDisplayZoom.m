function SetDisplayZoom(hObject, eventdata, handles)
% Sets STORMrender zoom to user selected value

global SR
imaxes = SR{handles.gui_number}.imaxes;
imaxes.zm = str2double(get(handles.displayzm,'String')); 
if imaxes.zm <= 1
    imaxes.zm = 1; % all the way out
    imaxes.cx = imaxes.W/2; % recenter
    imaxes.cy = imaxes.H/2;
end
set(handles.displayzm,'String',num2str(imaxes.zm,2));
SR{handles.gui_number}.imaxes = imaxes;
guidata(hObject, handles);
UpdateSliders(hObject,eventdata,handles);
ImLoad(hObject,eventdata, handles);
guidata(hObject, handles);
