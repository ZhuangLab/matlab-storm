function BoxPlotCell(data,varargin)
% generates a box plot 

%% Main Function

figure(2); clf;
data = cat(1,BArea,YArea);

maxDataPoints = max(cellfun(@length,data));
numDataTypes = length(data);

dataMatrix = NaN*ones(numDataTypes,maxDataPoints); 
for i=1:numDataTypes
    numDataPoints = length(data{i});
    dataMatrix(i,1:numDataPoints) = data{i};
end

boxplot(dataMatrix','width',.9);


% ,'Labels',{},'colors',CMap); 