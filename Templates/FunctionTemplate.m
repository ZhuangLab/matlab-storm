function outputs = Name(mustHaveVariables, varargin)
%--------------------------------------------------------------------------
% outputs = Name(mustHaveVariables, varargin)
% What does my function do?
%--------------------------------------------------------------------------
% Necessary Inputs
% mustHaveVariable/data type/(default, if available): Definition of the
% variable
%
% Example:
% indices/integer array/(1:10): The indices of the data to be analyzed
%--------------------------------------------------------------------------
% Outputs
% outputs/data type: Definition of the output
%
% Example:
% conv/float array: The convolution of x with y
%--------------------------------------------------------------------------
% Variable Inputs (Flag/ data type /(default)):
% 
% 'exampleInputFlag'/data type/(defalut value): Definition of the flag
%
% Example
% 'info'/info structure: Array of structures containing information of the
% files to load
%--------------------------------------------------------------------------
% Author Name
% Author email
% Current Date
%
% Version Number
%--------------------------------------------------------------------------
% Version update information
% V1.1: I made these changes...s
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
global myGlobalVariable;

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



