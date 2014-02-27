function UpdateConv(handles)
% Responds to toggle buttons in the Conventional panel.

global CC

% some shared parameters
H = CC{handles.gui_number}.pars0.H;
W = CC{handles.gui_number}.pars0.W;
convI = CC{handles.gui_number}.convI; 
clrmap = hsv(4);

% get the button states
channels = false(1,4); 
for c = 1:4; 
    channels(c) = eval(['get(','handles.oLayer',num2str(c),', ','''Value''',')']);
end


% update image (as determined by which step number we're on); 
if CC{handles.gui_number}.step == 1
    convI(:,:,~channels) = zeros(size(convI(:,:,~channels)));
    
    axes(handles.axes1); cla;
    Ncolor(convI,clrmap);
    xlim([0,W]); 
    ylim([0,H]);
    axes(handles.axes1);
    set(gca,'color','k');
    set(gca,'XTick',[],'YTick',[]);

    axes(handles.axes2); cla;
    Ncolor(convI,clrmap); 
    set(gca,'color','k');
    set(gca,'XTick',[],'YTick',[]);
    
elseif CC{handles.gui_number}.step == 2;
    
    beadMask = CC{handles.gui_number}.beadMask;
    daxMask0 = CC{handles.gui_number}.daxMask; % save Mask
    daxMask1 = CC{handles.gui_number}.daxMask1;
    maskIm =  CC{handles.gui_number}.convI;
    
    convMasks{1} = uint16(2^16*beadMask);
    convMasks{2} =  uint16(2^16*daxMask0);
    convMasks{3} = uint16(2^16*daxMask1);
    convMasks{4} = uint16(false(H,W));

    for c=find(channels)
        maskIm(:,:,c) = maskIm(:,:,c) + convMasks{c};
    end

     axes(handles.axes1); cla;
     set(gca,'color','k');
     set(gca,'XTick',[],'YTick',[]);
     Ncolor(maskIm,clrmap); 
     xlim([0,W]); ylim([0,H]);
     
elseif CC{handles.gui_number}.step == 3

    outlines = CC{handles.gui_number}.outlines; 
    [h,w] = size(outlines{1}); 
    convI(:,:,3:4) = zeros(H,W,2,'uint16'); 
    maskIm = .5*imresize(convI,[h,w]);
    maskIm(:,:,~channels) = zeros(size(maskIm(:,:,~channels)));
    maskIm(:,:,1) = maskIm(:,:,1) + uint16(2^16*(outlines{1}));
    maskIm(:,:,2) = maskIm(:,:,2) + uint16(2^16*(outlines{2}));
    maskIm(:,:,3) = maskIm(:,:,3) + uint16(2^16*(outlines{3}));
    maskIm(:,:,4) = maskIm(:,:,4) + uint16(2^16*(outlines{4}));

    % plot mask in main figure window
    clrmap = hsv(4); 
    axes(handles.axes1); cla;
    set(gca,'color','k');
    set(gca,'XTick',[],'YTick',[]);
    Ncolor(maskIm,clrmap); 
    title('dot mask'); 
    xlim([0,w]); ylim([0,h]); hold on;

    for i=1:4; 
        plot(0,0,'color',clrmap(i,:));
    end
    colordef black; colormap(hsv(4));
    CC{handles.gui_number}.axesObjects.legend = ...
       legend({'chn1 keep','chn1 reject','chn2 keep','chn2 reject'});


    
end
