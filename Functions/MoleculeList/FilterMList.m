function [filteredList, indices] = FilterMList(mlist, varargin)
% ------------------------------------------------------------------------
% [filteredList, indices] = FilterMList(mlist, varargin)
% This function filters an mlist on a specified range for a given field
%   name, g.e. FilterMList(mlist, 'a', [1 Inf]) returns all mlist entries
%   for which a >= 1 & a < Inf. 
%--------------------------------------------------------------------------
% Necessary Inputs
% mlist/ An mlist in compact format
%--------------------------------------------------------------------------
% Outputs 
% filteredList/ The mlist with all entries not matching the specific
%   parameters removed
%--------------------------------------------------------------------------
% Variable Inputs (Flag/ data type /(default)):
%--------------------------------------------------------------------------
% Jeffrey Moffitt
% jeffmoffitt@gmail.com
% September 3, 2014
%--------------------------------------------------------------------------
% Creative Commons License CC BY NC SA
%--------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Parse variable input
% -------------------------------------------------------------------------
if isempty(varargin)
    error('matlabSTORM:invalidArguments', 'Must provide a field name and range');
end

if (mod(length(varargin), 2) ~= 0 ),
    error(['Field names must be passed with ranges']);
end
fieldNames = varargin(1:2:end);
ranges = varargin(2:2:end);
numFlags = length(fieldNames);

if ~all(cellfun(@(x) ischar(x), fieldNames))
    error('matlabSTORM:invalidArguments', 'Invalid field name');
end

if ~all(cellfun(@(x) length(x), ranges) == 2)
    error('matlabSTORM:invalidArguments', 'All ranges must be provide as pairs, e.g. [1 Inf]');
end

% -------------------------------------------------------------------------
% Build Indices
% -------------------------------------------------------------------------
indices = true(length(mlist.x),1);
for i=1:length(fieldNames)
    indices = indices & mlist.(fieldNames{i}) >= ranges{i}(1) & mlist.(fieldNames{i}) < ranges{i}(2);
end

% -------------------------------------------------------------------------
% Index Structure
% -------------------------------------------------------------------------
filteredList = IndexStructure(mlist, indices);