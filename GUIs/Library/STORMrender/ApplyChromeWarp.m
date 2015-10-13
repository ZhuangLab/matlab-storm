function mlist = ApplyChromeWarp(mlist,chns,warpfile,varargin)
% mlist = ApplyChromeWarp(mlist,chns,warpfile)
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
warpD = 2;
fnames = {};
% warpfile = 'I:\2013-02-09_fab7Pc\Beads\3DBeads1\chromewarps.mat';

%--------------------------------------------------------------------------
% Parse Variable Input Parameters
%--------------------------------------------------------------------------
if nargin < 3
   error([mfilename,' expects inputs: cell of binnames, cell of channels, and string to a chromewarps.mat warp file']);
end
if nargin > 3
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
                verbose = CheckParameter(parameterValue,'boolean','verbose');                
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end


% handle non-cell input (for stucture arrays or single inputs)
output = 'cell';
if ~iscell(mlist)
    alist = mlist;
    mlist = cell(length(alist),1);
    for c=1:length(alist)
        mlist{c} = alist(c);
    end
    output = 'struct';
end
if ~iscell(chns)
    chns = {chns};
end

%--------------------------------------------------------------------------
%% Main Function
%--------------------------------------------------------------------------

if warpD ~= 0 && ~isempty(warpfile)  % No Chromewarp
    try
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
        xc = double(mlist{c}.xc); % shorthand.  TFORMINV can't handle singles (?!)
        yc = double(mlist{c}.yc);
        zc = double(mlist{c}.zc);
        x = double(mlist{c}.x); % shorthand.  TFORMINV can't handle singles (?!)
        y = double(mlist{c}.y);
        z = double(mlist{c}.z);
        k = find(strcmp(chns{c},chn_warp_names(:,1)));
        if ~isempty(k);  
            [xc,yc] = tforminv(tform_1{k},xc,yc); %#ok<*USENS>
            [x,y] = tforminv(tform_1{k},x,y); 
            if warpD > 2
                [xc,yc,zc] = tforminv(tform{k},xc,yc,zc);
                [x,y,z] = tforminv(tform{k},x,y,z);
            elseif warpD == 2
                [xc,yc] = tforminv(tform{k},xc,yc);
                [x,y] = tforminv(tform{k},x,y);
            end 
            mlist{c}.xc = single(xc);
            mlist{c}.yc = single(yc); 
            mlist{c}.x = single(x);
            mlist{c}.y = single(y); 
            if warpD ~=2.5
                mlist{c}.zc = single(zc);
                mlist{c}.z = single(z);
            end
            if verbose
                disp([fnames{c},' data mapped in ',num2str(warpD),'D using ',...
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
    catch er
        if verbose
            warning('failed to apply chromatic warp');
            disp(er.getReport);
        end
    end
end


if strcmp(output,'struct');
    alist = mlist;
    mlist = CreateMoleculeList(0);
    for c=1:length(alist)
        mlist(c) = alist{c};
    end
end
