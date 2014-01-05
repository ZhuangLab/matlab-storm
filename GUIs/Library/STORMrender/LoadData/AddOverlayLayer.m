function handles = AddOverlayLayer(hObject,handles,overlay_number,oname)
        % Adds a new radio button to the OverlayPanel, which can toggle this
        % channel on and off.  
    global SR
    
    
verbose = SR{handles.gui_number}.DisplayOps.verbose;
if verbose
disp(['Adding New Overlay ',num2str(overlay_number)]);
end

% Make button visible
buttonName = ['handles.oLayer',num2str(overlay_number)];
makeVisible = ['set(',buttonName,', ','''Visible''',', ','''on''',')'];
buttonPress = ['set(',buttonName,', ','''Value''',', ','true',')'];
updateName =  ['set(',buttonName,', ','''String''',', ','''',oname,'''',')'];
eval(makeVisible); 
eval(buttonPress); 
eval(updateName); 
guidata(hObject, handles);

SR{handles.gui_number}.OverlayNames{overlay_number} = oname;  

% update levels
N_stormlayers = length(SR{handles.gui_number}.cmax);
levelsNames = get(handles.LevelsChannel,'String');
levelsNames{N_stormlayers+overlay_number} = oname;
set(handles.LevelsChannel,'String',levelsNames);