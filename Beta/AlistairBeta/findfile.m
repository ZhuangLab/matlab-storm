function filefolder = findfile(pathin,sfile,varargin)
%--------------------------------------------------------------------------
%% Inputs 
% pathin / string 
%               -- search in this folder, all of its subdirectories and its 
%               parent directories as far up as 'maxup' for the folder 
%               containing the file named 'sfile'
% sfile / string
%               -- name of the file to search for.
%--------------------------------------------------------------------------
%% Outputs
%
%--------------------------------------------------------------------------
%% Optional Inputs
% maxup 1
% 
%--------------------------------------------------------------------------
% Alistair Boettiger
% boettiger.alistair@gmail.com
% October 9th, 2012
%
% Version 1.0
%--------------------------------------------------------------------------
% Version update information
% 
%--------------------------------------------------------------------------
% Creative Commons License 3.0 CC BY  
%--------------------------------------------------------------------------




%--------------------------------------------------------------------------
% Default Inputs
%--------------------------------------------------------------------------
maxup = 1; % stay at least this many folders above the root directory.  

%--------------------------------------------------------------------------
% Parse Optional Inputs
%--------------------------------------------------------------------------
if nargin == 3
    maxup = varargin{1};
end

%--------------------------------------------------------------------------
% Main Function
%--------------------------------------------------------------------------

  filefolder = [];

  % find all subdirectories
  alldirs = genpath(pathin); 
  dirbreaks = strfind(alldirs,';');
  N = length(dirbreaks); % number of total subfolders to search
  allpaths = cell(N,1);
  dirbreaks = [1,dirbreaks,length(alldirs)];
  allpaths{1} = alldirs(dirbreaks(1):dirbreaks(2)-1);
  for n=2:N
    allpaths{n} = alldirs(dirbreaks(n)+1:dirbreaks(n+1)-1);
  end
  % disp(allpaths)
  
  for k=1:N
        scontents = dir(allpaths{k});
        has_file = strmatch(sfile,{scontents(:).name});
        if ~isempty(has_file)
            filefolder = [allpaths{k},scontents(k).name];
            disp(['found ',sfile,' in ',filefolder]);
            break
        end
   end

  % Search Up through parent folders and all their subdirectories one up
  pathin = [pathin,filesep];
   f = strfind(pathin,filesep);
  u = 0;
 while isempty(filefolder) && u<length(f)- maxup
     u = u+1;
     uponedir = pathin(1:f(end-u)); % progressively step up directories, searching for file
     disp(['searching in ',uponedir]);
     fcontents = dir(uponedir);
     subfolders = find([fcontents(:).isdir]);
     for k=subfolders(3:end) % skip directories '.' and '..'
            scontents = dir([uponedir,fcontents(k).name]);
            disp(['searching in ',uponedir,fcontents(k).name]);
            has_file = strmatch(sfile,{scontents(:).name});
            if ~isempty(has_file)
                filefolder = [uponedir,fcontents(k).name];
                disp(['found ',sfile,' in ',filefolder]);
                break
            end
            subsubfolders = find([scontents(:).isdir]);
            for kk=subsubfolders(3:end) % skip directories '.' and '..'
                sscontents = dir([uponedir,fcontents(k).name,filesep,scontents(kk).name]);
                disp(['searching in ',uponedir,fcontents(k).name,filesep,scontents(kk).name]);
                has_file = strmatch(sfile,{sscontents(:).name});
                if ~isempty(has_file)
                    filefolder = [uponedir,fcontents(k).name,filesep,scontents(kk).name];
                    disp(['found ',sfile,' in ',filefolder]);
                    break
                end
            
            end
     end
 end