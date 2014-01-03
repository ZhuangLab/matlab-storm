function ChromatinPlots(handles, n)
% plot data for cluster n in main figure window
global CC   
    axes(handles.subaxis1); cla; %#ok<*LAXES>
    ShowConv(handles,n);
    
    axes(handles.subaxis2); cla; %#ok<*LAXES>
    ShowSTORM(handles,n);
    
    axes(handles.subaxis3); hold off; cla; %#ok<*LAXES>
    ShowDotTime(handles,n);
    
    axes(handles.subaxis4); cla; %#ok<*LAXES>
    ShowHist(handles,n);