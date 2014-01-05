function RunPlot2Ddots(handles)
    
    global SR scratchPath
if ~isfield(SR{handles.gui_number},'plt3Dfig')
    SR{handles.gui_number}.plt3Dfig =[];
end

npp = 160; % should be a global in imageops or something
vlist = MolsInView(handles);
chns = find(cellfun(@(x) ~isempty(x),vlist))';
Cs = length(chns); 
cmap = hsv(Cs);
lab = cell(Cs,1);
if ~isempty(SR{handles.gui_number}.plt3Dfig)
    if ishandle(SR{handles.gui_number}.plt3Dfig)
        close(SR{handles.gui_number}.plt3Dfig);
    end
end
SR{handles.gui_number}.plt3Dfig = figure; 

for c = chns
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