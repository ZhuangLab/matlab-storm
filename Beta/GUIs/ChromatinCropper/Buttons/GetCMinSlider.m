function GetCMinSlider(hObject, eventdata, handles)
% --- Executes on CMinSlider movement.
% hObject    handle to CMinSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global CC
sliderValue = get(hObject,'Value');

channels = false(1,2); % Storm Channels
for c = 1:2; 
    channels(c) = eval(['get(','handles.AdjustChn',num2str(c),', ','''Value''',')']);
end

CC{handles.gui_number}.pars0.cmin(channels) = sliderValue;
if CC{handles.gui_number}.step > 4
    axes(handles.subaxis2); cla;
    ShowSTORM(handles,CC{handles.gui_number}.dotnum);
end