
function [dpath,filename] = extractpath(fullfilename)
%--------------------------------------------------------------------------
% [dpath,filename] = extractpath(fullfilename
%--------------------------------------------------------------------------
% Description:
% Split a fullpath filename into separate path name and file name
% second output is optional can return just a filename;  
%
%--------------------------------------------------------------------------
% Alistair Boettiger   boettiger.alistair@gmail.com
% Updated Dec 28th, 2013
% February 24th, 2013

k = strfind(fullfilename,filesep);
if isempty(k)
     k = strfind(fullfilename,'/');
     if isempty(k)
         k = strfind(fullfilename,'\');
     end
end

if ~isempty(k)
dpath = fullfilename(1:k(end));
filename = fullfilename(k(end)+1:end);
else
    disp([fullfilename, ' is not a full filepath']);
    filename = fullfilename;
    dpath = ''; 
end

