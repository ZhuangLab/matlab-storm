function ProcessTimeout(processName,varargin)
%--------------------------------------------------------------------------
% ProcessTimeout('RogueProcess.exe','maxTime',TimeInSeconds)
% 

%% default parameters
% processName = 'blastall.exe'
% processName = 'java.exe'
maxTime = 60*30; % max run time in seconds
verbose = false;
veryverbose = false;

%--------------------------------------------------------------------------
% Parse Variable Input Arguments
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
            case 'maxTime'
                maxTime = CheckParameter(parameterValue, 'positive', 'maxTime');
            case 'verbose'
                verbose = CheckParameter(parameterValue,'boolean','verbose');
            case 'veryverbose'
                veryverbose = CheckParameter(parameterValue,'boolean','veryverbose');
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.' '  See help ' mfilename]);
        end
    end
end
%% Main Function

% Notes: 
% date-string is formatted: YYYYMMDDhhmmss

[~,A] = system(['wmic process where name=','"',processName,'"']);

if isempty(strfind(A,'No Instance(s) Available'))
    C = strsplit(A,'\n');

    dateStart = strfind(C{1},'CreationDate');
    dateEnd = strfind(C{1},'CSCreationClassName')-2;
    idStart = strfind(C{1},' ProcessId ');
    idEnd = strfind(C{1},' QuotaNonPagedPoolUsage')-2;
    c = clock; 
    currTime = c(4)*60*60+c(5)*60 + c(6);
    for i=1:length(C)-3
        dateString = C{i+1}(dateStart:dateEnd);
        idString = C{i+1}(idStart:idEnd);
    %     yearS = dateString(1:4); 
    %     monthS = dateString(5:6);
    %     dayS = dateString(7:8);
        hourS = dateString(9:10);
        minS  = dateString(11:12);
        secS = dateString(13:14);
        startTime = str2double(hourS)*60*60+str2double(minS)*60+str2double(secS);
        if veryverbose
            disp([idString 'has been running for ',num2str((currTime-startTime)/60),' min']); 
        end
        if currTime - startTime > maxTime;
            stopProcess = ['wmic process ',idString,' delete '];
            disp(['Analysis exceeded ',num2str(maxTime/60), ' min. ' 'Aborting process ',idString]); 
            dos(stopProcess);
        end
    end
else
if verbose
   disp([processName, ' is not currently running on this Windows machine.']); 
end
end

