function Im3Dslices(I,varargin)
%-------------------------------------------------------------------------
%% function Im3Dslices
% Im3Dslices(Ic);
% Im3Dslices(Ic,'downsample',value,'zStepSize',value,'xyStepSize',value,...
%    'theta',value,'color',value);
%  Converts at 3D image file into a 3D view of semi-transparent, 2d
%  histograms stacked in Z.  A threshold is also applied to render
%  invisible other background intensity.  
%-------------------------------------------------------------------------
% Inputs
% I mxnxp image  -- image matrix to render 3D.  If multicolor, I is a
%                   cell array of 3D image matrices.   
% 
%-------------------------------------------------------------------------
% Optional Inputs
% 'downsample' / double / 3
%                       -- downsample the input image to speed up render
% 'zStepSize' / double / 1 
%                       -- units per pixel in Z
% 'xyStepSize' / double / 1 
%                       -- units per pixel in XY
% 'theta' / double / auto
%                       -- Threshold image intensity at which to plot
%                       isosurfaces.  Default is 2 * average pixel
%                       intensity.
% 'coloroffset' / double / 0
%                       -- offset in color values (used for plotting
%                       multiple channels in the same figure in different
%                       colors.  The offset should be greater than the
%                       largest intensity value in the previous image call.
%                       
%-------------------------------------------------------------------------
% Outputs
%           Creates a plot in the current figure
%
%--------------------------------------------------------------------------
% Alistair Boettiger
% boettiger.alistair@gmail.com
% October 10th, 2012
%
% Version 1.1
%--------------------------------------------------------------------------
% Updates
% Version 1.1 now in multicolor!
%--------------------------------------------------------------------------
% Creative Commons License 3.0 CC BY 
%--------------------------------------------------------------------------


%-------------------------------------------------------------------------
%% Default parameters
%-------------------------------------------------------------------------
xyp = 1;
stp = 3;
zstp = 1; 
theta = cell(10,1); 
colr = 0;

%--------------------------------------------------------------------------
%% Parse Variable Input Arguments
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
            case 'downsample'
                stp = CheckParameter(parameterValue, 'positive', 'downsample');
            case 'zStepSize'
                zstp = CheckParameter(parameterValue, 'positive', 'zStepSize');
            case 'xyStepSize'
                xyp = CheckParameter(parameterValue, 'positive', 'xyStepSize');
            case 'theta'
                theta = CheckParameter(parameterValue, 'positive', 'theta');
            case 'coloroffset'
                colr = parameterValue;
            otherwise
                error(['The parameter ''', parameterName,...
                    ''' is not recognized by the function, ''',...
                    mfilename '''.' '  See help ' mfilename]);
        end
    end
end




%-------------------------------------------------------------------------
%% Parse variable input formats 
%-------------------------------------------------------------------------

% handling different inputs for multicolor images
if iscell(I)
    channels = length(I);
else
    I = {I}; 
end

if ~iscell(theta)
   theta = {theta};
end
if length(theta) < channels
    theta(2:channels) = theta(1); 
end





%-------------------------------------------------------------------------
%% Main Analysis Script
%-------------------------------------------------------------------------
for c=1:channels
    Iin = I{c};
    if isempty(theta{c})
       theta{c} = 2*nanmean(double(Iin(:)));
    end

    [hs,ws,Zs] = size(Iin);
    I2 = double(Iin);
    I2(I2<theta{c}) = NaN;

    [X,Y] = meshgrid((1:stp:ws)*xyp,(1:stp:hs)*xyp);
    % Plot nuclei data
    for z=1:Zs
        In = double(I2(1:stp:ws,1:stp:ws,z) + colr); 
        Z = (Zs - z*ones(size(In)))*zstp;
        surf(X,Y,Z,In); hold on;
    end
     shading interp;
     alpha(.45);  % make  transparent 
     colr = colr + max(In(:)); 
end