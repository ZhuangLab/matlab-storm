
function In = list2img(molist,imaxes,varargin) % ,zm,N,h,w)
%                           list2img.m
% Alistair Boettiger                                   Date Begun: 08/11/12
% Zhuang Lab                                        Last Modified: 08/22/12
% 
%   Inputs   molist - 1xn cell where n is the number of channels in the
%                     data.  Each cell contains a molecule list structure
%                     with the categories .xc, .yc, .a etc specifying
%                     molecule positions.  class specifies molecule class. 
%            zm     - scale factor for pixel size.  (new pixel size is 
%                     current pixel size / zm).
%            N      - Number of different molecule widths to plot
%            minW   - min width in pixels to blur width of dot
%            maxW   - max width in pixels for Gaussian blur of dot
%  Outputs   In     - cell array of zm*h x zm*w 

  
  
  
 % mlist = ReadMasterMoleculeList('J:\2013-10-01_G10\splitdax\647quad_G10_storm_0_4_alist.bin');
%  load('C:\Users\Alistair\Documents\Research\Projects\Chromatin\Data\2013-11-02_coloredRegions\G5_DotData_22_d3.mat')
%    molist = {vlist};

%--------------------------------------------------------------------------
%% Hard coded inputs
%--------------------------------------------------------------------------


% (mostly shorthand)
zm = imaxes.zm*imaxes.scale; % pixel size
w = imaxes.xmax-imaxes.xmin;
h = imaxes.ymax-imaxes.ymin;
W = round(w*zm);
H = round(h*zm); 
Cs = length(molist);
chns = find(true - cellfun(@isempty,molist))';
[ch,cw] = size(chns); 
if ch>cw; chns = chns'; end % must be row vector! 


%--------------------------------------------------------------------------
%% Default inputs
%--------------------------------------------------------------------------
infilter = cell(1,Cs);
for c=chns
    infilter{c} = true(length(molist{c}.xc),1);
end

dotsize = 4;
Zs = 1;  % 20
Zrange = [-500,500]; % range in nm 
npp = 160; 
scalebar = 500;
CorrectDrift = true;
showScalebar = true;

N = 6; % number of bins for different molecule widths

     

%--------------------------------------------------------------------------



%--------------------------------------------------------------------------
%% Parse variable input
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
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end

% dotsize = 4;
if length(dotsize) < Cs
    dotsize = repmat(dotsize,Cs,1);
end


%% Main Function
%--------------------------------------------------------------------------


% 
if scalebar < 1
    showScalebar = false; 
end

% initialize variables
x = cell(Cs,1); 
y = cell(Cs,1); 
z = cell(Cs,1); 
sigC = cell(Cs,1); 

for c=chns
    if CorrectDrift
        x{c} = molist{c}.xc;
        y{c} = molist{c}.yc;
        z{c} = molist{c}.zc;
    else
        x{c} = molist{c}.x;
        y{c} = molist{c}.y;
        z{c} = molist{c}.z;
    end
end

if Cs < 1
    return
end
  
  
% Min and Max Z
zmin = Zrange(1);
zmax = Zrange(2); 
Zsteps = linspace(zmin,zmax,Zs);
Zsteps = [-inf,Zsteps,inf];

In = cell(Cs,1);

for c=chns   
    
    % Min and Max Sigma
    a = molist{c}.a;
    sigC{c} = real(4./sqrt(a)); % 5
    sigs = sort(sigC{c});
    min_sig = sigs(max(round(.01*length(sigs)),1));
    max_sig = sigs(round(.99*length(sigs)));
    gc = fliplr(800*linspace(.5,8,N+1)); % intensity of dots. also linear in root photon number
    wdth = linspace(min_sig, max_sig,N+1); 
    wdth(end) = inf; 
    wc = linspace(.5*dotsize(c), 3*dotsize(c),N+1); 
    
    % actually build image
    maxint = 0; 
     Iz = zeros(H,W,Zs,'uint16');          
     for k=1:Zs
         I0 = zeros(H,W,'uint16');          
         inZ =  z{c} > Zsteps(k) & z{c} < Zsteps(k+1);
         for n=1:N
            inw = (sigC{c} > wdth(n) & sigC{c} < wdth(n+1) & inZ & infilter{c} ); % find all molecules which fall in this photon bin
            It = uint16(hist3([x{c}(inw)*zm,y{c}(inw)*zm],'Edges',{1.5:h*zm+.5, 1.5:w*zm+.5})); % drop all molecules into chosen x,y bin
            gaussblur = fspecial('gaussian',150,wc(n)); % create gaussian filter of appropriate width
            It = imfilter(gc(n)*It,gaussblur); % convert into gaussian of appropriate width
          %  figure(3); clf; imagesc(It); title(num2str(n));
            I0 = I0 + It;
         end
         Iz(:,:,k) = I0; 
     end
      maxint = max(Iz(:)) + maxint; % compute normalization
      Iz = uint16(2^16*double(Iz)./double(maxint)); % normalize
     In{c} = Iz; % record
   
    if showScalebar
        scb = round(1:scalebar/npp*zm);
        h1 = round(.9*H);
        In{c}(h1:h1+2,10+scb,:) = 2^16*ones(3,length(scb),Zs,'uint16'); % Add scale bar and labels
    end  
     
end

figure(1); clf; Ncolor(In{1}); colormap hot;

% % Good display code for troubleshooting.  Redundant with command in movie2vectorSTORM core script   
% % normalize color channels and render
% % combine in multicolor image
%     h = 256; 
%     w = 256;   
%     nmpp = 160; % nm per pixel
%       I2 =zeros(h*zm,w*zm,3,'uint16');
%       I2(:,:,1) = mycontrast(In{1},.0005,0);
%       I2(:,:,2) = mycontrast(In{2},.0003,0);
%       if length(molist)==2
%           In{3} = zeros(h*zm,w*zm,1,'uint16');   
%           I2(:,:,3) =In{3}; % needs to be a 3 color image still
%       elseif length(molist)==3
%           I2(:,:,3) = mycontrast(In{3},.0003,0);
%       elseif length(molist)==4 % 4th color is magenta
%           I2(:,:,1) =  I2(:,:,1) + mycontrast(In{4},.0005,0);
%           I2(:,:,3) = mycontrast(In{3},.0003,0) + mycontrast(In{4},.0005,0);
%       end             
     
%      I2 =zeros(h*zm,w*zm,3,'uint16');
%      I2(:,:,1) = (In{1});
%      I2(:,:,2) = (In{2});
%      I2(:,:,3) = (In{3});
%      I2(240*zm+1:241*zm,10*zm+1:14*zm,:) = 255*ones(1*zm,4*zm,3,'uint8');
%      figure(1); clf; imagesc(I2); 

% It = zeros(100,100,'uint16');
% It(50,50) = 2^16; wc = 4;
%  gaussblur = fspecial('gaussian',30,wc);
% Io = imfilter(It,gaussblur);
% figure(6); clf; imagesc(Io); 
%      
