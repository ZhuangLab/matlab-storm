function CSLstring = CSL2str(cellstring)
%--------------------------------------------------------------------------
% CSLstring = CSL2str(cellstring)
%--------------------------------------------------------------------------
% Takes a cell string and returns a comma separated list
% Alistair Boettiger
% February 24th, 2013

N = length(cellstring);

CSLstring = [];
for n=1:N-1
    CSLstring = [CSLstring,cellstring{n},', '];
end
CSLstring = [CSLstring,cellstring{N}];