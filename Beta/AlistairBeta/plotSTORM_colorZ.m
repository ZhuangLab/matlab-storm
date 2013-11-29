function [I,Itest] = plotSTORM_colorZ(mlist, varargin)
% I = plotSTORM_colorZ(mlist)
% I = plotSTORM_colorZ(mlist, imaxes)
% I = plotSTORM_colorZ(mlist, imaxes, 'Zsteps',20,'Zrange',[-200,200],...)
% I = plotSTORM_colorZ(mlist,'Zsteps',20,'Zrange',[-200,200],...)
% 
% routine from the STORMrender GUI
%--------------------------------------------------------------------------
% Necessary inputs:
% mlist / cell
%               -- cell of length N-channels, containing the molecule list
%               strctures for each color channel.  The fields mlist.xc,
%               mlist.yc, mlist.zc and mlist.a are required.  mlist.a is
%               used to compute the size of the spots.  
% 
%--------------------------------------------------------------------------
% Outputs:
% I / cell of HxWxZn matrices
%               -- each color channel is given a different element in the
%               cell.  
% 
%--------------------------------------------------------------------------
% Optional inputs:
% imaxes / struct  (Must be 2nd input if passed)
%               -- structure containing fields imaxes.H and imaxes.W (the
%               original image height and width, e.g. 256x256); imaxes.zm
%               the degree to increase the resolution by, and imaxes.scale,
%               a factor to increase the size by. scale=2 on a 256x256
%               input gives an output image 512x512. 
%               Also includes fields xmin 
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
% 'Zsteps' / double / 1
%              -- Number of different z-levels to render
% 'Zrange' / double / [-500,500] 
%              -- range in nm for color axis
% 'scalebar' / double / 500
%              -- size of scalebar in nm.  0 for no scalebar.
% 'correct drift' / logical / true
%              -- plot xc/yc or x/y coordinates of mlist
% 'use GPU' / logical / true
%              -- Use GPU accelerated plotting.  If GPU and CUDA are not
%              available, system will default to CPU
%
%--------------------------------------------------------------------------
% Alistair Boettiger
% boettiger.alistair@gmail.com
% October 6th, 2013
%
% Version 1.3
%--------------------------------------------------------------------------
% Creative Commons License 3.0 CC BY  
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
%% Hard coded inputs
%--------------------------------------------------------------------------

global ScratchPath %#ok<NUSED>

% (mostly shorthand)
Cs = length(mlist);
chns = find(true - cellfun(@isempty,mlist))';
[ch,cw] = size(chns); 
if ch>cw; chns = chns'; end % must be row vector! 


%--------------------------------------------------------------------------
%% Default inputs
%--------------------------------------------------------------------------
infilter = cell(1,Cs);
for c=chns
    infilter{c} = true(length(mlist{c}.xc),1);
end

dotsize = 4;
maxblobs = 2E4; %
maxdotsize = .05; 
Zs = 1;
Zrange = [-500,500]; % range in nm 
npp = 160; 
scalebar = 500;
CorrectDrift = true;
showScalebar = true;
verbose = false; 
useGPU = true; 

%--------------------------------------------------------------------------
%% Parse variable input
%--------------------------------------------------------------------------

% ---- Determine if later values are option flag and value pairs or imaxes.
if nargin > 1 
    if ischar(varargin{1})
        varinput = varargin;
    else
        varinput = varargin(2:end);
    end
else
    varinput = [];
end

% ------- Construct imaxes from data if not passed
if nargin == 1 || ischar(varargin{1})
    molist = cell2mat(mlist);
    allx = cat(1,molist.xc);
    ally = cat(1,molist.yc);
    imaxes.zm = 10; % default zoom; 
    imaxes.scale = 1;    
    imaxes.xmin =  floor(min(allx));
    imaxes.xmax = ceil(max(allx));
    imaxes.ymin = floor(min(ally));
    imaxes.ymax = ceil(max(ally));
    imaxes.H =  (imaxes.ymax - imaxes.ymin)*imaxes.zm*imaxes.scale;
    imaxes.W =  (imaxes.xmax - imaxes.xmin)*imaxes.zm*imaxes.scale; 
elseif ~ischar(varargin{1})
    imaxes = varargin{1}; 
end

% ---- Some short-hand
H = imaxes.H;
W = imaxes.W;
zm = imaxes.zm;

% --- Add necessary fields to a minimal imaxes if not present 
if ~isfield(imaxes,'scale'); imaxes.scale = 1; end
if ~isfield(imaxes,'xmin'); imaxes.xmin = 0; end
if ~isfield(imaxes,'xmax'); imaxes.xmax = W; end
if ~isfield(imaxes,'ymin'); imaxes.ymin = 0; end
if ~isfield(imaxes,'ymax'); imaxes.ymax = H; end
scale = imaxes.scale;



% -------------- Parse optional inputs flags

if ~isempty(varinput)
    if (mod(length(varinput), 2) ~= 0 ),
        error(['Extra Parameters passed to the function ''' mfilename ''' must be passed in pairs.']);
    end
    parameterCount = length(varinput)/2;
    for parameterIndex = 1:parameterCount,
        parameterName = varinput{parameterIndex*2 - 1};
        parameterValue = varinput{parameterIndex*2};
        switch parameterName
            case 'filter'
                infilter = parameterValue;
            case 'dotsize'
                dotsize = parameterValue;
            case 'maxblobs'
                maxblobs = CheckParameter(parameterValue,'positive','maxblobs');
            case 'maxdotsize'
                maxdotsize = CheckParameter(parameterValue,'positive','maxdotsize');
            case 'Zsteps'
                Zs = CheckParameter(parameterValue,'positive','Zsteps');
            case 'Zrange'
                Zrange = CheckParameter(parameterValue,'array','Zrange');
            case 'nm per pixel'
                npp = CheckParameter(parameterValue,'positive','nm per pixel');
            case 'scalebar'
                scalebar = CheckParameter(parameterValue,'nonnegative','scalebar');
            case 'correct drift'
                CorrectDrift = CheckParameter(parameterValue,'nonnegative','correct drift');
            case 'verbose'
                verbose = CheckParameter(parameterValue,'boolean','verbose');
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end

if length(dotsize) < Cs
    dotsize = repmat(dotsize,Cs,1);
end

for c=1:chns
    [fh,fw] = size(infilter{c});
    if fw > fh
        infilter{c} = infilter{c}';
    end
end




%--------------------------------------------------------------------------
%% Main Function
%--------------------------------------------------------------------------

% Test if GPU is available
try
 Itest =   GenGaussianSRImage(1,1,1,1,1,'zoom',1,'MaxBlobs',10);
catch er
   % disp(er.message);
    useGPU = false;
    Itest = 0; 
end
if Itest < 1E-10  || ~useGPU; 
%     if verbose
%          disp('GPU not available'); 
%     end
    % Use CPU version of render instead:
    I = list2img(mlist,imaxes,'filter',infilter,'dotsize',dotsize,...
        'Zsteps',Zs,'Zrange',Zrange','nm per pixel',npp,...
        'scalebar',scalebar,'correct drift',CorrectDrift); 
else    
     
    if scalebar < 1
        showScalebar = false; 
    end

    % initialize variables
    sig = cell(Cs,1);
    x = cell(Cs,1); 
    y = cell(Cs,1); 
    z = cell(Cs,1); 

    for c=chns
        if CorrectDrift
            x{c} = mlist{c}.xc;
            y{c} = mlist{c}.yc;
            z{c} = mlist{c}.zc;
        else
            x{c} = mlist{c}.x;
            y{c} = mlist{c}.y;
            z{c} = mlist{c}.z;
        end
        a = mlist{c}.a;
        sig{c} = real(dotsize(c)./sqrt(a)); % 5
    end
    xsize = W/zm; 
    ysize = H/zm; 
    h = round(ysize*zm*scale);
    w = round(xsize*zm*scale);

    I = cell(max(chns),1); 
    for c=chns
      I{c} = zeros(h,w,Zs,'uint16'); 
      zmin = Zrange(1);
      zmax = Zrange(2); 

      Zsteps = linspace(zmin,zmax,Zs);
      Zsteps = [-inf,Zsteps,inf]; %#ok<AGROW>

          maxint = 0;
          Iz = zeros(h,w,Zs,'single');
          for k=1:Zs
              if length(x{c}) >1
                 inbox = x{c}>imaxes.xmin & x{c} < imaxes.xmax & ...
                     y{c}>imaxes.ymin & y{c}<imaxes.ymax & ...
                     z{c} > Zsteps(k) & z{c} < Zsteps(k+1);
                     plotdots = inbox & infilter{c};
                 xi = (x{c}(plotdots)-imaxes.xmin);
                 yi = (y{c}(plotdots)-imaxes.ymin);
                 si = sig{c}(plotdots);
                 si(si<maxdotsize) = maxdotsize;  % 
                 Itemp=GenGaussianSRImage(xsize,ysize,xi,yi,si,...
                     'zoom',zm*scale,'MaxBlobs',maxblobs)';    
                 try
                 Iz(:,:,k) = Itemp;
                 catch
                     [hnew,wnew] = size(Itemp);
                     Iz = zeros(hnew,wnew,Zs,'single');
                     I{c} = zeros(hnew,wnew,Zs,'single');
                     Iz(:,:,k) = Itemp;
                 end
                 maxint = max(Itemp(:)) + maxint;
              end
          end
          
          for k=1:Zs
              I{c}(:,:,k) = uint16(Iz(:,:,k)./maxint*2^16);
          end

       % add scalebar
        if showScalebar
            scb = round(1:scalebar/npp*zm*scale);
            h1 = round(imaxes.H*.9*scale);
            I{c}(h1:h1+2,10+scb,:) = 2^16*ones(3,length(scb),Zs,'uint16'); % Add scale bar and labels
        end     
    end  
  
end
  