function vlist = msublist(mlist,imaxes,varargin)
% vlist = msublist(mlist,imaxes)
% vlist = msublist(mlist,imaxes,'filter',filter)
%-------------------------------------------------------------------------
%% inputs
%-------------------------------------------------------------------------
% mlist        -- molecule list
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
infilter = true(length(mlist.x),1); 
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
                infilter = CheckParameter(parameterValue,'boolean','filter');
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end
    
%-------------------------------------------------------------------------
%% Main function
%-------------------------------------------------------------------------   


inbox = mlist.x>imaxes.xmin & mlist.x < imaxes.xmax & mlist.y>imaxes.ymin & mlist.y<imaxes.ymax;
d1 = size(infilter,1);
if d1==1
    infilter = infilter';
end

idx = inbox & infilter;
vlist = IndexStructure(mlist,idx);
vlist.x = vlist.x - imaxes.xmin;
vlist.y = vlist.y - imaxes.ymin;
vlist.xc = vlist.xc - imaxes.xmin;
vlist.yc = vlist.yc -imaxes.ymin; 
vlist.imaxes = imaxes; 
vlist.inbox = inbox; 
% 
% 
% vlist.x = (mlist.x(inbox & infilter)-imaxes.xmin);
% vlist.y = (mlist.y(inbox & infilter)-imaxes.ymin);
% vlist.z = (mlist.z(inbox & infilter));
% vlist.xc = (mlist.xc(inbox & infilter)-imaxes.xmin);
% vlist.yc = (mlist.yc(inbox & infilter)-imaxes.ymin);
% vlist.zc = (mlist.zc(inbox & infilter));
% vlist.a= (mlist.a(inbox & infilter));
% vlist.i= (mlist.i(inbox & infilter));
% vlist.h= (mlist.h(inbox & infilter));
% vlist.frame= (mlist.frame(inbox & infilter));
% vlist.length= (mlist.length(inbox & infilter));
% vlist.w= (mlist.w(inbox & infilter));
% vlist.c= (mlist.c(inbox & infilter));

