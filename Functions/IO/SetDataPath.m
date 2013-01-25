function newPath = SetDataPath(newPath)
%--------------------------------------------------------------------------
% function newPath = SetDataPath(newPath) 
% This function sets the value of the global variable, defaultDataPath
%--------------------------------------------------------------------------
% Jeffrey Moffitt
% September 6, 2012
% jeffmoffitt@gmail.com
%
% Version 1.0
%--------------------------------------------------------------------------
% Version 1.1
% JRM; September 18, 2012
% Starts at the previous default path
%--------------------------------------------------------------------------



%--------------------------------------------------------------------------
% Hardcoded variables
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Global Variables
%--------------------------------------------------------------------------
global defaultDataPath;

%--------------------------------------------------------------------------
% Parse variable input
%--------------------------------------------------------------------------
if nargin<1
    newPath = uigetdir(defaultDataPath, 'Select new default data path');
    if newPath == 0
        display('Canceled');
        newPath = defaultDataPath;
        return;
    end
    
end

%--------------------------------------------------------------------------
% Check path validity
%--------------------------------------------------------------------------
if ~ischar(newPath)
    display('Not a valid path');
    newPath = pwd;
end

%--------------------------------------------------------------------------
% Set path
%--------------------------------------------------------------------------
defaultDataPath = [newPath '\']; % All paths must end in '\'