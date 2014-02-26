function handles = SRstartup(hObject,eventdata,handles)
% Initialize new structure in the SR (STORMrender) global variable


global binfile SR
if isempty(SR)
    SR = cell(1,1);
else
    SR = [SR;cell(1,1)];
end

handles.gui_number = length(SR);
set(handles.SRinstance,'String',['inst id',num2str(handles.gui_number)]);


% Initialize a few blank fields
SR{handles.gui_number}.Oz = {};  

% Default Display Options
    SR{handles.gui_number}.DisplayOps.ColorZ = false; 
    SR{handles.gui_number}.DisplayOps.Zsteps = 5;
    SR{handles.gui_number}.DisplayOps.DotScale = 4;
    SR{handles.gui_number}.DisplayOps.HidePoor = false;
    SR{handles.gui_number}.DisplayOps.scalebar = 500;
    SR{handles.gui_number}.DisplayOps.npp = 160;
    SR{handles.gui_number}.DisplayOps.verbose = true;
    SR{handles.gui_number}.DisplayOps.zrange = [-500,500];
    SR{handles.gui_number}.DisplayOps.CorrDrift = true;
    SR{handles.gui_number}.DisplayOps.clrmap = 'lines';
    SR{handles.gui_number}.DisplayOps.resolution = 512; 

% Default MultiBinFile Load Options
    SR{handles.gui_number}.LoadOps.warpD = 3; % set to 0 for no chromatic warp
    SR{handles.gui_number}.LoadOps.warpfile = ''; % can leave blank if no chromatic warp
    SR{handles.gui_number}.LoadOps.chns = {''};% {'750','647','561','488'};
    SR{handles.gui_number}.LoadOps.pathin = '';
    SR{handles.gui_number}.LoadOps.correctDrift = true;
    SR{handles.gui_number}.LoadOps.chnOrder = '[1:end]'; 
    SR{handles.gui_number}.LoadOps.sourceroot = '';
    SR{handles.gui_number}.LoadOps.bintype = '_alist.bin';
    SR{handles.gui_number}.LoadOps.chnFlag = {'750','647','561','488'};  
    SR{handles.gui_number}.LoadOps.dataset = 0;

% Default Contrast values
    SR{handles.gui_number}.omin = 0;
    SR{handles.gui_number}.omax = 1;
    


% avoid startup error
set(handles.Yslider,'Value',128);
set(handles.Yslider,'Min',0);
set(handles.Yslider,'Max',256);
set(handles.Yslider,'SliderStep',[0.005,0.05]);

% set up axes for plotting
 axes(handles.axes1); 
 set(gca,'color','k');
 set(gca,'XTick',[],'YTick',[]);
 colormap hot;
 axes(handles.axes2); 
 set(gca,'color','k');
set(gca,'XTick',[],'YTick',[]);
colormap hot;
 axes(handles.axes3); 
 set(gca,'color','w');
set(gca,'XTick',[],'YTick',[]);
% build dropdown menu
molfields = {'custom';'region';'z';'h';'a';'i';'w'};
set(handles.choosefilt,'String',molfields);

% set up sliders for contrast adjustment
set(handles.MaxIntSlider,'Max',1);
set(handles.MaxIntSlider,'Min',0);
set(handles.MaxIntSlider,'Value',1);
set(handles.MaxIntSlider,'SliderStep',[1/2^10,1/2^6])
set(handles.MinIntSlider,'Max',1);
set(handles.MinIntSlider,'Min',0);
set(handles.MinIntSlider,'Value',0); 
set(handles.MinIntSlider,'SliderStep',[1/2^10,1/2^6])

% Required for drag-and-drop load
if ~isempty(binfile)
    handles = QuickLoad(hObject,eventdata,handles);
end
