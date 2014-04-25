function [figHandle, movieData, parameters] = GenerateMListReport(MList, varargin)
% -------------------------------------------------------------------------
% [fig_handle, movieData, parameters] = GenerateMListReport(MList, varargin)
% This function calculates several basic properties of a STORM movie and
% displays them in a figure.  
%--------------------------------------------------------------------------
% Necessary Inputs
% MList/A molecule list structure. See ReadMasterMoleculeList().
%
%--------------------------------------------------------------------------
% Outputs
% figHandle/A figure handle
% movieData/A structure containing information about the movie.
%--------------------------------------------------------------------------
% Variable Inputs (Flag/ data type /(default)):
%--------------------------------------------------------------------------
% Jeffrey Moffitt
% jeffmoffitt@gmail.com
% April 23, 2014
%--------------------------------------------------------------------------
% Creative Commons License CC BY NC SA
%--------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Default variables
% -------------------------------------------------------------------------
defaults = cell(0,3);
defaults(end+1,:) = {'itemsToDisplay', 'cell', {'molecules', 'h', 'a', 'length'}};
defaults(end+1,:) = {'histogramRanges', 'cell', {[], [0 3e3 100], [0 1e4 100], [0 10 10]}};
defaults(end+1,:) = {'figHandle', 'handle', []};
defaults(end+1,:) = {'plotsPerRow', 'positive', 4};
defaults(end+1,:) = {'plotStyle', 'string', 'b-'};
defaults(end+1,:) = {'frameBin', 'positive', 200};

% -------------------------------------------------------------------------
% Parse necessary input
% -------------------------------------------------------------------------
if nargin < 1
    error('matlabSTORM:invalidArguments', 'A MList is required');
end

% -------------------------------------------------------------------------
% Parse variable input
% -------------------------------------------------------------------------
parameters = ParseVariableArguments(varargin, defaults, mfilename);

% -------------------------------------------------------------------------
% Create figure if it does not exist
% -------------------------------------------------------------------------
if isempty(parameters.figHandle)
    parameters.figHandle = figure();
end
figHandle = parameters.figHandle;

% -------------------------------------------------------------------------
% Determine number of subplots
% -------------------------------------------------------------------------
numSubPlots = length(parameters.itemsToDisplay);

% -------------------------------------------------------------------------
% Calculate number of molecules per frame 
% -------------------------------------------------------------------------
frameInds = double(min(MList.frame):parameters.frameBin:max(MList.frame));
ctrs{1} = [frameInds (frameInds(end) + parameters.frameBin)];
movieData.frameInds = frameInds;
n = hist(single(MList.frame), ctrs{1});
n = n(1:(end-1))/parameters.frameBin;

% -------------------------------------------------------------------------
% Add plots to figure
% -------------------------------------------------------------------------
for i=1:length(parameters.itemsToDisplay)
    figure(figHandle);
    subplot(ceil(numSubPlots/parameters.plotsPerRow), parameters.plotsPerRow, i);
    switch parameters.itemsToDisplay{i}
        case 'molecules'
            plot(movieData.frameInds, n, parameters.plotStyle); hold on;
            xlabel('Frame ID');
            ylabel('Number of Molecules');
            movieData.numMolecules = n;
            xlim([frameInds(1) - parameters.frameBin, frameInds(end) + parameters.frameBin]);
        otherwise
            data = double(MList.(parameters.itemsToDisplay{i}));
            initCenters = linspace(parameters.histogramRanges{i}(1), ...
                parameters.histogramRanges{i}(2), parameters.histogramRanges{i}(3));
            ctrs{2} = [initCenters (initCenters(end) + (initCenters(2)-initCenters(1)))];
            N = hist3([MList.frame data], ctrs);
            N = N(1:(end-1), 1:(end-1)); % Remove pading for values larger than max range
            normFactor = 1./sum(N,2);
            normFactor(isnan(normFactor)) = ones(1, sum(isnan(normFactor)));
            N = N.*repmat(normFactor, [1 parameters.histogramRanges{i}(3)]);
            mu = sum(N.*repmat(initCenters, [length(frameInds) 1]), 2);
            err = sum(N.*repmat(initCenters.^2, [length(frameInds) 1]), 2);
            err = sqrt(err - mu.^2).*sqrt(normFactor);
            muFieldName = [parameters.itemsToDisplay{i} 'Mu'];
            errFieldName = [parameters.itemsToDisplay{i} 'Err'];
            movieData.(muFieldName) = mu;
            movieData.(errFieldName) = err;
            errorbar(frameInds, mu, err, parameters.plotStyle); hold on;
            xlim([frameInds(1) - parameters.frameBin, frameInds(end) + parameters.frameBin]);
            xlabel('Frame ID');
            ylabel(parameters.itemsToDisplay{i});
    end
end
PresentationPlot();
