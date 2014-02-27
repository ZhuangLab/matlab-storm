function vlist = msublist(mlist,imaxes,varargin)
% vlist = msublist(mlist,imaxes)
% vlist = msublist(mlist,imaxes,'filter',filter)
%-------------------------------------------------------------------------
%% inputs
%-------------------------------------------------------------------------
% mlist        -- molecule list or cell array of molecule lists.
% imaxes        -- structure containing subregion data.  Required fields:
%               imaxes.xmin
%               imaxes.ymin
%               imaxes.xmax
%               imaxes.ymax
%-------------------------------------------------------------------------
%% Outputs
%-------------------------------------------------------------------------
% vlist         -- small molecule list structure, just for local region
%                specified by imaxes
%-------------------------------------------------------------------------
%% Optional inputs
%-------------------------------------------------------------------------
% 'filter' / logical / all true
%               -- logical vector specifying which molecules to keep.
%               Or cell array of logical vectors (if mlist is a cell array
%               of molecule lists). 
%--------------------------------------------------------------------------
% Alistair Boettiger
% boettiger.alistair@gmail.com
% February 18th, 2013
%
% Version 1.0
%--------------------------------------------------------------------------
% Creative Commons License 3.0 CC BY  
%--------------------------------------------------------------------------





%-------------------------------------------------------------------------
% default inputs
%-------------------------------------------------------------------------
infilter = []; 
%
%--------------------------------------------------------------------------
%% Parse variable input
%--------------------------------------------------------------------------
if nargin > 3
    if (mod(length(varargin), 2) ~= 0 ),
        error(['Extra Parameters passed to the function ''' mfilename ''' must be passed in pairs.']);
    end
    parameterCount = length(varargin)/2;
    for parameterIndex = 1:parameterCount,
        parameterName = varargin{parameterIndex*2 - 1};
        parameterValue = varargin{parameterIndex*2};
        switch parameterName
            case 'filter'
                infilter = parameterValue; % boolean or cell array of booleans 
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end
    
%-------------------------------------------------------------------------
%% Main function
%-------------------------------------------------------------------------   

outputList = false; % 

if ~iscell(mlist)
    outputList = true;
    mlist = {mlist};
    if ~isempty(infilter)
        infilter = {infilter};
    end
end
   
if isempty(infilter)
    infilter = cell(length(mlist),1);
end

vlist = cell(length(mlist),1); 

for i = 1:length(mlist); 
   if isempty(infilter{i})
      infilter{i} =  true(length(mlist{i}.x),1); %#ok<*AGROW>
   end
   
    inbox = mlist{i}.xc >imaxes.xmin & mlist{i}.xc < imaxes.xmax & ...
            mlist{i}.yc >imaxes.ymin & mlist{i}.yc <imaxes.ymax;
    d1 = size(infilter{i},1);
    if d1==1
        infilter{i} = infilter{i}';
    end

    idx = inbox & infilter{i};
    vlist{i} = IndexStructure(mlist{i},idx);
    vlist{i}.x = vlist{i}.x - imaxes.xmin;
    vlist{i}.y = vlist{i}.y - imaxes.ymin;
    vlist{i}.xc = vlist{i}.xc - imaxes.xmin;
    vlist{i}.yc = vlist{i}.yc -imaxes.ymin; 
    vlist{i}.imaxes = imaxes; 
    vlist{i}.inbox = inbox; 
end
    
if outputList
    vlist = vlist{1};
end

