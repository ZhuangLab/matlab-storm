function ShowConv(handles,n)
global CC
imagesc(CC{handles.gui_number}.Iconv{n}); colormap hot;
set(gca,'color','k'); set(gca,'XTick',[],'YTick',[]);

