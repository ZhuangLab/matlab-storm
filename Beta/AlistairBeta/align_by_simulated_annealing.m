function TData = align_by_simulated_annealing(Data,varargin)
%--------------------------------------------------------------------------
% TData = align_by_simulated_annealing(Data)
%           Align the curves specivied by the rows of Data by translating 
%--------------------------------------------------------------------------
% Inputs: 
% Data / Matrix NxM
%                 Matrix of N curves by M data-points. 
%--------------------------------------------------------------------------
% Outputs:
% TData / Matrix Nx2*M
%                Matrix of N curves shifted in column number such that the
%                standard deviation of the columns of TData is minimized.
%--------------------------------------------------------------------------
% Optional Inputs
% 'Rounds' / integer / 20
%                   -- number of rounds of annealing to try
% 'Shifts' / integer / 30
%                   -- number of shifts left and right to sample before
%                   temperature is dropped.  Increase this for large N. 
%                   Decrease for small N. 
% 'PlotProgress' / logical / true
%                   -- show dynamic plot of curves being aligned;  

%--------------------------------------------------------------------------
% Define default parameters
%--------------------------------------------------------------------------
T = 20; % number of shifts to try
K = 30; % number of rounds of annealing
PlotProgress = true; 
Cooling = 'inv';
InitShift = ''; 
%--------------------------------------------------------------------------
%% Parse mustHave variables
%--------------------------------------------------------------------------
if nargin < 1
   error([mfilename,' expects at least 1 input, daxfile']);
end

%--------------------------------------------------------------------------
%% Parse Variable Input Arguments
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
            case 'Rounds'
                K = CheckParameter(parameterValue, 'positive', 'Rounds');
            case 'Shifts'
                T = CheckParameter(parameterValue, 'positive', 'Shifts');
            case 'InitShift'
                InitShift = CheckParameter(parameterValue, 'positive', 'InitShift');
            case 'Cooling'
                Cooling = CheckList(parameterValue,{'exp','inv','linear'}, 'Cooling');
            case 'PlotProgress'
                PlotProgress  = CheckParameter(parameterValue, 'boolean', 'PlotProgress');
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.' '  See help ' mfilename]);
        end
    end
end


%%

[N,M] = size(Data); 
Data = [NaN*ones(N,floor(M/2)),Data,NaN*ones(N,floor(M/2))];
[~,P] = size(Data);

if isempty(InitShift)
    InitShift = M/3;
end


if PlotProgress
    fig = figure;
end

% Compute all our random numbers in 1 go, rather than inside a loop.
% also makes it easier to specify different cooling functions.  
if strcmp(Cooling,'linear')
    shifts = meshgrid(fliplr(1:K)*InitShift/K,1:T,1:N);
    shifts = shifts.*(rand(T,K,N)-.5)*2;
elseif strcmp(Cooling,'inv')
    shifts = meshgrid(InitShift./(1:K),1:T,1:N);
    shifts = shifts.*(rand(T,K,N)-.5)*2;
elseif strcmp(Cooling,'exp')
    shifts = meshgrid(InitShift*exp(-(linspace(0,K,K))),1:T,1:N);
    shifts = shifts.*(rand(T,K,N)-.5)*2;
end
shifts = round(shifts);
% figure(1); clf; pcolor(shifts(:,:,1)); colormap jet; colorbar;


for k=1:K  
% try T random shifts, record the fit error for each   
%-----------------------------------------------------
    S = zeros(T,N); 
    err = NaN*ones(1,T);
    for t=1:T
        TData = zeros(N,P); 
        for n = 1:N % looping over our different curves
            s = shifts(t,k,n);
           if s < 0 % shift to the right
               sn = abs(s); 
            TData(n,:) = [NaN*ones(1,sn), Data(n,1:end-sn)]; 
           else % shift to the left 
            TData(n,:) = [Data(n,1+s:end), NaN*ones(1,s)];
           end
           S(t,n) = s; % Record all shifts attempted
        end % end loop over different curves
           err(t) = nansum(nanstd(TData));  % compute error for that set of shifts
    end
    [~,ind] = min(err);

% Apply the optimal shift to all data, then loop back and drop the shift size ('temperature');    
%---------------------------------------------------------------
    % Find coordinates of optimal shift
     s_star  = S(ind,:); 
     for n = 1:N % looping over our different curves
           s = s_star(n); % scalar, to shift each curve
           if s < 0 % shift to the right
               sn = abs(s); 
            TData(n,:) = [NaN*ones(1,sn), Data(n,1:end-sn)]; 
           else % shift to the left 
            TData(n,:) = [Data(n,1+s:end), NaN*ones(1,s)];
           end
     end % end loop over different curves

        % nansum(nanstd(TData));
    if PlotProgress
        figure(fig); clf;
        colordef white; 
        set(gcf,'color','white'); 
        plot(TData','.','MarkerSize',1); pause(.0001); 
    end
    Data = TData; 
end