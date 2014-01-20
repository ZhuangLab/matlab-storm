function handles = QuickLoad(hObject,eventdata,handles)
global binfile SR
SR{handles.gui_number}.mlist = [];
if isempty(binfile)
   [FileName,PathName] = uigetfile('*.bin');
   binfile = [PathName,filesep,FileName];
else
    [~,FileName] = extractpath(binfile);
end
handles = AddStormLayer(hObject,handles,FileName,1);
handles = SingleBinLoad(hObject,eventdata,handles);
RunLevelsChannel(hObject,eventdata,handles);
guidata(hObject, handles);