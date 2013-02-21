
function fighand = normhistall(data,x,varargin)

%--------------------------------------------------------------------------
%% Default Parameters
%--------------------------------------------------------------------------
groupnames = cell(length(data),1); 
clrmap = 'hsv';
fighand = [];

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
            case 'groupnames'
                groupnames = CheckParameter(parameterValue, 'cell', 'groupnames');
            case 'xlabel'
                xlab = CheckParameter(parameterValue, 'string', 'xlabel');
            case 'colormap'
                clrmap = CheckParameter(parameterValue,'string','colormap'); 
            case 'fighandle'
                fighand= CheckParameter(parameterValue, 'positive', 'fighandle');
            otherwise
                error(['The parameter ''', parameterName,...
                    ''' is not recognized by the function, ''',...
                    mfilename '''.' '  See help ' mfilename]);
        end
    end
end

if isempty(fighand)
    fighand = figure; clf;
else
    figure(fighand); 
end

%--------------------------------------------------------------------------
%% Main function
%--------------------------------------------------------------------------

D = length(data);
for d=1:D
    h1 = hist(data{d},x);
    hnorm = sum(h1);
    bar(x,h1/hnorm,1);
    hold on;
end
 legend_hand = legend(groupnames);
 lh = findobj(legend_hand,'Type','patch');
 h = findobj(gca,'Type','patch');

cmap =eval([clrmap,'(D+1)']);
for d=1:D
    set(h(D-d+1),'FaceColor',cmap(d,:),'EdgeColor',cmap(d,:),'LineWidth',2);
    set(lh(D-d+1),'FaceColor',cmap(d,:),'EdgeColor',cmap(d,:));
end
xlim([min(x),max(x)]);
xlabel(xlab);
alpha .15;
PresentationPlot('LineWidth',0);

