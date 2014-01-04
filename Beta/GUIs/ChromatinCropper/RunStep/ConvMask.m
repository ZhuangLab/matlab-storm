function handles = ConvMask(handles)

global CC
 % load variables from previous step
 
if ~isempty(CC{handles.gui_number}.conv1)
numChns = 2;
else
 numChns = 1;
end

for n=1:numChns; 
     disp(['creating mask for channel ',num2str(n)]);

     if n == 1; 
         conv0 = CC{handles.gui_number}.conv;
     else
         conv0 = CC{handles.gui_number}.conv1; 
     end

    convI = CC{handles.gui_number}.convI;
    maskBeads = CC{handles.gui_number}.maskBeads;
    [H,W] = size(conv0);
    daxMask1 = false(H,W); 

    % load parameters
     saturate =  CC{handles.gui_number}.pars2.saturate(n); % 0.001;
     makeblack = CC{handles.gui_number}.pars2.makeblack(n); %  0.998; 
     beadDilate = CC{handles.gui_number}.pars2.beadDilate; %  2; 
     beadThresh = CC{handles.gui_number}.pars2.beadThresh; %  .3; 


    % Step 2: Threshold to find spots  [make these parameter options]
     try
         daxMask = mycontrast(uint16(conv0),saturate,makeblack); 
     catch er
         disp(er.message)
     end
     % figure(2); clf; imagesc(daxMask); colorbar;
     daxMask = daxMask > 1;
     beadMask = imdilate(maskBeads,strel('disk',beadDilate));
     beadMask = im2bw(beadMask,beadThresh);
     daxMask = daxMask - beadMask > 0; 
     if n==1
        daxMask0 = daxMask;
     else
        daxMask1 = daxMask;
     end
 end
 
 maskIm = convI;
 maskIm(:,:,2) = maskIm(:,:,2) + uint16(2^16*daxMask0);
 maskIm(:,:,3) = maskIm(:,:,3) + uint16(2^16*daxMask1);
 maskIm(:,:,1) = maskIm(:,:,1) + uint16(2^16*beadMask);
 

 figure(1); clf; 
 subplot(1,2,1); imagesc(daxMask0); 
 subplot(1,2,2); imagesc(daxMask1);
 
 % plot mask
 axes(handles.axes1); cla;
 set(gca,'color','k');
 set(gca,'XTick',[],'YTick',[]);
 cMap = lines(4); 
 Ncolor(maskIm,cMap); 
 xlim([0,W]); ylim([0,H]);

CC{handles.gui_number}.daxMask = daxMask0; % save Mask
CC{handles.gui_number}.daxMask1 = daxMask1;
 

        