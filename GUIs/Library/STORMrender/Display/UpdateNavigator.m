function handles = UpdateNavigator(hObject,handles)
% update navigator window in STORMrender

global SR
imaxes = SR{handles.gui_number}.imaxes;
    axes(handles.axes1);
    set(gca,'Xtick',[],'Ytick',[]);
    hold on;
    hside= imaxes.H*imaxes.scale/imaxes.zm;
    wside = imaxes.W*imaxes.scale/imaxes.zm;
    lower_x = imaxes.scale*imaxes.cx-wside/2;
    lower_y = imaxes.scale*imaxes.cy-hside/2;
    prevbox = findobj(gca,'Type','rectangle');
    delete(prevbox); 
    rectangle('Position',[lower_x,lower_y,wside,hside],...
        'EdgeColor','w','linewidth',1); 
    set(gca,'Xtick',[],'Ytick',[]);
    hold off;
    guidata(hObject, handles);