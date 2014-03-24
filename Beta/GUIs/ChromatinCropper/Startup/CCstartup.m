function handles = CCstartup(handles)
% Default parameter values for Chromatin Cropper

% Initialize Global GUI Parameters
global CC
if isempty(CC) % Build GUI instance ID 
    CC = cell(1,1);
else
    CC = [CC;cell(1,1)];
end
handles.gui_number = length(CC);


% Cleanup Axes
axes(handles.axes1);
set(gca,'color','k');
set(gca,'XTick',[],'YTick',[]);

axes(handles.axes2);
set(gca,'color','k');
set(gca,'XTick',[],'YTick',[]);

% update instance ID#     
set(handles.CCinstance,'String',['inst id',num2str(handles.gui_number)]);

% Directions for steps
CC{handles.gui_number}.source = '';
CC{handles.gui_number}.imnum = 1;
CC{handles.gui_number}.step = 1;
CC{handles.gui_number}.Dirs = ...
   {'Step 1: load conventional image';
    'Step 2: Find all spots in conventional image';
    'Step 3: load STORM image and filter on cluster properties';
    'Step 4: Perform drift correction';
    'Step 5: Crop and plot STORM-image';
    'Step 6: Quantify structural features and save locus data'};

ResetCCparameterDefaults(handles); 
ResetCCdata(handles);


