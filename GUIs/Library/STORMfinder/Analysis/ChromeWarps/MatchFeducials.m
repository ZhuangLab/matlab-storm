function [matched1,matched2,parameters] = MatchFeducials(image1spots,image2spots,varargin)
% Compute translation/rotation warp that best aligns the points in image1spots
% and image2spots by maximizing the alignment of the two points that show the 
% most mutually consistent x,y translation.  
%
%
% corrPrecision - precision at which to compute the correlation based
% alignment.  default is 1, no upsampling, which is more robust
% smaller numbers (e.g. 0.1) will give a finer (subpixel) alignment.  
% maxD - maximum distance after correlation based alignment that objects
% can be separated.  
% maxTrueSeparation -- maximum distance allowed between matched points 

global scratchPath
troubleshoot = false; 

% -------------------------------------------------------------------------
% Default variables
% -------------------------------------------------------------------------
defaults = cell(0,3);
defaults(end+1,:) = {'maxD', 'nonnegative', 5};
defaults(end+1,:) = {'maxTrueSeparation', 'nonnegative', inf};
defaults(end+1,:) = {'corrPrecision', 'nonnegative', 1};
defaults(end+1,:) = {'useCorrAlign', 'boolean', true};
defaults(end+1,:) = {'fighandle', 'handle', []};
defaults(end+1,:) = {'imageSize', 'array', [256 256]};
defaults(end+1,:) = {'showPlots', 'boolean', true};
defaults(end+1,:) = {'showCorrPlots', 'boolean', false};
defaults(end+1,:) = {'verbose', 'boolean', true};

% -------------------------------------------------------------------------
% Parse necessary input
% -------------------------------------------------------------------------
if nargin < 2
    error('matlabSTORM:invalidArguments', 'two nx2 vectors of points are required');
end

% -------------------------------------------------------------------------
% Parse variable input
% -------------------------------------------------------------------------
parameters = ParseVariableArguments(varargin, defaults, mfilename);

% parameters = ParseVariableArguments('', defaults, mfilename);

% image1spots = hybe1; image2spots = hybe2; 

%--------------------------------------------------------------------------
%% Main Function
%--------------------------------------------------------------------------

h = parameters.imageSize(1);
w = parameters.imageSize(2);

% -------------Step 1: Match by cross correlation -----------------------
% (This step is optional)
stp = parameters.corrPrecision; 
I1 = hist3([image1spots(:,2),image1spots(:,1)],{1:stp:h,1:stp:h});
I2 = hist3([image2spots(:,2),image2spots(:,1)],{1:stp:h,1:stp:w});
if parameters.useCorrAlign
    if parameters.showCorrPlots
        figure(10); clf;
    end
    [xshift,yshift] = CorrAlign(I1,I2,'showplot',parameters.showCorrPlots);
    xshift = xshift*stp;
    yshift = yshift*stp;
else
    xshift = 0;
    yshift = 0;
end

% Enforce maximum 


% % figure for troubleshooting correlation alignment; 
if troubleshoot
    figure(10); clf; 
    subplot(1,2,1); Ncolor(cat(3,I1,I2)); hold on; 
    plot(image1spots(:,1)/stp,image1spots(:,2)/stp,'ro');
    plot(image2spots(:,1)/stp,image2spots(:,2)/stp,'bo');
    subplot(1,2,2); Ncolor(cat(3,I1,I2)); hold on; 
    plot(image1spots(:,1)/stp,image1spots(:,2)/stp,'ro');
    plot(image2spots(:,1)/stp+xshift,image2spots(:,2)/stp+yshift,'bo');
end
    
if parameters.verbose
    disp(['xshift=',num2str(xshift),' yshift=',num2str(yshift)]);
end

%-------------- Step 2: Match by warp to nearest neigbhor --------------%
numFeducials = size(image2spots,1); 
image2spotsw = image2spots + repmat([xshift,yshift],numFeducials,1);
% Match unique nearest neighbors 
if size(image1spots,1) >= size(image2spots,1)
    [idx1,dist1] = knnsearch(image1spots,image2spotsw); %  indices of image1spots nearest for each point in image2spots 
    matches21 = [ (1:size(image2spots,1))',idx1 ];
    matches21(  dist1>parameters.maxD, :) = [];   % remove distant points

    % for the channel with the smaller number of feducials, remove double hits
    [v,n] = occurrences(idx1); 
    multihits1 = v(n>1);
    multihits1_idx = ismember( matches21(:,2), multihits1);
    matches21(multihits1_idx,:) = [];

    matched1 = matches21(:,2); 
    matched2 = matches21(:,1); 
else
    [idx2,dist2] = knnsearch(image2spotsw,image1spots); %  indices of image2spots nearest for each point in image1spots 
    matches12 = [ (1:size(image1spots,1))',idx2 ];
    matches12(  dist2>parameters.maxD, :) = [];   % remove distant points

    % for the channel with the smaller number of feducials, remove double hits
    [v,n] = occurrences(idx2); 
    multihits2 = v(n>1);
    multihits2_idx = ismember( matches12(:,2), multihits2);
    matches12(multihits2_idx,:) = [];

    matched1 = matches12(:,1); 
    matched2 = matches12(:,2); 
end
    

%----------------- Plotting ---------
if parameters.showPlots
    if isempty(parameters.fighandle);
        parameters.fighandle = figure; clf;
    else
        figure(parameters.fighandle); clf;
    end
        
    plot(image1spots(:,1),image1spots(:,2),'k.'); hold on;
    plot(image2spots(:,1),image2spots(:,2),'bo')
    % plot(image2spotsw(:,1),image2spotsw(:,2),'r+')

    for i=1:size(image1spots,1)
        text(image1spots(i,1)+2,image1spots(i,2),num2str(i)); hold on;
    end
    for i=1:size(image2spots,1)
            text(image2spots(i,1)+2,image2spots(i,2),num2str(i),'color','b')
    end
    
    for i=1:length(matched1);
        plot([image1spots(matched1(i),1),image2spots(matched2(i),1)],...
            [image1spots(matched1(i),2),image2spots(matched2(i),2)],'b'); 
    end
    pause(.02);
end
%-------------------------------------
