function SelectColormap(handles)

global CC
notCancel = true; 

dlg_title = 'Chose a color for spots';  num_lines = 1;
    Dprompt = {
    'color ("red","yellow",...)',... 
     };     %5 

 CC{handles.gui_number}.clrmap; % map
 CC{handles.gui_number}.clrmapName = 'hot';
    Opts{1} = CC{handles.gui_number}.clrmapName;
    
Opts = inputdlg(Dprompt,dlg_title,num_lines,Opts);
    
if isempty(Opts); 
        notCancel = false; 
end

if notCancel
    clr = Opts{1}; 
    SetColormap(handles,clr); 
end
    
