function handles = ImLoad(hObject,eventdata, handles)
% load variables
global   SR

mlist = SR{handles.gui_number}.mlist;  

% if we're zoomed out fully, recenter everything
if SR{handles.gui_number}.imaxes.zm == 1
  ImSetup(hObject,eventdata, handles); % reset to center
end
GetEdges(hObject, eventdata, handles);
UpdateSliders(hObject,eventdata,handles);

% tic
if SR{handles.gui_number}.DisplayOps.ColorZ
    Zsteps = SR{handles.gui_number}.DisplayOps.Zsteps;
    % In general, not worth excluding these dots from 2d images.
    % if desired, can be done by applying a molecule list filter.  
    if SR{handles.gui_number}.DisplayOps.HidePoor 
        for c = 1:length(SR{handles.gui_number}.infilter)
            SR{handles.gui_number}.infilter{c}(mlist{c}.c==9) = 0;  
        end
    end
else
    Zsteps = 1;
end


SR{handles.gui_number}.I = list2img(mlist, SR{handles.gui_number}.imaxes,...
    'filter',SR{handles.gui_number}.infilter,...
    'Zrange',SR{handles.gui_number}.DisplayOps.zrange,...
    'dotsize',SR{handles.gui_number}.DisplayOps.DotScale,...
    'Zsteps',Zsteps,'scalebar',0,...
    'N',6,...
    'correct drift',SR{handles.gui_number}.DisplayOps.CorrDrift);

if ~isempty(SR{handles.gui_number}.Oz)
    IntegrateOverlay(hObject,handles); % Integrate the Overlay, if it exists
end

UpdateMainDisplay(hObject,handles); % converts I, applys contrast, to RBG
guidata(hObject, handles);
% plottime = toc;
% disp(['total time to render image: ',num2str(plottime)]);
