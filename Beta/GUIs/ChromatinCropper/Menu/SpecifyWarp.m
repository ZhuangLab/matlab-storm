function SpecifyWarp(handles)

global CC

[~,newFolder,notCancel] = uigetfile(CC{handles.gui_number}.pars1.BeadFolder,...
    'Select chromewarps.mat file');
if notCancel ~= 0 
CC{handles.gui_number}.pars1.BeadFolder = newFolder; 
end