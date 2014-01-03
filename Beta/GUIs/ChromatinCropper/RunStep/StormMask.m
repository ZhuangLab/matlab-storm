function handles = StormMask(handles)

global CC

  % load variables from previous steps
     daxMask = CC{handles.gui_number}.daxMask;
     convI = CC{handles.gui_number}.convI;
     maxsize = CC{handles.gui_number}.pars3.maxsize;
     minsize = CC{handles.gui_number}.pars3.minsize;
     mindots = CC{handles.gui_number}.pars3.mindots; 
     startframe = CC{handles.gui_number}.pars3.startFrame; 
     mindensity = CC{handles.gui_number}.pars3.mindensity;
     
     % Step 3: Load molecule list and bin it to create image
        mlist = ReadMasterMoleculeList([folder,filesep,binfile.name]);
        infilt = mlist.frame>startframe;   
        M = hist3([mlist.yc(infilt),mlist.xc(infilt)],...
             {0:1/cluster_scale:H,0:1/cluster_scale:W});
        [h,w] = size(M);             
        mask = M>1;  %        figure(3); clf; imagesc(mask); 
        mask = imdilate(mask,strel('disk',3)); %       figure(3); clf; imagesc(mask);
        toobig = bwareaopen(mask,maxsize);  % figure(3); clf; imagesc(mask);
        mask = logical(mask - toobig) & imresize(daxMask,[h,w]); 
        mask = bwareaopen(mask,minsize);    % figure(3); clf; imagesc(mask);
        R = regionprops(mask,M,'PixelValues','Eccentricity',...
            'BoundingBox','Extent','Area','Centroid','PixelIdxList'); 
        aboveminsize = cellfun(@sum,{R.PixelValues}) > mindots;
        abovemindensity = cellfun(@sum,{R.PixelValues})./[R.Area] > mindensity;
        R = R(aboveminsize & abovemindensity);           
        allpix = cat(1,R(:).PixelIdxList);
        mask = double(mask); 
        mask(allpix) = 3;
        
        keep = mask>2; 
        reject = mask<2 & mask > 0;
            
         maskIm = imresize(convI,[h,w]);
         maskIm(:,:,1) = maskIm(:,:,1) + uint16(2^16*keep);
         maskIm(:,:,3) = maskIm(:,:,3) + uint16(2^16*reject);
        
        % plot mask in main figure window
        axes(handles.axes1); cla;
        set(gca,'color','k');
        set(gca,'XTick',[],'YTick',[]);
        imagesc(maskIm); title('dot mask'); 
        xlim([0,w]); ylim([0,h]);
        
        % Export step data
        CC{handles.gui_number}.mlist = mlist; 
        CC{handles.gui_number}.infilt = infilt; 
        CC{handles.gui_number}.R = R; 
        CC{handles.gui_number}.M = M; 