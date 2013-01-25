function [movie, infoFile, MList] = SimulateSTORM(varargin)
%--------------------------------------------------------------------------
% [movies, infoFiles, realPos] = SimulateSTORM(varargin)
% This function simulates a series of STORM movies given a certain set of
% parameters. These options and parameters are saved in the .notes field of
% the associated infoFiles
%--------------------------------------------------------------------------
% Inputs:
% 
%--------------------------------------------------------------------------
% Outputs:
%
%--------------------------------------------------------------------------
% Variable Inputs:
% 'verbose'/boolean(false): Is progress displayed?
%
% 'numFrames'/integer(10): The number of simulated frames
%
% 'frameDim'/2x1 integer(256x256): The size of the simulated image
%
% 'numEmit'/integer/(25): The number of emitters per frame
% 
% 'photonBudget'/float/(1e3): The number of photons per fluorophore. This value
% takes on different meanings depending on the noise properties of the
% emitter. It is a 2x1 array of [mean, variance] for the lognormal noise
% option
%
% 'background'/integer(100): The number of background counts per pixel
%
% 'photonNoise'/string('geometric'): The noise model for the number of
%    photons from each emitter
%   -'none': No noise
%   -'geometric': Geometric distribution with mean determined by
%       photonBudget
%   -'lognormal': Lognormal distribution with mean and variance determined
%       by photonBudget
%  
% 'imageNoise'/string('poisson'): The noise model for the entire image
%   -'none': No noise
%   -'poisson': Poisson distributed noise with mean set by the value of
%   each pixel
%
% 'dimension'/string('2D'): The dimensionality of the emitter locations
%   -'2D': Emitters are restricted to a single 2D plane
%
% 'upSample'/integer(8): The ratio of the 'real image' pixel size to the
%   simulated camera pixel size
%
% 'border'/integer(0): The number of camera pixels on each side of the
%   image in which fluorophores are removed
% 
% 'PSFconstructor'/string: A string command for generating the PSF used to
%   create the measured image from the real image
% 
% 'savePath'/string: The path where the image and molecule list will be
%   saved
% 
% 'saveName'/string(''): The name of the simulated image. If empty, the
%   image is not saved
% 
% 'saveMoleculeListName'/string: The name of the saved molecule list
%
%--------------------------------------------------------------------------
% Jeffrey Moffitt
% October 3-4, 2012
% jeffmoffitt@gmail.com
%
% Version 1.0
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Hardcoded Variables
%--------------------------------------------------------------------------
quiet = 0;
photonNoiseOptions = {'geometric', 'lognormal', 'none'};
imageNoiseOptions = {'poisson', 'none'};
dimensionOptions = {'2D'};

%--------------------------------------------------------------------------
% Global Variables
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Default Variables
%--------------------------------------------------------------------------
verbose = true;
numFrames = 10;
frameDim = [256 256];
numEmit = 25;
photonBudget = 1e3;
background = 70;
photonNoise = 'geometric';
imageNoise = 'poisson';
dimension = '2D';
upSample = 8;
border = 0;
PSFconstructor = 'fspecial(''gaussian'', 10*upSample, upSample)';
savePath = [pwd '\'];
saveName = '';
saveMoleculeListName = '';

%--------------------------------------------------------------------------
% Parse Variable Input
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
            case 'numFrames'
                numFrames = CheckParameter(parameterValue, 'positive', parameterName);
            case 'frameDim'
                frameDim = CheckParameter(parameterValue, 'positive', parameterName);
            case 'numEmit'
                numEmit = CheckParameter(parameterValue, 'positive', parameterName);
            case 'photonBudget'
                photonBudget = CheckParameter(parameterValue, 'positive', parameterName);
            case 'background'
                background = CheckParameter(parameterValue, 'nonnegative', parameterName);
            case 'photonNoise'
                photonNoise = CheckList(parameterValue, photonNoiseOptions, parameterName);
            case 'imageNoise'
                imageNoise = CheckList(parameterValue, imageNoiseOptions, parameterName);
            case 'dimension'
                dimension = CheckList(parameterValue, dimensionOptions, parameterName);
            case 'border'
                border = CheckParameter(parameterValue, 'nonnegative', parameterName);
            case 'savePath'
                savePath = CheckParameter(parameterValue, 'string', parameterName);
            case 'saveName'
                saveName = CheckParameter(parameterValue, 'string', parameterName);
                ind = find(ismember(saveName, '.'));
                if isempty(ind)
                    saveName = [saveName '.inf'];
                else
                    saveName = [saveName(1:(ind-1)) '.inf'];
                end
            case 'saveMoleculeListName'
                saveMoleculeListName = CheckParameter(parameterValue, 'string', parameterName);
            case 'upSample'
                upSample = CheckParameter(parameterValue, 'positive', parameterName);
            case 'PSFconstructor'
                PSFconstructor = CheckParameter(parameterValue, 'string', parameterName);
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end

%--------------------------------------------------------------------------
% Allocate memory for simulated image and for real image
%--------------------------------------------------------------------------
singleRealFrame = zeros(frameDim*upSample);
movie = zeros([frameDim numFrames]);
realPos = zeros(numFrames, numEmit, 3); % Frame number, x, y, and photon number

%--------------------------------------------------------------------------
% Create simulation parameter string (for later archival)
%--------------------------------------------------------------------------
simulationParameterString = ...
    ['numFrames: ' num2str(numFrames) '\n' ...
    'numEmit: ' num2str(numEmit) '\n' ...
    'photonBudget: ' num2str(photonBudget) '\n' ...
    'background: ' num2str(background) '\n' ...
    'photonNoise: ' photonNoise '\n' ...
    'imageNoise: ' imageNoise '\n' ... 
    'dimension: ' dimension '\n' ...
    'upSample: ' num2str(upSample) '\n' ...
    'border: ' num2str(border) '\n' ...
    'PSFconstructor: ' PSFconstructor];

if verbose
    display('-------------------------------------------------------------');
    display('Simulating STORM Movie');
    display([sprintf(simulationParameterString) ' ']);
    display('-------------------------------------------------------------');
end

%--------------------------------------------------------------------------
% Create PSF
%--------------------------------------------------------------------------
PSF = eval(PSFconstructor);

%--------------------------------------------------------------------------
% Calculate boundary indices
%--------------------------------------------------------------------------
if border
    realDim = upSample*frameDim;
    borderUp = border*upSample;
    [Xtop,Ytop] = meshgrid(1:realDim(1), 1:borderUp);
    [Xbottom,Ybottom] = meshgrid(1:realDim(1), (realDim(2)-borderUp+1):realDim(2));
    [Xleft,Yleft] = meshgrid(1:borderUp, 1:realDim(2));
    [Xright,Yright] = meshgrid((realDim(1)-borderUp+1):realDim(1), 1:realDim(2));

    indTop = sub2ind(frameDim*upSample, Xtop, Ytop);
    indBottom = sub2ind(frameDim*upSample, Xbottom,Ybottom);
    indLeft = sub2ind(frameDim*upSample, Xleft,Yleft);
    indRight = sub2ind(frameDim*upSample, Xright,Yright);

    borderInd = unique([reshape(indTop, [1 numel(indTop)]) reshape(indBottom, [1 numel(indBottom)]) ...
        reshape(indLeft, [1 numel(indLeft)]) reshape(indRight, [1 numel(indRight)]) ]);
end
%--------------------------------------------------------------------------
% Loop through frames
%--------------------------------------------------------------------------
for i=1:numFrames
    %--------------------------------------------------------------------------
    % Distribute fluorophores and calculate photon number
    %--------------------------------------------------------------------------
    fluorIndices = randi(numel(singleRealFrame), [1 numEmit]);
    if border
        fluorIndices = setdiff(fluorIndices, borderInd);
    end
    
    switch photonNoise
        case 'geometric'
            photonNumbers = geornd(1/photonBudget(1), [1, length(fluorIndices)]);
        case 'none'
            photonNumbers = photonBudget(1)*ones(1, length(fluorIndices));
        case 'lognormal'
            if length(photonBudget) ~= 2
                error('PhotonBudget must be a 1x2 vector for lognormal');
            end
            m = photonBudget(1);
            v = photonBudget(2);
            mu = log((m^2)/sqrt(v+m^2));
            sigma = sqrt(log(v/(m^2)+1));
            photonNumbers = lognrnd(mu,sigma, [1 length(fluorIndices)]);
        otherwise
            error(['Invalid photonNoise flag']);
    end
    
    singleRealFrame(fluorIndices) = photonNumbers;
    [x,y] = ind2sub(frameDim*upSample, fluorIndices);
    if ~isempty(fluorIndices)
        realPos(i, 1:length(fluorIndices), 1) = x;
        realPos(i, 1:length(fluorIndices), 2) = y;
        realPos(i, 1:length(fluorIndices), 3) = photonNumbers;
    end
    
    %--------------------------------------------------------------------------
    % Blur image with PSF
    %--------------------------------------------------------------------------
    singleRealFrame = imfilter(singleRealFrame, PSF, 'conv');

    %--------------------------------------------------------------------------
    % Sum upsampled adjacent pixels
    %--------------------------------------------------------------------------
    singleRealFrame = conv2(singleRealFrame, ones(upSample, upSample));
    
    %--------------------------------------------------------------------------
    % Pull out unique pixel values and reset frame
    %--------------------------------------------------------------------------
    movie(:,:,i) = singleRealFrame(upSample:upSample:end, upSample:upSample:end);
    singleRealFrame = zeros(frameDim*upSample);

    %--------------------------------------------------------------------------
    % Add background
    %--------------------------------------------------------------------------
    movie(:,:,i) = squeeze(movie(:,:,i)) + background*ones(frameDim);
    
    %--------------------------------------------------------------------------
    % Add image noise
    %--------------------------------------------------------------------------
    switch imageNoise
        case 'poisson'
            movie(:,:,i) = poissrnd(movie(:,:,i));
        case 'none'
            
        otherwise
            error('Invalid flag for imageNoise');
    end
    
    if verbose
        display(['Completed frame ' num2str(i) ' of ' num2str(numFrames)]);
    end
    
    %--------------------------------------------------------------------------
    % Rotate frame to fit Insight3 axis
    %--------------------------------------------------------------------------
    movie(:,:,i) = flipud(rot90(squeeze(movie(:,:,i)), 1));
end
%--------------------------------------------------------------------------
% Create Molecule List
%--------------------------------------------------------------------------
MList = CreateMoleculeList(numFrames*numEmit, 'compact', true);

for i=1:numFrames
    ind = find(realPos(i, :, 1) ~= 0); % Find fluorophores not removed on borders
    for j=1:length(ind)
        molInd = numEmit*(i-1) + j;
        MList.x(molInd) = (realPos(i,ind(j),1)-1)/upSample+0.5;
        MList.xc(molInd) = MList.x(molInd);
        MList.y(molInd) = (realPos(i,ind(j),2)-1)/upSample+0.5;
        MList.yc(molInd) = MList.y(molInd);
        MList.a(molInd) = realPos(i,ind(j),3);
        MList.i(molInd) = realPos(i,ind(j),3);
        MList.bg(molInd) = background;
        MList.frame(molInd) = i;
    end
end

%--------------------------------------------------------------------------
% Create infoFile
%--------------------------------------------------------------------------
infoFile = CreateInfoFileStructure();
infoFile.localName = saveName;
infoFile.localPath = savePath;
infoFile.file = [savePath saveName];
infoFile.machine_name = 'simulation';
infoFile.frame_dimensions = frameDim;
infoFile.frame_size = prod(frameDim);
infoFile.number_of_frames = numFrames;
infoFile.hstart = 1;
infoFile.hend = frameDim(1);
infoFile.vstart = 1;
infoFile.vend = frameDim(2);
infoFile.notes = sprintf(simulationParameterString);

if isempty(saveName)
    infoFile.localName = 'simulation.inf';
    infoFile.file = [savePath 'simulation.inf'];
end

%--------------------------------------------------------------------------
% Save .dax and .inf files
%--------------------------------------------------------------------------
if ~isempty(saveName)
    %--------------------------------------------------------------------------
    % Save dax file (info file saved with dax file)
    %--------------------------------------------------------------------------
    WriteDAXFiles(movie, infoFile, 'verbose', verbose)
end

%--------------------------------------------------------------------------
% Save Molecule List
%--------------------------------------------------------------------------
if ~isempty(saveMoleculeListName)
    WriteMoleculeList(MList, [savePath saveMoleculeListName], ...
        'writeAllFrames', false, 'numFrames', numFrames, 'verbose', true);
end


