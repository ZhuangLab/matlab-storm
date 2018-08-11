function [parameters, settings] = WriteDaoSTORMParameters(filePath, varargin)
% ------------------------------------------------------------------------
% [parameters, xmlObj] = CreateDaoSTORMParameters(varargin)
% This function creates a structure with fields the contain all of the
% parameters needed for 3D daoSTORM analysis. 
%--------------------------------------------------------------------------
% Necessary Inputs
% -- filePath: A string specifying the location of the file to write
% (provide an empty array to just return the parameters structure without 
%  saving a file)
%--------------------------------------------------------------------------
% Outputs
%--------------------------------------------------------------------------
% Variable Inputs (Flag/ data type /(default)):
%--------------------------------------------------------------------------
% Jeffrey Moffitt 
% jeffmoffitt@gmail.com
% March 9, 2016
%--------------------------------------------------------------------------
% Creative Commons License CC BY NC SA
%--------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Default variables
% -------------------------------------------------------------------------
defaults = cell(0,3);
% Parameters controlling this function, not daoSTORM
defaults(end+1,:) = {'verbose', 'boolean', false}; 

% Parameters describing the frames and AOI to analyze
defaults(end+1,:) = {'start_frame', 'integer', -1}; % The initial frame for analysis
defaults(end+1,:) = {'max_frame', 'integer', -1};   % The final frame for analysis (-1 implies all frames)

defaults(end+1,:) = {'x_start', 'nonnegative', 0};      % The first x pixel 
defaults(end+1,:) = {'x_stop', 'nonnegative', 2048};       % The last x pixel 
defaults(end+1,:) = {'y_start', 'nonnegative', 0};   % The first y pixel
defaults(end+1,:) = {'y_stop', 'nonnegative', 2048};    % The last y pixel

% Parameters describing the fitting
defaults(end+1,:) = {'model', {'2dfixed', '2d', '3d', 'Z'}, '2d'};
%   2dfixed - fixed sigma 2d gaussian fitting.
%   2d - variable sigma 2d gaussian fitting.
%   3d - x, y sigma are independently variable,
%          z will be fit after peak fitting.
%   Z - x, y sigma depend on z, z is fit as
%          part of peak fitting.

defaults(end+1,:) = {'iterations', 'positive', 20};     % The number of iterations to perform
defaults(end+1,:) = {'threshold', 'positive', 100.0};   % The minimum brightness
defaults(end+1,:) = {'sigma', 'positive', 1.0};         % The initial guess for the width (in pixels)

% Parameters describing the camera
defaults(end+1,:) = {'baseline', 'nonnegative', 100.0};    % The background term of the CCD
defaults(end+1,:) = {'pixel_size', 'positive', 160.0};  % The pixel size
defaults(end+1,:) = {'orientation', {'normal', 'inverted'}, 'normal'}; % The orientation of the CCD

% Parameters for multi-activator STORM
defaults(end+1,:) = {'descriptor', {'0', '1', '2', '3', '4'}, '1'}; 

% Parameters for peak matching
defaults(end+1,:) = {'radius', 'nonnegative', 0};   % Radius in pixels to connect molecules between frames
                                                    % 0 indicates no connection
                                                    
% Parameters for Z fitting
defaults(end+1,:) = {'do_zfit', 'boolean', false};  % Should z fitting be performed
defaults(end+1,:) = {'cutoff', 'nonnegative', 1.0};

defaults(end+1,:) = {'wx_wo', 'float', 238.3076};
defaults(end+1,:) = {'wx_c', 'float', 415.5645};
defaults(end+1,:) = {'wx_d', 'float', 958.792};
defaults(end+1,:) = {'wxA', 'float', -7.1131};
defaults(end+1,:) = {'wxB', 'float', 19.9998};
defaults(end+1,:) = {'wxC', 'float', 0.0};
defaults(end+1,:) = {'wxD', 'float', 0.0};
    
defaults(end+1,:) = {'wy_wo', 'float', 218.9904};
defaults(end+1,:) = {'wy_c', 'float', -310.7737};
defaults(end+1,:) = {'wy_d', 'float', 268.0425};
defaults(end+1,:) = {'wyA', 'float', 0.53549};
defaults(end+1,:) = {'wyB', 'float', -0.099514};
defaults(end+1,:) = {'wyC', 'float', 0.0};
defaults(end+1,:) = {'wyD', 'float', 0.0};

defaults(end+1,:) = {'min_z', 'float', -0.5};
defaults(end+1,:) = {'max_z', 'float', 0.5};

% Parameters for drift correction
defaults(end+1,:) = {'drift_correction', 'boolean', false}; % Should drift correction be applied
defaults(end+1,:) = {'frame_step', 'nonnegative', 8000};
defaults(end+1,:) = {'d_scale', 'positive', 2};

% -------------------------------------------------------------------------
% Define fields and types
% -------------------------------------------------------------------------
fieldsAndTypes = {...
    {'start_frame', 'int'}, {'max_frame', 'int'}, ...
    {'x_start', 'int'}, {'x_stop', 'int'}, ...
    {'y_start', 'int'}, {'y_stop', 'int'}, ...
    {'model', 'string'}, {'iterations', 'int'}, ...
    {'baseline', 'float'}, {'pixel_size', 'float'}, ...
    {'orientation', 'string'}, {'threshold', 'float'}, ...
    {'sigma', 'float'}, {'descriptor', 'string'}, ...
    {'radius', 'float'}, {'do_zfit', 'int'}, ...
    {'cutoff', 'float'}, ...
    {'wx_wo', 'float'}, {'wx_c', 'float'}, ...
    {'wx_d', 'float'}, {'wxA', 'float'}, ...
    {'wxB', 'float'}, {'wxC', 'float'}, ...
    {'wxD', 'float'}, ...
    {'wy_wo', 'float'}, {'wy_c', 'float'}, ...
    {'wy_d', 'float'}, {'wyA', 'float'}, ...
    {'wyB', 'float'}, {'wyC', 'float'}, ...
    {'wyD', 'float'}, ...
    {'min_z', 'float'}, {'max_z', 'float'}, ...
    {'drift_correction', 'int'}, {'frame_step', 'int'}, ...
    {'d_scale', 'int'}};

% -------------------------------------------------------------------------
% Parse variable input
% -------------------------------------------------------------------------
parameters = ParseVariableArguments(varargin, defaults, mfilename);

% -------------------------------------------------------------------------
% Check for requested file save
% -------------------------------------------------------------------------
if isempty(filePath)
    return;
end

% -------------------------------------------------------------------------
% Check for xml extension
% -------------------------------------------------------------------------
[~, ~, fileExt] = fileparts(filePath);
if ~strcmp(fileExt, '.xml')
    error('matlabSTORM:invalidArguments', 'Provided path must be to an xml file');
end

% -------------------------------------------------------------------------
% Create XML Object
% -------------------------------------------------------------------------
% Create the root element
xmlObj = com.mathworks.xml.XMLUtils.createDocument('settings');
settings = xmlObj.getDocumentElement;
% Loop over parameters fields and create individual nodes for each
for f=1:length(fieldsAndTypes)
    localFieldAndType = fieldsAndTypes{f};
    
    % Create node and define type
    node = xmlObj.createElement(localFieldAndType{1});
    node.setAttribute('type', localFieldAndType{2});
    
    % Find corresponding parameter and coerce value to string
    localValue = parameters.(localFieldAndType{1});
    if ~ischar(localValue)
        localValue = num2str(localValue);
    end
    
    node.appendChild(xmlObj.createTextNode(localValue));
    % Append to root element
    settings.appendChild(node);
end

% -------------------------------------------------------------------------
% Write xml
% -------------------------------------------------------------------------
xmlwrite(filePath, xmlObj);

if parameters.verbose
    display(['Wrote: ' filePath]);
end




