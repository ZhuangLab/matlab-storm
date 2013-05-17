function [Im,box_coords] = viewSteveMosaic(Mosaic_folder,position,varargin)
%--------------------------------------------------------------------------
% MosaicView = MosaicViewer(Mosaic_folder,position,varargin)
% 
%--------------------------------------------------------------------------
% Inputs: 
% folder / string 
%                   -- folder containing the mosaic created by STEVE
% position / 1x2 double
%                   -- vector location on which to center the mosaic, given
%                   in stage units (as recorded in .info files).
% 
%--------------------------------------------------------------------------
% Outputs:
% MosaicView / handle to figure created. 
% Im / image matrix plotted in figure
% box / coordinates of box
%--------------------------------------------------------------------------
% Optional Inputs:
% 'Ntiles' / double / 30
%                   -- number of images from the mosaic file nearest to the
%                   seed point to inculde in the output image
% 'shrink' / double / 1
%                   -- downsample the ouput by this factor.  
%                   for large N or for mapping lower res images which
%                   will be upsampled to high res scale, 'shrink' is
%                   advisable.  If only low res images, shrink should be at
%                   least the ratio of 100x to the mag used (i.e. 5 for
%                   20x images) 
% 'showall' / logical / false 
%                   -- show 4x and 10x images (will probably result in
%                   any 100x images being downsampled so that resulting
%                   plot still fits in memory
% 'showbox' / logical / true
%                   -- plot a 256x256 box centered at the target position.
% 'verbose' / logical / true
%                   -- print progress and warnings to command line. 
%--------------------------------------------------------------------------
% Alistair Boettiger
% boettiger.alistair@gmail.com
% October 10th, 2012
%
% Version 1.2
%--------------------------------------------------------------------------
% Creative Commons License 3.0 CC BY  
%--------------------------------------------------------------------------


global ScratchPath %#ok<NUSED>

%--------------------------------------------------------------------------
%% Default Parameters
%--------------------------------------------------------------------------
showbox = false;
shrk = 1; 
N = 30; 
verbose = true; 
showall = false;

% % some test parameters:
% infofile = ReadInfoFile('L:\2013-05-03_en_emb\STORM\647_en_emb_storm_0_10.dax');
% position = [infofile.Stage_X, infofile.Stage_Y];
% Mosaic_folder = 'L:\2013-05-03_en_emb\Mosaic\';

%--------------------------------------------------------------------------
%% Parse mustHave variables
%--------------------------------------------------------------------------
if nargin < 1
   error([mfilename,' expects 3 inputs, folder, bead_folder and binnames']);
end


%--------------------------------------------------------------------------
% Parse variable input
%--------------------------------------------------------------------------
if nargin > 1
    if (mod(length(varargin), 2) ~= 0 ),
        error(['Extra Parameters passed to the function ''' mfilename ''' must be passed in pairs.']);
    end
    parameterCount = length(varargin)/2;
    for parameterIndex = 1:parameterCount,
        parameterName = varargin{parameterIndex*2 - 1};
        parameterValue = varargin{parameterIndex*2};
        switch parameterName
            case 'shrink'
                shrk = CheckParameter(parameterValue,'positive','shrink');
            case 'Ntiles'
                N = CheckParameter(parameterValue,'positive','Ntiles');
            case 'showall'
                showall = CheckParameter(parameterValue,'boolean','showall');
            case 'showbox'
                showbox = CheckParameter(parameterValue,'boolean','showbox');
            case 'verbose';
                verbose = CheckParameter(parameterValue,'boolean','verbose');
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end


%--------------------------------------------------------------------------
%% Main code
%--------------------------------------------------------------------------

% Read in .mat files and get list
%-----------------------------------
mtiles = dir([Mosaic_folder,'*.mat']);
M = length(mtiles); 

xu = zeros(M,1);
yu = zeros(M,1);
xp = zeros(M,1);
yp = zeros(M,1); 
z = zeros(M,1); 
mag = zeros(M,1);

for m=1:M
     load([Mosaic_folder,mtiles(m).name]);
         xp(m) = x_pix;
         xu(m) = x_um;
         yp(m) = y_pix;
         yu(m) = y_um;
         mag(m) = magnification;
         z(m) = zvalue;
         disp(['sorting data... ',num2str(100*m/M,3),'%']);
end

N = min(N,M); 
[frames,~] = knnsearch([xu,yu],position,'k',N);

% get dimensions of grid to plot:
if showall
    magmin = 1/min(mag(frames));
else
    magmin = 1;
end
    
xmin = min(xp(frames)-magmin*128);
xmax = max(xp(frames)+magmin*128);
ymin = min(yp(frames)-magmin*128);
ymax = max(yp(frames)+magmin*128);

xs = round(xmax - xmin); 
ys = round(ymax - ymin);
X = round(xp-xmin);
Y = round(yp-ymin);

if xs > 256*30 && shrk < 4
    shrk = 4;
    disp(['warning: image downscaled ',num2str(shrk),' fold']);
elseif xs > 256*50 && shrk < 8
    shrk = 8;
    disp(['warning: image downscaled ',num2str(shrk),' fold']);
elseif xs > 256*100 && shrk < 16
    shrk = 16;
    disp(['warning: image downscaled ',num2str(shrk),' fold']);
end

xs = round(xs/shrk); 
ys = round(ys/shrk); 
X = round(X/shrk);
Y = round(Y/shrk); 

% This is heavy on memory for large N or for scaling up low res images.
if showall
    Im = zeros(ys,xs,1,'uint16'); % plot all is like to be too heavy on mem.
else
    Im = zeros(ys,xs,1,'uint16');
end
for k = 1:length(frames); 
    i = frames(k);
    load([Mosaic_folder,mtiles(i).name]);
    im = data;

    % for plotting the 4x images, need to scale up:
    if showall
        if mag(i) ~= 1
            im = imresize(im,1/mag(i));
        end 
    end
    
 % rescale image if requested
    im = imresize(im,1/shrk); 
    [h,w,~] = size(im);
    h2 = round(h/2); % avoid integer operands for colon operator warning
    w2 = round(w/2);    
    y1 = Y(i)+1-h2;
    y2 = Y(i)+h2;
    x1 = X(i)+1-w2;
    x2 = X(i)+w2;
    if showall
        Im(y1:y2,x1:x2) = uint16(im);
    else
        Im(y1:y2,x1:x2) = uint16(im);
    end
    if verbose
        if rem(k,5) == 0
          disp(['rebuilding mosaic ', num2str(100*k/length(frames),3), '% done']);
        end
    end
%     figure(1); 
%     imagesc(imresize(Im,1)); 
%     pause(.3); colormap gray;
end

%--------- show plot
% figure(1); clf;
if nargout==0
    imagesc(Im); 
    colormap gray;
end

%-------------------- compute pixel to um conversion    
%figure(2); plot(xu(mag==1),xp(mag==1),'k.');
mx = ( max(xp(mag==1)) - min(xp(mag==1)) )/( max(xu(mag==1)) - min(xu(mag==1)) ) ;
my = ( max(yp(mag==1)) - min(yp(mag==1)) )/( max(yu(mag==1)) - min(yu(mag==1)) ) ;

box_cx = mx*position(1)-xmin;
box_cy = my*position(2)-ymin;
box_coords = [box_cx,box_cy,256,256];
   
if showbox && nargout==0;
hold on;
  rectangle('Position',box_coords,'EdgeColor','w');
  lin = findobj(gca,'Type','patch');
  set(lin,'color','w','linewidth',3);
  hold off;
end