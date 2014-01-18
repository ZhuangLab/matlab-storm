function RunNextImage(hObject, eventdata, handles)
% --- Executes on button press in NextImage.
% hObject    handle to NextImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global CC
Nbins = length(CC{handles.gui_number}.binfiles);
CC{handles.gui_number}.imnum = CC{handles.gui_number}.imnum + 1;
if CC{handles.gui_number}.imnum <= 0
    CC{handles.gui_number}.imnum = 1;
end
if CC{handles.gui_number}.imnum > Nbins
    CC{handles.gui_number}.imnum = Nbins;
end

% Remove manually selected overlays 
CC{handles.gui_number}.pars1.overlays = {};

binfile = CC{handles.gui_number}.binfiles(CC{handles.gui_number}.imnum);    
set(handles.ImageBox,'String',binfile.name);
CC{handles.gui_number}.step = 1;
set(handles.DirectionsBox,'String',CC{handles.gui_number}.Dirs{1});
guidata(hObject,handles); 
RunRunStep(hObject, eventdata, handles);
