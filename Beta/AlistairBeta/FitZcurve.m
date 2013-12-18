function [wx,wx_fit] = FitZcurve(zz,Wi,varargin)


%--------------------------------------------------------------------------
%% Default parameters
%--------------------------------------------------------------------------
maxOutlier = 300;
endTrim = .1;
maxWidth = 1500; 
PlotsOn = false; 
wx_fit = []; 
w0Range = [100,600];
zrRange = [100,700];
gRange = [-600,600];
w0Conf = 100;
zrConf = 200;

%--------------------------------------------------------------------------
%% Parse mustHave variables
%--------------------------------------------------------------------------
if nargin < 2
   error([mfilename,' expects at least 2 inputs, daxfile and parsfile']);
end

%--------------------------------------------------------------------------
%% Parse Variable Input Arguments
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
            case 'maxOutlier'
                maxOutlier = CheckParameter(parameterValue, 'positive', 'maxOutlier');
            case 'PlotsOn'
                PlotsOn = CheckParameter(parameterValue, 'boolean', 'PlotsOn');
            case 'endTrim'
                endTrim = CheckParameter(parameterValue, 'positive', 'endTrim');
            case 'maxWidth'
                maxWidth = CheckParameter(parameterValue, 'positive', 'maxWidth');
            case 'w0Range'
                w0Range = CheckParameter(parameterValue, 'array', 'w0Range');
            case 'zrRange'
                zrRange = CheckParameter(parameterValue, 'array', 'zrRange');
            case 'gRange'
                gRange = CheckParameter(parameterValue, 'array', 'gRange');
            case 'zrConf'
                zrConf = CheckParameter(parameterValue, 'positive', 'zrConf');
            case 'w0Conf'
                w0Conf = CheckParameter(parameterValue, 'positive', 'w0Conf');
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.' '  See help ' mfilename]);
        end
    end
end

%% Main function

% i = 63;
% [m,k] = min(abs( Wx{i} -Wy{i}));
%  Wi = Wy{i};
%  zz = stagepos{i} - stagepos{i}(k);


%------------ Fitting Functions
% Initial fit to ID and remove outliers
ftype0 = fittype('w0*sqrt( ((z-g)/zr)^2 + 1 ) ',...
                'coeff', {'w0','zr','g'},'ind','z'); 
% Full fit             
ftype = fittype('w0*sqrt( B*((z-g)/zr)^4 + A*((z-g)/zr)^3 + ((z-g)/zr)^2 + 1 )',...
                'coeff', {'w0','zr','g','A','B'},'ind','z');

% initial simple fit to ID outlier points            
L = length(Wi);
ends = false(L,1); ends([1:round(endTrim*L),round((1-endTrim)*L):L]) = true;
toExclude = ends | Wi>maxWidth | zz<-1000 | zz>1000;
wx_fit0 = fit(zz,Wi,ftype0,'StartPoint',[ mean(w0Range)  mean(zrRange)  -240 ],...
    'Lower',[w0Range(1) zrRange(1) gRange(1)],...
    'Upper',[w0Range(2) zrRange(2) gRange(2)],...
    'Exclude',toExclude); % Expect curve to be near w0=300, zr=400 gx=-240;
wx = feval(wx_fit0,zz);
outliers = (abs(Wi - wx) > maxOutlier);

if PlotsOn
    figure(4); clf;
    plot(zz,Wi,'.'); hold on; 
    plot(zz(toExclude),Wi(toExclude),'r+');
    plot(zz,wx,'r');
    plot(zz(outliers),Wi(outliers),'r.');
    ylim([0,2000]); xlim([-1000,1000]);
end

% Full fitting (sometimes fails)
try
   % cI = confint(wx_fit0);
     wx_fit = fit(zz,Wi,ftype,'StartPoint',[ wx_fit0.w0  wx_fit0.zr  wx_fit0.g  0 0],...
          'Lower',[w0Range(1) zrRange(1) gRange(1) -2 -2],...
          'Upper',[w0Range(2) zrRange(2) gRange(2) 2 2],...
          'Exclude',outliers | zz< -1000 | zz>1000,'Robust','Bisquare'); 
    wx = feval(wx_fit,zz);
    if PlotsOn; 
       figure(4);  plot(zz,wx);
       pause(.1); 
    end
    cI = confint(wx_fit);
    if abs(cI(1,1) - cI(2,1)) > w0Conf || abs(cI(1,2) - cI(2,2)) > zrConf
        wx = NaN*ones(L,1);  
    end 
catch
    wx = NaN*ones(L,1);  
end


