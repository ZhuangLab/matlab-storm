function BoxPlot2D(x,data,varargin)
% BoxPlot2D(x,d) 
% generates a box plot for the data in each cell entry of d{i}, plotted at
% position x(i).
%
%--------------------------------------------------------------------------
% Optional Inputs
% 'width' / double / .03
% 'datanames' / cell / {}
% 'clrmap' / string or colormap
% 'showdots' / boolean / false
% 'MarkerSize' / double / 5

%% Main Function

%% Default parameters
width = .03;
clrmap = [];
datanames = {};
showdots = false;
MarkerSize = 5;


%--------------------------------------------------------------------------
%% Parse Variable Input Parameters
%--------------------------------------------------------------------------
if nargin > 1
    if (mod(length(varargin), 2) ~= 0 ),
        error(['Extra Parameters passed to the function ''' mfilename ''' must be passed in pairs.']);
    end
    parameterCount = length(varargin)/2;

    for parameterIndex = 1:parameterCount,
        parameterName = varargin{parameterIndex*2 - 1};
        parameterValue = varargin{parameterIndex*2};
        switch parameterName
            case 'width'
                width = CheckParameter(parameterValue,'fraction','width');
            case 'datanames'
                datanames = CheckParameter(parameterValue, 'cell', 'datanames');
            case 'colormap'
                clrmap = CheckParameter(parameterValue,'colormap','colormap') ; % string name of colormap or a colormap matrix.
            case 'showdots'
                showdots = CheckParameter(parameterValue,'boolean','showdots');
            case 'MarkerSize'
                MarkerSize = CheckParameter(parameterValue,'positive','dotsize'); 
            otherwise
                error(['The parameter ''', parameterName,...
                    ''' is not recognized by the function, ''',...
                    mfilename '''.' '  See help ' mfilename]);
        end
    end
end


%--------------------------------------------------------------------------
%% Actual Function
%--------------------------------------------------------------------------

xRange = max(x) - min(x);
numDataTypes = length(data);
w = xRange*width;

if isempty(clrmap)
    clrmap = repmat([0,0,1],numDataTypes,1);
end
if ischar(clrmap)
    try
    clrmap = eval([clrmap,'(numDataTypes)']);
    catch 
       disp([clrmap,' is not a valid colormap name']);  
    end
end

quartiles = zeros(numDataTypes,2);
medians = zeros(numDataTypes,1); 
for i=1:numDataTypes
    quartiles(i,:) = quantile(data{i},[.25,.75]);
    quarts = quantile(data{i},[.25,.75]);
    medians(i) = nanmedian(data{i});
    h = max(1E-16,quarts(2)-quarts(1));
    boxes = [x(i)-w/2,quarts(1),w,h];  
    
    hold on;
    rectangle('Position',boxes,'EdgeColor',clrmap(i,:)); 
    plot(x(i),medians(i),'.','color',clrmap(i,:),'MarkerSize',20);
    if ~isempty(datanames)
        text(x(i)+w,medians(i),datanames{i});
    end
    if showdots
        numPts = length(data{i}); 
        plot( x(i) + xRange*w*.001*(.5-rand(numPts,1)),data{i},'.',...
            'color',clrmap(i,:),'MarkerSize',MarkerSize);
    end
    
end

