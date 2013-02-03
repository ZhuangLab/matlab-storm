function Im3Dslices(Ic,varargin)
%-------------------------------------------------------------------------
%% function Im3D
% Im3D(Ic);
% Im3D(Ic,'downsample',value,'zStepSize',value,'xyStepSize',value,...
%    'theta',value,'color',value);
%  Converts at 3D image file into a 3D surface plot image, using the 3rd
%  dimension as Z information.  Isosurfaces are plotted at the indicated
%  threshold.  
%-------------------------------------------------------------------------
% Inputs
% Ic mxnxp image  -- image matrix to render 3D
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
% Version 1.0
%--------------------------------------------------------------------------
% Creative Commons License 3.0 CC BY 
%--------------------------------------------------------------------------


%-------------------------------------------------------------------------
%% Default parameters
%-------------------------------------------------------------------------
xyp = 1;
stp = 3;
zstp = 1; 
theta = []; 
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
%% Main Analysis Script
%-------------------------------------------------------------------------
if isempty(theta)
   theta = 2*double(nanmean(Ic(:)));
end

[hs,ws,Zs] = size(Ic);
I2 = double(Ic);
I2(I2<theta) = NaN;

[X,Y] = meshgrid((1:stp:ws)*xyp,(1:stp:hs)*xyp);
% Plot nuclei data
for z=1:Zs
    In = double(I2(1:stp:ws,1:stp:ws,z) + colr); 
    Z = (Zs - z*ones(size(In)))*zstp;
    surf(X,Y,Z,In); hold on;
end
 shading interp;
 alpha(.45);  % make nuclei transparent 