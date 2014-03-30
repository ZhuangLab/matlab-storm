function ShowConv(handles,n)
global CC

channels = zeros(1,2); % Storm Channels
for c = 1:2; 
    channels(c) = eval(['get(','handles.sLayer',num2str(c),', ','''Value''',')']);
end

Iconv = CC{handles.gui_number}.Iconv{n};
numChns = min(size(Iconv,3)); 

if numChns > 1
    Iconv(:,:,1) = CC{handles.gui_number}.Iconv{n}(:,:,2)*channels(1);
    Iconv(:,:,2) = CC{handles.gui_number}.Iconv{n}(:,:,1)*channels(2);
    clrmap = hsv(2);
else
    clrmap = CC{handles.gui_number}.clrmap;
end

Ncolor(Iconv,clrmap); 
set(gca,'color','k'); 
set(gca,'XTick',[],'YTick',[]);
axis image;