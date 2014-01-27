
function target_values = read_parameterfile(parameterfile,target_phrases,varargin)
%--------------------------------------------------------------------------
% target_values = read_parameterfile(parameterfile,target_phrases)
%
% Script scans the file 'parameterfile' for the occurance of the string 
% specified by 'target_phrases'.  These values are saved in the cell array
% target_values.  
%
%--------------------------------------------------------------------------
% Inputs
%  parameter file / string
%                       -- full path name of file to search
%  
% 
%  endmarker / string 
%                       -- flag at which to stop reading line.  leave empty
%                       if line ends with the target value to extract
%--------------------------------------------------------------------------
% Outputs
%  target_values / cell 
%                       -- cell array of strings, same size as the cell
%                       array 'target_phrases'
% -------------------------------------------------------------------------
% 
% Alistair Boettiger
% Zhuang Lab
% January 16th, 2013
% Copyright Creative Commons CC BY
% 
%% -------------------------------------------------------------------------

verbose = false;

% Automatically determine the parameter value end marker from the filetype.
if nargin > 2
    endmarker = varargin{1};
else
    parsflag = parameterfile(end-3:end);
    if strcmp(parsflag,'.xml');
        endmarker = '<';
    else
        endmarker = '';
    end
end

% lazy way to read in a text file:
try
T = char(textread(parameterfile,'%s','delimiter','\n','whitespace',''));
catch er
    disp(er.message); 
    error(['could not find: ',parameterfile]);
end
[max_lines,~] = size(T);
target_values = cell(size(target_phrases)); 

% find line containing target phrase entry;
for t=1:length(target_phrases)
    target_phrase = target_phrases{t};
   
    ln = 1; % loop through all lines, don't go past end.
    while isempty(regexp(T(ln,:),regexptranslate('escape',target_phrase),'once')) && ln < max_lines;
          ln=ln+1;
    end
    
    if ln==max_lines
        disp(['error: phrase "',target_phrase,'" not found in ',parameterfile]);
    end
    
    % now we have the line, find the position:
    ks = strfind(T(ln,:),target_phrase);  % starting point of name (whatever immideately follows target_phrase)
    ks = ks+length(target_phrase);
    if ~isempty(endmarker)
        ke = strfind(T(ln,ks:end),endmarker);
        ke = ks + ke(1)-2; 
    else
        ke = length(T(ln,:));
    end
    if verbose
        disp([target_phrase, T(ln,ks:ke)]);
    end
    target_values{t} =  strtrim(T(ln,ks:ke));
    
end
    
if verbose
    disp('done');
end
% save('C:\Users\Alistair\Documents\Projects\General_STORM\Test_data\test.mat');
% load('C:\Users\Alistair\Documents\Projects\General_STORM\Test_data\test.mat');
