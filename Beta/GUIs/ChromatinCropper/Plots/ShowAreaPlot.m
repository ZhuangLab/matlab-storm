function ShowAreaPlot(handles,n)
global CC
    try
    cluster_scale = CC{handles.gui_number}.pars0.npp/CC{handles.gui_number}.pars3.boxSize(1);     
    Area = CC{handles.gui_number}.data.AllArea{CC{handles.gui_number}.imnum,n};
    imagesc(CC{handles.gui_number}.map{n}); %
    text(1.2*cluster_scale,2*cluster_scale,...
        ['dot',num2str(n),' Area=',num2str(Area)],'color','w');
    caxis([0,1]); colormap hot;
    set(gca,'XTick',[],'YTick',[]);
    catch er
        disp(er.getReport); 
    end