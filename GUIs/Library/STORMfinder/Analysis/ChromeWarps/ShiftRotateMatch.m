function [tform_1,tform_1_inv,data2,dat2,parameters] = ShiftRotateMatch(dat,data,match_radius,varargin)
%% Compute and apply x-y translation warp (transform 1) 

%% Default Parameters

global scratchPath

% -------------------------------------------------------------------------
% Default variables
% -------------------------------------------------------------------------
defaults = cell(0,3);
defaults(end+1,:) = {'verbose', 'boolean', true};
defaults(end+1,:) = {'remove_crosstalk', 'boolean', true};
% -------------------------------------------------------------------------
% Parse variable input
% -------------------------------------------------------------------------
parameters = ParseVariableArguments(varargin, defaults, mfilename);


verbose = parameters.verbose;
remove_crosstalk = parameters.remove_crosstalk;

[~,numFields] = size(data(1).sample);
numSamples = length(dat); 
cmap = hsv(numSamples);
mark = {'o','o','.'};


%% Main Function
 tform_1 = cell(1,numSamples); % cell to contain tform_1 for each chn. 
 tform_1_inv = cell(1,numSamples);
 dat2 = dat;  % concatinated 
 
% save([scratchPath,'test3.mat']); 
% load([scratchPath,'test3.mat']); 
 
for s=1:numSamples
% maybe important for handling missing data:
    method = 'affine'; % 'translation rotation';
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


% match molecules in each section
% (much less ambiguious than matching superimposed selection list). 

% % Outdated.  
% 
% tform_start = maketform('affine',[1 0 0; 0 1 0; 0 0 1]);
% set1 = cell(numSamples,1);
% set2 = cell(numSamples,1);
% dat2(numSamples).refchn.x = [];
% for s = 1:numSamples
%     for k = 1:numFields          
%         % Hard-coded, remove 750 blead through on Quadview
%         % With good parameter choices should not be necessary.  
%          if remove_crosstalk  && beadmovie(1).quadview % Remove 750 crosstalk 
%            data2(2).refchn(k) = remove_bleadthrough(data2(2).refchn(k),data2(1).sample(k),tform_start, cx_radius,verbose,'Vis647',k);
%            data2(3).refchn(k) = remove_bleadthrough(data2(3).refchn(k),data2(1).sample(k),tform_start, cx_radius,verbose,'Vis647',k);
%            data2(2).sample(k) = remove_bleadthrough(data2(2).sample(k),data2(1).sample(k),tform_start, cx_radius,verbose,'Vis561',k);
%            data2(3).sample(k) = remove_bleadthrough(data2(3).sample(k),data2(1).sample(k),tform_start, cx_radius,verbose,'Vis488',k);
%         end
% 
%          % Match beads from each sample channel to counterpart in target reference channel 
%          % set1{s}.x{k} provides the set1 matches for sample s in frame k.  
%         [set1{s},set2{s}] = MatchMols(data2(s).refchn(k),data2(s).sample(k),...
%             tform_start, match_radius,verbose,data2(s).sample(k).chn,k,set1{s},set2{s},numFields);     
%     end      
%  % combine into single vectors
%     dat2(s).refchn.x = cell2mat(set1{s}.x);
%     dat2(s).refchn.y = cell2mat(set1{s}.y);
%     dat2(s).refchn.z = cell2mat(set1{s}.z);
%     dat2(s).sample.x = cell2mat(set2{s}.x);
%     dat2(s).sample.y = cell2mat(set2{s}.y);
%     dat2(s).sample.z = cell2mat(set2{s}.z);
% end


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