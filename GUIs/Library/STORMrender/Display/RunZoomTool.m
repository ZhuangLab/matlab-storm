function handles = RunZoomTool(hObject,eventdata,handles)
% Zoom enhance for STORMrender
%
% Zoom in on the boxed region specified by user selection of upper left and
% lower right coordinates.

global SR scratchPath %#ok<NUSED>
imaxes = SR{handles.gui_number}.imaxes;
handles = guidata(hObject);
% user specifies box:
axes(handles.axes2); 
set(gca,'XTick',[],'YTick',[]);
% GetEdges(hObject, eventdata, handles)
[x,y] = ginput(2);  % These are relative to the current axis
xim = imaxes.xmin + x/imaxes.scale/imaxes.zm;
yim = imaxes.ymin + y/imaxes.scale/imaxes.zm;
imaxes.cx = mean(xim);  % this is relative to the whole image
imaxes.cy = mean(yim); % y is indexed bottom to top for plotting
xdiff = abs(xim(2) - xim(1));
ydiff = abs(yim(2) - yim(1));
imaxes.zm =   min(imaxes.W/xdiff, imaxes.H/ydiff); 
if imaxes.zm > 128
    imaxes.zm = 128;
    disp('max zoom reached...');
end
set(handles.displayzm,'String',num2str(imaxes.zm,2));
SR{handles.gui_number}.imaxes = imaxes;
handles = UpdateSliders(hObject,eventdata,handles);

% plot box
axes(handles.axes2); hold on;
set(gca,'Xtick',[],'Ytick',[]);
rectangle('Position',[min(x),min(y),abs(x(2)-x(1)),abs(y(2)-y(1))],'EdgeColor','w'); hold off;
guidata(hObject, handles);
pause(.1); 
ImLoad(hObject,eventdata, handles);
guidata(hObject, handles);
