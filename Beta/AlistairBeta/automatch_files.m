

function [fnames,froots] = automatch_files(pathin,varargin)
%--------------------------------------------------------------------------
% fnames = automatch_files(pathin)
% [froots,fnames] = auotmatch_files(pathin, 'sourceroot',value, 
%       'filetype',value,'chns',value)        
% Automatically match up fileroots into multicolor datasets.  Trailing
% image numbers are used to identify different color channels of the same
% field of view.  Leading numbers specified by the parameter 'chns' are
% used to distinguish the different colors. 
% This last part could be optional, all images with the same number could
% be made as different color channels.  However that might be less robust,
% since many folders may have different image roots which restart the
% index number.  
%--------------------------------------------------------------------------
% Necessary Inputs
%   folder / string / 'C:/Data/STORM'
%               -- directory containing files to be sorted.  (e.g.
%               list.bin files)
%--------------------------------------------------------------------------
% Outputs
%   fnames / cell
%               -- cell of size N-channels by M-image positions.  Images
%               with data in only one channel will have an entry in only
%               one row.  Each cell contains the root of the filename.        
%   froots /cell    
%               -- identical to fnames but with the filetype ending
%               stripped.
%--------------------------------------------------------------------------
% Variable Inputs (Flag, data type,(default)):
% 'sourceroot', string, ''
%                  -- files must contain this string in their name to be
%                  loaded.  
% 'filetype', string, _list.bin
%                  -- Files must end with this string to be loaded.  
% 'chns', string, {'750','647','561','488'}
%                 -- Each color channel starts with this.
%
%--------------------------------------------------------------------------
% Alistair Boettiger
% boettiger.alistair@gmail.com
% October 10th, 2012
%
% Version 1.0
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
sourceroot = ''; 
filetype = '_list.bin';
chns = {'750','647','561','488'};

%--------------------------------------------------------------------------
% Parse mustHave variables
%--------------------------------------------------------------------------
if nargin < 1
   error([mfilename,' expects 1 inputs, filepathin']);
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
            case 'sourceroot'
                sourceroot = parameterValue;
                if ~ischar(sourceroot) 
                    error(['Not a valid value for ' parameterName]);
                end
                
            case 'filetype'
                filetype = parameterValue;
                if strcmp(filetype,'list.bin')
                    error(['Not a valid value for ' parameterName]);
                end
                
            case 'chns'
                chns = parameterValue;
                if ~iscell(chns)
                    error(['Not a valid value for ' parameterName]);
                end
         
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end

%--------------------------------------------------------------------------
% Main code
%--------------------------------------------------------------------------

Cs = length(chns); 

datname = cell(Cs,1); 
cSections = zeros(Cs,1); 
for c = 1:Cs
chn = chns{c}; 
    datname{c} = dir([pathin,filesep,chn,'*',sourceroot,'*',filetype]);
    cSections(c) = length(datname{c});
    disp([num2str(cSections(c)),' chn ',chn ,' datasets found in folder ', pathin]);
end

fnames = cell(Cs,max(cSections));
froots =  cell(Cs,max(cSections));
% Sort all data into cell array where each column contain the same position
% (image) in different color channels.  # of rows = # of color channels in
% image dataset.  
i=0;
for c=1:Cs
    chn = chns{c};
    allentered = fnames(:); % keep track of which names are already in list
    for k=1:cSections(c) % 
        % First check to see if this name already exists in list
        daxrt_temp = datname{c}(k).name; % Name
        m = cellfun(@(x) strfind(x,daxrt_temp), allentered,'UniformOutput',false);  % search in all already entered
        m = find(cellfun(@isempty,m)==false, 1); % linear index of entered variable [Matlab suggested faster way]?
        if isempty(m) % If it HAS NOT been already entered
            i=i+1; % Go to new column
            fnames{c,i} = daxrt_temp; % regexprep(,filetype,''); % Record the name without the nameflag (e.g. '_list.bin') part 
            rt = regexprep(datname{c}(k).name,chn,''); % Get the file root
            rt = regexprep(rt,filetype,'');  
            froots{c,i} = regexprep(daxrt_temp,filetype,'');
            cs = 1:Cs;  cs(c) = []; % look at all OTHER channels
            for cc=cs % Find the channel root in any other channel
                other_rt = regexprep( {datname{cc}.name},chns(cc),'');
                other_rt = regexprep( other_rt,filetype,'');
                m = cellfun(@(x) strmatch(x,rt,'exact'),other_rt ,'UniformOutput',false); 
                m = find(cellfun(@isempty,m)==false);
                if ~isempty(m) % If found, enter it in this row. Strip of the filetype first _list.bin or _mlist.bin
                    fnames{cc,i} = datname{cc}(m).name;
                    froots{cc,i} = regexprep(datname{cc}(m).name,filetype,'');
                end 
            end
        end
    end
end
 % load('C:\Users\Alistair\Documents\Projects\General_STORM\Test_data\test.mat');
