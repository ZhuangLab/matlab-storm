function GetParsLoadConv(handles)

global CC

    notCancel =true;
    dlg_title = 'Step 1 Pars: Load Image';  num_lines = 1;
    Dprompt = {
    'Location of chromewarps.mat for chromatic correction',... 1
    };

    Opts{1} = CC{handles.gui_number}.pars1.BeadFolder;
    Opts = inputdlg(Dprompt,dlg_title,num_lines,Opts);
    if isempty(Opts); 
        notCancel = false; 
    end
    if notCancel
     CC{handles.gui_number}.pars1.BeadFolder = Opts{1};
    end