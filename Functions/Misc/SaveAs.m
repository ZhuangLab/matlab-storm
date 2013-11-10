function SaveAs(h,savename,varargin)
% SaveAs(fighandle,fullfilename)
% SaveAs(fighandle,fullfilename,verbose)
%
%--------------------------------------------------------------------------
% Required Inputs:
%
% --- To Save a .mat file ---
% SaveAs(fullMatfilename)
% fullMatfilename must be a string corresponding filename for the '.mat'
% file to be saved.  If not a full filepath the file will be saved in the
% current working directory
% 
% SaveAs(fullMatfilename,variables)
% variables is a cell array of the names of the variables to save.  
% Note variables must be joined into a cell.  Example {'var1','var2'
% 
%--------------------------------------------------------------------------
% Outputs
% 
% 
%--------------------------------------------------------------------------
% Optional Inputs
% 
%
%--------------------------------------------------------------------------
% Notes
%
% This function wraps Matlab's saveas() function to avoid uintended 
% overwriting of files. 
% 

%--------------------------------------------------------------------------
%% Default Optional Inputs
%--------------------------------------------------------------------------
verbose = true; 
savevars = ''; 
ifConflict = 'prompt';

%--------------------------------------------------------------------------
% Parse variable input
%--------------------------------------------------------------------------

if ishandle(usrIn)
    h = usrIn;
    savename = varargin{1};
    savetype = 'savehandle';
else
    savename = usrIn;
    savetype = 'savedata';
    if nargin > 1
        savevars = varargin{1};
        saveall = false;
    elseif nargin == 1 || isempty(savevars)
        saveall = true;
    end
end

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
                ifConflict= CheckList(parameterValue, {'prompt','increment'}, 'ifConflict');
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
if strcmp(savetype,'savehandle')
    if exist(savename,'file')
        disp(['file ',savename, ' exists']);
        userInput = input('Overwrite? y/n/c ','s');
        if strcmp(userInput,'y')
            savehandle(h,savename,verbose)
        elseif strcmp(userInput,'n') && strcmp(ifConflict,'prompt')
            currpath = ExtractPath(savename);
            [savepath,savename] = uiputfile(currpath);
            savename = [savepath,filesep,savename];
            savehandle(h,savename,verbose)
         elseif strcmp(userInput,'n') && strcmp(ifConflict,'increment')
            savename = IncrementSaveName(savename);
            savehandle(h,savename,verbose)
         elseif strcmp(userInput,'c');
             return;
        end
    else
       savehandle(h,savename,verbose)
    end  
    
% %--------------------------------------- save()
% % for .mat file with list of variables
% elseif strcmp(savetype,'savedata'); 
%     if exist(savename,'file')
%         disp(['file ',savename, ' exists']);
%         userInput = input('Overwrite? y/n/c ','s');
%         if strcmp(userInput,'y')
%             savemat(savename,savevars,saveall,verbose)
%         elseif strcmp(userInput,'n') && strcmp(ifConflict,'prompt')
%             currpath = ExtractPath(savename);
%             [savepath,savename] = uiputfile(currpath);
%             savename = [savepath,filesep,savename];
%             savemat(savename,savevars,saveall,verbose)
%         elseif  strcmp(userInput,'n') && strcmp(ifConflict,'increment')
%             savename = IncrementSaveName(savename);
%             savemat(savename,savevars,saveall,verbose)
%          elseif strcmp(userInput,'c');
%              return;
%         end
%     else
%         savemat(savename,savevars,saveall,verbose)
%     end
% end


function savehandle(h,savename,verbose)
% h - handle to figure to save
% savename - full file path to save
% verbose - print saved file name and path to screen (true/false) 
saveas(h,savename);
if verbose
    disp(['wrote ',savename]);
end


 
% function savemat(savename,savevars,saveall,verbose)
% % savename - full file path to save
% % savevars - matlab variables to save
% % saveall - save all matlab variables (true/false)
% % verbose - print saved file name and path to screen (true/false) 
% if saveall
%     save(savename);
% else
%     save(savename,savevars{:});
% end
% if verbose
%     disp(['wrote ',savename]);
% end
