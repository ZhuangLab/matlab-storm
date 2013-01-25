function fieldName = CoerceFieldName(inputName)
%--------------------------------------------------------------------------
% fieldName = CoerceFieldName(inputName) 
% This removes illegal characters from an inputName string forming a
% string that can be used as the name of a structure field
%--------------------------------------------------------------------------
% Jeffrey Moffitt
% September 5, 2012
% jeffmoffitt@gmail.com
%
% Version 1.0
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Hardcoded variables
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Global Variables
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Remove text between paranthesis, brackets, or any of the like
%--------------------------------------------------------------------------
paraSignals = {'[', ']', '{', '}', '(', ')'};
ind = [];
for i=1:length(paraSignals)
    ind = union(ind, strfind(inputName, paraSignals{i}));
end
if length(ind>1)
    inputName = inputName(setdiff(1:length(inputName), ind(1):ind(end)));
elseif length(ind) == 1
    inputName = inputName(setdiff(1:length(inputName), ind));
end

%--------------------------------------------------------------------------
% Trim whitespace and replace internal whitespace with underscores
%--------------------------------------------------------------------------
inputName = strtrim(inputName);
inputName(isspace(inputName)) = '_';

%--------------------------------------------------------------------------
% Remove all remaining non-alphabetic letters
%--------------------------------------------------------------------------
fieldName = inputName(isletter(inputName)|(inputName == '_'));