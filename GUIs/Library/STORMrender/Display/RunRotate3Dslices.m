function RunRotate3Dslices(hObject,eventdata,handles)
global  SR
I=SR{handles.gui_number}.I;
imaxes = SR{handles.gui_number}.imaxes;
% currently hard-coded, should be user options 
npp =SR{handles.gui_number}.DisplayOps.npp; % npp 
zrange = SR{handles.gui_number}.DisplayOps.zrange; %  [-600,600];

if SR{handles.gui_number}.DisplayOps.ColorZ && SR{handles.gui_number}.DisplayOps.Zsteps > 1
dlg_title = 'Render3D';
num_lines = 1;

    Dprompt = {
    'threshold (blank for auto)',...
    'downsample'};
    default_Dopts = {
    '[]',...
    '3'};

opts = inputdlg(Dprompt,dlg_title,num_lines,default_Dopts);

Zs = SR{handles.gui_number}.DisplayOps.Zsteps;
xyp = npp/imaxes.scale/imaxes.zm; % nm per x/y pixel
zstp = (zrange(2)-zrange(1))/Zs;

theta = eval(opts{1});
stp = str2double(opts{2});


figure; clf; 
Im3Dslices(I,'zStepSize',zstp,'xyStepSize',xyp,...
    'theta',theta,'downsample',stp,'coloroffset',0);
set(gcf,'color','w');
xlabel('x-position (nm)');
ylabel('y-position (nm)');
zlabel('z-position (nm)');
xlim([0,(imaxes.xmax-imaxes.xmin)*npp]);
ylim([0,(imaxes.ymax-imaxes.ymin)*npp])

else
    disp('must set Display Ops color Z to true for 3D rendering'); 
    disp('Go to "More Display Ops" and set first field as "true"');
end

% make coloroffset larger than largest intensity of previous image to have
% stacked dots rendered in different intensities.  