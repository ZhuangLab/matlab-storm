function ShowAreaPlot(handles,n)
global CC
    try
    cluster_scale = CC{handles.gui_number}.pars0.npp/CC{handles.gui_number}.pars3.boxSize(1);     
    mainArea = CC{handles.gui_number}.tempData.mainArea;
    areaMap = CC{handles.gui_number}.tempData.areaMaps; 
    Ncolor(areaMap,CC{handles.gui_number}.clrmap);  
    
    text(1.2*cluster_scale,2*cluster_scale,...
        ['dot',num2str(n),' Area=',num2str(mainArea)],'color','w');
    set(gca,'XTick',[],'YTick',[]);
    catch er
        disp(er.getReport); 
    end