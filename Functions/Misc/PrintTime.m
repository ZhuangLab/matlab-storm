function timeString = PrintTime(varargin)
%--------------------------------------------------------------------------
% timeString = PrintTime()
% This function returns a string that contains the current time
%--------------------------------------------------------------------------
% Inputs:
%
%--------------------------------------------------------------------------
% Outputs:
% timeString: A string containing the current time
%
%--------------------------------------------------------------------------
% Jeffrey Moffitt
% May 18, 2013
% jeffmoffitt@gmail.com
%
% Version 1.0
%--------------------------------------------------------------------------
% Creative Commons Liscence
% Attribution-NonCommercial-ShareAlike 3.0 Unported License
% 2013
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Hardcoded Variables
%--------------------------------------------------------------------------
quiet = 0;


%--------------------------------------------------------------------------
% Default Variables
%--------------------------------------------------------------------------
verbose = false;
displayDate = false;

%--------------------------------------------------------------------------
% Parse Required Inputs
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Parse Variable Input
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
            case 'verbose'
                verbose = CheckParameter(parameterValue, 'boolean', 'verbose');
            case 'displayDate'
                displayDate = CheckParameter(parameterValue, 'boolean', 'displayDate');
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end

%--------------------------------------------------------------------------
% Get Time and Format
%--------------------------------------------------------------------------
time = clock;

dateString = [];
if displayDate
    dateString = [num2str(time(2)) '/' num2str(time(3)) '/' num2str(time(1)) ' '];
end
secondString = ['0' num2str(round(time(6)))];
minuteString = ['0' num2str(round(time(5)))];

timeString = [dateString num2str(time(4)) ':' minuteString((end-1):end) ':' secondString((end-1):end)];


