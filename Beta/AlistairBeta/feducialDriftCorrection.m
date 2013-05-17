
fpath = 'J:\2013-05-15_AATAT\'
mlists = dir([fpath,'*_mlist.bin']);
alists = dir([fpath,'*_alist.bin']);

mlist = ReadMasterMoleculeList([fpath,mlists(1).name]);
alist = ReadMasterMoleculeList([fpath,alists(1).name]);



figure(1); clf; 
plot(mlist.x,mlist.y,'r.',mlist.xc,mlist.yc,'bo',alist.x,alist.y,'ko','MarkerSize',10);


maxdrift = 5; 
p1s = mlist.frame==1;
x1s = mlist.x(p1s);
y1s = mlist.y(p1s); 

figure(1); clf; 
plot(x1s,y1s,'k.');

[idx,dist] = knnsearch([x1s,y1s],[x1s,y1s],'K',2);
nottooclose = dist(:,2)>2*maxdrift;
x1s = x1s(nottooclose);
y1s = y1s(nottooclose);


fb =[x1s-maxdrift, x1s + maxdrift,y1s-maxdrift, y1s + maxdrift];
feducial_boxes = [fb(:,1),fb(:,3),...
    fb(:,2)-fb(:,1),fb(:,4)-fb(:,3)];

Nfeducials = length(x1s);
Nframes = double(max(mlist.frame));
% feducial_trajectories = cell(Nfeducials,1);
Fed_traj = NaN*ones(Nframes,Nfeducials,2);

for i=1:Nfeducials
    figure(1); hold on; rectangle('Position',feducial_boxes(i,:),'Curvature',[1,1]);
    incirc = mlist.x > fb(i,1) & mlist.x < fb(i,2) & mlist.y > fb(i,3) & mlist.y < fb(i,4);
    Fed_traj(mlist.frame(incirc),i,1) = mlist.x(incirc);
    Fed_traj(mlist.frame(incirc),i,2) = mlist.y(incirc);
end


% subtract starting position from each trajectory
dx = Fed_traj(:,:,1)-repmat(Fed_traj(1,:,1),Nframes,1);
dy = Fed_traj(:,:,2)-repmat(Fed_traj(1,:,2),Nframes,1);

% show drift traces
figure(2); clf;
subplot(1,2,1); plot(dx);
subplot(1,2,2); plot(dy);

% compute median drift 
dxmed = nanmedian(dx,2); % xdrift per frame
dymed = nanmedian(dy,2); % ydrift per frame

% correct drift in feducials;
xc = Fed_traj(:,:,1)-repmat(dxmed,1,Nfeducials);
yc = Fed_traj(:,:,2)-repmat(dymed,1,Nfeducials);

figure(3); clf; 
plot(Fed_traj(:,:,1),Fed_traj(:,:,2),'r.','MarkerSize',1); hold on;
plot(xc,yc,'k.','MarkerSize',1);

% compute residual error (FWHM) after drift correction
fwhm = zeros(Nfeducials,1);
for j=1:Nfeducials
    xc1 = xc(~isnan(xc(:,j)),j);
    yc1 = yc(~isnan(yc(:,j)),j);
    sf = fit2Dgauss(xc1,yc1,'showmap',false);
    fwhm(j) = (sf.sigmax+sf.sigmay)/2*(2*sqrt(2*log(2)))*160;
end
