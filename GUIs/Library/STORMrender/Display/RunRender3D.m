function RunRender3D(hObject,eventdata,handles)
global SR scratchPath
I = SR{handles.gui_number}.I;
imaxes = SR{handles.gui_number}.imaxes;
% currently hard-coded, should be user options 
npp =SR{handles.gui_number}.DisplayOps.npp; 
zrange = SR{handles.gui_number}.DisplayOps.zrange; % = [-600,600];

if SR{handles.gui_number}.DisplayOps.ColorZ && SR{handles.gui_number}.DisplayOps.Zsteps > 1
    disp('use cell arrays of parameters for multichannel rendering'); 
    disp('see help Im3D for more options'); 

    dlg_title = 'Render3D. Group multichannel options in {}';
    num_lines = 1;

        Dprompt = {
        'threshold (blank for auto)',...
        'downsample',...
        'smoothing (must be odd integer)',...
        'color',...
        'alpha'};
    try
        default_Dopts = SR{handles.gui_number}.default_Dopts;
        opts = inputdlg(Dprompt,dlg_title,num_lines,default_Dopts);
    catch %#ok<CTCH>
        default_Dopts = {
        '[]',...
        '3',...
        '3',...
        'blue',...
        '1'};
        opts = inputdlg(Dprompt,dlg_title,num_lines,default_Dopts);
    end

    if ~isempty(opts)
        SR{handles.gui_number}.default_Dopts  = opts;
        Zs = SR{handles.gui_number}.DisplayOps.Zsteps;

        xyp = npp/imaxes.scale/imaxes.zm; % nm per x/y pixel
        zstp = (zrange(2)-zrange(1))/Zs;

        theta = eval(opts{1});
        stp = eval(opts{2});
        res = eval(opts{3});
        colr = opts{4}; 
        Cs = length(I);

        channels = zeros(1,Cs); % Storm Channels
        for c = 1:Cs; 
            channels(c) = eval(['get(','handles.sLayer',num2str(c),', ','''Value''',')']);
        end
        
        active_channels = find(channels);
        figure; clf; 
        Im3D(I(active_channels),'resolution',res,'zStepSize',zstp,'xyStepSize',xyp,...
            'theta',theta,'downsample',stp,'color',colr); %#ok<FNDSB> % NOT equiv! 
        set(gcf,'color','w');
        camlight left;
        xlabel('nm');
        ylabel('nm');
        zlabel('nm');
        xlim([0,(imaxes.xmax-imaxes.xmin)*npp]);
        ylim([0,(imaxes.ymax-imaxes.ymin)*npp]);
        alpha( eval(opts{5}) ); 
    end
else
    disp('must set Display Ops color Z to true for 3D rendering'); 
    disp('Go to "More Display Ops" and set first field as "true"');
end
