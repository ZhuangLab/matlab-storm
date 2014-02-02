function handles = CropperDriftCorrection(handles)

global CC scratchPath

% clear legend from previous step.  
ax = CC{handles.gui_number}.axesObjects.legend;
try
delete(ax);
catch
end

if isempty(CC{handles.gui_number}.mlist1)
    numChns = 1;
else
    numChns = 2;
end

for n=1:numChns

 % Load variables
 if n==1
     mlist = CC{handles.gui_number}.mlist;
 else
     mlist = CC{handles.gui_number}.mlist1;
 end
    drift_error = NaN;
      
    % Load user defined parameters
    H = CC{handles.gui_number}.pars0.H;
    W = CC{handles.gui_number}.pars0.W;
    npp = CC{handles.gui_number}.pars0.npp;
    
    folder = CC{handles.gui_number}.source;
    imnum = CC{handles.gui_number}.imnum;
    binfile = CC{handles.gui_number}.binfiles(imnum).name;
    daxname = [binfile(1:end-10),'.dax'];  
    
    if n==2
        daxname = regexprep(daxname,'647','750'); 
    end
    
    maxDrift = CC{handles.gui_number}.pars4.maxDrift(n);
    fmin = CC{handles.gui_number}.pars4.fmin(n);
    startFrame = CC{handles.gui_number}.pars4.startFrame(n);
    showPlots = CC{handles.gui_number}.pars4.showPlots(n); 
    showExtraPlots = CC{handles.gui_number}.pars4.showExtraPlots(n); 
    samplingRate = CC{handles.gui_number}.pars4.samplingRate(n); 
    % -------------- Method 1 (Default) -----------------------------
    % Attempts to automatically detect a movie of feducial beads and use
    % this for drift correction.  
    try
        beadname = regexprep(daxname,{'647quad','.dax'},{'561quad','_list.bin'});
        beadbin = [folder,filesep,beadname];
        axes(handles.axes1); cla; %#ok<*LAXES>
         [mlist,drift_error] = FeducialDriftCorrection(beadbin,...
             'maxdrift',maxDrift,'showplots',showPlots,'fmin',fmin,...
             'startframe',startFrame,'showextraplots',showExtraPlots,...
             'target',mlist,'samplingrate',samplingRate,'fighandle',handles.axes1);
          CC{handles.gui_number}.tempData.driftError = drift_error;
        goOn = true;
        retry = 0; 
    catch er
        disp(er.getReport);
        warning('Feducial Drift Correction Failed');
        retry = input(['Enter 1 to change parameters, 2 to attempt ',... 
            'image-based drift correction, 3 to skip. ']);
    end
    %--------------------------------------------------------------------
    
    %------------------ Method 2: Correlation based drift correction -----
    % (not as accurate as feducial beads)
    % 
    if retry == 2
        dlg_title = 'Step 4 Pars: Drift Correction';  num_lines = 1;
        Dprompt = {
        'Frames per correlation step',... 1
        'upsampling factor',... 2
        'show drift correction plots?',... 3 
        'Use data from local dot # (0=use full image)'};     %4

        Opts{1} = num2str(CC{handles.gui_number}.parsX.stepFrame);
        Opts{2} = num2str(CC{handles.gui_number}.parsX.scale);
        Opts{3} = num2str(CC{handles.gui_number}.parsX.showPlots);
        Opts{4} = num2str(CC{handles.gui_number}.parsX.local);
        Opts = inputdlg(Dprompt,dlg_title,num_lines,Opts);
        
        stepframe = str2num(Opts{1});   %#ok<ST2NM>
        scale = str2num(Opts{2});       %#ok<ST2NM>
        showplots = str2num(Opts{3});   %#ok<ST2NM>
        localRegion = str2num(Opts{4}); %#ok<ST2NM>
        
        if localRegion(n) == 0
           [x_drift,y_drift] = XcorrDriftCorrect(mlist,...
                'stepframe',stepframe(n),...
                'scale',scale(n),'showplots',showplots(n),...    
                'imagesize',[H,W],'nm per pixel',npp);
        else
            disp(['This option requires local regions to be detected first ',...
              'Run step 4 once without drift correction, then chose a dot ',...
              'and rerun step 4 using your preferred dot for calibration']); 
            vlist = CC{handles.gui_number}.vlists{ localRegion(n) };
            imaxes = CC{handles.gui_number}.imaxes{ localRegion(n) };
            H = imaxes.ymax - imaxes.ymin + 1;
            W = imaxes.xmax - imaxes.xmin + 1; 
            [x_drift,y_drift] = XcorrDriftCorrect(vlist,...
             'stepframe',stepframe(n),...
            'scale',scale(n),'showplots',showplots(n),...    
            'imagesize',[H,W],'nm per pixel',npp);  
                % local area may not have dots localized up through the last frame
            % of the movie.  Just assume no drift for these final frames if
            % doing local region based correction.  (They should only be a
            % couple to couple dozen of frames = a few seconds of drift at most).
            x_drift = [x_drift,zeros(1,max(mlist.frame)-max(vlist.frame))];
            y_drift = [y_drift,zeros(1,max(mlist.frame)-max(vlist.frame))];
        end
        mlist.xc = mlist.x - x_drift(mlist.frame)';
        mlist.yc = mlist.y - y_drift(mlist.frame)';
        goOn = true;
        %-----------------------------------------------------------------%
        
    elseif retry == 1;
        goOn = false;
        
    elseif retry == 3
        disp('skipping drift correction...')
        goOn = true; 
    end
    
    
    if goOn
        if n == 1
            CC{handles.gui_number}.mlist = mlist; % update mlist; 
        else
            CC{handles.gui_number}.mlist1 = mlist; % update mlist; 
        end   
    end
end


% use drift computation throughout 750 movie to align the 647 movie all the
% way back to the beginning of the data set.  
% Apply the chromatic warp.  
if n==2 
    BeadFolder = CC{handles.gui_number}.pars1.BeadFolder;
    warpfile = [BeadFolder,filesep,'chromewarps.mat'];
    mlists = {CC{handles.gui_number}.mlist1,...
             CC{handles.gui_number}.mlist};
         
    mlists = MultiChnDriftCorrect(mlists); 
  %  CC{handles.gui_number}.mlistsDC = mlists; % TEMPORARY Troubleshooting
    mlists = ApplyChromeWarp(mlists,{'750','647'},warpfile); 
    
 %   CC{handles.gui_number}.mlistsCW = mlists;  % TEMPORARY Troubleshooting
    CC{handles.gui_number}.mlist1 = mlists{1};
    CC{handles.gui_number}.mlist = mlists{2};   
end