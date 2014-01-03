function handles = LoadConv(handles)

global CC

% Previously common parameters
%-------------------------------------------------------
     H = CC{handles.gui_number}.pars0.H;
     W = CC{handles.gui_number}.pars0.W;
     
%      % Image properties 
%         imaxes.H = H;
%         imaxes.W = W;
%         imaxes.scale = 1;
        
% If first time running, find all bin files in folder        
if isempty(CC{handles.gui_number}.source)
    CC{handles.gui_number}.source = get(handles.SourceFolder,'String'); 
       
    CC{handles.gui_number}.binfiles = ...
         dir([CC{handles.gui_number}.source,filesep,'*_alist.bin']);
end

if isempty(CC{handles.gui_number}.binfiles)
 error(['error, no alist.bin files found in folder ',...
     CC{handles.gui_number}.source]);
end   

% Parse bin name and dax name for current image
    binfile = CC{handles.gui_number}.binfiles(CC{handles.gui_number}.imnum);
    folder = CC{handles.gui_number}.source;
    daxname = [binfile.name(1:end-10),'.dax'];    
    set(handles.ImageBox,'String',binfile.name);
    imnum = CC{handles.gui_number}.imnum;
    CC{handles.gui_number}.daxname = daxname;

    if isempty(CC{handles.gui_number}.pars1.BeadFolder)
        CC{handles.gui_number}.pars1.BeadFolder = ...
            [folder,filesep,'..',filesep,'Beads',filesep];
        
% Orig Step 1        
%----------------------------
      goOn = true;
    % MaxProjection of Conventional Image    
         convname = regexprep([folder,filesep,daxname],'storm','conv*');
         convname = dir(convname);
         convZs = length(convname);
         dax = zeros(H,W,1,'uint16');
         for z=1:convZs
             try
                 daxtemp = mean(ReadDax([folder,filesep,convname(z).name],'verbose',false),3);
                 dax = max(cat(3,dax,daxtemp),[],3);
             catch er
                 disp(er.message);
             end
         end
             
         figure(11); clf; imagesc(dax); colorbar; colormap hot;
         title('conventional image projected');
         try
            % get conventional image name, 
            if isempty(strfind(daxname,'647quad'))
            conv0Name = ['splitdax\647quad_',regexprep(daxname,'storm','conv_z0')];
            conv0Name = [folder,filesep,conv0Name];
            else
            conv0Name = regexprep([folder,filesep,daxname],'storm','conv_z0');
            end
            conv0 = mean(ReadDax(conv0Name,'verbose',false),3);
         catch er
            disp(er.message);
            disp(['could not find file ',conv0Name]);
            conv0 = dax;  
         end

          %%% try to load lamina and beads
         try
            laminaName =  regexprep(conv0Name,'647','488');
            lamina = mean(ReadDax(laminaName,'verbose',false),3);
         catch er
            disp(er.message);
            lamina = zeros(size(dax),'uint16');  
         end
         
         try
             beadsName=regexprep(conv0Name,'647','561');
             beads= mean(ReadDax(beadsName,'verbose',false),3);
         catch er
            disp(er.message);
            beads = zeros(size(dax),'uint16');
         end
         %%% try to correct channel misfits
         BeadFolder = CC{handles.gui_number}.pars1.BeadFolder;
         
         try
             if ~strcmp(BeadFolder,'skip')
                 warpfile = [BeadFolder,filesep,'chromewarps.mat'];
                 load(warpfile);

                 chn488 = find(strcmp(chn_warp_names(:,1),'488')); %#ok<NODEF>
                warpedLamina = imtransform(lamina,tform_1_inv{chn488},...
                    'XYScale',1,'XData',[1 W],'YData',[1 H]); %#ok<*DIMTRNS,USENS>
                warpedLamina = imtransform(warpedLamina,tform2D_inv{chn488},...
                    'XYScale',1,'XData',[1 W],'YData',[1 H]); %#ok<USENS>

                 chn561 = find(strcmp(chn_warp_names(:,1),'561'));
                warpedBeads = imtransform(beads,tform_1_inv{chn561},...
                    'XYScale',1,'XData',[1 W],'YData',[1 H]);
                warpedBeads = imtransform(warpedBeads,tform2D_inv{chn561},...
                    'XYScale',1,'XData',[1 W],'YData',[1 H]);
             end
         catch er
             % save([ScratchPath,'test.mat']);
             %  load([ScratchPath,'test.mat']);
             goOn = false;
             disp(er.message);
             BeadFolder = uigetdir(folder,'..');
             if BeadFolder == 0
                BeadFolder = 'skip';
             end 
             CC{handles.gui_number}.pars1.BeadFolder = BeadFolder;
             disp(BeadFolder)
             if ~strcmp(BeadFolder,'skip')
                 warpfile = [BeadFolder,filesep,'chromewarps.mat'];
                 load(warpfile);
                 disp(['found ',warpfile,' Rerun step to continue']);    
             else % skip drift correction
                  goOn = true;
             end
         end
         
%          save([ScratchPath,'test.mat']);
%          load([ScratchPath,'test.mat']);
         
         
         if goOn
             
             if  strcmp(BeadFolder,'skip')
                 warpedLamina = lamina;
                 warpedBeads = beads;
             end
             
            conv0 = uint16(conv0);
            warpedBeads = uint16(warpedBeads);
            warpedLamina = uint16(warpedLamina);           
            conv0 = imadjust(conv0,stretchlim(conv0,0));
            warpedBeads = imadjust(warpedBeads,stretchlim(warpedBeads,0));
            warpedLamina = imadjust(warpedLamina,stretchlim(warpedLamina,0));

            % save([ScratchPath,'test.mat'])
            %  load([ScratchPath,'test.mat'])

            axes(handles.axes1);
            set(gca,'color','k');
            set(gca,'XTick',[],'YTick',[]);
            [H,W] = size(conv0);
            convI = zeros(H,W,3,'uint16');
            convI(:,:,1) = conv0;
            convI(:,:,2) = warpedBeads;
            convI(:,:,3) = warpedLamina;        

            % Plot results
            axes(handles.axes1);
            set(gca,'color','k');
            set(gca,'XTick',[],'YTick',[]);
            imagesc(convI);
            colormap hot;
            xlim([0,W]); ylim([0,H]);

            axes(handles.axes2);
            imagesc(convI); colormap hot;
            set(gca,'color','k');
            set(gca,'XTick',[],'YTick',[]);

            % Save step data into global; 
            CC{handles.gui_number}.conv = conv0;  
            CC{handles.gui_number}.maskBeads = warpedBeads;
            CC{handles.gui_number}.convI = convI;
         end

    end