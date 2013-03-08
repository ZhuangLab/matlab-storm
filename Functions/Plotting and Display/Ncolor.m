function Io = Ncolor(I,varargin)
% ------------------------------------------------------------------------
% Ncolor(I);  
%                        -- Plot in current figure a 3-dimensional matrix
%                        as an image, interpreting each of the z-dimensions
%                        as a different color.  
% Io = Ncolor(I); 
%                        -- Returns a 3D RGB matrix which has mapped each
%                        of the z-dimensions of the input image to a
%                        different color in RGB space.  
% Io = Ncolor(I,cmap); 
%                        -- Convert the N layer matrix I into an RGB image
%                           according to colormap, 'cmap'.  
%------------------------------------------------------------------------
% Inputs
% I double / single / uint16 or uint8, 
%                       -- HxWxN where each matrix I(:,:,n) is
%                          to be assigned a different color. 
% cmap                  
%                       -- a valid matlab colormap. leave blank for default
%                       hsv (which is RGB for N=3).  Must be Nx3
%-------------------------------------------------------------------------
% Outputs
% Io same class as I.  
%                       -- HxWx3 RGB image
%--------------------------------------------------------------------------
% Alistair Boettiger
% boettiger.alistair@gmail.com
% October 10th, 2012
%
% Version 1.0
%--------------------------------------------------------------------------
% Creative Commons License 3.0 CC BY  
%--------------------------------------------------------------------------

if nargin == 1
    cmap = [];
elseif nargin == 2
    cmap = varargin{1};
else
    error('wrong number of inputs');
end
    

[h,w,cls] = size(I);
if isempty(cmap);
    cmap = hsv(cls);
end

Io = zeros(h,w,3,class(I));

for c=1:cls
    for cc = 1:3
    Io(:,:,cc) = Io(:,:,cc) + I(:,:,c)*cmap(c,cc);
    end
end

if nargout == 0
    imagesc(Io);
end


 