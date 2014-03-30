
function [dpath,filename] = ExtractPath(fullfilename,varargin)
%--------------------------------------------------------------------------
% [dpath,filename] = extractpath(fullfilename
%--------------------------------------------------------------------------
% Description:
% Split a fullpath filename into separate path name and file name
% second output is optional can return just a filename;  
%
%--------------------------------------------------------------------------
% Alistair Boettiger   boettiger.alistair@gmail.com
% Updated Dec 28th, 2013
% February 24th, 2013

verbose = false;

%--------------------------------------------------------------------------
% Parse Variable Input Parameters
%--------------------------------------------------------------------------
if nargin < 1
   error([mfilename,' expects input: filename string']);
end
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
                verbose = CheckParameter(parameterValue,'boolean','verbose');                
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end


k = strfind(fullfilename,filesep);
if isempty(k)
     k = strfind(fullfilename,'/');
     if isempty(k)
         k = strfind(fullfilename,'\');
     end
end

if ~isempty(k)
dpath = fullfilename(1:k(end));
filename = fullfilename(k(end)+1:end);
else
    if verbose
        disp([fullfilename, ' is not a full filepath']);
    end
    filename = fullfilename;
    dpath = ''; 
end
