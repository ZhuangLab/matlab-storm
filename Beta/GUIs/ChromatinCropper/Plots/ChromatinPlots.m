function ChromatinPlots(handles, n)
% plot data for cluster n in main figure window
global CC   

% fix background by clearing axis;
axes(handles.axes1); cla;
set(gca,'color','k');
set(gca,'XTick',[],'YTick',[]);

    axes(handles.subaxis1); cla; %#ok<*LAXES>
    ShowConv(handles,n);
    
    axes(handles.subaxis2); cla; %#ok<*LAXES>
    ShowSTORM(handles,n);
    
    axes(handles.subaxis3); hold off; cla; %#ok<*LAXES>
    ShowDotTime(handles,n);
    
    axes(handles.subaxis4); cla; %#ok<*LAXES>
    ShowHist(handles,n);
    
      figure(3); clf; 
subplot(1,3,1); Ncolor(CC{handles.gui_number}.ImgZ{n}{3}{1},CC{handles.gui_number}.clrmap);
set(gca,'XTick',[],'YTick',[]); axis image;
subplot(1,3,2); Ncolor(CC{handles.gui_number}.ImgZ{n}{1}{1},CC{handles.gui_number}.clrmap);
set(gca,'XTick',[],'YTick',[]); axis image;
subplot(1,3,3); Ncolor(CC{handles.gui_number}.ImgZ{n}{2}{1},CC{handles.gui_number}.clrmap);
set(gca,'XTick',[],'YTick',[]); axis image;
      
%        List2ImgXYZ(CC{handles.gui_number}.vlists{n},...
%              'colormap',CC{handles.gui_number}.clrmap,...
%              'xrange',[0,15],'yrange',[0 15],...
%              'zrescale',1,'zrange',[-1200,1200]); 
      
%       List2ImgXYZ(CC{handles.gui_number}.vlists{n},...
%           'colormap',CC{handles.gui_number}.clrmap,...
%           'xrange',[0,15],'yrange',[0,15]); 
         