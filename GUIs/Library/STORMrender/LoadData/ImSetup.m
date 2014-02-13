function handles = ImSetup(hObject,eventdata, handles)
% Setup defaults
% -------------------------------------------------------------------

global SR scratchPath

% if imaxes is already defined, use it. 
if isfield(SR{handles.gui_number},'imaxes')
   imaxes = SR{handles.gui_number}.imaxes; 
else
    % build new imaxes structure using ROI from parameter file if available
    mlist = SR{handles.gui_number}.mlist;  % short hand;
    w = zeros(length(mlist),1);
    h = zeros(length(mlist),1);
    for i=1:length(mlist)
        binfile = [SR{handles.gui_number}.LoadOps.pathin,SR{handles.gui_number}.fnames{i}];
        [mlist{i},h(i),w(i)] = ReZeroROI(binfile,mlist{i});
    end
    if sum(w==w(1)) ~= length(mlist) || sum(h==h(1)) ~= length(mlist)
        error('ROIs for the selected molecule lists different sizes'); 
    end
    imaxes.W = w(1);
    imaxes.H = h(1);
    SR{handles.gui_number}.mlist = mlist;
end

imaxes.scale = 2;  % upscale on display
imaxes.zm = 1;
imaxes.cx = imaxes.W/2;
imaxes.cy = imaxes.H/2;
imaxes.xmin = 0;
imaxes.xmax = imaxes.W;
imaxes.ymin = 0; 
imaxes.ymax = imaxes.H; 
imaxes.updatemini = true; 
set(handles.Xslider,'Min',imaxes.xmin);
set(handles.Xslider,'Max',imaxes.xmax);
set(handles.Yslider,'Min',imaxes.ymin);
set(handles.Yslider,'Max',imaxes.ymax);
SR{handles.gui_number}.imaxes = imaxes;
guidata(hObject, handles);
handles = UpdateSliders(hObject,eventdata,handles);
guidata(hObject, handles);