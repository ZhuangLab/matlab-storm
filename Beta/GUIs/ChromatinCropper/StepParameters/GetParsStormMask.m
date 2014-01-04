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
        CC{handles.gui_number}.pars3.boxSize = Str2vec(Opts{1}); % for 160npp, 16 -> 10nm boxes
        CC{handles.gui_number}.pars3.maxsize = Str2vec(Opts{2}); % 1E4 at 10nm cluster_scale, 1.2 um x 1.2 um 
        CC{handles.gui_number}.pars3.minsize = Str2vec(Opts{3}); % eg. minsize is 100 10x10 nm boxes.  400 is 200x200nm
        CC{handles.gui_number}.pars3.mindots = Str2vec(Opts{4}); % min number of localizations per STORM dot
        CC{handles.gui_number}.pars3.startFrame = Str2vec(Opts{5});   
        CC{handles.gui_number}.pars3.mindensity = Str2vec(Opts{6});   
    end