function handles = RunClearFilter(hObject,eventdata,handles)
% Clear all filters that mask molecules

global  SR
SR{handles.gui_number}.filts = struct('custom',[]); % empty structure to store filters
Cs = length(SR{handles.gui_number}.mlist);
    SR{handles.gui_number}.infilter = cell(Cs,1);
    channels = find(1-cellfun(@isempty,SR{handles.gui_number}.mlist))';
    for i=channels
        SR{handles.gui_number}.infilter{i} = true(size([SR{handles.gui_number}.mlist{i}.xc]));  % 
    end
SR{handles.gui_number}.cmax = .3*ones(Cs,1); % default values
SR{handles.gui_number}.cmin = 0*ones(Cs,1);  % default values
handles = ImLoad(hObject,eventdata, handles); % calls plotdata function