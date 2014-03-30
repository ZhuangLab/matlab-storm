function Show3DProj(handles,n)
% plot XY XZ and YZ projections

global CC


colordef black;
if ~isempty(n)
subplot(1,3,1); STORMcell2img(CC{handles.gui_number}.ImgZ{n}{3},'colormap',CC{handles.gui_number}.clrmap);
set(gca,'XTick',[],'YTick',[]); axis image; xlabel('x'); ylabel('y');
subplot(1,3,2); STORMcell2img(CC{handles.gui_number}.ImgZ{n}{1},'colormap',CC{handles.gui_number}.clrmap);
set(gca,'XTick',[],'YTick',[]); axis image; xlabel('x'); ylabel('z');
subplot(1,3,3); STORMcell2img(CC{handles.gui_number}.ImgZ{n}{2},'colormap',CC{handles.gui_number}.clrmap);
set(gca,'XTick',[],'YTick',[]); axis image; xlabel('y'); ylabel('z'); 
else
subplot(1,3,1); STORMcell2img(CC{handles.gui_number}.tempData.stormImagesXY,'colormap',CC{handles.gui_number}.clrmap);
set(gca,'XTick',[],'YTick',[]); axis image; xlabel('x'); ylabel('y');
subplot(1,3,2); STORMcell2img(CC{handles.gui_number}.tempData.stormImagesXZ,'colormap',CC{handles.gui_number}.clrmap);
set(gca,'XTick',[],'YTick',[]); axis image; xlabel('x'); ylabel('z');
subplot(1,3,3); STORMcell2img(CC{handles.gui_number}.tempData.stormImagesYZ,'colormap',CC{handles.gui_number}.clrmap);
set(gca,'XTick',[],'YTick',[]); axis image; xlabel('y'); ylabel('z'); 
end    
   