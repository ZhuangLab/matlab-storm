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
% Io = Ncolor(I,cMap); 
%                        -- Convert the N layer matrix I into an RGB image
%                           according to colormap, 'cMap'.  
%------------------------------------------------------------------------
% Inputs
% I double / single / uint16 or uint8, 
%                       -- HxWxN where each matrix I(:,:,n) is
%                          to be assigned a different color. 
% cMap                  
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

global scratchPath

if nargin == 1
    cMap = [];
elseif nargin == 2
    cMap = varargin{1};
else
    error('wrong number of inputs');
end
    

[h,w,cls] = size(I);
if isempty(cMap);
    cMap = hsv(cls);
end

Io = zeros(h,w,3,class(I));

try
% make white the default for single color images
if cls == 1
   Io = I; 
else
    for c=1:cls
        for cc = 1:3
        Io(:,:,cc) = Io(:,:,cc) + I(:,:,c)*cMap(c,cc);
        end
    end
end
catch er
    save([scratchPath,'troubleshoot.mat']);
    warning(er.getReport);
    warning(['Data saved in:' scratchPath,'troubleshoot.mat']);
    error('error running Ncolor'); 
end


if nargout == 0
    try
    imagesc(Io);
    catch
        imagesc(makeuint(Io,8));
    end
end


 