
function M = hist4(x,y,z,varargin)
% create a 3D density plot (3d histogram) from 3D data (x,y,z).  
% bins 
% M is a HxWxN matrix



h = max(y)-min(y)+1;
w = max(x)-min(x)+1;

xbins = 100;
ybins = 100;
zbins = 100;

Zs = linspace(min(z),max(z),zbins);
Zs = [Zs,inf];

M = zeros(xbins,ybins,zbins); 
for i=1:zbins
    inplane = z>Zs(i) & z<Zs(i+1);
    yi = y(inplane);
    xi = x(inplane);
    M(:,:,i) = hist3([yi,xi],{linspace(1,h,ybins),linspace(1,w,xbins)});
end


