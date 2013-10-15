function params = ReadXMLParameters(fileName, varargin)
%--------------------------------------------------------------------------
% params = ReadXMLParameters(fileName, varargin)
% This program loads an xml parameters file and returns a parameter
% structure
%--------------------------------------------------------------------------
% Necessary Inputs
% fileName/string/(''): File name and path of a parameters .xml file
%
%--------------------------------------------------------------------------
% Outputs
% params/structure: Structure containing the parameters
%
%--------------------------------------------------------------------------
% Variable Inputs (Flag/ data type /(default)):
% 
% 'verbose'/boolean/(false): Determines if parameter reporting 
%
% 'tagName'/string(''): Can be the name of any xml tag. If it exists in the
%   parameter file, it will be added to the parameter structure
%--------------------------------------------------------------------------
% Jeffrey Moffitt
% February 4, 2013
%
% Version 1.0
%--------------------------------------------------------------------------
% Creative Commons License CC BY
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Hardcoded Variables
%--------------------------------------------------------------------------
quiet = 0;

%--------------------------------------------------------------------------
% Global Variables
%--------------------------------------------------------------------------
global defaultParameterPath;

%--------------------------------------------------------------------------
% Default Variables: Define variable input variables here
%--------------------------------------------------------------------------
myDefaultVariable = defaultValue;
internalVariable1 = defaultValue1;

%--------------------------------------------------------------------------
% Parse mustHave variables
%--------------------------------------------------------------------------
if nargin < numMustHaveVariables
    %----------------------------------------------------------------------
    % Insert handle code
    %----------------------------------------------------------------------
end

%--------------------------------------------------------------------------
% Parse variable input
%--------------------------------------------------------------------------
if nargin > numMustHaveVariables
    if (mod(length(varargin), 2) ~= 0 ),
        error(['Extra Parameters passed to the function ''' mfilename ''' must be passed in pairs.']);
    end
    parameterCount = length(varargin)/2;

    for parameterIndex = 1:parameterCount,
        parameterName = varargin{parameterIndex*2 - 1};
        parameterValue = varargin{parameterIndex*2};
        switch parameterName
            case 'flag1'
                internalVariable1 = CheckParameter(parameterValue,'parameterclass','flag1'); 
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end

%--------------------------------------------------------------------------
% Main code
%--------------------------------------------------------------------------



