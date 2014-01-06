function RunStepParameters(hObject, eventdata, handles)
% --- Executes on button press in StepParameters.
% hObject    handle to StepParameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global CC
step = CC{handles.gui_number}.step;

% parameters get updated in the CC structure array
if step == 1
  GetParsLoadConv(handles); % just loading the image
  
elseif step == 2
    GetParsConvMask(handles);
    
elseif step == 3
    GetParsStormMask(handles);
    
elseif step == 4
    GetParsCropperDrift(handles);

elseif step == 5
    GetParsFindChromatin(handles);
    
elseif step == 6
    GetParsFilterChromatin(handles) 
    
elseif step == 7
    GetParsSaveChromatin(handles)
end