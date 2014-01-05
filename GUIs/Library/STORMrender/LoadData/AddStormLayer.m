function handles = AddStormLayer(hObject,handles,Sname,layer_number)
        % Adds a new radio button to the STORM layer, which can toggle this
        % channel on and off.  
global SR scratchPath  %#ok<NUSED>

verbose = SR{handles.gui_number}.DisplayOps.verbose;
if verbose
disp(['Adding New STORM layer ',num2str(layer_number)]);
end

% Make button visible
buttonName = ['handles.sLayer',num2str(layer_number)];
makeVisible = ['set(',buttonName,', ','''Visible''',', ','''on''',')'];
buttonPress = ['set(',buttonName,', ','''Value''',', ','true',')'];
updateName =  ['set(',buttonName,', ','''String''',', ','''',Sname,'''',')'];
eval(makeVisible); 
eval(buttonPress); 
eval(updateName); 
guidata(hObject, handles);

% update levels
LevelsNames = get(handles.LevelsChannel,'String');
LevelsNames{layer_number} = Sname;
set(handles.LevelsChannel,'String',LevelsNames);   
SR{handles.gui_number}.cmin(layer_number) = 0;
SR{handles.gui_number}.cmax(layer_number) = .7; 
