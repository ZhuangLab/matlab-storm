function [maxVolume, mI3, props3D] = Stats3DScatter(x,y,z,varargin)
% Returns the volume and moment of intertia for the largest connected
% domain created by x,y,z
% 
% minDots 
%            - min number of localizations per voxel to be counted as an
%            occupied voxel in determining connected regions.  If a
%            fraction f is passed, min dots will be determined from the
%            data as the counts greater than 


% default parameters

bins =[32,32,10];% number of bins per dimension  [128,128,40];
zrange = [-500, 500];
xrange = [];
yrange = []; 
minDots = .5; 

%--------------------------------------------------------------------------
%% Parse Variable Input Parameters
%--------------------------------------------------------------------------
if nargin > 3
    if (mod(length(varargin), 2) ~= 0 ),
        error(['Extra Parameters passed to the function ''' mfilename ''' must be passed in pairs.']);
    end
    parameterCount = length(varargin)/2;

    for parameterIndex = 1:parameterCount,
        parameterName = varargin{parameterIndex*2 - 1};
        parameterValue = varargin{parameterIndex*2};
        switch parameterName
            case 'bins'
                bins = CheckParameter(parameterValue, 'positive', 'bins');
            case 'xrange'
                xrange = CheckParameter(parameterValue, 'array', 'xrange');
            case 'yrange'
                yrange = CheckParameter(parameterValue, 'array', 'yrange');
            case 'zrange'
                zrange = CheckParameter(parameterValue, 'array', 'zrange');
            case 'minDots'
                minDots = CheckParameter(parameterValue,'nonnegative','minDots');
            otherwise
                error(['The parameter ''', parameterName,''' is not recognized by the function, ''',mfilename '''.' '  See help ' mfilename]);
        end
    end
end

if isempty(zrange)
    zrange = [min(z),max(z)]; 
end
if isempty(yrange)
    yrange = [min(y),max(y)];
end
if isempty(xrange)
    xrange = [min(x),max(x)];
end

%% Main Function

M4 = hist4(x,y,z,'bins',bins,'datarange',{xrange,yrange,zrange});
if minDots < 1 
    bw = M4 > quantile(nonzeros(M4),minDots);
else
    bw = M4 > minDots;
end
    
props3D = regionprops(bw,M4,'WeightedCentroid','Area','PixelValues','PixelList'); 
[maxVolume,mainReg] = max([props3D.Area]);

xyz = props3D(mainReg).PixelList;
xyz(:,1) = xyz(:,1)- props3D(mainReg).WeightedCentroid(1);
xyz(:,2) = xyz(:,2)- props3D(mainReg).WeightedCentroid(2);
xyz(:,3) = xyz(:,3)- props3D(mainReg).WeightedCentroid(3);
m = double(props3D(mainReg).PixelValues); 
mI3 = m'*((xyz(:,1)*bins(1)).^2+(xyz(:,2)*bins(2)).^2+(xyz(:,3)*bins(3)).^2)/sum(m);

unitVolume = diff(xrange)/bins(1) * diff(yrange)/bins(2) * diff(zrange)/bins(3);
maxVolume = maxVolume*unitVolume; 


    