 function handles = RunApplyFilter(hObject,eventdata,handles)
  global  SR scratchPath  %#ok<NUSED>
  filts = SR{handles.gui_number}.filts;
  contents = cellstr(get(handles.choosefilt,'String')); % returns choosefilt contents as cell array
  par = contents{get(handles.choosefilt,'Value')}; % returns selected item from choosefilt 

    % see which channels are selected to apply
    channels(1) = get(handles.fchn1,'Value');
    channels(2) = get(handles.fchn2,'Value');
    channels(3) = get(handles.fchn3,'Value');
    channels(4) = get(handles.fchn4,'Value');
    channels = find(channels);
    
    myfilt = get(handles.CustomFilter,'String');
    vlist = MolsInView(handles);
    
    local_filter = cell(max(channels),1);
 for c=1:channels;
    local_filter{c} = vlist{c}.locinfilter;
 end
  axes(handles.axes2);  
  [newfilter,filts] = applyfilter(vlist,local_filter, filts, channels, par, myfilt,...
      SR{handles.gui_number}.imaxes); 
  
  
  for c=1:channels
    SR{handles.gui_number}.infilter{c}(vlist{c}.inbox & vlist{c}.infilter) =  newfilter{c};
  end
   SR{handles.gui_number}.filts = filts;
  ImLoad(hObject,eventdata, handles); % calls plotdata function