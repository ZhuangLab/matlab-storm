function [wx,wx_fit] = FitZcurve(zz,Wi,varargin)


%--------------------------------------------------------------------------
%% Default parameters
%--------------------------------------------------------------------------
maxOutlier = 300;
endTrim = .1;
maxWidth = 1500; 
PlotsOn = false; 
wx_fit = []; 
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

            
 L = length(Wi);
ends = false(L,1); ends([1:round(endTrim*L),round((1-endTrim)*L):L]) = true;
toExclude = ends | Wi>maxWidth | zz<-1000 | zz>1000;
wx_fit0 = fit(zz,Wi,ftype0,'StartPoint',[ 300  450  -240 ],...
    'Lower',[250 -600 -1000],'Upper',[650,600,1000],...
    'Exclude',toExclude); % Expect curve to be near w0=300, zr=400 gx=-240;

% wx_fit0 = fit(zz,Wi,ftype,'StartPoint',[ 300  450  -240 0 0],...
%     'Lower',[100 -600 -1000 -2 -2],'Upper',[650,600,1000,0,0],...
%     'Exclude',ends | Wi>maxWidth); 


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
try
    cI = confint(wx_fit0);
     wx_fit = fit(zz,Wi,ftype,'StartPoint',[ wx_fit0.w0  wx_fit0.zr  wx_fit0.g  0 0],...
          'Lower',[cI(1,1)-150 cI(1,2)-150 cI(1,3)-150 -2 -2],...
          'Upper',[cI(2,1)+150,cI(2,2)+150,cI(2,3)+150,2,2],...
          'Exclude',outliers | zz< -1000 | zz>1000,'Robust','Bisquare'); %  
%     wx_fit = fit(zz,Wi,ftype,'StartPoint',[ wx_fit0.w0  wx_fit0.zr  wx_fit0.g  0 0],...
%          'Lower',[100 -1000 -1000 -2 -2],'Upper',[450,1000,1000,2,2],'Exclude',outliers); % 
    wx = feval(wx_fit,zz);
    if PlotsOn; 
       figure(4);  plot(zz,wx);
       pause(.1); 
    end
    cI = confint(wx_fit);
    if abs(cI(1,1) - cI(2,1)) > 100 || abs(cI(1,2) - cI(2,2)) > 300
        wx = NaN*ones(L,1);  
    end
    
catch
    wx = NaN*ones(L,1);  
end




