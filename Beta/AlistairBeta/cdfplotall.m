function cdfplotall(data,varargin)
%--------------------------------------------------------------------------
% generate a cumulative density function plots fo cell data
% 
%--------------------------------------------------------------------------
% cdfplotall(data)       -- histograms of the data in each cell of data
% cdfplotall(data,bins)  -- histograms of the data in each cell of data
% cdfplotall(data,x)     -- break data evenly into x bins
% cdfplotall(...,'groupnames',cell) -- cell of names for figure legend
% cdfplotall(...,'xlabel',string)   -- string for xlabel
% cdfplotall(...,'alpha',alphavalue) -- zero for alpha off
% cdfplotall(...,'colormap',colormap-name) -- colormap (e.g. 'hsv')
%--------------------------------------------------------------------------
% Alistair Boettiger
% CC BY 04/25/13
%--------------------------------------------------------------------------
% 

%--------------------------------------------------------------------------
%% Default Parameters
%--------------------------------------------------------------------------
groupnames = repmat({''},length(data),1); 
clrmap = 'jet';
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
                clrmap =parameterValue ; % string name of colormap or a colormap matrix.
            otherwise
                error(['The parameter ''', parameterName,...
                    ''' is not recognized by the function, ''',...
                    mfilename '''.' '  See help ' mfilename]);
        end
    end
end



%--------------------------------------------------------------------------
%% Main function
%--------------------------------------------------------------------------

% If data is a matrix, convert it to a cell-array
% If NaNs are used to pad variable length entries, strip these out. 
if ~iscell(data)
    [N,~] = size(data);
    data2 = cell(N,1); 
    for d=1:N
        nnan = logical(true - isnan(data(d,:)));
        data2{d} = data(d,nnan);
    end
    data = data2; 
end

N = length(data); 
gnames = cell(N,1); 
if ischar(clrmap)
    cmap =eval([clrmap,'(N)']);
else
    cmap = clrmap;
end

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


