
function mlist = MultiChnDriftCorrect(binnames,varargin)
%--------------------------------------------------------------------------
%  mlist  = MultiChnDriftCorrect(binnames)
%
%--------------------------------------------------------------------------
% Necessary Inputs
% binnames / cell 
%               -- contains full pathname of binfiles to be loaded
%--------------------------------------------------------------------------
% Outputs
%   mlist  -- cell of mlists in updated* insight format.  Class is
%                changed so that each color is in a separate class
%               (1,2,3,4).  *Updated insight format is mlist.x(allmols)
%               istead of mlist(allmols).x.
%
%--------------------------------------------------------------------------
% Variable Inputs (Flag, data type,(default)):
% 'correctDrift', logical, true.
%                  -- Use first channel initial position as baseline for
%                  drift correction of all channels? 
% 'saveGlobalDrift', logical, false
%                  -- save new drift txt file that has the corrected global
%                  drift.  
% 'verbose', logical, true
%--------------------------------------------------------------------------
% Alistair Boettiger
% boettiger.alistair@gmail.com
% January 27th, 2013
%
% Version 2.0
%
%--------------------------------------------------------------------------
% Version update information
% 
%--------------------------------------------------------------------------
% Creative Commons License 3.0 CC BY  
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Hardcoded Variables
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Global Variables
%--------------------------------------------------------------------------
% global myGlobalVariable;


%--------------------------------------------------------------------------
% Default Variables: Define variable input variables here
%--------------------------------------------------------------------------
saveGlobalDrift = false; 
correctDrift = true;
verbose = true;
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
            case 'saveGobalDrift'
                saveGlobalDrift = CheckParameter(parameterValue,'boolean','saveGlobalDrift');
            case 'verbose'
                verbose = CheckParameter(parameterValue,'string','verbose');                
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end

%--------------------------------------------------------------------------
% Main code
%--------------------------------------------------------------------------

%% Load all the molecule lists for this section 
 
    % initialize variables
Cs = length(binnames);     
mlist = cell(Cs,1);
mdrift = cell(Cs,1);

for c = 1:length(binnames);
%  Read in mlist from binfile 
     mdrift{c} = zeros(4,1); % if previous files are missing this prevents Global Drift correction from creating a fatal error
     if verbose
        disp(['loading ',binnames{c}, '...']); 
     end
     try  
        mlist{c} = ReadMasterMoleculeList(binnames{c},'verbose',verbose);
        if verbose
            disp('file loaded'); 
        end
     catch er
        disp(er.message)
        disp('error: could not find file...');
        continue
     end
     
     %   Apply drift correction in x-and-y.
     
     drift_xT = 0;
     drift_yT = 0;
     
     if correctDrift == 1;
            drift_xT = mlist{c}.xc(end) - mlist{c}.x(end) + drift_xT;
            drift_yT = mlist{c}.yc(end) - mlist{c}.y(end) + drift_yT; 
            mlist{c}.xc = mlist{c}.xc - drift_xT;
            mlist{c}.yc = mlist{c}.yc - drift_yT;
     end
        
 end % end loop over channels
        