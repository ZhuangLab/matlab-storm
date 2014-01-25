function ShowHist(handles,n)

global CC 
imagesc(CC{handles.gui_number}.Icell{n}); 
CC{handles.gui_number}.clrmap;
set(gca,'color','k'); 
set(gca,'XTick',[],'YTick',[]);
