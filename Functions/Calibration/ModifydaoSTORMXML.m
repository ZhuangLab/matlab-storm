function [xDoc, parameters] = ModifydaoSTORMXML(xmlFilePath, varargin)
% ------------------------------------------------------------------------
% [xDoc, parameters] = ModifydaoSTORMXML(xmlFilePath, varargin)
% This function loads a 3DdaoSTORM XML file and changes the fields as
%   appropriate. 
% UNDER CONSTRUCTION: Currently this program only modifies the Z
% calibration values based on a insight3cal structure. 
%--------------------------------------------------------------------------
% Necessary Inputs
% xmlFilePath/A path to an xml file containing Z calibration fields that 
%   follow the 3DdaoSTORM conventions. 
%--------------------------------------------------------------------------
% Outputs
% xDoc/The modified xml structure
%--------------------------------------------------------------------------
% Variable Inputs (Flag/ data type /(default)):
% savePath/path (''): The path to save the new xml file if desired.
%
%--------------------------------------------------------------------------
% Jeffrey Moffitt
% jeffmoffitt@gmail.com
% April 27, 2014
%--------------------------------------------------------------------------
% Creative Commons License CC BY NC SA
%--------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Default variables
% -------------------------------------------------------------------------
defaults = cell(0,3);
defaults(end+1,:) = {'savePath', 'string', ''};
defaults(end+1,:) = {'insightZcal', 'struct', []};
defaults(end+1,:) = {'verbose', 'boolean', true};

% -------------------------------------------------------------------------
% Parse necessary input
% -------------------------------------------------------------------------
if nargin < 2
    error('matlabSTORM:invalidArguments', ...
        'Both an xml file path and a z parameters structure are required');
end

% -------------------------------------------------------------------------
% Parse variable input
% -------------------------------------------------------------------------
parameters = ParseVariableArguments(varargin, defaults, mfilename);

% -------------------------------------------------------------------------
% Load document
% -------------------------------------------------------------------------
xDoc = xmlread(xmlFilePath);

% -------------------------------------------------------------------------
% Setup daoSTORM conversion
% -------------------------------------------------------------------------
conv = cell(0,2);
conv(end+1,:) = {'wx0', 'wx_wo'};
conv(end+1,:) = {'gx', 'wx_c'};
conv(end+1,:) = {'zrx', 'wx_d'};
conv(end+1,:) = {'Ax', 'wxA'};
conv(end+1,:) = {'Bx', 'wxB'};
conv(end+1,:) = {'Cx', 'wxC'};
conv(end+1,:) = {'Dx', 'wxD'};
conv(end+1,:) = {'wy0', 'wy_wo'};
conv(end+1,:) = {'gy', 'wy_c'};
conv(end+1,:) = {'zry', 'wy_d'};
conv(end+1,:) = {'Ay', 'wyA'};
conv(end+1,:) = {'By', 'wyB'};
conv(end+1,:) = {'Cy', 'wyC'};
conv(end+1,:) = {'Dy', 'wyD'};

% -------------------------------------------------------------------------
% Change xml fields
% -------------------------------------------------------------------------
if ~isempty(parameters.insightZcal)
    fields = fieldnames(parameters.insightZcal);
    for i=1:length(fields)
        convInd = find(strcmp(conv(:,1), fields{i}));
        if ~isempty(convInd)
            firstChild = xDoc.getElementsByTagName(conv(convInd,2)).item(0).getFirstChild;
            firstChild.setNodeValue(num2str(parameters.insightZcal.(fields{i})));
            if parameters.verbose
                display(['Changed ' conv{convInd,2} ' to ' num2str(parameters.insightZcal.(fields{i}))]);
            end
        end
    end
end

% -------------------------------------------------------------------------
% Save new file if desired
% -------------------------------------------------------------------------
if ~isempty(parameters.savePath)
    xmlwrite(parameters.savePath, xDoc);
    if parameters.verbose
        display(['Saved: ' parameters.savePath]);
    end
end

