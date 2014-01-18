 function handles=ClearAllData(hObject,eventdata,handles)
    global SR
     SR{handles.gui_number}.allfnames = [];
     SR{handles.gui_number}.froots = [];
     SR{handles.gui_number}.bins = [];
     handles=ClearCurrentData(hObject,eventdata,handles);