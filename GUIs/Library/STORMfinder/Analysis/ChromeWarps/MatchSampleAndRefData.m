function dat = MatchSampleAndRefData(data,match_radius1)

 %% match molecules in each section
% (much less ambiguious than matching superimposed selection list). 

% load([scratchPath, 'troubleshoot.mat']);

% save([scratchPath  'troubleshoot.mat']); disp('saving Troubeshooting data');

verbose = true;
[numSamples,numFields] = size(data.sample);


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

tform_start = maketform('affine',[1 0 0; 0 1 0; 0 0 1]);
dat(numSamples).refchn.x = [];

numFieldsWithData = numFields;
for s=1:numSamples
   numFieldsWithData = min([numFieldsWithData,length(data(s).refchn),length(data(s).sample)]);
end
numFields = numFieldsWithData;

set1 = cell(numSamples,1);
set2 = cell(numSamples,1);
% set1{s}.x{k} provides the set1 matches for sample s in frame k.  
for s=1:numSamples
    for k = 1:numFields   % k = 217  k=15;
    [set1{s},set2{s}] = MatchMols(data(s).refchn(k),data(s).sample(k),...
        tform_start, match_radius1,verbose,data(s).sample(k).chn,k,...
        set1{s},set2{s},numFields);
    end   
    dat(s).refchn.x = cat(1,set1{s}.x{:}); % cell2mat(set1{s}.x);
    dat(s).refchn.y = cat(1,set1{s}.y{:}); % cell2mat(set1{s}.y);
    dat(s).refchn.z = cat(1,set1{s}.z{:}); %  cell2mat(set1{s}.z);
    dat(s).sample.x = cat(1,set2{s}.x{:}); %  cell2mat(set2{s}.x);
    dat(s).sample.y = cat(1,set2{s}.y{:}); %  cell2mat(set2{s}.y);
    dat(s).sample.z = cat(1,set2{s}.z{:}); %  cell2mat(set2{s}.z);
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
      

