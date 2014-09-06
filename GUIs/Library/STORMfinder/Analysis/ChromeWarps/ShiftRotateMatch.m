function [tform_1,tform_1_inv,data2,dat2,parameters] = ShiftRotateMatch(dat,data,varargin)
%% Compute and apply x-y translation warp (transform 1) 

%% Default Parameters

global scratchPath

% -------------------------------------------------------------------------
% Default variables
% -------------------------------------------------------------------------
defaults = cell(0,3);
defaults(end+1,:) = {'method', 'string', 'affine'}; % 'translation rotation';  % <-- translation rotation sometimes gave weird behavior...?  
defaults(end+1,:) = {'verbose', 'boolean', true};
% -------------------------------------------------------------------------
% Parse variable input
% -------------------------------------------------------------------------
parameters = ParseVariableArguments(varargin, defaults, mfilename);

method = parameters.method; 
verbose = parameters.verbose;

[~,numFields] = size(data(1).sample);
numSamples = length(dat); 
cmap = hsv(numSamples);
mark = {'o','o','.'};


%% Main Function
 tform_1 = cell(1,numSamples); % cell to contain tform_1 for each chn. 
 tform_1_inv = cell(1,numSamples);
 dat2 = dat;  % concatinated 
 
 
% Compute a warp between the reference and sample beads in each frame.
for s=1:numSamples
    tform_1{s} = maketform('affine',[1 0 0; 0 1 0; 0 0 1]); % 
    if  ~isempty(dat(s).refchn.x)
        refdata = [dat(s).refchn.x dat(s).refchn.y];
        basedata = [dat(s).sample.x dat(s).sample.y ];
        tform_1{s} = WarpPoints(refdata,basedata,method); % compute warp
        tform_1_inv{s} = WarpPoints(basedata,refdata,method); % compute warp
        
        [xt,yt] = tforminv(tform_1{s}, dat(s).sample.x,  dat(s).sample.y);
        dat2(s).sample.x = xt; 
        dat2(s).sample.y = yt;
        
%         figure(2); hold on;
%         plot(refdata(:,1),refdata(:,2),mark{s},'color',cmap(s,:)); hold on;
%         plot(basedata(:,1),basedata(:,2),'+','color',cmap(s,:)); hold on;
%         [xdat,ydat] = ConnectDotPairs(dat2(s).refchn.x,dat2(s).refchn.y,dat2(s).sample.x,dat2(s).sample.y);
%         plot(xdat,ydat,'c-');
    end 
end

%------------------------------------
data2 = data; % sorted by frame
for s=1:numSamples

    for k=1:numFields
        [xt,yt] = tforminv(tform_1{s}, data(s).sample(k).x,  data(s).sample(k).y);
        data2(s).sample(k).x = xt; 
        data2(s).sample(k).y = yt;
    end
end


  % test plot
      subplot(1,2,2);
      for s=1:numSamples
      plot(dat2(s).refchn.x,dat2(s).refchn.y,mark{s},'color',cmap(s,:)); hold on;
      plot(dat2(s).sample.x,dat2(s).sample.y,'+','color',cmap(s,:)); hold on;
      [xdat,ydat] = ConnectDotPairs(dat2(s).refchn.x,dat2(s).refchn.y,dat2(s).sample.x,dat2(s).sample.y);
       plot(xdat,ydat,'c-');
      end
      title('after warp1'); 
% 
% %-------------------------------------------------------------------