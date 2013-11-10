
function [dpath,filename] = ExtractPath(fullfilename)
%--------------------------------------------------------------------------
% [dpath,filename] = extractpath(fullfilename)
%--------------------------------------------------------------------------
% Description:
% Split a fullpath filename into separate path name and file name
% second output is optional can return just a filename;  
%
%--------------------------------------------------------------------------
% Alistair Boettiger   boettiger.alistair@gmail.com
% February 24th, 2013

k = strfind(fullfilename,filesep);
dpath = fullfilename(1:k(end));
filename = fullfilename(k(end)+1:end);

