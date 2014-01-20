function SelectColormap(handles)

global CC
notCancel = true; 

dlg_title = 'Chose a color for spots';  num_lines = 1;
    Dprompt = {
    'color ("red","yellow",...)',... 
     };     %5 

    Opts{1} = CC{handles.gui_number}.clrmap;
    Opts = inputdlg(Dprompt,dlg_title,num_lines,Opts);
    clr = Opts{1}; 
    
if notCancel
    switch clr
        case 'yellow'
        clrmap = hot(256);
        clrmap = [clrmap(:,1),clrmap(:,1),clrmap(:,2)];
        clrmap(clrmap<0) = 0;
        colormap(clrmap); 

        case 'red'
        clrmap = hot(256);
        clrmap = [clrmap(:,1),clrmap(:,2),clrmap(:,3)];
        clrmap(clrmap<0) = 0;
        colormap(clrmap); 

        case 'blue'
        clrmap = hot(256);
        clrmap = [clrmap(:,3),clrmap(:,2),clrmap(:,1)];
        clrmap(clrmap<0) = 0;
        colormap(clrmap); 

        case 'green'
        clrmap = hot(256);
        clrmap = [clrmap(:,3),clrmap(:,1),clrmap(:,2)];
        clrmap(clrmap<0) = 0;
        colormap(clrmap); 

        case 'purple'
        clrmap = hot(256);
        clrmap = [clrmap(:,1),clrmap(:,3),clrmap(:,1)];
        clrmap(clrmap<0) = 0;
        colormap(clrmap); 
    end
    CC{handles.gui_number}.clrmap = clrmap; 
end