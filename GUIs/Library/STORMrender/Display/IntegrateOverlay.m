
function IntegrateOverlay(hObject,handles)
    %---------------------------------------------------------------------
% IntegrateOverlay into field of view
%    - subfunction of MenuOverlay, also called each time image resizes
%    in order to maintain overlay display.  

global   SR scratchPath  %#ok<NUSED>
if isfield(SR{handles.gui_number},'Overlay_opts');
    Overlay_opts =  SR{handles.gui_number}.Overlay_opts;
    imaxes = SR{handles.gui_number}.imaxes;
    for n=1:length(SR{handles.gui_number}.O);
        if ~isempty(SR{handles.gui_number}.O{n})
        SR{handles.gui_number}.Oz{n} = fxn_AddOverlay(SR{handles.gui_number}.O{n},imaxes,...
            'flipV',eval(Overlay_opts{2}),'flipH',eval(Overlay_opts{3}),...
            'rotate',eval(Overlay_opts{4}),'xshift',eval(Overlay_opts{5}),...
            'yshift',eval(Overlay_opts{6}),'channels',eval(Overlay_opts{7}) ); 
       % figure(4); clf; imagesc(I{imlayer});
        UpdateMainDisplay(hObject,handles);
        end
    end
end

