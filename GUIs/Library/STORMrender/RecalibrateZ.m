function newlist = RecalibrateZ(vlist,parsfile,varargin)
%%  newlist = RecalibrateZ(vlist,parsfile)
% applies the z calibration indicated by parameter file parsfile to the
% molecule list vlist and returns an updated molecule list. 

showPlots = false; 
showExtraPlots = false;
%--------------------------------------------------------------------------
%% Parse variable input
%--------------------------------------------------------------------------
if nargin > 2
    if (mod(length(varargin), 2) ~= 0 ),
        error(['Extra Parameters passed to the function ''' mfilename ''' must be passed in pairs.']);
    end
    parameterCount = length(varargin)/2;
    for parameterIndex = 1:parameterCount,
        parameterName = varargin{parameterIndex*2 - 1};
        parameterValue = varargin{parameterIndex*2};
        switch parameterName
            case 'showPlots'
                showPlots = CheckParameter(parameterValue,'boolean','showPlots');
            case 'showExtraPlots'
                showExtraPlots = CheckParameter(parameterValue,'boolean','showExtraPlots');
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end
%%
%  vlist = CC{1}.vlists{2};
%   parsfile = 'R:\2014-01-20_ANTC\647STORM2pars.xml';
%  parsfile = 'J:\2014-01-08_BXC\647daoPars.xml';
%  parsfile = 'Q:\2013-12-28_F12F11\Beads\647zcal_0001_zpars.xml'; 

parsflag = parsfile(end-3:end);
if strcmp(parsflag,'.xml');
    zpars_names = {
        '<wx_wo type="float">',...  wx0
        '<wx_c type="float">',...  gx
        '<wx_d type="float">',...  zrx
        '<wxA type="float">',...  Ax
        '<wxB type="float">',... Bx
        '<wy_wo type="float">',...  wy0
        '<wy_c type="float">',...  gy
        '<wy_d type="float">',...  zry
        '<wyA type="float">',...  Ay
        '<wyB type="float">',... By
        } ; 
   zpars_values = read_parameterfile(parsfile,zpars_names);
   zpars.wx0 = str2double(zpars_values{1});
   zpars.gx = str2double(zpars_values{2});
   zpars.zrx = str2double(zpars_values{3});
   zpars.Ax = str2double(zpars_values{4});
   zpars.Bx = str2double(zpars_values{5});
   zpars.wy0 = str2double(zpars_values{6});
   zpars.gy = str2double(zpars_values{7});
   zpars.zry = str2double(zpars_values{8});
   zpars.Ay = str2double(zpars_values{9});
   zpars.By = str2double(zpars_values{10});
end

wx = vlist.w ./ vlist.ax;   % /
wy = vlist.w .* vlist.ax;  % *
zdata = vlist.zc;
z = -1000:1000;

curveWx = zpars.wx0*sqrt( zpars.Bx*((z-zpars.gx)./zpars.zrx).^4 + ...
    zpars.Ax*((z-zpars.gx)./zpars.zrx).^3 + ((z-zpars.gx)./zpars.zrx).^2 + 1 )';
curveWy = zpars.wy0*sqrt( zpars.By*((z-zpars.gy)./zpars.zry).^4 + ...
    zpars.Ay*((z-zpars.gy)/zpars.zry).^3 + ((z-zpars.gy)./zpars.zry).^2 + 1 )';

% Compute new z positions
N = length(wx);
new_z = zeros(N,1);
for n=1:N
  [~,i] = min( (wx(n).^.5 - curveWx.^.5).^2 + (wy(n).^.5 - curveWy.^.5).^2 );
  new_z(n) = z(i); 
end

if showPlots
    figure(1); clf; plot(zdata,new_z,'k.'); axis image;
    set(gca,'color','w');
    xlabel('original z values');
    ylabel('recomputed z values'); 
end

if showExtraPlots
   figure(2); hold on; colordef white;
   plot(z,curveWx,'k'); hold on;
   plot(z,curveWy,'k');
   clrmap = jet(100);
   for n=1:N
       clr = round(100*(new_z(n)+1000)/2000)+1;
       plot(zdata(n),wx(n),'.','color',clrmap(clr,:));
       plot(zdata(n),wy(n),'.','color',clrmap(clr,:));
        plot(new_z(n),wx(n),'o','color',clrmap(clr,:));
        plot(new_z(n),wy(n),'o','color',clrmap(clr,:));
   end
   set(gca,'color','w');
   
   figure(13); clf; hist(zdata);
   
end

newlist = vlist;
newlist.z = new_z;
newlist.zc = new_z;

