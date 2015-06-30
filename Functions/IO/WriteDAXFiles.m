function WriteDAXFiles(movie, infoFile, varargin)
%--------------------------------------------------------------------------
% WriteDAXFiles(movie, infoFile, varargin)
% This function writes a movie to a .dax file based on the corresponding
% infoFile structure.  
%--------------------------------------------------------------------------
% Inputs:
% movie/int16 array: This array contains the movie data to
%   be saved.  
%
% infoFile/infoFile structure: This array contains the infoFile
% structures that define the properties of each movie.  
%--------------------------------------------------------------------------
% Outputs:
%
%--------------------------------------------------------------------------
% Variable Inputs:
% 
%--------------------------------------------------------------------------
% Jeffrey Moffitt
% October 3, 2012
% jeffmoffitt@gmail.com
%
% Version 1.0
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Hardcoded Variables
%--------------------------------------------------------------------------
quiet = 0;

%--------------------------------------------------------------------------
% Global Variables
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Default Variables
%--------------------------------------------------------------------------
verbose = 0;

%--------------------------------------------------------------------------
% Parse Required Input
%--------------------------------------------------------------------------
if nargin < 2
    error('Both a movie and an infoFile are required');
end

%--------------------------------------------------------------------------
% Parse Variable Input
%--------------------------------------------------------------------------
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
        otherwise
            error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
    end
end

%--------------------------------------------------------------------------
% Write .dax and .ini files
%--------------------------------------------------------------------------
    
%--------------------------------------------------------------------------
% Write .ini files
%--------------------------------------------------------------------------
WriteInfoFiles(infoFile, 'verbose', verbose);
    
%--------------------------------------------------------------------------
% Create dax name
%--------------------------------------------------------------------------
daxName = [infoFile.localName(1:(end-4)) '.dax'];
    
%--------------------------------------------------------------------------
% Write DAX file
%--------------------------------------------------------------------------
fid = fopen([infoFile.localPath daxName], 'w');
if fid<0
    error(['Unable to open ' infoFile.localPath daxName]);
end

fwrite(fid, ipermute(int16(movie), [2 1 3]), 'int16', 'b');

if verbose
    display(['Finished writing ' infoFile.localPath daxName]);
end

fclose(fid);
    
