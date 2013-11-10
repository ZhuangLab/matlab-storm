function savename = IncrementSaveName(savename)
% Input: savename - string specifying a save name for a file which
%           conflicts with an existing file
% Output: savename - modified save name which will not conflict with
%           exsiting file name.  
% Examples:   input = myfilename.mat       output = myfilename_save2.mat
%             input = myfilename_save2.mat output = myfilename_save3.mat   
% 
 currnum = strfind(savename,'_save');
 nameEnd = strfind(savename,'.');
 if isempty(nameEnd)
     nameEnd = length(savename);
 end
 if isempty(currnum)
    savename = [savename(1:nameEnd-1),'_save2',savename(nameEnd:end)];
 else
     currnum = str2double(savename(currnum+6:nameEnd-1));
     newnum = currnum + 1;
     savename = [savename(1:currnum+5),num2str(newnum),savename(nameEnd:end)];
 end