function ShowSTORM(handles,n)
% handles - contains user data
% n - index of chromatin spot to plot

global CC
    cmin = CC{handles.gui_number}.pars0.cmin;
    cmax = CC{handles.gui_number}.pars0.cmax;
    Istorm = CC{handles.gui_number}.Istorm{n};

    R = CC{handles.gui_number}.R;
    TCounts = sum(R(n).PixelValues);
    DotSize = length(R(n).PixelValues);
    MaxD = max(R(n).PixelValues);
    cluster_scale = CC{handles.gui_number}.pars0.npp/...
                    CC{handles.gui_number}.pars3.boxSize(1);     
 
if isempty(CC{handles.gui_number}.mlist1)
    numChns = 1;
    clrmap = 'hot';
else
    numChns = 2;
    clrmap = 'lines';
end

channels = false(1,numChns); % Storm Channels
for c = 1:numChns; 
    channels(c) = eval(['get(','handles.sLayer',num2str(c),', ','''Value''',')']);
end
active_channels = find(channels);


Io = STORMcell2img(Istorm,...
'active channels',active_channels,...
'cmin',cmin,'cmax',cmax,...
'colormap',clrmap);
% 'numClrs',numClrs,

Ncolor(Io);
    set(gca,'color','k'); set(gca,'XTick',[],'YTick',[]);
    text(1.2*cluster_scale,2*cluster_scale,...
    ['dot',num2str(n),' counts=',num2str(TCounts),' size=',...
         num2str(DotSize),' maxD=',num2str(MaxD)],...
         'color','w');