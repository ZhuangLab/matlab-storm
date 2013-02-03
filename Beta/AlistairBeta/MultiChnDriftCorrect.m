
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
                correctDrift = checkParameter(parameterValue,'boolean','correctDrift'); 
            case 'saveGobalDrift'
                saveGlobalDrift = checkParameter(parameterValue,'boolean','saveGlobalDrift');
            case 'verbose'
                verbose = checkParameter(parameterValue,'string','verbose');                
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
     if correctDrift == 1;
        fname = regexprep(binnames{c},'_list.bin',''); % remove list.bin
        fname = regexprep(fname,'_mlist.bin',''); % in case data is from DaoSTORM 
        driftfile = [fname,'_drift.txt'];
        if verbose
            disp(['reading file ',driftfile]);
        end
        fid = fopen(driftfile);
        dr = fscanf(fid, '%g %g %g %g', [4 inf]);
        fclose(fid);
        mdrift{c} = zeros(4,length(dr));
        if c==1 % first channel just record drift
            mdrift{c}(1,:) = dr(1,:);
            mdrift{c}(2,:) = dr(2,:);
            mdrift{c}(3,:) = dr(3,:);
            mdrift{c}(4,:) = dr(4,:); 
        else % other channels add final drift point of previous channel to start point of this channel,
            % this makes all measurements relative to the initial position of the whole section.     
                % try
                % save('C:\Users\Alistair\Documents\Projects\General_STORM\Test_data\test.mat');
                 % load('C:\Users\Alistair\Documents\Projects\General_STORM\Test_data\test.mat');
                mdrift{c}(1,:) = dr(1,:);
                mdrift{c}(2,:) = dr(2,:)+ mdrift{c-1}(2,end);
                mdrift{c}(3,:) = dr(3,:)+ mdrift{c-1}(3,end);
                mdrift{c}(4,:) = dr(4,:)+ mdrift{c-1}(4,end);
                
                if saveGlobalDrift
                    % write global drift correction to disk
                    fid = fopen([fname,'_GlobalDrift.txt'],'w+'); % make text document for writing. overwrite if existing
                    fprintf(fid, '%g %g %g %g\r\n', mdrift{c});
                    fclose(fid);
                end
        end   
        clear dr; 
        
        if  c~=1 % don't change for the first channel
            % use conncatinated drift correction
            
            % save('C:\Users\Alistair\Documents\Projects\General_STORM\Test_data\test.mat');
            % load('C:\Users\Alistair\Documents\Projects\General_STORM\Test_data\test.mat');
            
            xdrift = mdrift{c}(2,:);
            ydrift = mdrift{c}(3,:);
            mlist{c}.xc = mlist{c}.x - xdrift(mlist{c}.frame)';
            mlist{c}.yc = mlist{c}.y - ydrift(mlist{c}.frame)';       
            
        end
     end
        clear xdrift ydrift  % save memory;
 end % end loop over channels
        