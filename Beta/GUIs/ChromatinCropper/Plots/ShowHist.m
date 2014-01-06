function ShowHist(handles,n)

global CC 
imagesc(CC{handles.gui_number}.Ihist{n}); 
set(gca,'color','k'); 
set(gca,'XTick',[],'YTick',[]);
