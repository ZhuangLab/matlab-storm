function notCancel = ResumePrevious(handles)
% load data structure from a previously started analysis and pick up where
% you left off (reads existing data structure to determine what image you
% were on).  

global CC
savefolder = get(handles.SaveFolder,'String');
[fileName,filePath,notCancel] = uigetfile(savefolder);
if notCancel ~= 0
    disp('loading data..');
    load([filePath,filesep,fileName]);
    CC{handles.gui_number} = CCguiData;
%     CC{handles.gui_number}.data = data;
%     CC{handles.gui_number}.pars0 = CCguiData.pars0;
%     CC{handles.gui_number}.pars1 = CCguiData.pars1;
%     CC{handles.gui_number}.pars2 = CCguiData.pars2;
%     CC{handles.gui_number}.pars3 = CCguiData.pars3;
%     CC{handles.gui_number}.pars4 = CCguiData.pars4;
%     CC{handles.gui_number}.pars5 = CCguiData.pars5;
%     CC{handles.gui_number}.pars6 = CCguiData.pars6;
%     CC{handles.gui_number}.pars7 = CCguiData.pars7;
%     CC{handles.gui_number}.parsX = CCguiData.parsX;
%     CC{handles.gui_number}.imnum = CCguiData.imnum-1;
end