function handles = StormMask(handles)

global CC

 
if sum(CC{handles.gui_number}.daxMask1(:)) ~= 0
    numChns = 2;
else
    numChns = 1;
end

for n=1:numChns; 
     disp(['creating mask for channel ',num2str(n)]);
     
  % load variables from previous steps
      if n==1
           daxMask= CC{handles.gui_number}.daxMask;
      else
           daxMask= CC{handles.gui_number}.daxMask1;
      end
     cluster_scale= CC{handles.gui_number}.pars0.npp/...
                       CC{handles.gui_number}.pars3.boxSize(n); 
     maxsize =      CC{handles.gui_number}.pars3.maxsize(n);
     minsize =      CC{handles.gui_number}.pars3.minsize(n);
     mindots =      CC{handles.gui_number}.pars3.mindots(n); 
     startframe =   CC{handles.gui_number}.pars3.startFrame(n); 
     mindensity =   CC{handles.gui_number}.pars3.mindensity(n);
     convI =        CC{handles.gui_number}.convI;
     folder =       CC{handles.gui_number}.source;
     binfile = CC{handles.gui_number}.binfiles(CC{handles.gui_number}.imnum).name;
     H = CC{handles.gui_number}.pars0.H;
     W = CC{handles.gui_number}.pars0.W;
     
     if n==2
         binfile = regexprep(binfile,'647','750');
     end
     
    % Step 3: Load molecule list and bin it to create image
    mlist =     ReadMasterMoleculeList([folder,filesep,binfile]);
    mlist =     ReZeroROI(binfile,mlist);
    infilt =    mlist.frame>startframe;   
    M =         hist3([mlist.yc(infilt),mlist.xc(infilt)],...
                      {0:1/cluster_scale:H,0:1/cluster_scale:W});
    [h,w] =     size(M);             
    mask =      M>1;                                     %  figure(3); clf; imagesc(mask); 
    mask =      imdilate(mask,strel('disk',3));          %  figure(3); clf; imagesc(mask);
    toobig =    bwareaopen(mask,maxsize);                %  figure(3); clf; imagesc(mask);
    mask =      logical(mask - toobig) & imresize(daxMask,[h,w]); 
    mask =      bwareaopen(mask,minsize);                %  figure(3); clf; imagesc(mask);
    R =         regionprops(mask,M,'PixelValues','Eccentricity',...
                  'BoundingBox','Extent','Area','Centroid','PixelIdxList'); 
    aboveminsize =    cellfun(@sum,{R.PixelValues}) > mindots;
    abovemindensity = cellfun(@sum,{R.PixelValues})./[R.Area] > mindensity;
    R =         R(aboveminsize & abovemindensity);           
    
    % Just for plotting
    allpix =    cat(1,R(:).PixelIdxList);
    mask =      double(mask); 
    mask(allpix) = 3;
    if n == 1
        keep = mask>2; 
        reject = mask<2 & mask > 0;
        keep1 = keep;
        reject1 = reject; 
    else
        keep1 = mask>2; 
        reject1 = mask<2 & mask > 0;
    end

    % Export step data
    if n == 1
        CC{handles.gui_number}.mlist = mlist; 
        CC{handles.gui_number}.infilt = infilt; 
        CC{handles.gui_number}.R = R; % This is the STORM mask
        CC{handles.gui_number}.M = M; % This is for reference
    elseif n == 2
        CC{handles.gui_number}.mlist1 = mlist; 
        CC{handles.gui_number}.infilt1 = infilt; 
        CC{handles.gui_number}.R1 = R; % This is the STORM mask
        CC{handles.gui_number}.M1 = M; % This is for reference
    end    
end

% plot results 
 maskIm = imresize(convI,[h,w]);
 maskIm = maskIm + repmat(uint16(2^16*(keep+keep1)),1,1,4);
 maskIm(:,:,1) = maskIm(:,:,1) + uint16(2^16*(reject+reject1));

% plot mask in main figure window
axes(handles.axes1); cla;
set(gca,'color','k');
set(gca,'XTick',[],'YTick',[]);
Ncolor(maskIm); 
title('dot mask'); 
xlim([0,w]); ylim([0,h]);

%----------------------------
% Troubleshooting:
figure(1); clf; plot(CC{handles.gui_number}.mlist1.xc,CC{handles.gui_number}.mlist1.yc,'k.');
figure(1); clf; imagesc(CC{handles.gui_number}.M1);



figure(1); clf; 
subplot(2,2,1); imagesc(CC{handles.gui_number}.M);
subplot(2,2,2); imagesc(CC{handles.gui_number}.M1);
subplot(2,2,3); imagesc(keep);
subplot(2,2,4); imagesc(keep1);
