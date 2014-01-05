function RunMenuFeudicalDrift(hObject, eventdata, handles)
%--------------------------------------------------------------------------
% hObject    handle to MenuFeducialDrift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%--------------------------------------------------------------------------
% feducialDriftCorrection(binname)
% feducialDriftCorrection(mlist)
% feducialDriftCorrection([],'daxname',daxname,'mlist',mlist,...);
%
%--------------------------------------------------------------------------
% Required Inputs
%
% daxname / string - name of daxfile to correct drift
% or 
% mlist / structure 
% 
%--------------------------------------------------------------------------
% Optional Inputs
% 
% 'startframe' / double / 1  
%               -- first frame to find feducials in
% 'maxdrift' / double / 2.5 
%               -- max distance a feducial can get from its starting 
%                  position and still be considered the same molecule
% 'integrateframes' / double / 500
% 'fmin' / double / .5
%               -- fraction of frames which must contain feducial
% 'nm per pixel' / double / 158 
%               -- nm per pixel in camera
% 'showplots' / boolean / true
% 'showextraplots' / boolean / false
% 
global SR scratchPath

mlist = SR{handles.gui_number}.mlist;

for c = 1:length(mlist) 
dlg_title = 'Feducial Drift Correction Options';
num_lines = 1;
Dprompt = {
    'feducial binfile (STORM-chn or binfile string)',... 1
    'correct STORM chn: ',... 2
    'start frame (1 = first appearance)',...        3
    'max drift (pixels)',...          4
    'integrate frames (smoothing localization noise)',...   5
    'min fraction of frames ',...              6
    'nm per pixel',...      7 
    'show plots',...          8
    'show extra plots',...   9
    'frame to ID feducials (1 = first appearance)',...
    'correct back from previous channels'};       
Opts{1} = '';
Opts{2} = ''; % ['[',num2str(1:length(mlist)),']'];
Opts{3} = num2str(1);
Opts{4} = num2str(2.5);
Opts{5} = num2str(500);
Opts{6} = num2str(0.7);
Opts{7} = num2str(SR{handles.gui_number}.DisplayOps.npp);
Opts{8} = 'true';
Opts{9} = 'false';
Opts{10} = num2str(1);
Opts{11} = 'true';
Opts = inputdlg(Dprompt,dlg_title,num_lines,Opts);

if length(Opts) > 1 % Do nothing if cancelled      
    if isempty(Opts{1})
        startfolder = SR{handles.gui_number}.LoadOps.pathin;
        if isempty(startfolder)
            startfolder = extractpath(SR{handles.gui_number}.infofile.localPath);
        end
        [filename,pathname,selected] = uigetfile(...
            {'*.bin', 'Molecule List (*.bin)';
            '*.*', 'All Files (*.*)'},...
            ['Choose bin file with feducials for chn ',num2str(c)],...
            startfolder); % prompts user to select directory 
        if selected > 0
            sourcename = [pathname,filesep,filename];
        end
    end
    
    %  save([scratchPath,'test.mat']); 
    % load([scratchPath,'test.mat']); 
    
    [dxc,dyc] = feducialDriftCorrection(sourcename,...        
        'startframe',eval(Opts{3}),...     3
        'maxdrift',eval(Opts{4}),...          4
        'integrateframes',eval(Opts{5}),...
        'fmin',eval(Opts{6}),...
        'nm per pixel',eval(Opts{7}),...
        'showplots',eval(Opts{8}),...
        'showextraplots',eval(Opts{9}),...
        'spotframe',eval(Opts{10}) );
       
    % record drift in this channel.  Calc drift from previous channels
   SR{handles.gui_number}.driftData{c}.xDrift = nonzeros(dxc);
   SR{handles.gui_number}.driftData{c}.yDrift = nonzeros(dyc);
   if eval(Opts{11}) && c>1
    prevXdrift = [0,SR{handles.gui_number}.driftData{1:c-1}.xDrift(end)];
    prevYdrift = [0,SR{handles.gui_number}.driftData{1:c-1}.yDrift(end)]; 
   else
    prevXdrift = 0; 
    prevYdrift = 0;
   end
    mlist{c}.xc = mlist{c}.x - dxc(mlist{c}.frame) - sum(prevXdrift);
    mlist{c}.yc = mlist{c}.y - dyc(mlist{c}.frame) - sum(prevYdrift); 
end  
   
end
% Need to reapply chromewarps 
if length(mlist) > 1
mlist = ApplyChromeWarp(mlist,SR{handles.gui_number}.LoadOps.chns,...
        SR{handles.gui_number}.LoadOps.warpfile,...
        'warpD',SR{handles.gui_number}.LoadOps.warpD,...
        'names',SR{handles.gui_number}.fnames); 
end
SR{handles.gui_number}.mlist = mlist;
ImLoad(hObject,eventdata, handles);