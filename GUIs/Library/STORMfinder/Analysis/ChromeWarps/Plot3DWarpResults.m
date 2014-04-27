function [figH,cdf,cdf_thresh,thr] = Plot3DWarpResults(data,dat,dat2,figH)

%% Defaults

nm_per_pix = 158; 
xys = (nm_per_pix)^2;
thr = .75;

fit3D = false;
mark = {'o','o','.'};

[~,numFields] = size(data(1).sample);
numSamples = length(dat); 
cmap = hsv(numSamples);

%% Main Function

% level unwarped zdata based on flatness of field in frame1
% syntax 
 % zlevel = z_apply - level_data([x_fit,y_fit,z_fit],[x_apply,y_apply])  (x,y,z to compute tilt)
for s=1:numSamples
     zc_ref  = LevelData([dat2(s).refchn.x, dat2(s).refchn.y, dat2(s).refchn.z],[dat2(s).refchn.x, dat2(s).refchn.y]); % unwarped ref data
     dat2(s).refchn.zo  = dat2(s).refchn.z - zc_ref;
     zc_sample  = LevelData([dat2(s).sample.x, dat2(s).sample.y, dat2(s).sample.z],[dat2(s).sample.x, dat2(s).sample.y]); % unwarped sample data
    dat2(s).sample.zo = dat2(s).sample.z- zc_sample;  
end


%% 
% Color coded histograms of the leveled z-distributions of beads in each
% color.  The bar color indicates the actual cluster. 
zmin = -650; zmax = 650; % for plotting only

if fit3D
dataIs3D = true;
try
    passes = numFields/fpZ ;
    col = hsv(passes+1);
    sample_clust = zeros(numSamples,passes+1);
    ref_clust = zeros(numSamples,passes+1);
    for n=1:numSamples    
        for j=1:passes % separate molecules into z clusters
            ks = (1+(j-1)*fpZ:j*fpZ); % subset of frames at specific z-height
            sample_clust(n,j+1) = sample_clust(n,j) + sum(cellfun(@length,set2{n}.z(ks)));
            ref_clust(n,j+1) = ref_clust(n,j) + sum(cellfun(@length,set1{n}.z(ks)));
        end
    end

    % histogram each z cluster as a different color.  Do for each of the
        % channels (including reference channels) 
    figH.zdist = figure; clf;
    
    hx = linspace(zmin,zmax,50);    
    for n=1:numSamples    
        for j=2:passes+1 % j=3;
        % for sample beads
        subplot(numSamples,2,(2*n)-1); 
        hist(dat2(n).sample.zo(sample_clust(n,j-1)+1: sample_clust(n,j) ),hx);
        title(['plot: ',num2str((2*n)-1),' ', data(n).sample(1).chn]); 
        xlim([zmin,zmax]); hold on;
        h1  = findobj(gca,'Type','Patch'); 
        set(h1(1),'FaceColor',col(j-1,:),'EdgeColor',col(j-1,:)); alpha .7;

        % For reference beads
        subplot(numSamples,2,(2*n)); 
        hist(dat2(n).refchn.zo(ref_clust(n,j-1)+1: ref_clust(n,j) ),hx);
        title(['plot: ',num2str((2*n)),' ', data(n).refchn(1).chn]); 
        xlim([zmin,zmax]); hold on;
        h1  = findobj(gca,'Type','Patch'); 
        set(h1(1),'FaceColor',col(j-1,:),'EdgeColor',col(j-1,:)); alpha .7; 
        end
    end
     colormap(col(1:passes,:));
     colorbar; caxis([1,passes]);
     set(gcf,'color','w');
catch er
    disp(er.message)
    disp(['error in computing histogram of z-positions.  ',...
        'Perhaps the wrong number of frames per z positions is entered']);
    disp(['should the frames per z be: ',num2str(fpZ)]);
    dataIs3D = false; 
end
else
    dataIs3D = false; 
end
%%  XZ error
if dataIs3D
figH.xzerr =  figure; clf;
  subplot(1,2,1);
  for s=1:numSamples
  plot(dat(s).refchn.x,dat(s).refchn.z,mark{s},'color',cmap(s,:)); hold on;
  plot(dat(s).sample.x,dat(s).sample.z,'+','color',cmap(s,:)); hold on;
  end
 title('unwarped xz scatter');     ylim([zmin,zmax]); % xlim([100,110]);    

   subplot(1,2,2);
  for s=1:numSamples
  plot(dat2(s).refchn.x,dat2(s).refchn.z,mark{s},'color',cmap(s,:)); hold on;
  plot(dat2(s).sample.tx,dat2(s).sample.tz,'+','color',cmap(s,:)); hold on;
  end
 title('warped xz scatter');     ylim([zmin,zmax]); % xlim([100,110]);    
end
 

%% XY average warp error
% xy error
figH.xyerr_all =  figure; clf; subplot(1,2,1);
  for s=1:numSamples
  plot(dat(s).refchn.x,dat(s).refchn.y,mark{s},'color',cmap(s,:)); hold on;
  plot(dat(s).sample.x,dat(s).sample.y,'+','color',cmap(s,:)); hold on;
  end
 title('unwarped');  

 subplot(1,2,2);
  for s=1:numSamples
  plot(dat2(s).refchn.x,dat2(s).refchn.y,mark{s},'color',cmap(s,:)); hold on;
  plot(dat2(s).sample.tx,dat2(s).sample.ty,'+','color',cmap(s,:)); hold on;
  end
 title('warped');  
 
 
figH.xyerr =  figure; clf; subplot(1,2,1);
xmin = 100; xmax = 130; ymin = 100; ymax = 130; 
  for s=1:numSamples
  plot(dat(s).refchn.x,dat(s).refchn.y,mark{s},'color',cmap(s,:)); hold on;
  plot(dat(s).sample.x,dat(s).sample.y,'+','color',cmap(s,:)); hold on;
  end
 title('unwarped');   
 xlim([xmin,xmax]); 
 ylim([ymin,ymax]); 

 subplot(1,2,2);
  for s=1:numSamples
  plot(dat2(s).refchn.x,dat2(s).refchn.y,mark{s},'color',cmap(s,:)); hold on;
  plot(dat2(s).sample.tx,dat2(s).sample.ty,'+','color',cmap(s,:)); hold on;
  end
 title('warped');
 xlim([xmin,xmax]);
 ylim([ymin,ymax]);  

%% 3D Total warp error

% pre-warp error (3D)
prewarperror = cell(numSamples,1); 
for s=1:numSamples
prewarperror{s} = sqrt( xys*(dat(s).sample.x - dat(s).refchn.x).^2 +...
                 xys*(dat(s).sample.y - dat(s).refchn.y).^2 +...
                (dat(s).sample.z - dat(s).refchn.z).^2 );
end

% post-warp1 error (3D)
warp1error = cell(numSamples,1); 
for s=1:numSamples
warp1error{s} = sqrt( xys*(dat2(s).sample.x - dat2(s).refchn.x).^2 +...
                 xys*(dat2(s).sample.y - dat2(s).refchn.y).^2 +...
                (dat2(s).sample.z - dat2(s).refchn.z).^2 );
end

% post warp error (3D), 
postwarperror = cell(numSamples,1); 
cdf(numSamples).x = []; 
cdf_thresh = zeros(numSamples,1); 
for s=1:numSamples
postwarperror{s} = sqrt( xys*(dat2(s).sample.tx - dat2(s).refchn.x).^2 +...
                     xys*(dat2(s).sample.ty - dat2(s).refchn.y).^2 +...
                    (dat2(s).sample.tz - dat2(s).refchn.z).^2 );
[cdf(s).y, cdf(s).x] = ecdf(postwarperror{s});
cdf_thresh(s)  = (cdf(s).x(find(cdf(s).y>thr,1,'first')));
disp([num2str(100*thr,2),'% of ',data(s).sample(1).chn,...
    ' 3D beads aligned to ', num2str(cdf_thresh(s)),'nm']);
end

% Histogram warp error
figH.warperr = figure; clf; 
k=0;
for s=1:numSamples
    k=k+1;
    subplot(numSamples,3,k); hist(prewarperror{s},100);
    title(['unwarped ',data(s).sample(1).chn,' <error>: ',...
        num2str(mean(prewarperror{s}),3),'nm'],'FontSize',7);
    k=k+1;
    subplot(numSamples,3,k); hist(warp1error{s},100);
    title(['After affine : ',data(s).sample(1).chn,' <error>: ',...
        num2str(mean(warp1error{s}),3),'nm'],'FontSize',7);
    k=k+1;
    subplot(numSamples,3,k); hist(postwarperror{s},100);  
    title(['3D warped ',data(s).sample(1).chn,': ' num2str(100*thr,2),...
        '% aligned to ', num2str(cdf_thresh(s),4),'nm'],'FontSize',7);
end
set(gcf,'color','w');

