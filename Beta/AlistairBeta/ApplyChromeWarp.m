

function mlist = ApplyChromeWarp(mlist,chns,warpfile,varargin)
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
% mlist / cell
%               -- cell array of molecule list structures
% chns / cell
%               -- the names of the channels in the order they are listed
%               in mlist.  These must match the names of the channels in
%               the warpfile to be used.  
% warpfile / string
%               -- full path and filename of the .mat file containing the
%               chromatic warps (produced by function CalcChromeWarp.m).
%               This mat file contains the following variables:
%    'tform_1','tform','tform2D', -- transforms 
%    'cdf','cdf2D','cdf_thresh','cdf2D_thresh','thr', -- quality scores
%    'chn_warp_names' -- names of channels
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
% Global Parameters
%--------------------------------------------------------------------------
global ScratchPath


%--------------------------------------------------------------------------
% Default Parameters
%--------------------------------------------------------------------------
verbose = true; 
warpD = 3;
fnames = {};
% warpfile = 'I:\2013-02-09_fab7Pc\Beads\3DBeads1\chromewarps.mat';

%--------------------------------------------------------------------------
% Parse Variable Input Parameters
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
            case 'names'
                fnames = CheckParameter(parameterValue,'cell','names'); 
            case 'verbose'
                verbose = CheckParameter(parameterValue,'string','verbose');                
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end

%--------------------------------------------------------------------------
%% Maing Function
%--------------------------------------------------------------------------

% save([ScratchPath,'test2.mat'])
% load([ScratchPath,'test2.mat'])

if warpD ~= 0 % No Chromewarp

    load(warpfile)
% If chromewarp file does not have channel names, assume defaults.  
if ~exist('chn_warp_names','var')
    chn_warp_names = {'750','647';'561','647';'488','647'};
end

% if no filenames are given, use channel match names
if isempty(fnames)
    fnames = chns;
end


if warpD == 2 
    tform = tform2D;
end

for c=1:length(mlist) % c =2
    x = double(mlist{c}.xc); % shorthand.  TFORMINV can't handle singles (?!)
    y = double(mlist{c}.yc);
    z = double(mlist{c}.zc);
    k = find(strcmp(chns{c},chn_warp_names(:,1)));
    if ~isempty(k);  
        [x,y] = tforminv(tform_1{k},x,y); %#ok<*USENS>
        [x,y,z] = tforminv(tform{k},x,y,z);
        mlist{c}.xc = single(x);
        mlist{c}.yc = single(y); 
        if warpD ~=2.5
            mlist{c}.zc = single(z);
        end
        if verbose
            disp([fnames{c},' data mapped in',num2str(warpD),'D using ',...
                chn_warp_names{k,1},' to ',chn_warp_names{k,2},...
                ' bead warp map.']);
            disp(['3D Warp accuracy: ',num2str(cdf_thresh(k),2),' nm']); 
            disp(['xy Warp accuracy: ',num2str(cdf2D_thresh(k),2),' nm']);
        end
    else
        if verbose
            disp([fnames{c},' used as reference channel. Not warped.']); 
        end
    end       
end


end