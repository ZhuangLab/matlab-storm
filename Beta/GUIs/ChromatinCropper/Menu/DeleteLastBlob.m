function DeleteLastBlob(handles)

global CC


dotnum = find(~isnan(CC{handles.gui_number}.data.mainArea(:,1)),1,'last');
confirm = questdlg(['Confirm deletion of blob',num2str(dotnum)],'confirm delete','yes','no','no') ;

if strcmp(confirm,'yes')
CC{handles.gui_number}.data.mainArea(dotnum,:) = NaN; %   <-- backup 1  
end