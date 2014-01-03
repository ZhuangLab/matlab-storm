function GetParsStormMask(handles)

global CC
notCancel = true;

dlg_title = 'Step 3 Pars: Filter Clusters';  num_lines = 1;
    Dprompt = {
    'box size (nm)',... 1
    'max dot size (boxes)',... 2
    'min dot size (boxes)',... 3
    'min localizations',...  4
    'start frame',...  5
    'min average density',... 6
    };     

    Opts{1} = num2str(CC{handles.gui_number}.pars3.boxSize);
    Opts{2} = num2str(CC{handles.gui_number}.pars3.maxsize);
    Opts{3} = num2str(CC{handles.gui_number}.pars3.minsize);
    Opts{4} = num2str(CC{handles.gui_number}.pars3.mindots);
    Opts{5} = num2str(CC{handles.gui_number}.pars3.startFrame);
    Opts{6} = num2str(CC{handles.gui_number}.pars3.mindensity);
    Opts = inputdlg(Dprompt,dlg_title,num_lines,Opts);
    if isempty(Opts);
        notCancel = false; 
    end
    if notCancel
    CC{handles.gui_number}.pars3.boxSize = str2double(Opts{1}); % for 160npp, 16 -> 10nm boxes
    CC{handles.gui_number}.pars3.maxsize = str2double(Opts{2}); % 1E4 at 10nm cluster_scale, 1.2 um x 1.2 um 
    CC{handles.gui_number}.pars3.minsize = str2double(Opts{3}); % eg. minsize is 100 10x10 nm boxes.  400 is 200x200nm
    CC{handles.gui_number}.pars3.mindots = str2double(Opts{4}); % min number of localizations per STORM dot
    CC{handles.gui_number}.pars3.startFrame = str2double(Opts{5});   
    CC{handles.gui_number}.pars3.mindensity = str2double(Opts{6});   
    end