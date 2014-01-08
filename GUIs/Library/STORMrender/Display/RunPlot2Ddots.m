function RunPlot2Ddots(handles)
    
global SR scratchPath
if ~isfield(SR{handles.gui_number},'plt3Dfig')
    SR{handles.gui_number}.plt3Dfig =[];
end

npp = 160; % should be a global in imageops or something
vlist = MolsInView(handles);

numChannels = length(vlist); 
channels = zeros(1,numChannels); % Storm Channels
for c = 1:numChannels; 
    channels(c) = eval(['get(','handles.sLayer',num2str(c),', ','''Value''',')']);
end
active_channels = find(channels);
cmap = hsv(numChannels);
lab = cell(numChannels,1);
if ~isempty(SR{handles.gui_number}.plt3Dfig)
    if ishandle(SR{handles.gui_number}.plt3Dfig)
        close(SR{handles.gui_number}.plt3Dfig);
    end
end
SR{handles.gui_number}.plt3Dfig = figure; 

for c = active_channels
    if length(vlist{c}.x) > 2000
        msize = 1;
    else
        msize = 5; 
    end
    plot(vlist{c}.xc*npp,vlist{c}.yc*npp,'.','color',cmap(c,:),...
        'MarkerSize',msize);
    lab{c} = ['channel ',num2str(c)', ' # loc:',num2str(length(vlist{c}.x))];
    hold on;
end
xlabel('x (nm)'); ylabel('y (nm)');
title(lab); 