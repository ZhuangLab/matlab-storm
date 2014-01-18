function handles = AutoMultiLoad(handles)

global SR scratchPath  %#ok<NUSED>
stoprun = 0;
% confirm auto-load options
dlg_title = 'Bin file names must begin with unique channel flag';
num_lines = 1;
prompt = ...
    {'files containing string',...
    'bin type',...
    'channel flag',...
    'Match set to load (0 to print matches)'...
    };
default_opts = ...
    {SR{handles.gui_number}.LoadOps.sourceroot,...
    SR{handles.gui_number}.LoadOps.bintype,...
    CSL2str(SR{handles.gui_number}.LoadOps.chnFlag),...
    num2str(SR{handles.gui_number}.LoadOps.dataset),...
    };   
opts = inputdlg(prompt,dlg_title,num_lines,default_opts);

if ~isempty(opts) % don't try anything if dialogue box is canceled
    SR{handles.gui_number}.LoadOps.sourceroot = opts{1};
    SR{handles.gui_number}.LoadOps.bintype = opts{2};
    SR{handles.gui_number}.LoadOps.chnFlag = parseCSL(opts{3}); 
    SR{handles.gui_number}.LoadOps.dataset = str2double(opts{4});
    %  if we don't have a file path, prompt user to find one. 
    if isempty(SR{handles.gui_number}.LoadOps.pathin)
        SR{handles.gui_number}.LoadOps.pathin = uigetdir(pwd,'select data folder');
        if ~SR{handles.gui_number}.LoadOps.pathin
            SR{handles.gui_number}.LoadOps.pathin = '';
            stoprun = 1;
        end
    end

    if ~stoprun
        % Automatically group all bin files of same section in different colors
        %   based on image number, if it has not already been done
        if SR{handles.gui_number}.LoadOps.dataset == 0 || isempty(SR{handles.gui_number}.fnames)
        [SR{handles.gui_number}.bins,SR{handles.gui_number}.allfnames] = ...
            automatch_files( [SR{handles.gui_number}.LoadOps.pathin,filesep],...
               'sourceroot',SR{handles.gui_number}.LoadOps.sourceroot,...
               'filetype',SR{handles.gui_number}.LoadOps.bintype,...
               'chns',SR{handles.gui_number}.LoadOps.chnFlag);
        disp('files found and grouped:'); 
        disp(SR{handles.gui_number}.bins(:));
        end

        % Figure out which channels are really in data set  
        if SR{handles.gui_number}.LoadOps.dataset == 0
         i=1;
        else
         i=SR{handles.gui_number}.LoadOps.dataset;
        end

        hasdata = logical(1-cellfun(@isempty, SR{handles.gui_number}.bins(:,i)));
        binnames =  SR{handles.gui_number}.bins(hasdata,i); % length cls must equal length binnames
        if sum((logical(1-hasdata))) ~=0
        disp('no data found for in channels:');
        disp(SR{handles.gui_number}.LoadOps.chnFlag(logical(1-hasdata)))
        end

        SR{handles.gui_number}.fnames = SR{handles.gui_number}.allfnames(hasdata,i);
        disp('will load:');
        disp(SR{handles.gui_number}.fnames);   
        for c=1:length(SR{handles.gui_number}.fnames)
            handles = AddStormLayer(hObject,handles,SR{handles.gui_number}.fnames{c},c);
        end
    handles = MultiBinLoad(hObject,eventdata,handles,binnames);    
    end
end