function [diffStruct] = CompareReconstructions(varargin)
%--------------------------------------------------------------------------
% [diffStruct] = CompareReconstructions(MList1, MList2)
% This function compares two molecule lists and compute statistical
% properties of the difference such as recall and average localization
% difference.  
%--------------------------------------------------------------------------
% Inputs:
% 'MList1'/structure([]): The first molecule list to compare. This input
% can be a path to this molecule list, a molecule list in compact or
% non-compact form, or a high resolution image format structure.  
%
% 'MList2'/structure([]): The second molecule list to compare. 
%--------------------------------------------------------------------------
% Outputs:
% 'diffStruct'/structure array: This structure contains information on the
% difference between the reconstruction of every frame in each molecule list.  
%--------------------------------------------------------------------------
% Variable Inputs:
% 'verbose'/boolean(false): Is progress displayed?
%--------------------------------------------------------------------------
% Jeffrey Moffitt
% March 25, 2013
% jeffmoffitt@gmail.com
%
% Version 1.0
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Hardcoded Variables
%--------------------------------------------------------------------------
quiet = 0;

%--------------------------------------------------------------------------
% Global Variables
%--------------------------------------------------------------------------
global defaultDataPath

%--------------------------------------------------------------------------
% Default Variables
%--------------------------------------------------------------------------
verbose = true;

%--------------------------------------------------------------------------
% Parse Required Input
%--------------------------------------------------------------------------
foundMLists = {};
MList1 = [];
MList2 = [];
for i=1:length(varargin)
    if isstruct(varargin{i})
        if isfield('x')
            foundMLists{end+1} = varargin{i};
        elseif isfield('pixelInd')
            foundMLists{end+1} = ConvertHRImageToMList(varargin{i}, 'verbose', true);
        end
    elseif ischar(varargin{i})
        if exist(varargin{i}) == 2
            [pathStr, name, ext] = fileparts(varargin{i});
            switch ext
                case '.bin'
                    foundMLists{end+1} = ReadMasterMoleculeList(varargin{i}, 'compact', true, 'verbose', true);
                case '.hrf'
                    foundMLists{end+1} = ConvertHRImageToMList( ...
                        ReadHighResImage(varargin{i}, 'verbose', true, 'returnForm', 'compact'), ...
                        'verbose', true);
            end
        end
    end
end
for i=1:length(foundMLists)
    eval(['MList' num2str(i) '=foundMLists{i};']);
    if i==2
        break;
    end
end

if isempty(MList1)
    [file, pathName] = uigetfile([defaultDataPath '*_list.bin']);
    if ~isempty(file)
        MList1 = ReadMasterMoleculeList([pathName file], 'compact', true);
    end
end
if isempty(MList2)
    [file, pathName] = uigetfile([defaultDataPath '*_list.bin']);
    if ~isempty(file)
        MList2 = ReadMasterMoleculeList([pathName file], 'compact', true);
    end
end

if isempty(MList1) || isempty(MList2)
    error('Too few MLists provided');
end

%--------------------------------------------------------------------------
% Parse Variable
%--------------------------------------------------------------------------
if nargin > 0
    if (mod(length(varargin), 2) ~= 0 ),
        error(['Extra Parameters passed to the function ''' mfilename ''' must be passed in pairs.']);
    end
    parameterCount = length(varargin)/2;

    for parameterIndex = 1:parameterCount,
        parameterName = varargin{parameterIndex*2 - 1};
        parameterValue = varargin{parameterIndex*2};
        switch parameterName
            case 'verbose'
                verbose = CheckParameter(parameterValue, 'boolean', parameterName);
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end

%--------------------------------------------------------------------------
% Compile MList Stats
%--------------------------------------------------------------------------
maxFrame = max([max(MList1.frame) max(MList2.frame)]);

%--------------------------------------------------------------------------
% Initialize different structure
%--------------------------------------------------------------------------
diffStruct(maxFrame).num1 = 0;
diffStruct(maxFrame).num2 = 0;
diffStruct(maxFrame).recall = 0;
diffStruct(maxFrame).avErrX = 0;
diffStruct(maxFrame).avErrY = 0;
diffStruct(maxFrame).avErr = 0;
diffStruct(maxFrame).distX = {};
diffStruct(maxFrame).distY = {};
diffStruct(maxFrame).dist = {};

%--------------------------------------------------------------------------
% Compare frames
%--------------------------------------------------------------------------
for i=1:maxFrame
    % Find molecules in frame i
    ind1 = find(MList1.frame == i);
    ind2 = find(MList2.frame == i);

    % Compute recall
    N1 = length(ind1);
    N2 = length(ind2)
    diffStruct(i).num1 = N1;
    diffStruct(i).num2 = N2;
    diffStruct(i).recall = N1/N2;

    % Compute distance matrix X
    X1 = repmat(MList1.x(ind1), [1 N2]);
    X2 = repmat(MList2.x(ind2)', [N1 1]);
    
    % Compute distance matrix Y
    Y1 = repmat(MList1.y(ind1), [1 N2]);
    Y2 = repmat(MList2.y(ind2)', [N1 1]);
    
    % Compute distance between all combinations
    distX = X2-X1;
    distY = Y2-Y1;
    dist = distX.^2 + distY.^2;
    
    % Find minimum distances
    minX = min(distX);
    minY = min(distY);
    minTot = min(dist);
    
    % Record results
    diffStruct(i).avErrX = mean(minX);
    diffStruct(i).avErrY = mean(minY);
    diffStruct(i).avErr = mean(minTot);
    diffStruct(i).distX{1} = minX;
    diffStruct(i).distY{1} = minY;
    diffStruct(i).dist{1} = minTot;
end
     