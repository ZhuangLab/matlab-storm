function ChromatinPlots2(handles, n)
% plot data for cluster n in main figure window 
% called during cluster stat computation

axes(handles.subaxis1); cla; %#ok<*LAXES>    
ShowConv(handles,n);

axes(handles.subaxis2); cla; %#ok<*LAXES>   
ShowSTORM(handles,n);

axes(handles.subaxis3); hold off; cla;  %#ok<*LAXES>
ShowAreaPlot(handles,n);

axes(handles.subaxis4); cla; %#ok<*LAXES>
ShowHist(handles,n);
    
figure(3); clf;
Show3DProjFilt(handles);
            