function GetDotSlider(hObject, eventdata, handles)
% --- Executes on DotSlider movement.
% hObject    handle to DotSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global CC
if CC{handles.gui_number}.step == 5
    n = round(get(handles.DotSlider,'Value'));
    set(handles.DotNum,'String',num2str(n));
    CC{handles.gui_number}.dotnum = n;
    ChromatinPlots(handles, n);
end
if CC{handles.gui_number}.step == 6
    n = round(get(handles.DotSlider,'Value'));
    set(handles.DotNum,'String',num2str(n));
    CC{handles.gui_number}.dotnum = n;
    FilterChromatinClusters(handles); 
end
guidata(hObject,handles); 