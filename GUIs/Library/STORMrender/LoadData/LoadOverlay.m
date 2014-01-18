function LoadOverlay(hObject,eventdata,handles)
global SR binfile

if ~isfield(SR{handles.gui_number},'Overlay_opts')
    SR{handles.gui_number}.Overlay_opts = [];
end
Overlay_opts =  SR{handles.gui_number}.Overlay_opts ;
if ~isfield(SR{handles.gui_number},'O')
    SR{handles.gui_number}.O = [];
end

% ------------- load image
% open dialog box to decide whether image should be flipped or rotated
dlg_title = 'Set Load Options';
num_lines = 1;
  Overlay_prompt = {
    'Image selected (leave blank to select with getfile prompt)',...
    'Flip Vertical',...
    'Flip Horizontal',...
    'Rotate by N degrees'...
    'horizontal shift'...
    'vertical shift'...
    'channels'...
    'Max frames (for Daxfiles)',...
    'Overlay Layer (leave blank to add new layer)',...
    'Contrast',...
    'Channel for chromatic warp (blank for no warp)'};

try
Overlay_opts = inputdlg(Overlay_prompt,dlg_title,num_lines,Overlay_opts);
catch er 
    % reset 
    disp(er.message)
    Overlay_opts = {
    '',...
    'false',...
    'false',...
    '0',...
    '0',...
    '0',...
    '[]',...
    '4',...
    '',...
    '[0,.3]',...
    ''};
    Overlay_opts = inputdlg(Overlay_prompt,dlg_title,num_lines,Overlay_opts);
end

if ~isempty(Overlay_opts) % Load Overlay Not canceled

    if isempty(Overlay_opts{1})
        
        if ~isempty(SR{handles.gui_number}.LoadOps.pathin)
            startfolder = SR{handles.gui_number}.LoadOps.pathin;
        elseif ~isempty(binfile)
            startfolder = extractpath(binfile);
        else
            startfolder = pwd;
        end
        
        
    [filename,pathname,selected] = uigetfile(...
        {'*.dax;*.jpg;*.png;*.tif','Image files (*.dax, *.jpg, *.png, *.tif)';
        '*.dax','DAX (*.dax)';
        '*.jpg', 'JPEGS (*.jpg)';
        '*.tif', 'TIFF (*.tif)';
        '*.png', 'PNG (*.png)';
        '*.*', 'All Files (*.*)'},...
        'Choose an image file to overlay',...
        startfolder); % prompts user to select directory 
    sourcename = [pathname,filesep,filename];
    Overlay_opts{1} = sourcename;
    else 
        selected = 1;
    end
    
    if selected~=0;
        k = strfind(Overlay_opts{1},'.dax');
        if isempty(k)
            tempO = imread(Overlay_opts{1}); % load image file;
        else  % For DAX files
            tempO = ReadDax(Overlay_opts{1},'endFrame',eval(Overlay_opts{8}));
            tempO = uint16(mean(tempO,3));  %average all frames loaded.   might cause problems
        end
        
        if ~isempty(Overlay_opts{11})
           if isempty(SR{handles.gui_number}.LoadOps.warpfile)
                if ~isempty(SR{handles.gui_number}.LoadOps.pathin)
                    startfolder = SR{handles.gui_number}.LoadOps.pathin;
                elseif ~isempty(binfile)
                    startfolder = extractpath(binfile);
                else
                    startfolder = pwd;
                end
              [filename,pathname,selected] = uigetfile({'*.mat'},'Select Warpfile',startfolder);
              SR{handles.gui_number}.LoadOps.warpfile = [pathname,filesep,filename];
           end
            if selected
                tempO = WarpImage(tempO,Overlay_opts{11},SR{handles.gui_number}.LoadOps.warpfile);
            end
        end
        
        Noverlays = length(SR{handles.gui_number}.O);
        if isempty(Overlay_opts{9})
            SR{handles.gui_number}.O{Noverlays+1} = tempO; 
            overlay_number = length(SR{handles.gui_number}.O);%  ;
        else
            overlay_number =  eval(Overlay_opts{9});
            SR{handles.gui_number}.O{overlay_number} = tempO;
        end

        % Still need to address contrast for overlays
        imcaxis = eval(Overlay_opts{10});
        SR{handles.gui_number}.omin(overlay_number) = imcaxis(1);
        SR{handles.gui_number}.omax(overlay_number) = imcaxis(2);
        [~,filename] = extractpath(Overlay_opts{1});
        SR{handles.gui_number}.Overlay_opts = Overlay_opts ;

        % Add to Overlays List
        handles = AddOverlayLayer(hObject,handles,overlay_number,filename);
        guidata(hObject, handles);
        IntegrateOverlay(hObject,handles);
    end
end