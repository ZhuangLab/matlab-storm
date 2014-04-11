function [renderedImage, parameters] = RenderMList(MList, varargin)
% ------------------------------------------------------------------------
% [renderedImage, parameters] = RenderMList(MList, varargin)
% This function renders an MList into a high resolution image.  
%--------------------------------------------------------------------------
% Necessary Inputs
% MList/A molecule list structure. See ReadMasterMoleculeList().
%
%--------------------------------------------------------------------------
% Outputs
% renderedImage/An NxM array containing the rendered molecules.
% parameters/A structure containing the parameters used to render the
%   image.
%--------------------------------------------------------------------------
% Variable Inputs (Flag/ data type /(default)):
%--------------------------------------------------------------------------
% Jeffrey Moffitt
% jeffmoffitt@gmail.com
% April 10, 2014
%--------------------------------------------------------------------------
% Creative Commons License CC BY NC SA
%--------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Default variables
% -------------------------------------------------------------------------
defaults = cell(0,3);
defaults(end+1,:) = {'renderMode', {'molecules', 'photons'}, 'molecules'};
defaults(end+1,:) = {'gaussianWidth', 'nonnegative', .1};
defaults(end+1,:) = {'index', 'array', []};
defaults(end+1,:) = {'mlistType', {'compact', 'noncompact'}, 'compact'};
defaults(end+1,:) = {'ROI', 'array', [1 256; 1 256]};
defaults(end+1,:) = {'imageScale', 'positive', 10};
defaults(end+1,:) = {'view', 'cell', {'x', 'y'}};
defaults(end+1,:) = {'photonsField', 'string', 'a'};

% -------------------------------------------------------------------------
% Parse necessary input
% -------------------------------------------------------------------------
if nargin < 1
    error('matlabSTORM:invalidArguments', 'A MList is required');
end

% -------------------------------------------------------------------------
% Parse variable input
% -------------------------------------------------------------------------
parameters = ParseVariableArguments(varargin, defaults, mfilename);

% -------------------------------------------------------------------------
% Determine range
% -------------------------------------------------------------------------
dx = 1/parameters.imageScale;
for i=1:2
    edges{i} = (parameters.ROI(i,1)-1):dx:parameters.ROI(i,2);
end

% -------------------------------------------------------------------------
% Determine data to render
% -------------------------------------------------------------------------
switch parameters.mlistType
    case 'compact'
        if ~isempty(parameters.index)
            for i=1:2
                data(:,i) = MList.(parameters.view{i})(parameters.index);
            end
        else
            for i=1:2
                data(:,i) = MList.(parameters.view{i});
            end
        end
    case 'noncompact'
        if ~isempty(parameters.index)
            for i=1:2
                data(:,i) = MList(parameters.index).(parameters.view{i});
            end
        else
            for i=1:2
                data(:,i) = MList(parameters.index).(parameters.view{i});
            end
        end
end

% -------------------------------------------------------------------------
% Render image and remove spurious last row and column
% -------------------------------------------------------------------------
switch parameters.renderMode
    case 'molecules'
        renderedImage = hist3(data, 'Edges', edges);
        renderedImage = renderedImage(1:(length(edges{1})-1), 1:(length(edges{2})-1));
    case 'photons'
        % -------------------------------------------------------------------------
        % Underdevelopment
        % -------------------------------------------------------------------------
end

% -------------------------------------------------------------------------
% Blur image
% -------------------------------------------------------------------------
if parameters.gaussianWidth ~= 0
    sigma = parameters.gaussianWidth*parameters.imageScale;
    matSize = max(3, 10*floor(sigma/2) + 1); %Force to nearest odd
    filterMat = fspecial('gaussian', matSize, sigma);
    renderedImage = imfilter(renderedImage, filterMat);
end
