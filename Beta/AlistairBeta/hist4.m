
function M = hist4(x,y,z,varargin)
% create a 3D density plot (3d histogram) from 3D data (x,y,z).  
% bins 
% M is a HxWxN matrix

%-------------------------------------------------------------------------
% Default Parameters
%-------------------------------------------------------------------------
bins = [100,100,100];
datatype = 'uint16';
datarange = cell(1,3); 

%-------------------------------------------------------------------------
% Parse variable input
%-------------------------------------------------------------------------

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
            case 'datatype'
                datatype = CheckParameter(parameterValue, 'string', 'datatype');
            case 'datarange'
                datarange = CheckParameter(parameterValue, 'cell', 'datarange');
            otherwise
                error(['The parameter ''', parameterName,...
                    ''' is not recognized by the function, ''',...
                    mfilename '''.' '  See help ' mfilename]);
        end
    end
end


%-------------------------------------------------------------------------
%% Main Function
%-------------------------------------------------------------------------

% bins = [128,128,30]
% datarange = {xrange,yrange,zrange}
% x = vlist.xc*npp; y=vlist.yc*npp; z=vlist.z;         

[rx,ry,rz] = datarange{:};

xbins = bins(1);
ybins = bins(2);
zbins = bins(3);

if isempty(rz)
    rz = [min(z),max(z)]; % range of z
end
if isempty(ry)
    ry = [min(y),max(y)];
end
if isempty(rx)
    rx = [min(x),max(x)];
end

Zs = linspace(rz(1),rz(2),zbins);
Ys = linspace(ry(1),ry(2),ybins);
Xs = linspace(rx(1),rx(2),xbins);
Zs = [Zs,inf];

M = zeros(xbins,ybins,zbins,datatype); 
for i=1:zbins % i=6
    inplane = z>Zs(i) & z<Zs(i+1);
    yi = y(inplane);
    xi = x(inplane);
    M(:,:,i) = hist3([yi,xi],{Ys,Xs});
end


%    [~,~,zs] = size(M);
%         figure(10);
%         k=0;
%         for j=1:zs
%             k=k+1;
%             subplot(6,6,k); imagesc(M(:,:,j));
%         end
%         

