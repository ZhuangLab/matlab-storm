function [zParams, curves, parameters] = ParseInsightZCalibration(calibrationString, varargin)
% ------------------------------------------------------------------------
% [zParams, curves] = ParseInsightZCalibration(calibrationString, varargin)
% This function parses an Insight3 Z calibration string and returns the
% parameters in the structure zCalParameters.   
%--------------------------------------------------------------------------
% Necessary Inputs
% calibrationString/string: A calibration string that contains the insight3
% Z calibration parameters. 
%
%--------------------------------------------------------------------------
% Outputs
% zCalParameters/A structure containing the calibration parameters in the \
%   following fields.
%   --wx0: The amplitude of the curve
%   --zrx: The minimum position 
%   --gx: The scaling factor for the Z axis
%   --Ax: Coefficient for the third order term
%   --Bx: Coefficient for the fourth order term
%   --Cx: Coefficient for the fifth order term 
%   --Dx: Coefficient for the sxith order term (used only by DaoSTORM)
%       and similar fields for y
%
% curves/3xN array: An array containing the wx, wy, and z range for the
% specified parameters. 
%
%--------------------------------------------------------------------------
% Variable Inputs (Flag/ data type /(default)):
% 'ZRange'/array(-600:1:600): This array determines the Z-range for the curves output.  
%--------------------------------------------------------------------------
% Jeffrey Moffitt
% jeffmoffitt@gmail.com
% April 24, 2014
%--------------------------------------------------------------------------
% Creative Commons License CC BY NC SA
%--------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Default variables
% -------------------------------------------------------------------------
defaults = cell(0,3);
defaults(end+1,:) = {'ZRange', 'array', -400:1:400};

% -------------------------------------------------------------------------
% Parse necessary input
% -------------------------------------------------------------------------
if nargin < 1
    error('matlabSTORM:invalidArguments', 'A calibration string is required.');
end

% -------------------------------------------------------------------------
% Parse variable input
% -------------------------------------------------------------------------
parameters = ParseVariableArguments(varargin, defaults, mfilename);

% -------------------------------------------------------------------------
% Parse string
% -------------------------------------------------------------------------
equalsInds = regexp(calibrationString, '=');
semiColonInds = regexp(calibrationString, ';');

% -------------------------------------------------------------------------
% Check validity of string
% -------------------------------------------------------------------------
if isempty(equalsInds) || isempty(semiColonInds)
    error('matlabSTORM:invalidArguments', 'Not a valid calibration string. No equals or semicolons.');
end

if length(equalsInds) ~= length(semiColonInds)
   error('matlabSTORM:invalidArguments', ...
       'Not a valid calibration string. Not an equal number of equals and semicolones.');
end

% -------------------------------------------------------------------------
% Parse string and build structure
% -------------------------------------------------------------------------
for i=1:length(equalsInds)
    if i==1
        fieldInds = [1, equalsInds(i)-1];
    else
        fieldInds = [semiColonInds(i-1)+1, equalsInds(i)-1];
    end
    entryInds = [equalsInds(i) + 1, semiColonInds(i)-1];
    fieldName = strtrim(calibrationString(fieldInds(1):fieldInds(2)));
    entryString = calibrationString(entryInds(1):entryInds(2));
    switch fieldName
        case {'wx0', 'zrx', 'gx', 'Dx', 'Cx', 'Bx', 'Ax', ...
                'wy0', 'zry', 'gy', 'Dy', 'Cy', 'By', 'Ay'}
            zParams.(fieldName) = str2num(entryString);
    end
end

% -------------------------------------------------------------------------
% Calculate Curves
% -------------------------------------------------------------------------
curves = zeros(3, length(parameters.ZRange));
curves(1,:) = parameters.ZRange;

z = (parameters.ZRange - zParams.gx)/zParams.zrx;
curves(2,:) = zParams.wx0*(1 + z.^2 + zParams.Ax*z.^3 + ...
    zParams.Bx*z.^4 + zParams.Cx*z.^5 + zParams.Dx*z.^6);

z = (parameters.ZRange - zParams.gy)/zParams.zry;
curves(3,:) = zParams.wy0*(1 + z.^2 + zParams.Ay*z.^3 + ...
    zParams.By*z.^4 + zParams.Cy*z.^5 + zParams.Dy*z.^6);



