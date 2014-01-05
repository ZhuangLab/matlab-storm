function handles = RunLevelsChannel(hObject,eventdata,handles)
global SR
N_stormchannels = length(SR{handles.gui_number}.cmax);
selected_channel = get(handles.LevelsChannel,'Value');
if selected_channel <= N_stormchannels
% Set slider positions and values to the current selected channel
    minin = SR{handles.gui_number}.cmin(selected_channel);
    maxin = SR{handles.gui_number}.cmax(selected_channel);
else
    minin = SR{handles.gui_number}.omin(selected_channel - N_stormchannels);
    maxin = SR{handles.gui_number}.omax(selected_channel - N_stormchannels);    
end
set(handles.MaxIntSlider,'Value',minin);
set(handles.MaxIntBox,'String',num2str(minin));
set(handles.MaxIntSlider,'Value',maxin);
set(handles.MaxIntBox,'String',num2str(maxin));
 