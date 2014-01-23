function structOut = IndexStructure(structIn,idx)
% Takes a structure which contains N fields all of a common length.  This
% fields may be cell arrays or numeric arrays.  Also takes a index.
% Returns a structure with the same N fields but each field contains only
% the values in idx.  


for f=fieldnames(structIn)';
    if iscell( structIn.(f{1})  )
        structOut.(f{1})=structIn.(f{1}){idx};
    else
        structOut.(f{1})=structIn.(f{1})(idx);
    end
end