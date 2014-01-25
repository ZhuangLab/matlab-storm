function GetParsFindChromatin(handles)    

global CC

notCancel = true; 

dlg_title = 'Step 5 Pars: render STORM images';  num_lines = 1;
Dprompt = {
    'field of view (nm)',...  % field of view (nm)
    'voxel size (nm)',...        % (nm)
    'show dots colored-coded by frame number? (slow)',...
    'rescale z-data',...
    };

    Opts{1} = num2str(CC{handles.gui_number}.pars5.regionSize);
    Opts{2} = num2str(CC{handles.gui_number}.pars5.boxSize);
    Opts{3} = num2str(CC{handles.gui_number}.pars5.showColorTime);
    Opts{4} = num2str(CC{handles.gui_number}.pars5.zrescale);
    Opts = inputdlg(Dprompt,dlg_title,num_lines,Opts);
if isempty(Opts); notCancel = false; end
if notCancel
    CC{handles.gui_number}.pars5.regionSize = eval(Opts{1}); % 30
    CC{handles.gui_number}.pars5.boxSize = eval(Opts{2});  %  1;
    CC{handles.gui_number}.pars5.showColorTime = eval(Opts{3});
    CC{handles.gui_number}.pars5.zrescale= eval(Opts{4});
end