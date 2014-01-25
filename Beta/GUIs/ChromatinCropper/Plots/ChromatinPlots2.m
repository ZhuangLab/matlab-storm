function ChromatinPlots2(handles, n)
% plot data for cluster n in main figure window 
% called during cluster stat computation
global CC;

axes(handles.subaxis1); cla; %#ok<*LAXES>    
ShowConv(handles,n);

axes(handles.subaxis2); cla; %#ok<*LAXES>   
ShowSTORM(handles,n);

axes(handles.subaxis3); hold off; cla;  %#ok<*LAXES>
ShowAreaPlot(handles,n);

axes(handles.subaxis4); cla; %#ok<*LAXES>
ShowHist(handles,n);
    
figure(3); clf;
subplot(1,3,1); 
Ncolor(CC{handles.gui_number}.tempData.stormImagesXYfilt{1},...
                CC{handles.gui_number}.clrmap);
subplot(1,3,2); 
Ncolor(CC{handles.gui_number}.tempData.stormImagesXZfilt{1},...
                CC{handles.gui_number}.clrmap);
subplot(1,3,3); 
Ncolor(CC{handles.gui_number}.tempData.stormImagesYZfilt{1},...
                CC{handles.gui_number}.clrmap);
            