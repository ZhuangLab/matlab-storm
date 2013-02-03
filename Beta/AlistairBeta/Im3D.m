function Im3D(I,varargin)
%-------------------------------------------------------------------------
%% function Im3D
% Im3D(Ic);
% Im3D(Ic,'downsample',value,'zStepSize',value,'xyStepSize',value,...
%    'theta',value,'resolution',value,'color',value);
%  Converts at 3D image file into a 3D surface plot image, using the 3rd
%  dimension as Z information.  Isosurfaces are plotted at the indicated
%  threshold.  
%-------------------------------------------------------------------------
% Inputs
% I mxnxp image  -- image matrix to render 3D.  If multicolor, Ic is a
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
%                       If multicolor image: use a cell of doubles to
%                       specify different threshold options for each color
%                       channel. 
% 'resolution' / double / 3
%                       -- smoothing of image prior to rendering.  higher
%                       numbers here speed up plotting and lower image
%                       resolution.
%                       If multicolor image: use a cell of doubles to
%                       specify different resolution option for each color
%                       channel. 
% 'color' / string / 'blue'
%                       -- surface color of objects
%                           if multicolor, 'color' should be a cell array
%                           of strings, indicating the color of each
%                           channel.  
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
res = 3; 
colr = 'blue';

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
                theta = parameterValue;  % allowed to be a cell or a double
            case 'resolution'
                res = parameterValue; % allowed to be a cell or a double
            case 'color'
                colr = parameterValue; % allowed to be a cell or a double
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

if ~iscell(res)
    res = {res};
end
if length(res) < channels
    res(2:channels) = res(1); 
end

if ~iscell(colr)
    colr = {colr};
end
if length(colr) < channels
    colr =  mat2cell(hsv(channels),ones(1,channels),3);
end

 save('C:\Users\Alistair\Documents\Projects\General_STORM\Test_data\test.mat')
% load('C:\Users\Alistair\Documents\Projects\General_STORM\Test_data\test.mat')

%-------------------------------------------------------------------------
%% Main Analysis Script
%-------------------------------------------------------------------------

for c=1:channels
    Iin = I{c};
    if isempty(theta{c})
       theta{c} = 2*nanmean(double(Iin(:)));
    end

    disp(theta{c});

    [hs,ws,Zs] = size(Iin);
    x = (1:stp:ws)*xyp;
    y = (1:stp:hs)*xyp;
    z = Zs*zstp-zstp*(1:Zs);
    I1 = Iin;
    [X,Y,Z] = meshgrid(x,y,z);
    data = I1(1:stp:end,1:stp:end,1:Zs);
    data = smooth3(data,'box',res{c});
    patch(isosurface(Y,X,Z,data,theta{c}),'FaceColor',colr{c},'EdgeColor','none');
end
