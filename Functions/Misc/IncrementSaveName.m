function savename = IncrementSaveName(savename,varargin)
%-------------------------------------------------------------------------
% Input: savename - string specifying a save name for a file which
%           conflicts with an existing file
% Output: savename - modified save name which will not conflict with
%           exsiting file name.  
% Examples:   input = myfilename.mat       output = myfilename_save2.mat
%             input = myfilename_save2.mat output = myfilename_save3.mat   
%
%-------------------------------------------------------------------------
% Alistair Boettiger
% boettiger.alistair@gmail.com
% November 2013 CC BY
% 
%-------------------------------------------------------------------------
%%


% -------------------------------------------------------------------------
% Default variables
% -------------------------------------------------------------------------
defaults = cell(0,3);
defaults(end+1,:) = {'verbose', 'boolean', true};
defaults(end+1,:) = {'overwrite', 'boolean', false};
% -------------------------------------------------------------------------
% Parse necessary input
% -------------------------------------------------------------------------
if nargin < 1
    error('matlabSTORM:invalidArguments', 'requires name');
end

% -------------------------------------------------------------------------
% Parse variable input
% -------------------------------------------------------------------------
parameters = ParseVariableArguments(varargin, defaults, mfilename);

%% Main function

% ------------------------------------------------------------------------
% Check if files exist
% ------------------------------------------------------------------------
[savefolder,name,saveformat] = fileparts(savename);

if ~parameters.overwrite
    done = false;
    countStartIdx = regexp(name,'\([0-9]*\.?[0-9]\)'); % find numbers in parenthesis
    if ~isempty(countStartIdx)
        count = num2str(name(countStartIdx+1:end-1));
    else
        count = 0;
    end
    newName = name;
    while ~done
        done = false;
        if exist([savefolder filesep newName saveformat])
            count = count + 1;
        else
            done = true;
        end
        if  count > 0
            newName = [name '(' num2str(count) ')'];
        end
    end

    if count > 0 && parameters.verbose
        display(['Found existing files. Appending ' num2str(count) ' to all file names.']);
    end
end

savename = [savefolder filesep newName saveformat];

% 
% 
% %%
% if ~exist(savename)
%     savename = savename;
% else
%     disp('incrementing save name');
%     disp(['new savename = ',savename]);
% 
%      currnumIdx = strfind(savename,'_save');
%      nameEnd = strfind(savename,'.');
%      nameEnd = nameEnd(end); % the last dot
%      if isempty(nameEnd)
%          nameEnd = length(savename);
%      end
%      if isempty(currnumIdx)
%         savename = [savename(1:nameEnd-1),'_save2',savename(nameEnd:end)];
%      else
%          currnum = str2double(savename(currnumIdx+5:nameEnd-1));
%          newnum = currnum + 1;
%          savename = [savename(1:currnumIdx+4),num2str(newnum),savename(nameEnd:end)];
%      end
%  end