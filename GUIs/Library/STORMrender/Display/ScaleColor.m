function ScaleColor(hObject,handles)
 global SR scratchPath %#ok<NUSED>

% x scale for histogram (log or normal)
logscalecolor = logical(get(handles.logscalecolor,'Value'));
N_stormchannels = length(SR{handles.gui_number}.cmax);
selected_channel = get(handles.LevelsChannel,'Value');

% Read in current slider postions, set numeric displays accordingly
maxin = get(handles.MaxIntSlider,'Value');
minin = get(handles.MinIntSlider,'Value'); 
set(handles.MaxIntBox,'String',num2str(maxin));
set(handles.MinIntBox,'String',num2str(minin));

% If it's STORM data, record data range from I and store max min as
% cmax / cmin
if selected_channel <= N_stormchannels
    raw_ints  = double(SR{handles.gui_number}.I{selected_channel}(:)); 
    SR{handles.gui_number}.cmax(selected_channel) = maxin;
    SR{handles.gui_number}.cmin(selected_channel) = minin;
else % If it's Overlay data adjust O
    selected_channel = selected_channel-N_stormchannels;
    raw_ints  = double(SR{handles.gui_number}.Oz{selected_channel}(:)); 
    SR{handles.gui_number}.omax(selected_channel) = maxin;
    SR{handles.gui_number}.omin(selected_channel) = minin;
end
 
 % Display histogram;            
    raw_ints = raw_ints(:);
    max_int = max(raw_ints);

   axes(handles.axes3); cla reset; 
    set(gca,'XTick',[],'YTick',[]); 
   if ~logscalecolor
       xs = linspace(0,max_int,1000); 
        hi1 = hist(nonzeros(raw_ints)./max_int,xs);
        hist(nonzeros(raw_ints),xs); hold on;
        inrange = nonzeros(raw_ints( raw_ints/max_int>minin & raw_ints/max_int<maxin))./max_int;
        hist(inrange,xs);
        h2 = findobj('type','patch'); 
        xlim([min(xs),max(xs)]);
   else  % For Log-scale histogram  
       xs = linspace(-5,0,50);
       lognorm =  log10(nonzeros(raw_ints)/max_int);
       hi1 = hist(lognorm,xs);
       hist(lognorm,xs); hold on;
       xlim([min(xs),max(xs)]);
       log_min = (minin-1)*5; % map relative [0,1] to logpowers [-5 0];
       log_max = (maxin-1)*5; % map relative [0,1] to logpowers [-5 0];
       inrange = lognorm(lognorm>log_min & lognorm<log_max);
       hist(inrange,xs);
       xlim([min(xs),max(xs)]);
       clear h2;
       h2 = findobj('type','patch'); 
   end
    ylim([0,1.2*max([hi1,1])]);
   set(h2(2),'FaceColor','b','EdgeColor','b');
   set(h2(1),'FaceColor','r','EdgeColor','r');
   set(gca,'XTick',[],'YTick',[]);
   alpha .5;

  clear raw_ints;        
  UpdateMainDisplay(hObject,handles);
  guidata(hObject, handles);