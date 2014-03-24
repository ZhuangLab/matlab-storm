function [medStats,numCycles,filt] = GetSwitchingStats(mlist,varargin)
%--------------------------------------------------------------------------
% Returns statistics on molecule behavior in movie
%     Distribution of # of cycles per dye / cluster
%     Distribution of # of photons per cycle
%     Distribution of Height of localizations
%     Distribution of number of frames per cycle 
%
%--------------------------------------------------------------------------
% % Optional Inputs
% boxSize = 10; % nm % to determine cluster centroids.  
% minLoc = 2; % min localizations to be called a switching cluster
% clusterWidth = 1; % pixels (distance over which to cluster localizations)
% startframe = 1; 
% npp = 160; % nm per pixel
% photonsPerCount = .43;
% verbose = true;
% allSpots = false; 
% roi = [];
%
%--------------------------------------------------------------------------
%

% folder = '\\Cajal\TSTORMdata\140320_buffers\'

% mlist = ReadMasterMoleculeList([folder,'Buffer1_2_c1_list.bin']);

% figure(1); clf; plot(mlist.x,mlist.y,'k.');

%--------------------------------------------------------------------------
%% Default Variables
%--------------------------------------------------------------------------
boxSize = 20; % nm % to determine cluster centroids.  
minLoc = 2; % min localizations to be called a switching cluster
clusterWidth = 1; % pixels (distance over which to cluster localizations)
startframe = 1; 
npp = 160; % nm per pixel
photonsPerCount = .43;
verbose = true;
allSpots = false; 
plotsOn = true;
roi = [];
saveName = '';
maxDots = 2500;

%--------------------------------------------------------------------------
%% Parse variable input
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
            case 'boxSize'
                boxSize = CheckParameter(parameterValue,'positive','boxSize');
            case 'minLoc'
                minLoc = CheckParameter(parameterValue,'positive','minLoc');
            case 'clusterWidth'
                clusterWidth = CheckParameter(parameterValue,'positive','clusterWidth');
            case 'startframe'
                startframe = CheckParameter(parameterValue,'positive','startframe');
            case 'npp'
                npp = CheckParameter(parameterValue,'positive','npp');
            case 'photonsPerCount'
                photonsPerCount = CheckParameter(parameterValue,'positive','photonsPerCount');
            case 'allSpots'
                allSpots = CheckParameter(parameterValue,'boolean','allSpots');
            case 'verbose'
                verbose = CheckParameter(parameterValue,'boolean','verbose');
            case 'plotsOn'
                plotsOn = CheckParameter(parameterValue,'boolean','plotsOn');
            case 'roi'
                roi = CheckParameter(parameterValue,'array','roi');
            case 'saveName'
                saveName = CheckParameter(parameterValue,'string','saveName');
            case 'maxDots'
                maxDots  = CheckParameter(parameterValue,'string','maxDots');
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end

if isempty(roi)
    roi = [0,256,0,256];
end

%% Main Function

yBins = roi(3):(boxSize/npp):roi(4); 
xBins = roi(1):(boxSize/npp):roi(2);
mapIdx = hist3([mlist.y,mlist.x],{yBins,xBins});  
% figure(2); clf; imagesc(mapIdx); caxis([0,3]);

mapBW = mapIdx>=minLoc;  % figure(2); clf; imagesc(mapBW);
props = regionprops(mapBW,mapIdx,'WeightedCentroid');
cents = cat(1,props.WeightedCentroid)*boxSize/npp;

numDots = min(length(props),maxDots); 

% Feducials must be ID'd in at least fmin fraction of total frames
fb =[cents(:,1)-clusterWidth/2, cents(:,1)+clusterWidth/2,cents(:,2)-clusterWidth/2,cents(:,2)+clusterWidth/2];

%  figure(2); clf; imagesc(mapIdx); caxis([0,3]);
%  xhist = (mlist.xc-roi(1))*npp/boxSize+1;
%  yhist = (mlist.yc-roi(3))*npp/boxSize+1;
%  hold on; plot(xhist,yhist,'k.','MarkerSize',10);
%  plot(cents(:,1)*npp/boxSize,cents(:,2)*npp/boxSize,'c+','MarkerSize',10);

 % figure(3); clf; plot(mlist.xc(mlist.a*.43>2500),mlist.yc(mlist.a*.43>2500),'k.');
 
dotFrames = cell(numDots,1); 
keptSpots = false(length(mlist.x),1);
for i=1:numDots
    inbox = mlist.x > fb(i,1) & mlist.x < fb(i,2) & ...
        mlist.y > fb(i,3) & mlist.y < fb(i,4) & ...
        mlist.frame > startframe;
   dotFrames{i} = mlist.frame(inbox);
   keptSpots = keptSpots | inbox; 
   if verbose && (rem(i,1000) == 0)
       disp(i/numDots*100);
   end
end


%% 

if allSpots 
    filt = true(length(mlist.x),1);
else
    filt = keptSpots;
end

numCycles = cellfun(@length,dotFrames);


meanCycles = mean(numCycles); 
medCycles = median(numCycles); 

meanPhotons = mean(mlist.a(filt)*photonsPerCount);
medPhotons  = median(mlist.a(filt)*photonsPerCount);

meanHeight = mean(mlist.h(filt));
medHeight = median(mlist.h(filt)); 

meanFramesOn = mean(mlist.length(filt));
medFramesOn = median(mlist.length(filt));

cyclesX = 1:50;
photonX = 0:100:10E3;
heightX = 0:10:10E3;
lengthX = 0:100;

% Plotting
if plotsOn
    subplot(3,2,1); hist(numCycles,cyclesX); 
    title(['Ave # Cycles=',num2str(meanCycles,3)]); xlim([0,max(cyclesX)]);
    subplot(3,2,2); hist(double(mlist.a)*photonsPerCount,photonX); 
    title(['Ave # Photons=',num2str(meanPhotons,3)]); xlim([0,max(photonX)]);
    subplot(3,2,3); hist(double(mlist.h),heightX); 
    title(['Ave Height=',num2str(meanHeight,3)]); xlim([0,max(heightX)]);
    subplot(3,2,4); hist(double(mlist.length),lengthX);
    title(['Ave frames on=',num2str(meanFramesOn,3)]); xlim([0,max(lengthX)]);
    subplot(3,2,5);  imagesc(mapIdx(50:150,50:150)); caxis([0,5]); axis off;
    subplot(3,2,6); imagesc(0*mapIdx(50:150,50:150)); hold on;  colormap gray;
                    plot((mlist.xc-roi(1))+1,(mlist.yc-roi(3))+1,'w.'); hold on;
                    plot(cents(:,1),cents(:,2),'c+');
    PresentationPlot();
    figHand = gcf;
    if ~isempty(saveName)
        disp(['saving ',saveName]);
        saveas(figHand,saveName); 
    end
end

if verbose
    disp(['Median # cycles = ',num2str(medCycles,4)])
    disp(['Mean # cycles = ',num2str(meanCycles,4)])
    disp(['Mean # photons = ',num2str(meanPhotons,4)])
    disp(['Median # photons = ',num2str(medPhotons,4)])
    disp(['Mean height = ',num2str(meanHeight,4)])
    disp(['Median height = ',num2str(medHeight,4)])
    disp(['Mean # frames on = ',num2str(meanFramesOn,4)])
    disp(['Median # frames on = ',num2str(medFramesOn,4)])
end

aveStats(1) = meanCycles;
aveStats(2) = meanPhotons;
aveStats(3) = meanHeight;
aveStats(4) = meanFramesOn; 

medStats(1) = medCycles;
medStats(2) = medPhotons;
medStats(3) = medHeight;
medStats(4) = medFramesOn; 
