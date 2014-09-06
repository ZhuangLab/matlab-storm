function structOut = IndexStructure(structIn,idx,varargin)
% Takes a structure which contains N fields all of a common length.  This
% fields may be cell arrays or numeric arrays.  Also takes a index.
% Returns a structure with the same N fields but each field contains only
% the values in idx.  
%  structOut = IndexStructure(structIn,idx,'celldata',false,'verbose',true)

verbose = false; 
celldata = true; 
%--------------------------------------------------------------------------
%% Parse variable input
%--------------------------------------------------------------------------
if nargin > 2
    if (mod(length(varargin), 2) ~= 0 ),
        error(['Extra Parameters passed to the function ''' mfilename ''' must be passed in pairs.']);
    end
    parameterCount = length(varargin)/2;
    for parameterIndex = 1:parameterCount,
        parameterName = varargin{parameterIndex*2 - 1};
        parameterValue = varargin{parameterIndex*2};
        switch parameterName
            case 'celldata'
                celldata = CheckParameter(parameterValue,'boolean','celldata');
            case 'verbose'
                verbose = CheckParameter(parameterValue,'boolean','verbose');
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end
    
%-------------------------------------------------------------------------
%% Main function
%-------------------------------------------------------------------------   


for f=fieldnames(structIn)';
    try
    if iscell( structIn.(f{1})  ) && celldata
        structOut.(f{1})=structIn.(f{1}){idx};
    else
        structOut.(f{1})=structIn.(f{1})(idx);
    end
    catch
        if verbose
           disp(['field ',f{1},' could not be indexed']);  
        end
        structOut.(f{1})=structIn.(f{1});
    end
    
end