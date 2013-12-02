



x = mlist.x;
y = mlist.y;
frame = mlist.frame;
wx = mlist.w ./ mlist.ax;   % /
wy = mlist.w .* mlist.ax;  % *
z = mlist.z;

scanzfile = [bead_path,'\',froot,'.off'];
fid = fopen(scanzfile);
stage = textscan(fid, '%d\t%f\t%f\t%f','headerlines',1);
fclose(fid);

zrange = max(stage{4}-stage{4}(1))*1000;
[maxoffset,Zmaxoffset] = max(stage{2});
offset_start = mean(stage{2}(1:Zmaxoffset-5));
nm_per_offsetunit = zrange/(maxoffset - offset_start);

zst = -stage{2}*nm_per_offsetunit; 
zst = zst - zst(1);
if PlotsOn
    stageplot = figure; plot(zst); 
    set(gcf,'color','w');
    xlabel('frame','FontSize',14); 
    ylabel('stage position','FontSize',14); 
    set(gca,'FontSize',14);
    saveas(stageplot,[bead_path,'\fig_',SaveRoot,Dao_root,froot,'_stage','.png']);
    if verbose; 
        disp(['wrote: ',bead_path,'\fig_',SaveRoot,Dao_root,froot,'_stage','.png']);
    end
end
[~,fstart] = min(zst);
[~,fend] = max(zst);
if fstart > fend
    zst = -zst;
    [~,fstart] = min(zst);
    [~,fend] = max(zst);
end
stagepos = zst(fstart:fend)
figure(1); clf; plot(x,y,'k.');

% cluster localizations


showextraplots = true;
showplots = true;
startframe = 290;
maxdrift = 2;
fmin = .5;

% Step 1, find all molecules that are "ON" in startframe.
if startframe == 1
    startframe = min(mlist.frame);
end
p1s = mlist.frame==startframe;
x1s = mlist.x(p1s);
y1s = mlist.y(p1s);

if showextraplots
   figure(2); clf; 
   plot(mlist.x,mlist.y,'k.','MarkerSize',1);
   hold on;
   plot(x1s,y1s,'bo');
   legend('all localizations','startframe localizations'); 
end

% Reject molecules that are too close to other molecules
if length(x1s) > 1
    [~,dist] = knnsearch([x1s,y1s],[x1s,y1s],'K',2);
    nottooclose = dist(:,2)>2*maxdrift;
    x1s = x1s(nottooclose);
    y1s = y1s(nottooclose);
end    

% Feducials must be ID'd in at least fmin fraction of total frames
fb =[x1s-maxdrift, x1s + maxdrift,y1s-maxdrift, y1s + maxdrift];
Tframes = zeros(length(x1s),1);
for i=1:length(x1s)
    inbox = mlist.x > fb(i,1) & mlist.x < fb(i,2) & ...
        mlist.y > fb(i,3) & mlist.y < fb(i,4) & ...
        mlist.frame > startframe;
   Tframes(i) = sum(inbox);
end
feducials = Tframes > fmin*(max(mlist.frame)-startframe); 


if sum(feducials) == 0 
   error('no feducials found. Try changing fmin or startframe');  
end
x1s = x1s(feducials);
y1s = y1s(feducials);
fb = fb(feducials,:);
feducial_boxes = [fb(:,1),fb(:,3),...
    fb(:,2)-fb(:,1),fb(:,4)-fb(:,3)];

if showplots
    colormap gray;
    figure(1); hold on; 
    plot(x1s,y1s,'k.');
end

%% Record position of feducial in every frame

Nfeducials = length(x1s);
Nframes = double(max(mlist.frame));
Fed_traj = NaN*ones(Nframes,Nfeducials,2);
figure(1); clf;
figure(2); clf; 
Cmap = jet(Nfeducials);
numMols = length(mlist.x);
incirc = false(Nfeducials,numMols);
inmotion= false(Nfeducials,numMols);
stagepos = cell(Nfeducials,1); 
off = [-200,1150,-220,1350,-320];
% off = [-400,-200,-200,200]; 
for i=1:Nfeducials
    incirc(i,:) = mlist.x > fb(i,1) & mlist.x <= fb(i,2) & mlist.y > fb(i,3) & mlist.y <= fb(i,4);
    inmotion(i,:) = mlist.frame >= fstart & mlist.frame <= fend; 
    stagepos{i} = zst(mlist.frame(incirc(i,:) & inmotion(i,:)));
    Fed_traj(mlist.frame(incirc(i,:)),i,1) = double(mlist.x(incirc(i,:)));
    Fed_traj(mlist.frame(incirc(i,:)),i,2) = double(mlist.y(incirc(i,:)));
    if showplots
        figure(1); hold on; 
        rectangle('Position',feducial_boxes(i,:),'Curvature',[1,1]);
        plot( mlist.x(incirc(i,:)), mlist.y(incirc(i,:)),'.',...
            'MarkerSize',5,'color',Cmap(i,:));
        figure(2); hold on; 
        plot(stagepos{i}+off(i), mlist.w(incirc(i,:) & inmotion(i,:)) ./...
            mlist.ax(incirc(i,:) & inmotion(i,:)),'+','color',Cmap(i,:));
        plot(stagepos{i}+off(i), mlist.w(incirc(i,:) & inmotion(i,:)) .*...
            mlist.ax(incirc(i,:) & inmotion(i,:)),'.','color',Cmap(i,:));
        ylim([0,2000]);
    end
end




