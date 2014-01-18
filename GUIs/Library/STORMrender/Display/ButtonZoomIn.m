function ButtonZoomIn(hObject, eventdata, handles)
% Zoom in 2x on STORMrender window

global SR
imaxes = SR{handles.gui_number}.imaxes;
imaxes.zm = imaxes.zm*2; 
if imaxes.zm > 128
    imaxes.zm = 128;
    disp('max zoom reached...');
end
SR{handles.gui_number}.imaxes = imaxes;
set(handles.displayzm,'String',num2str(imaxes.zm,2));
ImLoad(hObject,eventdata, handles);
guidata(hObject, handles);