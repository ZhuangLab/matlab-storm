function value = CheckParameter(value, type, name)
%--------------------------------------------------------------------------
% CheckParameter(value, type, name)
% This function returns true/false depending on whether the given parameter
% value satisfies the requirements specified by type
%--------------------------------------------------------------------------
% Inputs:
% value: The value of any variable to be checked
%
% type/string or cell array of strings: A flag to specify the check
%   conditions or the set of conditions to test
%   Valid types: 
%           'positive',
%           'nonnegative',
%           'struct',
%           'cell',
%           'string'
%           'boolean'
%           'array' 
% 
% name/string: The name of the parameter to be checked
%--------------------------------------------------------------------------
% Outputs:
% value: The value of the variable to be checked
%
%--------------------------------------------------------------------------
% Jeffrey Moffitt *  &  Alistair Boettiger #
% * jeffmoffitt@gmail.com, # boettiger.alistair@gmail.com
% October 2013 
% Version 1.3
%--------------------------------------------------------------------------
% Creative Commons Liscence
% Attribution-NonCommercial-ShareAlike 3.0 Unported License
% 2013
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Hardcoded Variables
%--------------------------------------------------------------------------
quiet = 0;

%--------------------------------------------------------------------------
% Parse Required Inputs
%--------------------------------------------------------------------------
if nargin < 3
    error('Not enough inputs');
end

if ~ischar(name)
    error('Invalid parameter name');
end

if ~iscell(type)
    temp = type;
    type = cell(1,1);
    type{1} = temp;
    clear temp;
end

%--------------------------------------------------------------------------
% Check Conditions
%--------------------------------------------------------------------------
for i=1:length(type)
    switch type{i}
        case 'positive'
            if value <= 0
                error([name ' is not positive']);
            end
        case 'nonnegative'
            if value < 0
                error([name ' is not nonnegative']);
            end
        case 'struct'
            if ~isstruct(value)
                error([name ' is not a structure']);
            end
        case 'array'
            if length(value)<= 1
                error([name ' is not an array']);
            end
        case 'boolean'
            if ~islogical(value) && value == 1 && value == 0
                error([name ' is not a boolean']);
            end
        case 'string'
            if ~ischar(value)
                error([name ' is not a string']);
            end
        case 'cell'
            if ~iscell(value)
                error([name 'is not a cell']);
            end
        otherwise
            error('Not a valid type');
    end
end
