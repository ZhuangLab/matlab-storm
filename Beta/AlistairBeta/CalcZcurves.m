
% startup;

PlotsOn = true;

daxfile = 'O:\2013-12-01_F08\Beads\647_zcal_0002.dax';
[bead_path,daxname] = extractpath(daxfile);
binfile = regexprep(daxfile,'.dax','_list.bin');
froot = regexprep(daxname,'.dax','');

mlist = ReadMasterMoleculeList(binfile);

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
%     saveas(stageplot,[bead_path,'\fig_',SaveRoot,Dao_root,froot,'_stage','.png']);
%     if verbose; 
%         disp(['wrote: ',bead_path,'\fig_',SaveRoot,Dao_root,froot,'_stage','.png']);
%     end
end
[~,fstart] = min(zst);
[~,fend] = max(zst);
if fstart > fend
    zst = -zst;
    [~,fstart] = min(zst);
    [~,fend] = max(zst);
end
stagepos = zst(fstart:fend);


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
    figure(2); hold on; 
    plot(x1s,y1s,'r.');
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
Wx = cell(Nfeducials,1);
Wy = cell(Nfeducials,1); 
xpos = cell(Nfeducials,1);
ypos = cell(Nfeducials,1); 
off = zeros(1,Nfeducials);
% off = [-200,1150,-220,1350,-320];
% off = [-400,-200,-200,200]; 
for i=1:Nfeducials
    incirc(i,:) = mlist.x > fb(i,1) & mlist.x <= fb(i,2) & mlist.y > fb(i,3) & mlist.y <= fb(i,4);
    inmotion(i,:) = mlist.frame >= fstart & mlist.frame <= fend; 
    stagepos{i} = zst(mlist.frame(incirc(i,:) & inmotion(i,:)));
    Fed_traj(mlist.frame(incirc(i,:)),i,1) = double(mlist.x(incirc(i,:)));
    Fed_traj(mlist.frame(incirc(i,:)),i,2) = double(mlist.y(incirc(i,:)));
    Wx{i} = double( mlist.w(incirc(i,:) & inmotion(i,:)) ./...
                    mlist.ax(incirc(i,:) & inmotion(i,:)) );
    Wy{i} = double( mlist.w(incirc(i,:) & inmotion(i,:)) .*...
                    mlist.ax(incirc(i,:) & inmotion(i,:)) );
    xpos{i} = mlist.x(incirc(i,:));
    ypos{i} = mlist.y(incirc(i,:));
    if showplots
        figure(1); hold on; 
        rectangle('Position',feducial_boxes(i,:),'Curvature',[1,1]);
        plot( xpos{i},ypos{i},'.','MarkerSize',5,'color',Cmap(i,:));
        figure(2); hold on; 
        plot(stagepos{i}+off(i),Wx{i} ,'+','color',Cmap(i,:));
        plot(stagepos{i}+off(i),Wy{i} ,'.','color',Cmap(i,:));
        ylim([0,2000]);
    end
end


%% align all curves so wx and wy cross at z=0


            
Z = cell(Nfeducials,1); 
Wxf = cell(Nfeducials,1); 
Wyf = cell(Nfeducials,1); 
wX = cell(Nfeducials,1); 
wY = cell(Nfeducials,1); 
figure(2); clf; figure(3); clf;
for  i=1:Nfeducials  %  i = 10:5:37 %  i =7
    [m,k] = min(abs( Wx{i} -Wy{i}));
    if m<50
        zz = stagepos{i} - stagepos{i}(k);
        [wx,Wxf{i}] = FitZcurve(zz,Wx{i},'PlotsOn',true);
        [wy,Wyf{i}] = FitZcurve(zz,Wy{i},'PlotsOn',true);
    else
        wx = NaN; wy = NaN; zz = NaN; 
    end
    
    if isnan(wx)
        wy = wx;
        zz = wx;
        Wyf{i} = [];
    elseif isnan(wy)
        wx = wy;
        zz = wy;
        Wxf{i} = []; 
    end
    Z{i} = zz(zz>-600 & zz<600); 
    wX{i} = wx(zz>-600 & zz<600);
    wY{i} = wy(zz>-600 & zz<600);
    
    figure(2); hold on; 
        plot( zz,wx,'+','color',Cmap(i,:));
        plot( zz,wy,'.','color',Cmap(i,:));
        ylim([0,2000]); xlim([-600,600]);
    figure(3); hold on;
        plot(zz,Wx{i} ,'+','color',Cmap(i,:),'MarkerSize',5);
        plot(zz,Wy{i} ,'.','color',Cmap(i,:),'MarkerSize',5);
        ylim([0,2000]); xlim([-600,600]);
        i
end
figure(2); set(gcf,'color','w'); set(gca,'FontSize',16);
xlabel('Z-position'), ylabel('dot-width'); legend('wx','wy');
title('curve fits');

figure(3); set(gcf,'color','w'); set(gca,'FontSize',16);
xlabel('Z-position'), ylabel('dot-width'); legend('wx','wy');
title('raw data');
%% see if curves could align any better by cross-correlation
figure(7); clf;
shift = NaN*zeros(Nfeducials,1);
shiftY = NaN*zeros(Nfeducials,1);
r=find(~cellfun(@isempty,wX),1,'first');
for i=1:Nfeducials
    if ~isempty(wX{i})
        xc = xcorr(wX{r},wX{i});
        figure(6) ;clf; plot(xc)

        L = length(wX{r});
        [~,s] = max(xc);
        shift(i) = s-L;
        
        figure(7); 
        plot(Z{r},wX{r}); hold on; 
        plot(Z{i}+shift(i), wX{i},'r');
    end
    
     if ~isempty(wY{i})
        xc = xcorr(wY{r},wY{i});
        figure(6) ;clf; plot(xc)

        L = length(wY{r});
        [~,s] = max(xc);
        shiftY(i) = s-L;
        
        figure(7); 
        plot(Z{r},wY{r}); hold on; 
        plot(Z{i}+shiftY(i), wY{i},'r');
    end
    
    
end

%%
wy0s = NaN*zeros(Nfeducials,1);
wx0s = NaN*zeros(Nfeducials,1);
zrY = NaN*zeros(Nfeducials,1);
zrX = NaN*zeros(Nfeducials,1);
for i=1:Nfeducials
    if ~isempty(Wyf{i})
        wy0s(i) = Wyf{i}.w0;
        zrY(i) = Wyf{i}.zr;
    end
    if ~isempty(Wxf{i})
        wx0s(i) = Wxf{i}.w0;
        zrX(i) = Wxf{i}.zr;
    end
end
X = zeros(26);
idx = sub2ind([26,26],round(feducial_boxes(:,1)/10),round(feducial_boxes(:,2)/10));
X(idx) = wx0s;
X(idx) = wy0s;
figure(6); imagesc(X);
title('wy0s');
