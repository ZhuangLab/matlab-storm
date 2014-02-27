function ShowConv(handles,n)
global CC

channels = false(1,2); % Storm Channels
for c = 1:2; 
    channels(c) = eval(['get(','handles.sLayer',num2str(c),', ','''Value''',')']);
end

Iconv = CC{handles.gui_number}.Iconv{n};
numChns = min(size(Iconv,3),sum(channels)); 

if numChns > 1
    clrmap = hsv(2);
else
    clrmap = CC{handles.gui_number}.clrmap;
end

Ncolor(Iconv(:,:,channels),clrmap); 
set(gca,'color','k'); 
set(gca,'XTick',[],'YTick',[]);
axis image;