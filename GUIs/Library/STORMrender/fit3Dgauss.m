
function fpars = fit3Dgauss(xdata,ydata,zdata,varargin)
% sf = fit3Dgauss(xdata,ydata)
% sf = fit3Dgauss(xdata,ydata,'bin',value,'showmap',value)
%-------------------------------------------------------------------------
% Inputs:
% xdata        -- vector of x-coordinates to fit
% ydata        -- vector of y-coordinates to fit
%-------------------------------------------------------------------------
% Outputs:
% fpars   -- fit parameters: x_0, y_0, z_0, sigma_x, sigma_y, sigma_z, a1
%             g(x,y,z) = a1*exp( -(x-x0).^2/(2*sigmax^2)
%                                -(y-y0).^2/(2*sigmay^2)
%                                -(z-z0).^2/(2*sigmaz^2) );
%
%-------------------------------------------------------------------------
% Optional inputs:
% 'bin' / scalar / 10                -- bin size to use in fitting 
% 'showplot' / logical /false        -- plot scatter and centroid
%--------------------------------------------------------------------------
% Alistair Boettiger
% boettiger.alistair@gmail.com
% February 19th, 2013
%
% Version 1.0
%--------------------------------------------------------------------------
% Creative Commons License 3.0 CC BY  
%--------------------------------------------------------------------------
% Notes:
% this funcution requires custom function hist4
%
%--------------------------------------------------------------------------




%-------------------------------------------------------------------------
%% default inputs
%-------------------------------------------------------------------------
sc = 50; % resolution for binning positions prior to Gaussian fit
showplot = false;
%--------------------------------------------------------------------------
%% Parse variable input
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
            case 'bin'
                sc = parameterValue;  
            case 'showplot'
                showplot = parameterValue;
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end
   
% xdata = xp;
% ydata = yp;
% zdata = zp;

%-------------------------------------------------------------------------
%% Main function
%-------------------------------------------------------------------------   
xint = linspace(min(xdata),max(xdata),sc);
yint = linspace(min(ydata),max(ydata),sc);
zint = linspace(min(zdata),max(zdata),sc); 
Gin = hist4(xdata,ydata,zdata,'bins',[sc,sc,sc]);


        
[X,Y,Z] = meshgrid(xint,yint,zint);
X = X(:); Y=Y(:); Z = Z(:); G = double(Gin(:)); 
fpars = nlinfit([X,Y,Z],double(G),@gauss3,[mean(xdata),mean(ydata),mean(zdata),std(xdata),std(ydata),std(zdata),max(G)]); 
 
if showplot
    figure;
    plot3(xdata,ydata,zdata,'k.','MarkerSize',1);
    hold on; plot3(fpars(1),fpars(2),fpars(3),'r.','MarkerSize',30);
end

function g = gauss3(pars,vars)
    x0=pars(1);
    y0=pars(2);
    z0=pars(3);
    sigmax=pars(4);
    sigmay=pars(5);
    sigmaz=pars(6);
    a1=pars(7);
    x = vars(:,1);
    y = vars(:,2);
    z = vars(:,3);
  g =  a1*exp( -(x-x0).^2/(2*sigmax^2)   -(y-y0).^2/(2*sigmay^2)  -(z-z0).^2/(2*sigmaz^2));

    
