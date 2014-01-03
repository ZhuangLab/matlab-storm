function ShowSTORM(handles,n)
global CC
    cmin = CC{handles.gui_number}.pars0.cmin;
    cmax = CC{handles.gui_number}.pars0.cmax;
    Istorm = CC{handles.gui_number}.Istorm{n};
    Istorm = imadjust(Istorm,[cmin,cmax],[0,1]);
    R = CC{handles.gui_number}.R;
    TCounts = sum(R(n).PixelValues);
    DotSize = length(R(n).PixelValues);
    MaxD = max(R(n).PixelValues);
    cluster_scale = CC{handles.gui_number}.pars0.npp/...
                    CC{handles.gui_number}.pars3.boxSize;     
    
    imagesc(Istorm); colormap hot;
    set(gca,'color','k'); set(gca,'XTick',[],'YTick',[]);
    text(1.2*cluster_scale,2*cluster_scale,...
    ['dot',num2str(n),' counts=',num2str(TCounts),' size=',...
         num2str(DotSize),' maxD=',num2str(MaxD)],...
         'color','w');


    