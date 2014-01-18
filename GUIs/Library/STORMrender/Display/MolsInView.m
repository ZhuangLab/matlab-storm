function vlist = MolsInView(handles)
% return just the portion of the molecule list in the fied of view; 
   
    global SR 
    infilter = SR{handles.gui_number}.infilter;
    imaxes = SR{handles.gui_number}.imaxes;
     mlist = SR{handles.gui_number}.mlist;
     
     Cs = length(mlist); 
    channels = zeros(1,Cs); % Storm Channels
    for c = 1:Cs; 
       channels(c) = eval(['get(','handles.sLayer',num2str(c),', ','''Value''',')']);
    end
    active_channels = find(channels);

    vlist = cell(Cs,1);
    
    for c=active_channels;
      if length(mlist{c}.x) >1
         vlist{c} = msublist(mlist{c},imaxes,'filter',infilter{c});
         vlist{c}.channel = c; 
         vlist{c}.infilter = infilter{c};
         vlist{c}.locinfilter = infilter{c}(infilter{c} & vlist{c}.inbox);
      end
    end  