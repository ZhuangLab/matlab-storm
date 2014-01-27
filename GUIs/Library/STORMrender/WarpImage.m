function imageOut = WarpImage(imageIn,chnName,warpfile,varargin)
%  WarpImage(imageIn,chnName,warpfile)
% applies chromatic warp to 2D image
%--------------------------------------------------------------------------
% Outputs
% imageOut / matrix        -- warped 2D image  
%
%--------------------------------------------------------------------------
% Inputs
% imageIn / matrix
%               -- 2D image 
% chnName / string
%               -- the names of the channel the data was taken in.
%                   This must match the names of the channels in
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
% verbose / logical / true
%               -- print status to command window?   
%--------------------------------------------------------------------------
% Alistair Boettiger
% boettiger.alistair@gmail.com
% December 28th 2013
%
% Version 1.0
%--------------------------------------------------------------------------
% Version update information
% 
%--------------------------------------------------------------------------
% Creative Commons License 3.0 CC BY  
%--------------------------------------------------------------------------



%--------------------------------------------------------------------------
% Default Parameters
%--------------------------------------------------------------------------
verbose = true; 
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
            case 'verbose'
                verbose = CheckParameter(parameterValue,'boolean','verbose');                
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end

%% Main Function
load(warpfile)

% If chromewarp file does not have channel names, assume defaults.  
if ~exist('chn_warp_names','var')
    chn_warp_names = {'750','647';
                      '561','647';
                      '488','647'};
end

[H,W] = size(imageIn); 

chnIdx = find(strcmp(chn_warp_names(:,1),chnName)); 
if ~isempty(chnIdx)
    imageOut = imtransform(imageIn,tform_1_inv{chnIdx},...
                'XYScale',1,'XData',[1 W],'YData',[1 H]); %#ok<*DIMTRNS,USENS>
    imageOut = imtransform(imageOut,tform2D_inv{chnIdx},...
                'XYScale',1,'XData',[1 W],'YData',[1 H]); %#ok<USENS>
    if verbose
        disp(['Data mapped using ',...
            chn_warp_names{chnIdx,1},' to ',chn_warp_names{chnIdx,2},...
            ' bead warp map.']);
        disp(['Warp accuracy: ',num2str(cdf2D_thresh(chnIdx),2),' nm']);
    end
else
    if verbose
        disp('Data not warped');
    end
    imageOut = imageIn; 
end


