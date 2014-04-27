function STORMfinderDefaults(handles,eventdata,hObject)
% default parameters for STORMfinder

global SF
% initialize other variables as empty
SF{handles.gui_number}.inifile = ''; 
SF{handles.gui_number}.xmlfile = ''; 
SF{handles.gui_number}.gpufile = ''; 
SF{handles.gui_number}.mlist = []; 
SF{handles.gui_number}.FitPars = []; 
SF{handles.gui_number}.impars = []; 
SF{handles.gui_number}.fullmlist = []; 

% Default Analysis options
SF{handles.gui_number}.defaultAopts{1} = 'true';
SF{handles.gui_number}.defaultAopts{2} = 'false';
SF{handles.gui_number}.defaultAopts{3} = '2';
SF{handles.gui_number}.defaultAopts{4} = '60';
SF{handles.gui_number}.defaultAopts{5} = '95';
SF{handles.gui_number}.defaultAopts{6}= 'true';
SF{handles.gui_number}.defaultAopts{7}= '';

% Choose default command line output for STORMfinder
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);