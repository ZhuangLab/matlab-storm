function RunAutoContrast(hObject, eventdata, handles)
% Auto contrast image

global SR
    Cs = length(SR{handles.gui_number}.mlist);
    for c=1:Cs
        SR{handles.gui_number}.cmax(c) = .9;
        SR{handles.gui_number}.cmin(c) = 0;
    end
UpdateMainDisplay(hObject,handles);
guidata(hObject, handles);
