function handles = LoadBin(hObject,eventdata,handles,multiselect)
% Brings up dialogue box to select bin file(s) to load;     

global binfile SR


if ~isempty(SR{handles.gui_number}.LoadOps.pathin)
    startfolder = SR{handles.gui_number}.LoadOps.pathin;
elseif ~isempty(binfile)
    startfolder = extractpath(binfile);
else
    startfolder = pwd;
end
[FileName,PathName,FilterIndex] = uigetfile({'*.bin','Bin file (*.bin)';...
    '*.*','All Files (*.*)'},'Select molecule list',startfolder,...
    'MultiSelect',multiselect);
if FilterIndex ~=0
    handles=ClearCurrentData(hObject,eventdata,handles);
    
    SR{handles.gui_number}.LoadOps.pathin = PathName;
    set(handles.datapath,'String',SR{handles.gui_number}.LoadOps.pathin); 
    if ~iscell(FileName) % Single Binfile selected
        binfile = [PathName,filesep,FileName];
        handles = AddStormLayer(hObject,handles,FileName,1);
        guidata(hObject, handles);
        handles = SingleBinLoad(hObject,eventdata,handles);
    else  % For Multiple Bin Files Selected      
        prompt = 'In what order were these taken?  ';
        chnOrder = inputdlg(char({prompt,FileName{:}}),...
            '',1,{['[',num2str(fliplr(1:length(FileName))),']'] }) ;  
        chnOrder = chnOrder{1}; 
        SR{handles.gui_number}.LoadOps.chnOrder = chnOrder;     
        binnames = eval(['FileName(',chnOrder,')']);
        for c=1:length(FileName)
            handles = AddStormLayer(hObject,handles,binnames{c},c);
            guidata(hObject, handles);
        end
        handles = MultiBinLoad(hObject,eventdata,handles,binnames);
    end    
end