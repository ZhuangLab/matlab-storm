function RunRunStep(hObject, eventdata, handles)
% --- Executes on button press in RunStep.
% hObject    handle to RunStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% global parameters
global CC ScratchPath %#ok<*NUSED>
   
% Actual Step Commands
step = CC{handles.gui_number}.step;
if step == 1
    handles = LoadConv(handles);   
elseif step == 2
   handles = ConvMask(handles);       
elseif step == 3
    handles = StormMask(handles); 
elseif step == 4  
    handles = CropperDriftCorrection(handles);
elseif step == 5
    handles = FindChromatinClusters(handles);
elseif step == 6
    handles = FilterChromatinClusters(handles);
elseif step == 7
    handles = SaveChromatinClusters(handles); 
end 
% Update handles structure
guidata(hObject, handles);

