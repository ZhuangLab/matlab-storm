function fighand = cdfplotall(data,varargin)

%--------------------------------------------------------------------------
%% Default Parameters
%--------------------------------------------------------------------------
groupnames = repmat({''},length(data),1); 
clrmap = 'hsv';
fighand = [];
xlab = '';

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

N = length(data); 
gnames = cell(N,1); 
cmap =eval([clrmap,'(N+1)']);
for g=1:N
    if ~isempty(data{g})
        [f,x]=ecdf(data{g}); 
        gnames{g} = [groupnames{g},' N=',num2str(length(data{g}))];
        stairs(x,f,'color',cmap(g,:),'linewidth',3);
    else
        plot(0,0,'.','color',cmap(g,:));
        gnames{g} = '';
    end
    hold on;
end
try
legend(gnames,'Location','Best');
catch er
    disp(er.message);
end
xlabel(xlab);
PresentationPlot('LineWidth',0);


