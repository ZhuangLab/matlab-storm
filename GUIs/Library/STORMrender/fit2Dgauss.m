function sf = fit2Dgauss(xdata,ydata,varargin)
%--------------------------------------------------------------------------
% sf = fit2Dgauss(xdata,ydata)
% sf - fit2Dgauss(xdata,ydata,'bin',value,'showmap',value)
%--------------------------------------------------------------------------
% Inputs:
% xdata        -- vector of x-coordinates to fit
% ydata        -- vector of y-coordinates to fit
%--------------------------------------------------------------------------
% Outputs:
% sf / sfit    -- basically a structure.  sf.a1 is the height of the
%              gaussian, sf.sigmax/sigmay are the widths, [x0,y0] the 
%              centerrelative to the box defined by min and max of the x,y 
%              data.  entering sf will give back the model and the
%              confidence intervals.  see sfit for more info.
%--------------------------------------------------------------------------
% Optional inputs:
% 'bin' / scalar / 10
%                           -- bin size to use in fitting 
% 'showmap' / logical / true
%                           -- display map of the localizations
%--------------------------------------------------------------------------
% Alistair Boettiger
% boettiger.alistair@gmail.com
% October 10th, 2012
%
% Version 1.0
%--------------------------------------------------------------------------
% Creative Commons License 3.0 CC BY  
%--------------------------------------------------------------------------





%-------------------------------------------------------------------------
%% default inputs
%-------------------------------------------------------------------------
sc = 10; % resolution for binning positions prior to Gaussian fit
showmap = true; % 

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
            case 'showmap'
                showmap = parameterValue;
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end
    
%-------------------------------------------------------------------------
%% Main function
%-------------------------------------------------------------------------   
yint = linspace(min(ydata),max(ydata),sc);
xint = linspace(min(xdata),max(xdata),sc);
    Z = hist3([ydata,xdata],{yint,xint});
    
    if showmap
        figure(2); clf; imagesc(Z);  colormap hot; colorbar;
        xnorm = xdata-min(xdata);
        xscale_fact = 1/max(xnorm); 
        xnorm = .5+xnorm*xscale_fact*sc;
        ynorm = ydata-min(ydata);
        yscale_fact = 1/max(ynorm);
        ynorm = .5+ynorm*yscale_fact*sc;
        hold on;
        plot(xnorm,ynorm,'c.','MarkerSize',1);
    end
    
    [X,Y] = meshgrid(xint,yint);
    X = double(X(:)); Y=double(Y(:)); Z = double(Z(:)); 
    gauss2 = fittype( @(a1, sigmax, sigmay, x0,y0, x, y) a1*exp(-(x-x0).^2/(2*sigmax^2)-(y-y0).^2/(2*sigmay^2)),'independent', {'x', 'y'},'dependent', 'z' );
    sf = fit([X,Y],Z,gauss2,'StartPoint',[max(Z), std(xdata), std(ydata), mean(X), mean(Y)]); 
    
    if showmap
        xc_norm = (sf.x0 -min(xdata))*xscale_fact*sc+.5;
        yc_norm = (sf.y0 -min(ydata))*yscale_fact*sc+.5;
        plot(xc_norm,yc_norm,'g*','MarkerSize',50);
    end
    
    
    
