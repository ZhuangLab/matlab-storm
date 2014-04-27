function dat = MatchSampleAndRefData(data,varargin)
%-------------------------------------------------------------------------
%  Required Input
% data is a size n structure for the n different sample - reference pairs
% of image stacks.  
% data(n).refchn  - contains coordinates .x .y and .z from k different f
%                   ields of view of the reference channel (e.g. 647 beads) 
% data(n).sample - contains coordinates .x .y and .z from k different f
%                   ields of view of the sample channel (e.g. 561 beads)


 %% match molecules in each section
% (much less ambiguious than matching superimposed selection list). 

% load([scratchPath, 'troubleshoot.mat']);

% save([scratchPath  'troubleshoot.mat']); disp('saving Troubeshooting data');

% -------------------------------------------------------------------------
% Default variables
% -------------------------------------------------------------------------
defaults = cell(0,3);
defaults(end+1,:) = {'matchRadius', 'nonnegative', 2};
defaults(end+1,:) = {'showPlots', 'boolean', true};
defaults(end+1,:) = {'verbose', 'boolean', true};

% -------------------------------------------------------------------------
% Parse necessary input
% -------------------------------------------------------------------------
if nargin < 1
    error('matlabSTORM:invalidArguments', 'data structure is required');
end

% -------------------------------------------------------------------------
% Parse variable input
% -------------------------------------------------------------------------
parameters = ParseVariableArguments(varargin, defaults, mfilename);

%% Main Function
numSamples = length(data);
numFields = length(data(1).sample);
% for plotting
cmap = hsv(numSamples);
mark = {'o','o','.'};
      
% % plots for troubleshooting
%  k = 1; 
% figure(1); clf; 
% for s=1:numSamples
%     plot(data(s).refchn(k).x,data(s).refchn(k).y,'+','color',cmap(s,:)); hold on;
%     plot(data(s).sample(k).x,data(s).sample(k).y,mark{s},'color',cmap(s,:)); hold on;
% end

% tform_start = maketform('affine',[1 0 0; 0 1 0; 0 0 1]);
dat(numSamples).refchn.x = [];

numFieldsWithData = numFields;
for s=1:numSamples
   numFieldsWithData = min([numFieldsWithData,length(data(s).refchn),length(data(s).sample)]);
end
numFields = numFieldsWithData;

% set1 = cell(numSamples,1);
% set2 = cell(numSamples,1);
% set1{s}.x{k} provides the set1 matches for sample s in frame k.  
for s=1:numSamples
%     for k = 1:numFields   % k = 217  k=15;
%     [set1{s},set2{s}] = MatchMols(data(s).refchn(k),data(s).sample(k),...
%         tform_start, match_radius1,verbose,data(s).sample(k).chn,k,...
%         set1{s},set2{s},numFields);
%     end   
%     dat(s).refchn.x = cat(1,set1{s}.x{:}); % cell2mat(set1{s}.x);
%     dat(s).refchn.y = cat(1,set1{s}.y{:}); % cell2mat(set1{s}.y);
%     dat(s).refchn.z = cat(1,set1{s}.z{:}); %  cell2mat(set1{s}.z);
%     dat(s).sample.x = cat(1,set2{s}.x{:}); %  cell2mat(set2{s}.x);
%     dat(s).sample.y = cat(1,set2{s}.y{:}); %  cell2mat(set2{s}.y);
%     dat(s).sample.z = cat(1,set2{s}.z{:}); %  cell2mat(set2{s}.z);
%     
    ref = cell(numFields,3); 
    sample = cell(numFields,3); 
    for k=1:numFields
        [matched1,matched2] = MatchFeducials(...
            [data(s).refchn(k).x,data(s).refchn(k).y],...
            [data(s).sample(k).x,data(s).sample(k).y],...
            'showPlots',parameters.showPlots,'maxD',parameters.matchRadius);
        ref{k,1} = data(s).refchn(k).x(matched1);
        ref{k,2} = data(s).refchn(k).y(matched1);
        ref{k,3} = data(s).refchn(k).z(matched1);

        sample{k,1} = data(s).sample(k).x(matched2);
        sample{k,2} = data(s).sample(k).y(matched2);
        sample{k,3} = data(s).sample(k).z(matched2);

        if parameters.verbose
            disp(['frame ',num2str(k),' :matched ',num2str(length(matched2)),...
                ' of ',num2str(length(data(s).sample(k).x)),' ',...
                data(s).sample(k).chn,' beads'])
        end
    end
    dat(s).refchn.x = cat(1,ref{:,1});
    dat(s).refchn.y = cat(1,ref{:,2});
    dat(s).refchn.z = cat(1,ref{:,3});
    dat(s).sample.x = cat(1,sample{:,1});
    dat(s).sample.y = cat(1,sample{:,2});
    dat(s).sample.z = cat(1,sample{:,3});    
end


% test plot
  figure; clf; subplot(1,2,1); 
  for s=1:numSamples
    plot(dat(s).refchn.x,dat(s).refchn.y,mark{s},'color',cmap(s,:)); hold on;
    plot(dat(s).sample.x,dat(s).sample.y,'+','color',cmap(s,:)); hold on;
    [xdat,ydat] = ConnectDotPairs(dat(s).refchn.x,dat(s).refchn.y,dat(s).sample.x,dat(s).sample.y);
    plot(xdat,ydat,'c-');
  end
  legend('ref chn matched','data chn matched')
      

