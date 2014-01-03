function handles = ConvMask(handles)

global CC
 % load variables from previous step
        conv0 = CC{handles.gui_number}.conv;
        convI = CC{handles.gui_number}.convI;
        maskBeads = CC{handles.gui_number}.maskBeads;
        
        % load parameters
         saturate =  CC{handles.gui_number}.pars2.saturate; % 0.001;
         makeblack = CC{handles.gui_number}.pars2.makeblack; %  0.998; 
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
         
%          save([ScratchPath,'test.mat']);
%          load([ScratchPath,'test.mat']);

         maskIm = convI;
         maskIm(:,:,1) = maskIm(:,:,1) + uint16(2^16*daxMask);
         maskIm(:,:,2) = maskIm(:,:,2) + uint16(2^16*beadMask);
         daxMask = daxMask - beadMask > 0; 

%           figure(1); clf; imagesc(beadMask);
%            figure(2); clf; imagesc(daxMask);
         
         % plot mask
         axes(handles.axes1); cla;
         set(gca,'color','k');
         set(gca,'XTick',[],'YTick',[]);
         imagesc(maskIm); 
         xlim([0,W]); ylim([0,H]);
         
        % Save step data into global
        CC{handles.gui_number}.daxMask = daxMask; 