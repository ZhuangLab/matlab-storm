function mlist = MultiChnDriftCorrect(mlist,varargin)
%--------------------------------------------------------------------------
%  mlist  = MultiChnDriftCorrect(mlist)
%
%--------------------------------------------------------------------------
% Necessary Inputs
% mlist / cell 
%           -- cell of mlists in updated* insight format.  Class is
%                changed so that each color is in a separate class
%               (1,2,3,4).  *Updated insight format is mlist.x(allmols)
%               istead of mlist(allmols).x.
%--------------------------------------------------------------------------
% Outputs
%   mlist  -- cell of mlists in updated* insight format.  Class is
%                changed so that each color is in a separate class
%               (1,2,3,4).  *Updated insight format is mlist.x(allmols)
%               istead of mlist(allmols).x.
%
%--------------------------------------------------------------------------
% Variable Inputs (Flag, data type,(default)):
% 'verbose', logical, true
%--------------------------------------------------------------------------
% Alistair Boettiger
% boettiger.alistair@gmail.com
% January 27th, 2013
%
% Version 3.0
%
%--------------------------------------------------------------------------
% Version update information
% version 2.0 January 27th, 2013
% 
%--------------------------------------------------------------------------
% Creative Commons License 3.0 CC BY  
%--------------------------------------------------------------------------



%--------------------------------------------------------------------------
% Default Variables: Define variable input variables here
%--------------------------------------------------------------------------
correctDrift = true;
verbose = true;
npp = 160;
%--------------------------------------------------------------------------
% Parse mustHave variables
%--------------------------------------------------------------------------
if nargin < 1
   error([mfilename,' expects input: cell of binnames']);
end


%--------------------------------------------------------------------------
% Parse variable input
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
            case 'correctDrift'
                correctDrift = CheckParameter(parameterValue,'boolean','correctDrift'); 
            case 'verbose'
                verbose = CheckParameter(parameterValue,'boolean','verbose');  
            case 'npp'
                npp = ChecParameter(parameterValue,'positive','npp');
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end

%--------------------------------------------------------------------------
% Main code
%--------------------------------------------------------------------------

%% Load all the molecule lists for this section 
if correctDrift
    numChns = length(mlist);
    drift_xi = zeros(1,numChns);
    drift_yi = zeros(1,numChns);   
    for c = 1:length(mlist);
        drift_xi(c) = mlist{c}.xc(end) - mlist{c}.x(end);
        drift_yi(c) = mlist{c}.yc(end) - mlist{c}.y(end); 
        drift_xT = sum([0,drift_xi(1:c-1)]);
        drift_yT = sum([0,drift_yi(1:c-1)]);
        mlist{c}.xc = mlist{c}.xc - drift_xT;
        mlist{c}.yc = mlist{c}.yc - drift_yT;
        if verbose
             disp(['corrected global drift of ',num2str(drift_xT*npp,3),' nm in X']); 
             disp(['corrected global drift of ',num2str(drift_yT*npp,3),' nm in Y']); 
        end
    end
end



        