function Show3DProjFilt(handles)
% plot XY XZ and YZ projections

global CC

colordef black;
subplot(1,3,1); 
STORMcell2img(CC{handles.gui_number}.tempData.stormImagesXYfilt,...
                'colormap',CC{handles.gui_number}.clrmap);
set(gca,'XTick',[],'YTick',[]); axis image; 
xlabel('x','FontSize',15); ylabel('y','FontSize',15);

subplot(1,3,2); 
STORMcell2img(CC{handles.gui_number}.tempData.stormImagesXZfilt,...
                'colormap',CC{handles.gui_number}.clrmap);
set(gca,'XTick',[],'YTick',[]); axis image; 
xlabel('x','FontSize',15); ylabel('z','FontSize',15); 

subplot(1,3,3); 
STORMcell2img(CC{handles.gui_number}.tempData.stormImagesYZfilt,...
                'colormap',CC{handles.gui_number}.clrmap);
set(gca,'XTick',[],'YTick',[]); axis image;
xlabel('y','FontSize',15); ylabel('z','FontSize',15);             


