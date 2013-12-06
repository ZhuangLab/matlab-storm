function MList = ConvertHRImageToMList(varargin)
%--------------------------------------------------------------------------
% MList = ConvertHRImageToMList(HRImage, varargin)
% This function converts a HRImage into a molecule list
%
%--------------------------------------------------------------------------
% Outputs:
%
% MList/structure: This structure contains the properties of all of the
% molecules found in the HRImage
%
%--------------------------------------------------------------------------
% Required Input:
%
% HRImage: A HRImage structure or a valid path to a HRimage. 
%  
%--------------------------------------------------------------------------
% Variable Input:
%
% 'verbose'/false: A string that determines if the function displays
% progress
%--------------------------------------------------------------------------
% Jeffrey Moffitt
% jeffmoffitt@gmail.com
% November 15, 2012
%
% Version 1.0
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Hardcoded variables
%--------------------------------------------------------------------------
flags = {'verbose', 'savePath'};
defaultMoleculeNumber = 1e7;
moleculeThreshold = 1;
connectivity =8;
%--------------------------------------------------------------------------
% Global Variables
%--------------------------------------------------------------------------
global defaultDataPath;

%--------------------------------------------------------------------------
% Define default parameters
%--------------------------------------------------------------------------
verbose = true;
HRImage = [];
HRImagePath = [];
savePath = -1;
upSample = 8;

%--------------------------------------------------------------------------
% Parse Required Input
%--------------------------------------------------------------------------
if nargin < 1
    error('Function requires at least one input');
end

if isstruct(varargin{1})
    HRImage = varargin{1};
    varargin = varargin(2:end);
elseif ismember(varargin{1}, flags)
    error('Valid HRImage or path to an HRImage is required');
else
    HRImagePath = varargin{1};
    varargin = varargin(2:end);
end

%--------------------------------------------------------------------------
% Parse Variable Input Arguments
%--------------------------------------------------------------------------
if nargin > 1
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
            case 'savePath'
                savePath = CheckParameter(parameterValue, 'string', parameterName);
            case 'upSample'
                upSample = CheckParameter(parameterValue, 'positive', parameterName);
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end

%--------------------------------------------------------------------------
% Load HRImage if needed
%--------------------------------------------------------------------------
if isempty(HRImage)
    HRImage = ReadHighResImage(HRImagePath, 'verbose', verbose);
end

%--------------------------------------------------------------------------
% Allocate memory for molecule list
%--------------------------------------------------------------------------
MList = CreateMoleculeList(defaultMoleculeNumber, 'compact', true);

%--------------------------------------------------------------------------
% Find Molecules frame by frame
%--------------------------------------------------------------------------
count = 1;
numFrames = max(HRImage.frame);

for i=1:numFrames
    single_frame = zeros(HRImage.dim');
    pixels = HRImage.pixelInd(HRImage.frame == i) + 1; %+1 to convert C->matlab indexing
   
    single_frame(pixels) = HRImage.intensity(HRImage.frame == i);
    
    bw = single_frame > moleculeThreshold;
    L = bwconncomp(bw, connectivity);
    objs = regionprops(L, single_frame, 'Area', 'WeightedCentroid', 'MeanIntensity');
    
    idx = count:(count+length(objs)-1);
    count = count + length(objs);
    
    centroid = [objs.WeightedCentroid];
    area = [objs.Area];
    intensity = [objs.MeanIntensity];
    
    MList.x(idx,1) = (centroid(1:2:end)-1)/upSample + 0.5 + 0.5/upSample;
    MList.y(idx,1) = (centroid(2:2:end)-1)/upSample + 0.5 + 0.5/upSample;
    MList.xc(idx,1) = (centroid(1:2:end)-1)/upSample + 0.5 + 0.5/upSample;
    MList.yc(idx,1) = (centroid(2:2:end)-1)/upSample + 0.5 + 0.5/upSample;
    MList.i(idx,1) = area.*intensity;
    MList.frame(idx,1) = int32(double(i)*ones(1, length(objs)));
    
    if verbose
        display(['Found ' num2str(length(objs)) ' molecules in frame ' num2str(i)]);
    end
    
end
%--------------------------------------------------------------------------
% Truncate Molecule List
%--------------------------------------------------------------------------
MList_fields = fieldnames(MList);
for i=1:length(MList_fields);
    MList.(MList_fields{i}) = MList.(MList_fields{i})(1:(count-1));
end




%--------------------------------------------------------------------------
% Save molecule list
%--------------------------------------------------------------------------
if savePath ~= -1
    if isempty(savePath)
        [pathStr, fileStr, extension] = fileparts(HRImage.name);
        WriteMoleculeList(MList, [pathStr '\' fileStr(1:(end-4)) '._list.bin'], ...
            'verbose', verbose);
    else
        WriteMoleculeList(MList, savePath, 'verbose', verbose);
    end
end
    