function molist = chromewarp(chn,molist,Bead_folder,varargin)
% mlist = chromewarp(chn,mlist,Bead_folder,warpD)
% applies chromatic warp to .xc .yc .zc and overwrites those values with
%   the new values. Should consider overwiting .x .y .z instead, chromatic
%   warp differences are usually bigger than drift. 
%--------------------------------------------------------------------------
% Outputs
% mlist         -- modified mlist containing warped variables.
%
%--------------------------------------------------------------------------
% Inputs
% chn / string 
%               -- the name of the channel corresponding to mlist.  Must
%               match channel name in tforms3D.mat/tforms2D.mat.
%               acceptable values = '488','561','647',or '750'
% mlist / struct
%               -- the molecule list structure
% Bead_folder / string
%               -- the location of the warp transfrom ('tforms2D.mat' or
%               'tforms3D.mat').
%
%--------------------------------------------------------------------------
% Optional Inputs
% warpD / double / 3       
%               -- the warp to apply. 3 = 3D. 2.5 = 2D only applied to x
%               and y.
% verbose / logical / true
%               -- print status to command window?   
%--------------------------------------------------------------------------
% Alistair Boettiger
% boettiger.alistair@gmail.com
% October 9th, 2012
%
% Version 2.0
%--------------------------------------------------------------------------
% Version update information
% 
%--------------------------------------------------------------------------
% Creative Commons License 3.0 CC BY  
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Default parameters
%--------------------------------------------------------------------------
verbose = true;
warpD = 3;

%--------------------------------------------------------------------------
% Parse variable input
%--------------------------------------------------------------------------
if nargin < 1
   error([mfilename,' expects input: cell of binnames']);
end
if nargin > 1
    if (mod(length(varargin), 2) ~= 0 ),
        error(['Extra Parameters passed to the function ''' mfilename ''' must be passed in pairs.']);
    end
    parameterCount = length(varargin)/2;
    for parameterIndex = 1:parameterCount,
        parameterName = varargin{parameterIndex*2 - 1};
        parameterValue = varargin{parameterIndex*2};
        switch parameterName    
            case 'warpD'
                warpD = CheckParameter(parameterValue,'nonnegative','warpD'); 
            case 'verbose'
                verbose = CheckParameter(parameterValue,'string','verbose');                
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end

%--------------------------------------------------------------------------
% Maing Function
%--------------------------------------------------------------------------

if warpD ~= 0 % Don't apply chromewarp;
    
x = double(molist.xc); % shorthand.  TFORMINV can't handle singles (?!)
y = double(molist.yc);
z = double(molist.zc);

has3D = dir([Bead_folder,filesep,'tforms3D.mat']);
has2D = dir([Bead_folder,filesep,'tforms2D.mat']);
if isempty(has3D) && ~isempty(has2D) && warpD == 3
    disp('no 3D warp map found, using 2D warp map');
    warpD = 2;
end
if isempty(has2D) && ~isempty(has3D) && warpD == 2
     disp('no 2D warp map found, using 3D warp map on x and y only');
    warpD = 2.5;
end
if isempty(has3D) && isempty(has2D)
   disp(['error: folder ',Bead_folder,' does not contain a tforms3D.mat or tforms2D.mat warp map']); 
end

% channel '647' needs no modification to warp to itself.  
if strcmp(chn,'647')
    warpD = 4;
end

if warpD == 3
    load([Bead_folder,filesep,'tforms3D.mat']);
    if strcmp(chn,'750')
        if exist('tform750_1','var')
          [x,y] = tforminv(tform750_1, x,y);
        end
         [x,y,z] = tforminv(tform750, x,y,z);
         if verbose; disp('750 data mapped to 647 chn in 3D'); end
    elseif strcmp(chn,'561')  
        if exist('tform561_1','var')
          [x,y] = tforminv(tform561_1,x,y);
        end
        [x,y,z] =  tforminv(tform561, x,y,z);
       if verbose; disp('561 data mapped to 647 chn in 3D'); end
    elseif strcmp(chn,'488') 
        if exist('tform488_1','var')
          [x,y] = tforminv(tform488_1, x,y);
        end
        [x,y,z] = tforminv(tform488, x,y,z);
        if verbose; disp('488 data mapped to 647 chn in 3D'); end

    end
elseif warpD == 2.5
      load([Bead_folder,filesep,'tforms3D.mat']);
    if strcmp(chn,'750')
         [x,y,~] = tforminv(tform750, x,y,z);
        if verbose; disp('750 data mapped to 647 chn in 2D'); end
    elseif strcmp(chn,'561')  
        [x,y,~] = tforminv(tform561,  x,y,z);
        if verbose; disp('561 data mapped to 647 chn in 2D'); end
    elseif strcmp(chn,'488')    
        [x,y,~] = tforminv(tform488,  x,y,z);
        if verbose; disp('488 data mapped to 647 chn in 2D'); end

    end
elseif warpD == 2
     load([Bead_folder,filesep,'tforms2D.mat']);
    if strcmp(chn,'750')
        if exist('tform750_1','var')
          [x,y] = tforminv(tform750_1, x,y);
        end
         [x,y] = tforminv(tform750_2D, x,y);
         if verbose; disp('750 data mapped to 647 chn in 2D'); end
    elseif strcmp(chn,'561') 
        if exist('tform561_1','var')
          [x,y] = tforminv(tform561_1, x,y);
        end
        [x,y] =  tforminv(tform561_2D,x,y);
        if verbose; disp('561 data mapped to 647 chn in 2D'); end
    elseif strcmp(chn,'488')  
        if exist('tform488_1','var')
          [x,y] = tforminv(tform488_1, x,y);
        end
        [x,y] =  tforminv(tform488_2D,x,y);
        if verbose; disp('488 data mapped to 647 chn in 2D'); end

    end
end

molist.xc = single(x);
molist.yc = single(y);
molist.zc = single(z);

end
