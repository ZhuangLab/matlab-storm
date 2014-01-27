function GetParsFilterChromatin(handles) 

global CC
notCancel = true; 

dlg_title = 'Step 6 Pars: Quantify Features';  num_lines = 1;
   Dprompt = {
    'Box Size (nm)',... 
    'start frame ',...        3
    'Min Localizations per box',...  4
    'Min Size (boxes)',...  %5 
    'Save root'};    % 6

    Opts{1} = num2str(CC{handles.gui_number}.pars6.boxSize); 
    Opts{2} = num2str(CC{handles.gui_number}.pars6.startFrame);
    Opts{3} = num2str(CC{handles.gui_number}.pars6.minLoc);
    Opts{4} = num2str(CC{handles.gui_number}.pars6.minSize);
    Opts{5} = num2str(CC{handles.gui_number}.pars6.saveroot);
    Opts = inputdlg(Dprompt,dlg_title,num_lines,Opts);
    if isempty(Opts); notCancel = false; end
    if notCancel
    CC{handles.gui_number}.pars6.boxSize = eval(Opts{1}); % 30
    CC{handles.gui_number}.pars6.startFrame= eval(Opts{2});  %  1;
	CC{handles.gui_number}.pars6.minLoc= eval(Opts{3});  % 0;
	CC{handles.gui_number}.pars6.minSize= eval(Opts{4});  % 30; 
    CC{handles.gui_number}.pars6.saveroot= Opts{5};
    end