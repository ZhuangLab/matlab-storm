function handles = CropperDriftCorrection(handles)

global CC

 % Load variables
    mlist = CC{handles.gui_number}.mlist;
    drift_err = '';
      
    % Load user defined parameters
    
    H = CC{handles.gui_number}.pars0.H;
    W = CC{handles.gui_number}.pars0.W;
    npp = CC{handles.gui_number}.pars0.npp;
        
    maxDrift = CC{handles.gui_number}.pars4.maxDrift;
    fmin = CC{handles.gui_number}.pars4.fmin;
    startFrame = CC{handles.gui_number}.pars4.startFrame;
    showPlots = CC{handles.gui_number}.pars4.showPlots; 
    showExtraPlots = CC{handles.gui_number}.pars4.showExtraPlots; 
    
    % -----------Apply Drift Correction------------------
    try
    beadname = regexprep(daxname,{'647quad','.dax'},{'561quad','_list.bin'});
    beadbin = [folder,filesep,beadname];
     [x_drift,y_drift,~,drift_err] = feducialDriftCorrection(beadbin,...
         'maxdrift',maxDrift,'showplots',showPlots,'fmin',fmin,...
         'startframe',startFrame,'showextraplots',showExtraPlots);
    missingframes = max(mlist.frame) - length(x_drift);
    x_drift = [x_drift; zeros(missingframes,1)];
    y_drift = [y_drift; zeros(missingframes,1)];
    mlist.xc = mlist.x - x_drift(mlist.frame);
    mlist.yc = mlist.y - y_drift(mlist.frame); 
    CC{handles.gui_number}.mlist = mlist; % update in global data
    goOn = true;
    retry = 0; 
    catch er
        disp(er.message);
        warning('Feducial Drift Correction Failed');
        retry = input(['Enter 1 to change parameters, 2 to attempt ',... 
            'image-based drift correction, 3 to skip. ']);
    end
    
    if retry == 2
           dlg_title = 'Step 4 Pars: Drfit Correction';  num_lines = 1;
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

        if eval(Opts{4})==0
       [x_drift,y_drift] = XcorrDriftCorrect(mlist,'stepframe',eval(Opts{1}),...
            'scale',eval(Opts{2}),'showplots',eval(Opts{3}),...    
            'imagesize',[H,W],'nm per pixel',npp);
        else
          disp(['This option requires local regions to be detected first ',...
              'Run step 4 once without drift correction, then chose a dot ',...
              'and rerun step 4 using your preferred dot for calibration']); 
          vlist = CC{handles.gui_number}.vlists{ eval(Opts{4}) };
          imaxes = CC{handles.gui_number}.imaxes{ eval(Opts{4}) };
          H = imaxes.ymax - imaxes.ymin + 1;
          W = imaxes.xmax - imaxes.xmin + 1; 
          [x_drift,y_drift] = XcorrDriftCorrect(vlist,...
             'stepframe',eval(Opts{1}),...
            'scale',eval(Opts{2}),'showplots',eval(Opts{3}),...    
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
        
    elseif retry == 1;
        goOn = false;
        
    elseif retry == 3
        disp('skipping drift correction...')
        x_drift = 0;
        y_drift = 0;
        goOn = true; 
    end
    
    if goOn
             % plot mask in main figure window
        axes(handles.axes1); cla;
        Nframes = length(x_drift); 
        try
        if Nframes > 1
            buf = round(.05*Nframes); 
        z = zeros(size(x_drift')); z= [z(1:end-buf),NaN*ones(1,buf)];
        col = [double(1:Nframes-1),NaN];  % This is the color, vary with x in this case.
         surface([x_drift';x_drift']*npp,[y_drift';y_drift']*npp,...
             [z;z],[col;col],'facecol','no','edgecol','interp',...
            'linew',1);    
        colormap('jet');
        set(gcf,'color','w'); 
        xlabel('nm'); 
        ylabel('nm'); 
        xlim([min(x_drift*npp),max(x_drift*npp)]);
        ylim([min(y_drift*npp),max(y_drift*npp)]);
         text(mean(x_drift*npp),mean(y_drift*npp),...
             ['Drift Correction Uncertainty: ',num2str(drift_err,3),'nm']);
        end
        catch
        end
        
        CC{handles.gui_number}.mlist = mlist; % update mlist; 
    end
 