function I = plotSTORM(mlist, imaxes, varargin)
% I = plotSTORM(mlist, imaxes, infilter)
% routine from the STORMrender GUI
%--------------------------------------------------------------------------
%% Necessary inputs
%--------------------------------------------------------------------------
% mlist / cell
%               -- cell of length N-channels, containing the molecule list
%               strctures for each color channel.  The fields mlist.xc,
%               mlist.yc, mlist.zc and mlist.a are required.  mlist.a is
%               used to compute the size of the spots.  
%
% imaxes / struct
%               -- structure containing fields imaxes.H and imaxes.W (the
%               original image height and width, e.g. 256x256; imaxes.zm
%               the degree to increase the resolution by, and imaxes.sc, a
%               scaling factor to increase the size by. sc=2 on a 256x256
%               input gives an output image 512x512.  
%--------------------------------------------------------------------------
%% Outputs
% I matrix HxWxN where N is the number of color channels (no empty elements
% in mlist)
%--------------------------------------------------------------------------
%% Optional inputs
%--------------------------------------------------------------------------
% 'filter' / cell / keep all dots
%               -- cell of length N-channels, each element is a vector of
%               length N-molecules in the corresponging m-list.  This
%               vector is a logical which contains ones for all the
%               molecules that are to be displayed from that m-list.  
% 'dotsize' / double / 4
%              -- Allows dots to be rescaled
% 'maxblobs' / double / 2E4
%              -- max number of dots to try and render at once (limited by
%              graphics card.  If graphics card errors, reduce this number)
% 'maxdotsize' / double / .05
%              -- dots which should be larger than this based on
%              uncertainty will appear this size.  This prevents GPU errors
%              from trying to make massive blobs.  
%--------------------------------------------------------------------------
% Alistair Boettiger
% boettiger.alistair@gmail.com
% October 10th, 2012
%
% Version 1.0
%--------------------------------------------------------------------------
% Creative Commons License 3.0 CC BY  
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
%% Hard coded inputs
%--------------------------------------------------------------------------
% (mostly shorthand)
scale = imaxes.scale;
H = imaxes.H;
W = imaxes.W;
zm = imaxes.zm;
Cs = length(mlist);
chns = find(true - cellfun(@isempty,mlist))';


%--------------------------------------------------------------------------
%% Default inputs
%--------------------------------------------------------------------------
infilter = cell(1,Cs);
for c=chns
    infilter{c} = true(length(mlist{c}),1);
end

dotsize = 4;
maxblobs = 2E4; %
maxdotsize = .05; 
mindotsize = .1;
npp = 160; 
scalebar = 500;
showScalebar = 1; 
%--------------------------------------------------------------------------



%--------------------------------------------------------------------------
% Parse variable input
%--------------------------------------------------------------------------
if nargin > 2
    if (mod(length(varargin), 2) ~= 0 ),
        error(['Extra Parameters passed to the function ''' mfilename ''' must be passed in pairs.']);
    end
    parameterCount = length(varargin)/2;
    for parameterIndex = 1:parameterCount,
        parameterName = varargin{parameterIndex*2 - 1};
        parameterValue = varargin{parameterIndex*2};
        switch parameterName
            case 'filter'
                infilter = parameterValue;
            case 'dotsize'
                dotsize = parameterValue;
            case 'maxblobs'
                maxblobs = parameterValue;
            case 'maxdotsize'
                maxdotsize = parameterValue;
            case 'nm per pixel'
                npp = parameterValue;
            case 'scalebar size'
                scalebar = parameterValue;
            case 'scalebar'
                showScalebar = CheckParameter(parameterValue,'boolean',scalebar); 
        end
    end
end

%% Main Function
%--------------------------------------------------------------------------

% initialize variables
sig = cell(Cs,1);
x = cell(Cs,1); 
y = cell(Cs,1); 
z = cell(Cs,1); 


for c=chns
    x{c} = mlist{c}.xc;
    y{c} = mlist{c}.yc;
    z{c} = mlist{c}.zc;
    a = mlist{c}.a;
    sig{c} = real(dotsize./sqrt(a)); % 5
end
xsize = W/zm;
ysize = H/zm;

 I = zeros(ceil(xsize*zm*scale),ceil(ysize*zm*scale),Cs,'uint16');
  for c=chns
      if length(x{c}) >1
          inbox = x{c}>imaxes.xmin & x{c} < imaxes.xmax & y{c}>imaxes.ymin & y{c}<imaxes.ymax;
          tic
         xi = (x{c}(inbox & infilter{c}')-imaxes.xmin);
         yi = (y{c}(inbox & infilter{c}')-imaxes.ymin);
         si = sig{c}(inbox & infilter{c}');
         si(si<maxdotsize) = maxdotsize;  % 
         si(si>mindotsize) = mindotsize; 
         Itemp=GenGaussianSRImage(xsize,ysize,xi,yi,si,'zoom',zm*scale,'MaxBlobs',maxblobs)';  % 1E5     
                 I(:,:,c) = Itemp;
         toc
      end
  end  
  
  
  % add scalebar
if showScalebar
    scb = round(1:scalebar/npp*zm*scale);
    h1 = round(imaxes.H*.9*scale);
    I(h1:h1+2,10+scb,:) = 2^16*ones(3,length(scb),Zs*Cs,'uint16'); % Add scale bar and labels
end

  