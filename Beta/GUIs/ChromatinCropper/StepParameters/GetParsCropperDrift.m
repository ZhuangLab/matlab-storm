function GetParsCropperDrift(handles)

global CC
notCancel = true; 

dlg_title = 'Step 4 Pars: Drift Correction';  num_lines = 1;
    Dprompt = {
    'max drift (pixels)',... 1
    'min fraction of frames',... 2
    'start frame (1 = auto detect)',...        3
    'show drift correction plots?',...  4
    'show extra drift correction plots?',...  5 
    'sampling rate (data relative to beads)',...
    'integrate frames',...
    };   % 

    Opts{1} = num2str(CC{handles.gui_number}.pars4.maxDrift);
    Opts{2} = num2str(CC{handles.gui_number}.pars4.fmin);
    Opts{3} = num2str(CC{handles.gui_number}.pars4.startFrame);
    Opts{4} = num2str(CC{handles.gui_number}.pars4.showPlots);
    Opts{5} = num2str(CC{handles.gui_number}.pars4.showExtraPlots);
    Opts{6} = num2str(CC{handles.gui_number}.pars4.samplingRate);
    Opts{7} = num2str(CC{handles.gui_number}.pars4.integrateframes);
    
    Opts = inputdlg(Dprompt,dlg_title,num_lines,Opts);
    if isempty(Opts);
        notCancel = false;
    end
    if notCancel
        CC{handles.gui_number}.pars4.maxDrift = str2num(Opts{1}); %#ok<*ST2NM>
        CC{handles.gui_number}.pars4.fmin = str2num(Opts{2});
        CC{handles.gui_number}.pars4.startFrame= str2num(Opts{3});
        CC{handles.gui_number}.pars4.showPlots = str2num(Opts{4}); 
        CC{handles.gui_number}.pars4.showExtraPlots = str2num(Opts{5});
        CC{handles.gui_number}.pars4.samplingRate = str2num(Opts{6});
        CC{handles.gui_number}.pars4.integrateframes= str2num(Opts{7});
    end