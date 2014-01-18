function GetParsFindChromatin(handles)    

global CC

notCancel = true; 

dlg_title = 'Step 5 Pars: render STORM images';  num_lines = 1;
    Dprompt = {
    'cropping box size (nm) ',...  % convert this to box size in nm
    'zm for STORM',...        % convert this to something sensible
    'show dots colored-coded by frame number? (slow)',...
    };

    Opts{1} = num2str(CC{handles.gui_number}.pars5.scale);
    Opts{2} = num2str(CC{handles.gui_number}.pars5.zm);
    Opts{3} = num2str(CC{handles.gui_number}.pars5.showColorTime);
    Opts = inputdlg(Dprompt,dlg_title,num_lines,Opts);
    if isempty(Opts); notCancel = false; end
    if notCancel
    CC{handles.gui_number}.pars5.scale = eval(Opts{1}); % 30
    CC{handles.gui_number}.pars5.zm = eval(Opts{2});  %  1;
    CC{handles.gui_number}.pars5.showColorTime = eval(Opts{3});
    end