function ShowDotTime(handles,n)    
global CC  

if CC{handles.gui_number}.pars5.showColorTime
     hold on;
    Itime = CC{handles.gui_number}.Itime;
    for c=1:size(Itime,2); 
        if length(Itime{n,c}(:,1)) < 30E3
            cmp = CC{handles.gui_number}.cmp;
            if size(Itime,2) > 1
                figure(4); subplot(1,2,c);
            end
            scatter(Itime{n,c}(:,1),Itime{n,c}(:,2), 5, cmp{n,c}, 'filled');
            warning('off','MATLAB:hg:patch:RGBColorDataNotSupported');
            xlim([min(Itime{n,c}(:,1)),max(Itime{n,c}(:,1))]);
            ylim([min(Itime{n,c}(:,2)),max(Itime{n,c}(:,2))]);
        else
            disp(['Dot ',num2str(n),' contains too many localization to plot']); 
        end
    end
end
set(gca,'color','k'); set(gcf,'color','w'); 
set(gca,'XTick',[],'YTick',[]);

 


