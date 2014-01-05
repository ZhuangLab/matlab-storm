function handles = UpdateMainDisplay(hObject,handles)
% Updates the main display in the STORMrender GUI
global  SR scratchPath  %#ok<NUSED>

I = SR{handles.gui_number}.I;
imaxes = SR{handles.gui_number}.imaxes;
% I cell containing current STORM image
% Oz cell containing appropriately rescaled overlay image
% Io 3-color output image. Global only to pass to export/save image calls.

guidata(hObject, handles);
numChannels = length(I); 
numOverlays = length(SR{handles.gui_number}.Oz);

% Find out which channels are toggled for display
%------------------------------------------------------------        
channels = zeros(1,numChannels); % Storm Channels
for c = 1:numChannels; 
    channels(c) = eval(['get(','handles.sLayer',num2str(c),', ','''Value''',')']);
end
active_channels = find(channels);

overlays = zeros(1,numOverlays); % Overlay channels
for c = 1:numOverlays
    overlays(c) = eval(['get(','handles.oLayer',num2str(c),', ','''Value''',')']);
end
active_overlays = find(overlays);
[~,~,Zs] = size(I{1});
numClrs = numChannels*Zs + numOverlays;  
%-----------------------------------------------------------
% Stack all image layers (channels, z-dimensions, and overlays)
%   into a common matrix for multicolor rendering.  Apply indicated
%   contrast for all data.  
Io = STORMcell2img(I,'overlays',SR{handles.gui_number}.Oz,...
'active channels',active_channels,'active overlays',active_overlays,...
'cmin',SR{handles.gui_number}.cmin,'cmax',SR{handles.gui_number}.cmax,...
'omin',SR{handles.gui_number}.omin,'omax',SR{handles.gui_number}.omax,...
'numClrs',numClrs,'colormap',SR{handles.gui_number}.DisplayOps.clrmap);

% Add ScaleBar (if indicated)
Cs_out = size(Io,3); 
if SR{handles.gui_number}.DisplayOps.scalebar > 0 
    scb = round(1:SR{handles.gui_number}.DisplayOps.scalebar/SR{handles.gui_number}.DisplayOps.npp*imaxes.zm*imaxes.scale);
    h1 = round(imaxes.H*.9*imaxes.scale);
    Io(h1:h1+2,10+scb,:) = 2^16*ones(3,length(scb),Cs_out,'uint16'); % Add scale bar and labels
end
%-----------------------------------------------------------

% Update the display
%--------------------------------------------------
axes(handles.axes2); cla;
set(gca,'XTick',[],'YTick',[]);
imagesc(Io); 
shading interp;
axes(handles.axes2);
set(handles.imtitle,'String',SR{handles.gui_number}.fnames(:)); % interpreter, none
% colorbar; colormap(hsv(Zs*Cs));
set(gca,'XTick',[],'YTick',[]);
if imaxes.updatemini
    axes(handles.axes1); cla;
    set(gca,'XTick',[],'YTick',[]);
    imagesc(Io); 
    imaxes.updatemini = false;
    set(gca,'XTick',[],'YTick',[]);
    SR{handles.gui_number}.imaxes = imaxes;
end
SR{handles.gui_number}.Io = Io; 
guidata(hObject, handles);