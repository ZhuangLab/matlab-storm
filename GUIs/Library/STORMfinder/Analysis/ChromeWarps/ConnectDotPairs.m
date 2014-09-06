function [xdat,ydat] = ConnectDotPairs(x1,y1,x2,y2,varargin)

numPts = length(x1);
try
xdat = reshape([x1 x2 NaN*ones(numPts,1)]',numPts*3,1);
ydat = reshape([y1 y2 NaN*ones(numPts,1)]',numPts*3,1);
catch er
    disp(er.getReport)
    warning('input x and y lists must be column vectors.  Unable to link lists'); 
    xdat = NaN;
    ydat = NaN;
end