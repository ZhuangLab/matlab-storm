function SaveImage(h,savename,varargin)
% SaveAs(fighandle,fullfilename)
% SaveAs(fighandle,fullfilename,verbose)
%
%--------------------------------------------------------------------------
% Required Inputs:
%
% h / handle        - handle to figure to be saved
% savename / string - name (and full filepath if desired) to save figure as
%                     Should include format (.png, .tif, .fig, .eps).  
% 
%--------------------------------------------------------------------------
% Outputs:
% The file indicated by savename will be created.  If this file already
% exists the user will be prompted to provide a new savename or overwrite
% it.  Alternatively you may request the function to automatically generate
% an new version of the filename.  
% 
%--------------------------------------------------------------------------
% Optional Inputs
% ifConflict / string / 'prompt'
%               - If the file exists, this function can 'prompt' the
%               user to overwite the file, enter a new name with the uiput
%               gui, or cancel.  
%               Passing the function SaveAs(...,'ifConflict','increment')
%               will cause the function to automatically generate a new
%               file name.  
%
%--------------------------------------------------------------------------
% Notes
%
% This function wraps Matlab's saveas() function to avoid uintended 
% overwriting of files.
% 
% Required Additional Functions: 
% ExtractPath, IncreaseSaveName, CheckList, CheckParameter
%-------------------------------------------------------------------------
% Alistair Boettiger
% boettiger.alistair@gmail.com
% November 2013 CC BY
% 
%-------------------------------------------------------------------------



%--------------------------------------------------------------------------
%% Default Optional Inputs
%--------------------------------------------------------------------------
verbose = true; 
ifConflict = 'prompt';

%--------------------------------------------------------------------------
% Parse variable input
%--------------------------------------------------------------------------

if nargin > 2
    varpars = varargin(1:end);
    if (mod(length(varpars), 2) ~= 0 ),
        error(['Extra Parameters passed to the function ''' mfilename ''' must be passed in pairs.']);
    end
    parameterCount = length(varpars)/2;
    for parameterIndex = 1:parameterCount,
        parameterName = varpars{parameterIndex*2 - 1};
        parameterValue = varpars{parameterIndex*2};
        switch parameterName
            case 'ifConflict'
                ifConflict= CheckList(parameterValue, {'prompt','increment','overwrite'}, 'ifConflict');
            case 'verbose'
                verbose = CheckParameter(parameterValue,'boolean','verbose');
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
%% Main Code
%--------------------------------------------------------------------------

%------------------------------------------ saveas()
% to save matlab figure file
if exist(savename,'file') && strcmp(ifConflict,'prompt')
    disp(['file ',savename, ' exists']);
    userInput = input('Overwrite? y/n/c ','s');
    if strcmp(userInput,'y')
        savehandle(h,savename,verbose);
    elseif strcmp(userInput,'n')
        currpath = ExtractPath(savename);
        [savePath,savename] = uiputfile(currpath);
        if isempty(savename)
            return
        end
        savename = [savePath,filesep,savename];
        savehandle(h,savename,verbose)     
     elseif strcmp(userInput,'c');
         return;
    end
elseif exist(savename,'file') && strcmp(ifConflict,'increment')
    while exist(savename,'file')
        savename = IncrementSaveName(savename);
    end
    savehandle(h,savename,verbose);
else
   savehandle(h,savename,verbose);
end  
    


function savehandle(h,savename,verbose)
% h - handle to figure to save
% savename - full file path to save
% verbose - print saved file name and path to screen (true/false) 
saveas(h,savename);
if verbose
    disp(['wrote ',savename]);
end



