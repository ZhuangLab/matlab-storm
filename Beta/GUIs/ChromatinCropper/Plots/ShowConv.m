function ShowConv(handles,n)
global CC

channels = false(1,2); % Storm Channels
for c = 1:2; 
    channels(c) = eval(['get(','handles.sLayer',num2str(c),', ','''Value''',')']);
end
display_channels = [1,4];
display_channels = display_channels(channels);
Ncolor(CC{handles.gui_number}.Iconv{n}(:,:,display_channels),CC{handles.gui_number}.clrmap); 
set(gca,'color','k'); 
set(gca,'XTick',[],'YTick',[]);
axis image;