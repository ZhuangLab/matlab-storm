classdef StructureArray < dynamicprops
%------------------------------------------------------------------------
% structArray = StructureArray(varargin)
% This class introduces an abstract data type, the structure array, which
% which acts like a normal array of structures, each with single entries in
% each field, but stores these data in a format that is far more memory
% efficient. 
%
% Creating a structure array:
% A = StructureArray(fieldName1, values1, fieldName2, values2, ...)
% A = StructureArray('a', 1:10, 'b', randn(1,10), ....)
%   produces a structure array with fields a and b.
%
% Indexing a structure array:
%    subStructArray = A(inds);
%       produces a structure array with the same fields as A but in which
%       each field is indexed with the provided inds.
%
% Accessing data in a structure array:
%    data = A(inds).a
%    or
%    data = A.a(inds)
%    data is the values in a determined by the indices in ind
%
% Assigning values to a structure array:
%    A(1:5) = B
%    If B is a structure array with size 5 and the same fields as A, then
%    the appropriate elements in A are assigned the values of B
%
%   A(1:5).a = data or A.a(1:5) = data
%   Assigns the values in data to the first 5 elements in the field a
%
% Concatenating structure arrays
% C = [A B];
% 
% Copying a structure array:
%   CAUTION: Structure arrays are handle objects. So copies are handle
%   references not actual copies. B = A, produces an object,B, that is a
%   reference to A. Modifying values in B WILL modifify values in A. 
%   To copy, use the following call
%   B = StructureArray(A);
% ------------------------------------------------------------------------
% Jeffrey Moffitt
% jeffmoffitt@gmail.com
% August 8, 2015
%--------------------------------------------------------------------------
% Creative Commons License CC BY NC SA
%--------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Define properties
% ------------------------------------------------------------------------
properties (Access=private)
    dataSize = 0;   % The size of the individual fields
end

% -------------------------------------------------------------------------
% Define methods
% ------------------------------------------------------------------------
methods
    % -------------------------------------------------------------------------
    % Constructor
    % ------------------------------------------------------------------------
    function obj = StructureArray(varargin)
    % Create or copy a StructureArray object
    % obj = StructureArray(fieldName1, values1, fieldName2, values2, ...)
    % copyObj = StructureArray(originalObj)
    %
        if nargin == 1 % Handle single input requests
            switch class(varargin{1})
                case {'StructureArray', 'struct'} % Handle the request for a copy or a conversion
                    oldObj = varargin{1};
                    fieldNames = fields(oldObj);
                    argIn = cell(1, length(fieldNames)*2);
                    argIn(1:2:end) = fieldNames;
                    for f=1:length(fieldNames)
                        argIn{2*f} = oldObj.(fieldNames{f});
                    end
                    obj = StructureArray(argIn{:});
                    return;
            end
        end
        
        % Check providied inputs
        if ~mod(nargin+1,2)
            error('matlabFunctions:invalidArguments', 'The incorrect number of entries was provided');
        end
        
        % Identify field names and values
        fieldNames = varargin(1:2:end);
        values = varargin(2:2:end);
        
        % Build object
        for f=1:length(fieldNames)
            addprop(obj, fieldNames{f});
            
            if f==1 % Set the data size based on the first provided input
                obj.dataSize = size(values{f},1);
            else
                if ~all(size(values{f},1) == obj.dataSize) % Check size of all provided data
                    error('matlabFunctions:invalidArgument', 'Incorrect number of values');
                end
            end
            % Assign values
            obj.(fieldNames{f}) = values{f};
        end
    end
    
    % -------------------------------------------------------------------------
    % Assign values via subscripting: i.e. A(inds) = B
    % ------------------------------------------------------------------------
    function obj = subsasgn(obj, S, data)
        % Handle single call
        if length(S)==1
            switch S.type
                case '.'
                    if ~isprop(obj, S.subs)
                        if ~all(size(data) == obj.dataSize)
                            error('matlabFunctions:structureArray', 'Added data is the incorrect size');
                        end
                        addprop(obj, S.subs);
                    end
                    obj.(S.subs) = data;
                case '()'
                    if ~strcmp(class(data), 'StructureArray')
                        error('matlabFunctions:structureArray', 'Only structure arrays can be inserted in this fashion');
                    end
                    if length(fields(obj)) ~= length(fields(data)) || ...
                            ~isempty(setdiff(fields(obj), fields(data)))
                        error('matlabFunctions:structureArray', 'Fields must match');
                    end
                    fieldNames = fields(obj);
                    for f=1:length(fieldNames)
                        obj.(fieldNames{f})(S.subs{:}) = data.(fieldNames{f});
                    end
            end
        elseif length(S) == 2 % Handle compound call, e.g. A(1:3).b = newData 
            ind = strcmp({S.type}, '.');
            fieldName = S(ind).subs;
            subs = S(~ind).subs;
            if ~isprop(obj, fieldName)
                error('matlabFunctions:structureArray', 'Fields cannot be added in this fashion');
            end
            obj.(fieldName)(subs{:}) = data;
        else
            error('matlabFunctions:structureArray', 'Invalid indexing.');
        end
    end
    
    % -------------------------------------------------------------------------
    % Overload reference commands
    % ------------------------------------------------------------------------
    function output = subsref(obj, S)
        % Handle single reference, e.g. A.b
        if length(S) == 1
            switch S.type
                case '()'
                    fieldNames = fields(obj);
                    argIn = cell(1, length(fieldNames)*2);
                    argIn(1:2:end) = fieldNames;
                    for f=1:length(fieldNames)
                        argIn{2*f} = obj.(fieldNames{f})(S.subs{:});
                    end
                    output = StructureArray(argIn{:});
                    return;
                case '.'
                    output = obj.(S.subs);
                    return
            end
        else % Handle compound reference, e.g. A(1:5).b
            switch S(1).type
                case '.'
                    output = obj.(S(1).subs);
                    if ~ischar(S(2).subs{1})
                        output = output(S(2).subs{:});
                    end
                case '()'
                    output = obj.(S(2).subs)(S(1).subs{:});
            end
        end
    end
    
    % -------------------------------------------------------------------------
    % Overload size command
    % ------------------------------------------------------------------------
    function output = size(obj)
        output = obj.dataSize;
    end
    
    % -------------------------------------------------------------------------
    % Overload horizontal cat method
    % ------------------------------------------------------------------------
    function newObj = horzcat(A, B)
        
        % Handle the empty concatenation case
        if isempty(A)
            newObj = B;
            return;
        elseif isempty(B)
            newObj = A;
            return;
        end
        
        if length(fields(A)) ~= length(fields(B)) & ...
                isempty(setdiff(fields(A), fields(B)))
            error('matlabFunctions:incongruentArrays', ['Names of fields in structure arrays being concatenated do not match. ' ...
                'Concatenation of structure arrays requires that these arrays have the same set of fields.']);
        end
        
        fieldNames = fields(A);
        argIn = cell(1, length(fieldNames)*2);
        argIn(1:2:end) = fieldNames;
        for f=1:length(fieldNames)
            argIn{2*f} = horzcat(A.(fieldNames{f}), B.(fieldNames{f}));
        end
        newObj = StructureArray(argIn{:});
    end
    
    % -------------------------------------------------------------------------
    % Overload vertical cat method
    % ------------------------------------------------------------------------
    function newObj = vertcat(A, B)

        % Handle the empty concatenation case
        if isempty(A)
            newObj = B;
            return;
        elseif isempty(B)
            newObj = A;
            return;
        end

        
        if length(fields(A)) ~= length(fields(B)) & ...
                isempty(setdiff(fields(A), fields(B)))
            error('matlabFunctions:incongruentArrays', ['Names of fields in structure arrays being concatenated do not match. ' ...
                'Concatenation of structure arrays requires that these arrays have the same set of fields.']);
        end
        
        fieldNames = fields(A);
        argIn = cell(1, length(fieldNames)*2);
        argIn(1:2:end) = fieldNames;
        for f=1:length(fieldNames)
            argIn{2*f} = vertcat(A.(fieldNames{f}), B.(fieldNames{f}));
        end
        newObj = StructureArray(argIn{:});
    end
    
    % -------------------------------------------------------------------------
    % Overload isfield
    % ------------------------------------------------------------------------
    function bool = isfield(obj, fieldName)
        if ~ischar(fieldName)
            error('matlabFunctions:incorrectArguments', 'Field name must be a string');
        end
        bool = ismember(fieldName, fields(obj));
    end
    
    % -------------------------------------------------------------------------
    % Overload isempty
    % ------------------------------------------------------------------------
    function bool = isempty(obj)
        if any(obj.dataSize == 0)
            bool = true;
        else
            bool = false;
        end
    end
    
%     % -------------------------------------------------------------------------
%     % Overload of length
%     % ------------------------------------------------------------------------
%     function num = length(obj)
%         num = max(obj.dataSize);
%     end

end
    
end