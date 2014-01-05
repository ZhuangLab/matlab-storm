function RunManualContrast(hObject, eventdata, handles)
% takes user input to contrast image

global SR
SR{handles.gui_number}.cmax = input('enter a vector for max intensity for each channel: ');
SR{handles.gui_number}.cmin = input('enter a vector for min intensity for each channel: ');
UpdateMainDisplay(hObject,handles);
guidata(hObject, handles);
