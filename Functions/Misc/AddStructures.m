function structOut = AddStructures(struct1,struct2,varargin)
% Takes a structure which contains N fields all of a common length.  This
% fields may be cell arrays or numeric arrays.  Also takes a index.
% Returns a structure with the same N fields but each field contains only
% the values in idx.  
%  structOut = IndexStructure(structIn,idx,'celldata',false,'verbose',true)



% -------------------------------------------------------------------------
% Default variables
% -------------------------------------------------------------------------
defaults = cell(0,3);
defaults(end+1,:) = {'verbose', 'boolean',true};
defaults(end+1,:) = {'catdim', 'positive',1};

% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Parse necessary input
% -------------------------------------------------------------------------
if nargin < 2
    error('matlabSTORM:invalidArguments', 'required: struct1,struct2');
end

% -------------------------------------------------------------------------
% Parse variable input
% -------------------------------------------------------------------------
parameters = ParseVariableArguments(varargin, defaults, mfilename);


    
%-------------------------------------------------------------------------
%% Main function
%-------------------------------------------------------------------------   


for f=fieldnames(struct1)';
    try
        structOut.(f{1})=cat(parameters.catdim,struct1.(f{1}),struct2.(f{1}));
    catch
        if parameters.verbose
           disp(['field ',f{1},' could not be concatinated']);  
        end
        structOut.(f{1})={struct1.(f{1}),struct2.(f{1})};
    end
end