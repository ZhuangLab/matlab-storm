function handles=ClearCurrentData(hObject,eventdata,handles)
        % clear existing fields for these variables
        global SR
        SR{handles.gui_number}.mlist = [];
        SR{handles.gui_number}.fnames = [];
        SR{handles.gui_number}.infofile = [];
        SR{handles.gui_number}.Oz = {};     
        SR{handles.gui_number}.O = {};
        if isfield(SR{handles.gui_number},'imaxes');
        SR{handles.gui_number}=rmfield(SR{handles.gui_number},'imaxes');
        end
        
    % Clear levels (contrasting)
    set(handles.LevelsChannel,'Value',1);
    set(handles.LevelsChannel,'String',{'channel1'});
      
    % Make STORM and Overlay layers invisible again
    for c=1:6
        eval(['set(','handles.sLayer',num2str(c),', ','''Visible''',', ','''off''',')']);
        eval(['set(','handles.oLayer',num2str(c),', ','''Visible''',', ','''off''',')']);
    end
