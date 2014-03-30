function ShowHist(handles,n)

global CC 

Iconv = CC{handles.gui_number}.Iconv{n};
channels = false(1,2); % active Channels
for c = 1:2; 
    channels(c) = eval(['get(','handles.sLayer',num2str(c),', ','''Value''',')']);
end
numChns = size(Iconv,3); 
if numChns > 1
    clrmap = hsv(2);
else
    clrmap = CC{handles.gui_number}.clrmap;
end

STORMcell2img(CC{handles.gui_number}.Icell{n},'colormap',clrmap,...
    'active channels',find(channels));


set(gca,'color','k'); 
set(gca,'XTick',[],'YTick',[]);
