function [renderedImages, parameters] = RenderStack(MList, range, varargin)
% ------------------------------------------------------------------------
% [renderedImages, parameters] = RenderStack(MList, range, varargin)
% This function renders a series of high resolution images of the MList or
%   data structure with the appropriate values indexed by the values in
%   range. 
%--------------------------------------------------------------------------
% Necessary Inputs
% MList/A molecule list structure. See ReadMasterMoleculeList().
%    Alternatively, MList could be an Nx3 array containing the data to be
%    rendered.  The first two dimensions contain the data to be rendered
%    and the third contains the data used to split the stack. 
% range/An L+1x1 array that determines which which values be included in
%    each stack
%--------------------------------------------------------------------------
% Outputs
% renderedImage/An NxMxL array containing the rendered molecules within the
%   L values determined by range.
% parameters/A structure containing the parameters used to render the
%   image.
%--------------------------------------------------------------------------
% Variable Inputs (Flag/ data type /(default)):
%--------------------------------------------------------------------------
% Jeffrey Moffitt
% jeffmoffitt@gmail.com
% May 8, 2014
%--------------------------------------------------------------------------
% Creative Commons License CC BY NC SA
%--------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Default variables
% -------------------------------------------------------------------------
defaults = cell(0,3);
defaults(end+1,:) = {'renderMode', {'molecules', 'photons'}, 'molecules'};
defaults(end+1,:) = {'gaussianWidth', 'nonnegative', .2};
defaults(end+1,:) = {'index', 'array', []};
defaults(end+1,:) = {'mlistType', {'compact', 'noncompact'}, 'compact'};
defaults(end+1,:) = {'ROI', 'array', [1 256; 1 256]};
defaults(end+1,:) = {'imageScale', 'positive', 10};
defaults(end+1,:) = {'view', 'cell', {'x', 'y', 'z'}}; % Note that this is an overload
defaults(end+1,:) = {'photonsField', 'string', 'a'};
defaults(end+1,:) = {'matSizeScale', 'positive', 5};
defaults(end+1,:) = {'verbose', 'boolean', false};

% -------------------------------------------------------------------------
% Parse necessary input
% -------------------------------------------------------------------------
if nargin < 2
    error('matlabSTORM:invalidArguments', 'An MList and a range are required.');
end

% -------------------------------------------------------------------------
% Parse variable input
% -------------------------------------------------------------------------
parameters = ParseVariableArguments(varargin, defaults, mfilename);

% -------------------------------------------------------------------------
% Timing if verbose
% -------------------------------------------------------------------------
if parameters.verbose
    tic;
end

% -------------------------------------------------------------------------
% Build data array
% -------------------------------------------------------------------------
if isstruct(MList)
    switch parameters.mlistType
        case 'compact'
            if ~isempty(parameters.index)
                for i=1:3
                    data(:,i) = MList.(parameters.view{i})(parameters.index);
                end
            else
                for i=1:3
                    data(:,i) = MList.(parameters.view{i});
                end
            end
        case 'noncompact'
            if ~isempty(parameters.index)
                for i=1:3
                    data(:,i) = [MList(parameters.index).(parameters.view{i})];
                end
            else
                for i=1:3
                    data(:,i) = [MList.(parameters.view{i})];
                end
            end
    end
else % Handle direct input of data array
    data = MList;
    dim = size(data);
    if ~any(dim == 3)
        error('matlabSTORM:invalidArguments', 'Provided array is not Nx3');
    elseif dim(1)==3
        data = data';
    end
end

% -------------------------------------------------------------------------
% Parse molecules into appropriate ranges
% -------------------------------------------------------------------------
[~, inds] = histc(data(:,3), range);

% -------------------------------------------------------------------------
% Preallocate memory
% -------------------------------------------------------------------------
dx = 1/parameters.imageScale;
for i=1:2
    dim(i) = length(((parameters.ROI(i,1)-1):dx:parameters.ROI(i,2))) - 1;
end
renderedImages = zeros(dim(1), dim(2), length(range)-1);

% -------------------------------------------------------------------------
% Create image stack
% -------------------------------------------------------------------------
for i=1:(length(range)-1)
    renderedImages(:,:,i) = RenderMList(data(inds==i,1:2), 'parameters', parameters);
end

% -------------------------------------------------------------------------
% Performance reporting
% -------------------------------------------------------------------------
if parameters.verbose
    display(['Rendered stack in ' num2str(toc) ' s']);
end
