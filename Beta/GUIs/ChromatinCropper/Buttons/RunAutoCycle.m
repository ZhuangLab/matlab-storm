function RunAutoCycle(hObject, eventdata, handles)
% --- Executes on button press in AutoCycle.
% hObject    handle to AutoCycle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global CC
CC{handles.gui_number}.auto = true; 
currImage = CC{handles.gui_number}.imnum;
dat = dir([handles.Source,filesep,'*_alist.bin']);
Nfiles = length(dat); 
for n=currImage:Nfiles
    disp(['Analyzing image ',num2str(1),' of ',num2str(Nfiles),' ',...
        dat.Name]); 
    for step = 1:7
        CC{handles.gui_number}.step = step;
        RunRunStep(hObject, eventdata, handles);
    end
    RunNextImage(hObject, eventdata, handles)
end
CC{handles.gui_number}.auto = false; 
