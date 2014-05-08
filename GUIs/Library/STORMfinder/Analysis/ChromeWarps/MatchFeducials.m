function [matched1, matched2,parameters] = MatchFeducials(image1spots,image2spots,varargin)
% Compute translation/rotation warp that best aligns the points in image1spots
% and image2spots by maximizing the alignment of the two points that show the 
% most mutually consistent x,y translation.  


% -------------------------------------------------------------------------
% Default variables
% -------------------------------------------------------------------------
defaults = cell(0,3);
defaults(end+1,:) = {'maxD', 'nonnegative', 2};
defaults(end+1,:) = {'useCorrAlign', 'boolean', true};
defaults(end+1,:) = {'fighandle', 'handle', []};
defaults(end+1,:) = {'imageSize', 'array', [256 256]};
defaults(end+1,:) = {'showPlots', 'boolean', true};
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



%--------------------------------------------------------------------------
%% Main Function
%--------------------------------------------------------------------------

h = parameters.imageSize(1);
w = parameters.imageSize(2);

% ----------------------- Step 1 Match beads-----------------------
% Match by cross correlation
I1 = hist3([image1spots(:,2),image1spots(:,1)],{1:.1:h,1:.1:h});
I2 = hist3([image2spots(:,2),image2spots(:,1)],{1:.1:h,1:.1:w});
if parameters.useCorrAlign
    [xshift,yshift] = CorrAlign(I1,I2);
    xshift = xshift/10;
    yshift = yshift/10;
else
    xshift = 0;
    yshift = 0;
end

numFeducials = size(image2spots,1); 
image2spotsw = image2spots + repmat([xshift,yshift],numFeducials,1);
% Match unique nearest neighbors 
[idx,dist] = knnsearch(image1spots,image2spotsw); % nearest image1spots for each point in image2spots 
idx(dist>parameters.maxD) = NaN;
[v,n] = occurrences(idx);
matched1 =  v(n==1);  % the indices of points in image 1 who have only 1 match within maxD 
matched2 = find(ismember(idx,matched1)); 

% This really shouldn't be necessary, but something crazy happens above
dist2 = ( (image1spots(matched1,1)-image2spots(matched2,1)).^2 + (image1spots(matched1,2)-image2spots(matched2,2)).^2);
failDots = dist2 > parameters.maxD^2;
matched1(failDots) = [];
matched2(failDots) = [];

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

    for i=1:length(matched1);
        plot([image1spots(matched1(i),1),image2spots(matched2(i),1)],...
            [image1spots(matched1(i),2),image2spots(matched2(i),2)],'b'); 
    end
    pause(.02);
end
%-------------------------------------
