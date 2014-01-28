function GetParsLoadConv(handles)

    global CC

    notCancel =true;
    dlg_title = 'Step 1 Pars: Load Image';  num_lines = 1;
    Dprompt = {
    'Location of chromewarps.mat for chromatic correction',... 1
    'Locus name',...
    'Locus color',...
    };

    Opts{1} = CC{handles.gui_number}.pars1.BeadFolder;
    Opts{2} = CC{handles.gui_number}.pars1.locusname;
    Opts{3} = CC{handles.gui_number}.pars1.locusColor;
    Opts = inputdlg(Dprompt,dlg_title,num_lines,Opts);
    if isempty(Opts); 
        notCancel = false; 
    end
    
    if notCancel
         CC{handles.gui_number}.pars1.BeadFolder = Opts{1};
         CC{handles.gui_number}.pars1.locusname = Opts{2};
         CC{handles.gui_number}.pars1.locusColor = Opts{3};
         try
            SetColormap(handles,Opts{3});
            CC{handles.gui_number}.clrmapName = Opts{3}; 
         catch er
             disp(er.message);
             SetColormap(handles,'hot')
             disp('using default colormap'); 
         end
    end