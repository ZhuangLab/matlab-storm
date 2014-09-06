function [figH,cdf2D,cdf2D_thresh,thr] = Plot2DWarpResults(data,dat,dat2,figH)

nm_per_pix = 158; 
xys = (nm_per_pix)^2;
thr = .75;


numSamples = length(dat2);

%% 2D XY average warp error


% pre-warp error (3D)
prewarperror2D = cell(numSamples,1); 
for s=1:numSamples
prewarperror2D{s} = sqrt( xys*(dat(s).sample.x - dat(s).refchn.x).^2 +...
                    xys*(dat(s).sample.y - dat(s).refchn.y).^2  );
end

% pre-warp error (3D)
warp1error2D = cell(numSamples,1); 
for s=1:numSamples
warp1error2D{s} = sqrt( xys*(dat2(s).sample.x - dat2(s).refchn.x).^2 +...
                    xys*(dat2(s).sample.y - dat2(s).refchn.y).^2  );
end

% post warp error (3D), 
postwarperror2D = cell(numSamples,1); 
cdf2D(numSamples).x = []; 
cdf2D_thresh = zeros(numSamples,1); 
for s=1:numSamples
postwarperror2D{s} = sqrt( xys*(dat2(s).sample.tx2D - dat2(s).refchn.x).^2 +...
                     xys*(dat2(s).sample.ty2D - dat2(s).refchn.y).^2 );
[cdf2D(s).y, cdf2D(s).x] = ecdf(postwarperror2D{s});
cdf2D_thresh(s)  = (cdf2D(s).x(find(cdf2D(s).y>thr,1,'first')));
disp([num2str(100*thr,2),'% of ',data(s).sample(1).chn,...
    ' 2D beads aligned to ', num2str(cdf2D_thresh(s)),'nm']);
end


% Histogram warp error
figH.warperr_2d = figure; clf; colordef white;
k=0;
for s=1:numSamples
    k=k+1;
    subplot(numSamples,3,k); hist(prewarperror2D{s},100);
    title(['unwarped ',data(s).sample(1).chn,' <error>: ',...
        num2str(mean(prewarperror2D{s}),3),'nm'],'FontSize',7);
    k=k+1;
    subplot(numSamples,3,k); hist(warp1error2D{s},100);
    title(['After affine ',data(s).sample(1).chn,' <error>: ',...
        num2str(mean(warp1error2D{s}),3),'nm'],'FontSize',7);
    k=k+1;
    subplot(numSamples,3,k); hist(postwarperror2D{s},100);  
    title(['2D warped ',data(s).sample(1).chn,': ' num2str(100*thr,2),...
        '% aligned to ', num2str(cdf2D_thresh(s),4),'nm'],'FontSize',7);
end
set(gcf,'color','w');

 