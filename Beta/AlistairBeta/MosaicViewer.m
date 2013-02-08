
multicolor = true;
folder = 'I:\2013-02-02_BXCemb\Mosaic';
position_list = ['I:\2013-02-02_BXCemb\STORM',filesep,'positions.txt'];

% Find msc file
fname = dir([folder,filesep,'*.msc']);
if isempty(fname)
    error(['cannot find .msc file in ',folder]);
else
fname = fname.name;
end

% Load msc file
if multicolor
    msc_length = 8;  % number of columns in new format (multi-color)
else
    msc_length = 7; % number of columns in old format
end

msc= textread([folder,filesep,fname],'%s','delimiter',',','headerlines',2,'endofline','\r\n');
try
    M = reshape(msc,msc_length,length(msc)/msc_length)';
catch er
    disp(er.message);
    disp('color data for mosaic not found...');
    msc_length = 7;
    M = reshape(msc,msc_length,length(msc)/msc_length)';
end

% parse msc file
xu = cellfun(@str2double,M(:,2)); 
yu = cellfun(@str2double,M(:,3)); 
x  = cellfun(@str2double,M(:,4));
y  = cellfun(@str2double,M(:,5));
mag= cellfun(@str2double,M(:,6));
z  = cellfun(@str2double,M(:,7));

% just load 100x 
%(the 4x tiling makes for way too big an image to load into memory).  
z100x = 800;% find(mag==1,1,'last');
% frames = 450:800; % 1:800

N =30; p = 4;
P = csvread(position_list);
[nebs,dists] = knnsearch([xu,yu],P(p,:),'k',N);

frames = nebs; 
  sy = median(y(mag==1)./xu(mag==1));
  sx = median(x(mag==1)./yu(mag==1));

% get dimensions of grid to plot:
xmin = min(x(frames));
xmax = max(x(frames));
ymin = min(y(frames));
ymax = max(y(frames));

xs = round(xmax - xmin + 256); 
ys = round(ymax - ymin + 256);
X = round(x-xmin+ 256);
Y = round(y-ymin+ 256);

xs = round(xs/shrk); ys = round(ys/shrk); 
X = round(X/shrk); Y = round(Y/shrk); 

% This is heavy on memory:
Im = zeros(ys,xs,3,'uint8');
for k = 1:length(frames); 
    i = frames(k);% z100x+1-k; % start from bottom of list, oldest images first.
   % try
 im = imread([folder,filesep,M{i,1},'.png']); % load image
%     catch er
%         im = zeros(256,'uint8');
%         disp(er.message);
%     end

% % for plotting the 4x images, need to scale up:
%  if mag(i) == .04
%      im = imresize(im,1/.04);
%  end
     im = imresize(im,1/shrk); 
     [h,w,~] = size(im);
  
    % color channels
    try
        if strfind(M{i,8},'488');
            chn = 2;
        elseif strfind(M{i,8},'561');
            chn = 1;
        elseif strfind(M{i,8},'647');
            chn = 3;
        else
            chn = 2;
        end
    catch er
        % disp('channel not specified');
        chn = 2;
    end
    h2 = round(h/2); % avoid integer operands for colon operator warning
    w2 = round(w/2); 
    
    if k==1
        chn=1;
    end
    
  Im(Y(i)+1-h2:Y(i)+h2,X(i)+1-w2:X(i)+w2,chn) = im(:,:,1);
  if rem(k,100) == 0
      disp(['rebuilding mosaic ', num2str(100*k/length(frames),3), '% done']);
  end
end

  figure(5); clf; image(imresize(Im,1)); 

%%  




% 
%      
% if ~isempty(position_list)
%      P = csvread(position_list);
%      P(:,1) =(sy*P(:,1) - ymin + 256)/shrk; 
%      P(:,2) = (sx*P(:,2)- xmin + 256)/shrk;
% 
%      % should be a direct conversion.  However this doesn't seem to work.
%     % P(:,1) = P(:,1)/.167 - ymin + 256;  % STORM4 with QV .167 um/pixel
%     % P(:,2) = P(:,2)/.167- xmin + 256;
%     hold on;
%     for p=1:length(P)
%         rectangle('Position',[P(p,2)-127,P(p,1)-127,256,256],'EdgeColor','r');
%     end
% else 
%     P =[];
% end
% 
%   