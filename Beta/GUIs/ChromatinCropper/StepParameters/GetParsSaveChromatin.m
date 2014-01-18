function GetParsSaveChromatin(handles)

global CC
notCancel = true;

  dlg_title = 'Step 7 Pars: Data Export Options';  num_lines = 1;
    Dprompt = {
    'Save dots colored-coded by frame number? (slow)'...
    'root for savename'};     %1 
     Opts{1} = num2str(CC{handles.gui_number}.pars7.saveColorTime);
     Opts{2} = CC{handles.gui_number}.pars7.saveroot;
     Opts = inputdlg(Dprompt,dlg_title,num_lines,Opts);
    if isempty(Opts); notCancel = false; end
    if notCancel
     CC{handles.gui_number}.pars7.saveColorTime = eval(Opts{1}); % 30
     CC{handles.gui_number}.pars7.saveroot = Opts{2}; 
    end