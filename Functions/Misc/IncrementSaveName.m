function savename = IncrementSaveName(savename)
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

disp('incrementing save name');
savename

 currnumIdx = strfind(savename,'_save');
 nameEnd = strfind(savename,'.');
 nameEnd = nameEnd(end); % the last dot
 if isempty(nameEnd)
     nameEnd = length(savename);
 end
 if isempty(currnumIdx)
    savename = [savename(1:nameEnd-1),'_save2',savename(nameEnd:end)];
 else
     currnum = str2double(savename(currnumIdx+5:nameEnd-1));
     newnum = currnum + 1;
     savename = [savename(1:currnumIdx+4),num2str(newnum),savename(nameEnd:end)];
 end