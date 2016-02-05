function [uniqueInputValues,numOccurrences,indexes] = occurrences(A,varargin)
%--------------------------------------------------------------------------
% [v,n] = occurrences(A) returns the vector v listing all the values in A 
% and a vector n the number of times they appear.
% A is a NxM matrix containing N potentionally non-unique entries each
% defined by M components. 
% [v,n,i] = occurrences(A)  
% 
% 
%--------------------------------------------------------------------------
% Alistair Boettiger
% boettiger.alistair@gmail.com
% Oct 8th 2013
% Version 2.0 Nov 16th, 2014
% 
%--------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Default variables
% -------------------------------------------------------------------------
defaults = cell(0,3);
defaults(end+1,:) = {'verbose', 'boolean', false};
defaults(end+1,:) = {'stable', 'boolean', true};
% -------------------------------------------------------------------------
% Parse necessary input
% -------------------------------------------------------------------------
if nargin < 1
    error('matlabSTORM:invalidArguments', 'data array is required');
end

% -------------------------------------------------------------------------
% Parse variable input
% -------------------------------------------------------------------------
parameters = ParseVariableArguments(varargin, defaults, mfilename);
% parameters = ParseVariableArguments([], defaults, mfilename);


%% Main function


inputString = A;
[indexes, uniqueInputValues] = grp2idx(inputString);
numOccurrences = histc(indexes,1:numel(uniqueInputValues));
if ~iscell(A)
    uniqueInputValues = str2double(uniqueInputValues)'; % make double, match old row convention 
    numOccurrences = numOccurrences'; % matching old code
end

    


