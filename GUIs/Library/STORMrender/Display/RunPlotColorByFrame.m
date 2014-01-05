function RunPlotColorByFrame(hObject,eventdata,handles)
global SR scratchPath

if ~isfield(SR{handles.gui_number},'pltColorByFramefig')
SR{handles.gui_number}.pltColorByFramefig =[];
end

npp = SR{handles.gui_number}.DisplayOps.npp;
vlist = MolsInView(handles);
chns = find(cellfun(@(x) ~isempty(x),vlist))';
Cs = length(chns); 
if ~isempty(SR{handles.gui_number}.pltColorByFramefig)
    if ishandle(SR{handles.gui_number}.pltColorByFramefig)
        close(SR{handles.gui_number}.pltColorByFramefig);
    end
end
SR{handles.gui_number}.pltColorByFramefig = figure; 

for c = chns
    if length(vlist{c}.x) > 2000
        msize = 1;
    else
        msize = 5; 
    end
    subplot(length(chns),1,c);
    ColorByFrame(vlist{c},'SizeData',msize,'npp',npp);
    lab = ['channel ',num2str(c)', ' # loc:',num2str(length(vlist{c}.x))];
    title(lab);
end
xlabel('x (nm)'); ylabel('y (nm)');