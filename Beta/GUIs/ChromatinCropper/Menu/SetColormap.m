function SetColormap(handles,clr)

global CC    

    switch clr
        case 'yellow'
        clrmap = hot(256);
        clrmap = [(clrmap(:,1)*4/5+clrmap(:,2)/5).^1.5,(clrmap(:,1)*2/3+clrmap(:,2)/3).^1.5,clrmap(:,2).^1.5];
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
        clrmap = [(clrmap(:,1)*4/5+clrmap(:,2)/5),clrmap(:,3),(clrmap(:,1)*2/3+clrmap(:,2)/3)];
        clrmap(clrmap<0) = 0;
        colormap(clrmap); 
        
        otherwise
            error(['colormap ',clr,' not recognized']); 
            clrmap = CC{handles.gui_number}.clrmap;
    end
    CC{handles.gui_number}.clrmap = clrmap; 
