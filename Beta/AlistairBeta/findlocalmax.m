

% generate some random peaks of variable heights:

H = 100;
W=H; 

data = zeros(H,W,'uint16');
temp = data;
for j=1:20
    temp(1+round(rand(5)*(H*W-1))) = 1500;
    data = data+temp;
end
figure(1); clf; imagesc(data); colorbar;
 gaussblur = fspecial('gaussian',20,4);
 data = 2*imfilter(data,gaussblur,'replicate');
figure(1); clf; imagesc(data); colorbar;
%%

% Gradually 'fillup' the image by raising the threshold, and record the
% centroids of all peaks that vanished in the previous step.  

N = 500;
thetas = linspace(0,.1,N);
count = NaN*zeros(1,N);
R = cell(1,N);
lowdot = cell(100,1); 
k=0;
for i=1:N
   bw = im2bw(data,thetas(i));
   bw = bwareaopen(bw,10);
   R{i} = regionprops(bw,'Centroid','PixelIdxList'); 
   count(i) = length(R{i});
   if i>1
       if count(i) < count(i-1)
           pvs = {R{i-1}.PixelIdxList};
           cents = cat(1,R{i-1}.Centroid);
           lengths = cellfun(@length, pvs);
           
           Nlost = count(i-1)-count(i); 
           for jj=1:Nlost
               [~,j] = min(lengths);
                k = k+1;
                lowdot{k} = cents(j,:);
                lengths(j) = [];
                cents(j,:) = [];
           end
         %  pause
       end
   end
    figure(2); clf; plot(count,'.-');  xlim([0,N]);
    figure(3); clf; imagesc(bw);
    
    figure(1); clf; imagesc(data); colorbar;
    hasdata = logical(1-cellfun(@isempty,lowdot));
    lowdot2 = lowdot(hasdata);
    lowdots = cell2mat(lowdot2);
    if ~isempty(lowdots)
        figure(1); hold on; 
        plot(lowdots(:,1),lowdots(:,2),'k+','MarkerSize',10);
    end
    
    if count(i) == 0
        break
    end
  % pause
end
%
figure(2); clf; plot(count,'.-');   xlim([0,N]);

[~,im] = max(count);
imthresh = thetas(im);
bw2 = im2bw(data,imthresh);
bw2 = bwareaopen(bw2,10);
figure(3); clf; imagesc(bw2);
R2 = regionprops(bw2,'Centroid');
cents = cat(1,R2.Centroid);
figure(1); clf; imagesc(data); colorbar;
figure(1); hold on; plot(cents(:,1),cents(:,2),'k.','MarkerSize',10);
hasdata = logical(1-cellfun(@isempty,lowdot));
lowdot = lowdot(hasdata);
lowdots = cell2mat(lowdot);
figure(1); hold on; plot(lowdots(:,1),lowdots(:,2),'k+','MarkerSize',10);

%%  A better way:
bw3 = data > imdilate(data, [1 1 1; 1 0 1; 1 1 1]);

        R3 =  regionprops(bw3,data,'WeightedCentroid');
        cents = cat(1,R3.WeightedCentroid);
        figure(4); clf; imagesc(data); hold on;
        plot(cents(:,1),cents(:,2),'k+');

% Also works:
bw3 = imregionalmax(data);

 R3 =  regionprops(bw3,data,'WeightedCentroid');
        cents = cat(1,R3.WeightedCentroid);
        figure(4); clf; imagesc(data); hold on;
        plot(cents(:,1),cents(:,2),'k+');

% http://stackoverflow.com/questions/1856197/how-can-i-find-local-maxima-in-an-image-in-matlab

