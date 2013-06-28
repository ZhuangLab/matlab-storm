% PlotDax2Bin

% function in development
% script version is functional 06/11/13


%% Required Inputs
% daxfile / string 
% region (xmin,xmax,ymin,ymax);

close all;
clear dax; clear bin;
startFrame = 800;
endFrame = 3000; 
daxfile = 'F:\2012-02-06\H3\647_0001.dax';
region = [110+20 160-15 180+14 230-27]; % region = [110 160 180 230];

% daxfile = 'F:\2012-02-24\Psc-hox\750cal_0001.dax';
% daxfile = 'L:\2013-05-04_en_emb\STORM\647_en_emb_storm_0_7.dax';
% region = [155,170,90,95];
%  daxfile ='H:\2013-05-28_K\647_k_storm_0001.dax';
% region= [130,150,125,145]; % 
%  daxfile = 'H:\2013-06-05_BB3\647_BB3_BXC_storm_0_1.dax';
% region = [90 110 180 200];

bin = ReadMasterMoleculeList([daxfile(1:end-4),'_alist.bin']);
figure(2); clf; plot(bin.xc,bin.yc,'k.','MarkerSize',1);


daxM = max(ReadDaxBeta(daxfile,'startFrame',1,'endFrame',100),[],3);
figure(3); clf; imagesc(daxM); colormap gray;
daxC = max(ReadDaxBeta(daxfile,'startFrame',1,'endFrame',300,...
    'subregion',region),[],3);
figure(3); clf; imagesc(daxC); colormap gray; colorbar;
hold on;
plot(bin.x,bin.y,'y.','MarkerSize',1);

dax = ReadDaxBeta(daxfile,'startFrame',startFrame,'endFrame',endFrame,'subregion',...
    region);

figure(1); clf; hist(bin.h,1000);

inbox = bin.xc > region(1) & bin.xc < region(2) & ...
    bin.yc > region(3) & bin.yc < region(4) & bin.h > 130;  %...
    % bin.frame > startFrame-1 & bin.frame < endFrame+1;
x = bin.xc(inbox)-region(1)+1;
y = bin.yc(inbox)-region(3)+1;


daxT = max(dax,[],3);
figure(2); clf; imagesc(daxT); colormap gray;
hold on; plot(x,y,'y.'); % caxis([500,7500]);



figure(3); clf; 
subplot(1,2,1);
imagesc(daxT); colormap gray;
set(gcf,'color','k');
subplot(1,2,2);  imagesc(0*daxT); hold on;
hold on; plot(x,y,'r.');

[h,w,L] = size(dax);
dots = bin.frame(inbox)> startFrame & bin.frame(inbox)< startFrame ...
    + L-1 & bin.h(inbox) > 300;
allframes = bin.frame(inbox);
Nframes = length(unique(allframes(dots)));

close all;
clear Frame STORM mov;
figure(1); clf; colormap gray;
set(gcf,'color','k');
figure(2); clf;  imagesc(0*daxT);  colormap gray; hold on;
set(gcf,'color','k');
Frame(Nframes) = struct('cdata',[],'colormap','gray');
STORM(Nframes) = struct('cdata',[],'colormap','gray');
n = 0;
for t=1:L
    figure(1);
    f = t + startFrame -1 ; 
    inframe = f == bin.frame(inbox) & bin.h(inbox)>300; 
    if sum(inframe)>0
        n = n+1;
        % subplot(1,2,1); cla;
        figure(1); cla;  
        imagesc(dax(:,:,t)); caxis([150,1200]); hold on;
        plot(x(inframe),y(inframe),'ro','MarkerSize',10); 
        pause(.001); 
        Frame(n) = getframe;     
        figure(2);           
        plot(x(inframe),y(inframe),'r.','MarkerSize',10); hold on; 
        pause(.001); 
        STORM(n) = getframe;
     end
end
figure(10); clf; movie(STORM,1);

% Merge frames into single movie.   
clear mov;
mov(Nframes)= struct('cdata',[],'colormap','gray');
for n =1:Nframes
    Frame(n).colormap = 'gray';
    STORM(n).colormap = 'gray';
    mov(n).cdata = [Frame(n).cdata,STORM(n).cdata];
    mov(n).colormap = 'gray';
end
figure(10); clf; movie(mov,1);
movie_name = 'C:\Users\Alistair\Videos\H3_STORM.avi';
movie2avi(mov,movie_name,'colormap',colormap(gray(230)),'fps',30);

% Plot Rendered image
imaxes.W = 300;
imaxes.H = 250;
imaxes.xmin = region(1);
imaxes.xmax = region(2);
imaxes.ymin = region(3);
imaxes.ymax = region(4);
imaxes.zm = 20;
imaxes.cx = (imaxes.xmin + imaxes.xmax)/2;
imaxes.cy = (imaxes.ymin + imaxes.ymax)/2;
imaxes.scale = 1;

I = plotSTORM_colorZ({bin},imaxes,'scalebar',500,'correct drift',true,...
    'Zsteps',1,'dotsize',5);
dotim = figure(1); clf; imagesc(4*I{1}); colormap gray;
    
