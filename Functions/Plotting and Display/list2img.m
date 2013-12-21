
function In = list2img(mlist,varargin) % ,zm,N,h,w)
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

  
  
  

%--------------------------------------------------------------------------
%% Hard coded inputs
%--------------------------------------------------------------------------

global ScratchPath %#ok<NUSED>

% (mostly shorthand)
Cs = length(mlist);
chns = find(true - cellfun(@isempty,mlist))';
[ch,cw] = size(chns); 
if ch>cw; chns = chns'; end % must be row vector! 
N = 6; 

%--------------------------------------------------------------------------
%% Default inputs
%--------------------------------------------------------------------------
infilter = cell(1,Cs);

for c=chns
    infilter{c} = true(length(mlist{c}.xc),1);
end

dotsize = 4;
Zs = 1;
Zrange = [-500,500]; % range in nm 
npp = 160; 
scalebar = 500;
CorrectDrift = true;
showScalebar = true;
fastMode = false;
verbose = false;

% If imaxes is not passed as a variable
if nargin == 1 || ischar(varargin{1})
    imaxes.zm = 10; % default zoom; 
    imaxes.scale = 1;    
    molist = cell2mat(mlist);
    allx = cat(1,molist.xc);
    ally = cat(1,molist.yc);
    imaxes.xmin =  floor(min(allx));
    imaxes.xmax = ceil(max(allx));
    imaxes.ymin = floor(min(ally));
    imaxes.ymax = ceil(max(ally));
    imaxes.H =  (imaxes.ymax - imaxes.ymin)*imaxes.zm*imaxes.scale;
    imaxes.W =  (imaxes.xmax - imaxes.xmin)*imaxes.zm*imaxes.scale; 
elseif ~ischar(varargin{1})
    imaxes = varargin{1};
end

if nargin > 1 
    if ischar(varargin{1})
        varinput = varargin;
    else
        varinput = varargin(2:end);
    end
else
    varinput = [];
end
    

% Add necessary fields to a minimal imaxes;
%  minimal imaxes is just imaxes.zm; 
if ~isfield(imaxes,'scale'); imaxes.scale = 1; end
if ~isfield(imaxes,'H') && ~isfield(imaxes,'xmin');
    molist = cell2mat(mlist);
    allx = cat(1,molist.xc);
    ally = cat(1,molist.yc);
    imaxes.xmin =  floor(min(allx));
    imaxes.xmax = ceil(max(allx));
    imaxes.ymin = floor(min(ally));
    imaxes.ymax = ceil(max(ally));
    imaxes.H =  (imaxes.ymax - imaxes.ymin)*imaxes.zm*imaxes.scale;
    imaxes.W =  (imaxes.xmax - imaxes.xmin)*imaxes.zm*imaxes.scale; 
elseif ~isfield(imaxes,'H') && isfield(imaxes,'xmin'); 
    imaxes.H =  (imaxes.ymax - imaxes.ymin)*imaxes.zm;
    imaxes.W =  (imaxes.xmax - imaxes.xmin)*imaxes.zm; 
else
    H = imaxes.H;
    W = imaxes.W;
end
    

if ~isfield(imaxes,'xmin'); imaxes.xmin = 0; end
if ~isfield(imaxes,'xmax'); imaxes.xmax = H; end
if ~isfield(imaxes,'ymin'); imaxes.ymin = 0; end
if ~isfield(imaxes,'ymax'); imaxes.ymax = W; end



%--------------------------------------------------------------------------



%--------------------------------------------------------------------------
% Parse variable input
%--------------------------------------------------------------------------

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
                dotsize = CheckParameter(parameterValue,'positive','dotsize');
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
            case 'Fast'
                fastMode =  CheckParameter(parameterValue,'boolean','Fast');
            case 'N'
                N  = CheckParameter(parameterValue,'positive','N');
            case 'verbose'
                verbose = CheckParameter(parameterValue,'boolean','verbose'); 
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end


%% More input conversion stuff


% (mostly shorthand)
zm = imaxes.zm*imaxes.scale; % pixel size
W = imaxes.W*imaxes.scale; % floor(w*zm);
H = imaxes.W*imaxes.scale; %  floor(h*zm); 

if length(dotsize) < Cs
    dotsize = repmat(dotsize,Cs,1);
end


%% Main Function
%--------------------------------------------------------------------------

ltic = tic;

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
        x{c} = mlist{c}.xc;
        y{c} = mlist{c}.yc;
        z{c} = mlist{c}.zc;
    else
        x{c} = mlist{c}.x;
        y{c} = mlist{c}.y;
        z{c} = mlist{c}.z;
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
    a = mlist{c}.a;
    sigC{c} = real(4./sqrt(a)); % 5
    sigs = sort(sigC{c});
    min_sig = sigs(max(round(.01*length(sigs)),1));
    max_sig = sigs(round(.99*length(sigs)));
    gc = fliplr(800*linspace(.5,8,N+1)); % intensity of dots. also linear in root photon number
    wdth = linspace(min_sig, max_sig,N+1); 
    wdth(end) = inf; 
    wc = linspace(.01*dotsize(c), .05*dotsize(c),N+1)*zm; 
    
    % actually build image
    maxint = 0; 
     Iz = zeros(H,W,Zs);          
     for k=1:Zs
         I0 = zeros(H,W);          
         inZ =  z{c} >= Zsteps(k) & z{c} < Zsteps(k+2);
         for n=1:N
             inbox = x{c}>imaxes.xmin & x{c} < imaxes.xmax & ...
                     y{c}>imaxes.ymin & y{c}<imaxes.ymax;
            inW = sigC{c} >= wdth(n) & sigC{c} < wdth(n+1);
            plotdots = inbox & inW & inZ & infilter{c} ; % find all molecules which fall in this photon bin        
            xi = x{c}(plotdots)*zm-imaxes.xmin*zm;
            yi = y{c}(plotdots)*zm-imaxes.ymin*zm;
           
            It = hist3([yi,xi],'Edges',{1:H,1:W}); % drop all molecules into chosen x,y bin   {1.5:h*zm+.5, 1.5:w*zm+.5}
            gaussblur = fspecial('gaussian',150,wc(n)); % create gaussian filter of appropriate width
            if ~fastMode
                It = imfilter(gc(n)*It,gaussblur); % convert into gaussian of appropriate width
            end
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

ltime = toc(ltic);
if verbose
disp(['list2img took ',num2str(ltime,4),' s']); 
end
% figure(1); clf; Ncolor(In{1}); colormap hot;


% 

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
