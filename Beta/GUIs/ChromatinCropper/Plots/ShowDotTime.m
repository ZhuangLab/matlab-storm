function ShowDotTime(handles,n)    
global CC  

if CC{handles.gui_number}.pars5.showColorTime
     hold on;
    Itime = CC{handles.gui_number}.Itime;
    cmp = CC{handles.gui_number}.cmp;
    scatter(Itime{n}(:,1),Itime{n}(:,2), 5, cmp{n}, 'filled');
    warning('off','MATLAB:hg:patch:RGBColorDataNotSupported');
    xlim([min(Itime{n}(:,1)),max(Itime{n}(:,1))]);
    ylim([min(Itime{n}(:,2)),max(Itime{n}(:,2))]);
end
set(gca,'color','k'); set(gcf,'color','w'); 
set(gca,'XTick',[],'YTick',[]);

 


