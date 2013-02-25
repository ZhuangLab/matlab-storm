function Iout = imflip(Iin,dim)
%------------------------------------------------------------------------
% Iout = imflip(Iin,dim)
%    flips the image file Iin along the dimension specified by dim.
% 
%------------------------------------------------------------------------
% Inputs
%  Iin / Matrix, HxWxN, any class   -- image to be flipped
%  dim / double                     -- dimension to flip image,
%                           1=horizontal, 2=vertical, 0 =no flip
% 
%------------------------------------------------------------------------
% Outputs:
% Iout / Matrix     -- same size as Iin, flipped along indicated dim.
% 
%------------------------------------------------------------------------
% Alistair Boettiger
% February 24th, 2013


chns = size(Iin,3);
intype = class(Iin);
Iout = zeros(size(Iin),intype);
if dim == 1;
    for c=1:chns
        Iout(:,:,c) = fliplr(Iin(:,:,c));
    end
elseif dim == 2
    for c=1:chns
        Iout(:,:,c) = flipud(Iin(:,:,c));
    end
elseif dim == 0
    Iout = Iin; 
else
    disp('error: expected 2nd entry as dimension = 1 or 2 or 0 for no flip'); 
end
