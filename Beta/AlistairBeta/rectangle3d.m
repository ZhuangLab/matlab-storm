function h = rectangle3d(mins,lengths,varargin)
%--------------------------------------------------------------------------
% rectangle3d([xmin,ymin,zmin],[xlength,ylength,zlength]);
%
%--------------------------------------------------------------------------
% Required inputs
%--------------------------------------------------------------------------
% [xmin,ymin,zmin]               -- vector of min box coorner
% [xlength,ylength,zlength]      -- vector of box dimensions
%
%--------------------------------------------------------------------------
% Outputs (optional)
%--------------------------------------------------------------------------
% h     -- handle to the box object
%
%--------------------------------------------------------------------------
% Optional inputs
%--------------------------------------------------------------------------
% 'color' / string / 'b'    -- color of box 
% 'linewidth' / double / 1  -- linewidth
%
%--------------------------------------------------------------------------
% Examples
%--------------------------------------------------------------------------
% The BoundingBox from 3D regionprops command can be plotted by:
%    rectangle3d(R(1).BoundingBox(1:3),R(1).BoundingBox(4:6))
%
%--------------------------------------------------------------------------
% Alistair Boettiger
% boettiger.alistair@gmail.com
% February 19th, 2013
%
% Version 1.0
%--------------------------------------------------------------------------
% Credits
%--------------------------------------------------------------------------
% Based off of solution from Amro on StackOverflow
% http://stackoverflow.com/questions/7309188/how-to-plot-3d-grid-cube-in-matlab
%--------------------------------------------------------------------------




%-------------------------------------------------------------------------
%% default inputs
%-------------------------------------------------------------------------
colr = 'b'; 
lw = 1; % 
%
%--------------------------------------------------------------------------
%% Parse variable input
%--------------------------------------------------------------------------
if nargin > 3
    if (mod(length(varargin), 2) ~= 0 ),
        error(['Extra Parameters passed to the function ''' mfilename ''' must be passed in pairs.']);
    end
    parameterCount = length(varargin)/2;
    for parameterIndex = 1:parameterCount,
        parameterName = varargin{parameterIndex*2 - 1};
        parameterValue = varargin{parameterIndex*2};
        switch parameterName
            case 'color'
                colr = parameterValue;                   
            case 'linewidth'
                lw = parameterValue;
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end

x = linspace(mins(1),mins(1)+lengths(1),2);
y = linspace(mins(2),mins(2)+lengths(2),2);
z = linspace(mins(3),mins(3)+lengths(3),2);

[X1, Y1, Z1] = meshgrid(x([1 end]),y,z);
X1 = permute(X1,[2 1 3]); Y1 = permute(Y1,[2 1 3]); Z1 = permute(Z1,[2 1 3]);
X1(end+1,:,:) = NaN; Y1(end+1,:,:) = NaN; Z1(end+1,:,:) = NaN;
[X2, Y2, Z2] = meshgrid(x,y([1 end]),z);
X2(end+1,:,:) = NaN; Y2(end+1,:,:) = NaN; Z2(end+1,:,:) = NaN;
[X3, Y3, Z3] = meshgrid(x,y,z([1 end]));
X3 = permute(X3,[3 1 2]); Y3 = permute(Y3,[3 1 2]); Z3 = permute(Z3,[3 1 2]);
X3(end+1,:,:) = NaN; Y3(end+1,:,:) = NaN; Z3(end+1,:,:) = NaN;


h = line([X1(:);X2(:);X3(:)], [Y1(:);Y2(:);Y3(:)], [Z1(:);Z2(:);Z3(:)]);
set(h, 'Color',colr, 'LineWidth',lw, 'LineStyle','-')
