function GetParsConvMask(handles)

global CC

notCancel = true; 

dlg_title = 'Step 2 Pars: Conv. Segmentation';  num_lines = 1;
    Dprompt = {
    'fraction to saturate',... 1
    'fraction to make black',... 2
    'Bead area dilation',... 3 
    'Bead threshold',...  4
     };     %5 

    Opts{1} = num2str(CC{handles.gui_number}.pars2.saturate);
    Opts{2} = num2str(CC{handles.gui_number}.pars2.makeblack);
    Opts{3} =  num2str(CC{handles.gui_number}.pars2.beadDilate);
    Opts{4} =  num2str(CC{handles.gui_number}.pars2.beadThresh);
    
    Opts = inputdlg(Dprompt,dlg_title,num_lines,Opts);
    if isempty(Opts);
        notCancel = false;
    end
    if notCancel
     CC{handles.gui_number}.pars2.saturate = str2num(Opts{1}); %#ok<*ST2NM>
     CC{handles.gui_number}.pars2.makeblack = str2num(Opts{2}); 
     CC{handles.gui_number}.pars2.beadDilate= str2double(Opts{3}); 
     CC{handles.gui_number}.pars2.beadThresh= str2double(Opts{4}); 
    end