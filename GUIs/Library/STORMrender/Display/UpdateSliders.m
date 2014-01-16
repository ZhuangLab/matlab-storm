function handles = UpdateSliders(hObject,eventdata,handles)
% Update slider positions as field of view changes

global SR
imaxes = SR{handles.gui_number}.imaxes;
handles = guidata(hObject);
set(handles.Xslider,'Value',imaxes.cx);
set(handles.Yslider,'Value',imaxes.H-imaxes.cy);

set(handles.Xslider,'Min',0);
set(handles.Xslider,'Max',imaxes.W);
set(handles.Yslider,'Min',0);
set(handles.Yslider,'Max',imaxes.H);

stepSlider =  .15/imaxes.zm;  % Move field of view by this percent
jumpSlider = min(1,5*stepSlider);
set(handles.Xslider,'SliderStep',[stepSlider,jumpSlider])
set(handles.Yslider,'SliderStep',[stepSlider,jumpSlider])

SR{handles.gui_number}.imaxes = imaxes;
handles = UpdateNavigator(hObject,handles);
guidata(hObject, handles);