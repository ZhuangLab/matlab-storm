
function modify_script(fname_in,fname_out,target_phrases,new_values,varargin)
%--------------------------------------------------------------------------
% modify_ini_file(fname_in,fname_out,target_phrase,new_value)
%
% Script scans the file 'fname_in' for the occurance of the text string 
% specified by 'target_phrase'.  Prints to screen the current value of the
% text following the target_phrase, and saves a new file 'fname_out' where
% this following text has been replaced with the string 'new_value'.  
%
% All entries should be strings.  fname_in should include the source folder
% and complete file name, as should fname_out.  fname_in must contain the
% string 'target_phrase'. 
%
%--------------------------------------------------------------------------
% Inputs
%  fname_in / string / 'C:/STORM/pars/647_pars.ini'
%  fname_out / string/ 
%  target_phrases / cell array of strings
%  new_values / cell array of strings 
%
%--------------------------------------------------------------------------
% Outputs
%  the file specified by fname_out will be created.  If fname_out =
%  fname_in, the input file will be modified with the original values
%  replaced with the new values.
%
% -------------------------------------------------------------------------
% 
% Alistair Boettiger
% Zhuang Lab
% September 18th, 2012
% Copyright Creative Commons CC BY
% 
%% -------------------------------------------------------------------------

% Parse inputs
%--------------------------------------------------------------------------
% if no separate save name is given, overwrite input file.  
if isempty(fname_out)
    fname_out = fname_in;
end

if nargin == 5;
    endmarker = varargin{1};
else
    endmarker = ''; 
end

verbose = false; % fixed for the moment.  Usful for troubleshooting

% Main script
%--------------------------------------------------------------------------


% my preferred way to read in a text file:
try
T = char(textread(fname_in,'%s','delimiter','\n','whitespace',''));
catch er
    disp(er.message); 
    error(['could not find: ',fname_in]);
end
[max_lines,~] = size(T);
T_new = T;

% find line containing target phrase entry;
for t=1:length(target_phrases)
    target_phrase = target_phrases{t};
    new_value = new_values{t};   
    ln = 1; % loop through all lines, don't go past end.
    while isempty(regexp(T(ln,:),regexptranslate('escape',target_phrase),'once')) && ln < max_lines;
          ln=ln+1;
    end
    % now we have the line, find the position:
    ks = strfind(T(ln,:),target_phrase);  % starting point of name (whatever immideately follows target_phrase)
    ks = ks+length(target_phrase);
    if ~isempty(endmarker)
        ke = strfind(T(ln,ks:end),endmarker);
        ke = ks + ke(1)-2; 
    else
        ke = ks+length(new_value);
        T_new(ln,ke:end) = repmat(' ',[1,length(T_new(ln,ke:end))]);
    end
   
    new_line = [T_new(ln,1:ks-1),new_value,T_new(ln,ke+1:end)];
    T_new(ln,1:length(new_line)) = new_line;
    
    if verbose
        disp(['Orig line: ' T(ln,:)]);
        disp(['New line: ' T_new(ln,:)]);
    end
end
    
% print to file
disp(['writing file ',fname_out,'...'])

fid = fopen(fname_out,'w+');
for ln=1:max_lines
    str = deblank(T_new(ln,:));  fprintf(fid,str,['']); fprintf(fid,'%s\r\n',['']);
end
fclose(fid); 
if verbose
    disp('done');
end

 % save('C:\Users\Alistair\Documents\Projects\General_STORM\Test_data\test.mat');
% load('C:\Users\Alistair\Documents\Projects\General_STORM\Test_data\test.mat');
