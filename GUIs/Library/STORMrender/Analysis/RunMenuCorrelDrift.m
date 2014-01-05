function RunMenuCorrelDrift(hObject, eventdata, handles)
% hObject    handle to MenuCorrelDrift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%--------------------------------------------------------------------------
% mlist = XcorrDriftCorrect(binfile)
% mlist = XcorrDriftCorrect(mlist)
%
%--------------------------------------------------------------------------
% Required Inputs
% mlist (molecule list structure)
% OR
% binfile (string)
% 
%
%--------------------------------------------------------------------------
% Optional Inputs
% 'imagesize' / double 2-vector / [256 256] -- size of image
% 'scale' / double / 5 -- upsampling factor for binning localizations
% 'stepframe' / double / 10E3 -- number of frames to average
% 'nm per pixel' / double / 158 -- nm per pixel in original data
% 'showplots' / logical / true -- plot computed drift?
%--------------------------------------------------------------------------
% Outputs
% mlist (molecule list structure) 
%           -- mlist.xc and mlist.yc are overwritten with the new drift
%           corrected values.  
% 
%--------------------------------------------------------------------------
global SR scratchPath

%--------------------------------------------------------------------------
% Get parameters: 
imagesize = [SR{handles.gui_number}.imaxes.H,...
    SR{handles.gui_number}.imaxes.W];


dlg_title = 'Correlation-based Drift Correction';
num_lines = 1;
Dprompt = {
    'stepframe',... 1
    'channel',... 2
    'scale',...        3
    'nm per pixel',...
    'showplots',...
    'use only current ROI'};     %5   
Opts{1} = num2str(6E3);
Opts{2} = num2str(1);
Opts{3} = num2str(4);
Opts{4} = num2str(SR{handles.gui_number}.DisplayOps.npp);
Opts{5} = 'true';
Opts{6} = 'true';
Opts = inputdlg(Dprompt,dlg_title,num_lines,Opts);

if ~isempty(Opts)
    c = str2double(Opts{2});
    mlist = SR{handles.gui_number}.mlist;

    if eval(Opts{6})
              vlist = MolsInView(handles);
              % imaxes = SR{handles.gui_number}.imaxes;  
              % H = imaxes.ymax - imaxes.ymin + 1;
              % W = imaxes.xmax - imaxes.xmin + 1; 
               H = vlist{c}.imaxes.H;
               W = vlist{c}.imaxes.W;
               npp = SR{handles.gui_number}.DisplayOps.npp;

              [dxc,dyc] = XcorrDriftCorrect(vlist{c},...
                 'stepframe',eval(Opts{1}),...
                'scale',eval(Opts{2}),'showplots',eval(Opts{3}),...    
                'imagesize',[H,W],'nm per pixel',npp);  
            % local area may not have dots localized up through the last frame
            % of the movie.  Just assume no drift for these final frames if
            % doing local region based correction.  (They should only be a
            % couple to couple dozen of frames = a few seconds of drift at most).
            dxc = [dxc,zeros(1,max(mlist{c}.frame)-max(vlist{c}.frame))];
            dyc = [dyc,zeros(1,max(mlist{c}.frame)-max(vlist{c}.frame))];
    else
        [dxc,dyc] =  XcorrDriftCorrect( ...
            SR{handles.gui_number}.mlist{ c },...
            'imagesize',imagesize,...
            'scale',eval(Opts{3}),...
            'stepframe',eval(Opts{1}),...
            'nm per pixel',eval(Opts{4}),...
            'showplots',eval(Opts{5}) ); 
    end
    mlist{c}.xc = mlist{c}.x - dxc(mlist{c}.frame)';
    mlist{c}.yc = mlist{c}.y - dyc(mlist{c}.frame)';  
    SR{handles.gui_number}.mlist = mlist;
    ImLoad(hObject,eventdata, handles);
end