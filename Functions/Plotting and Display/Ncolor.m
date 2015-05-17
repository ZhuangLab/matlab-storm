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


clrmap = []; 
if nargin == 2
    clrmap = varargin{1};
elseif nargin > 2
    error('wrong number of inputs');
end
[h,w,numColors] = size(I);


if isempty(clrmap) && numColors ==1
    clrmap = hot(256);
elseif isempty(clrmap) && numColors < 10;
    clrmap = hsv(numColors); 
end


if numColors == 1 && size(clrmap,1) > 10;
    Io = I; 
else
    if ischar(clrmap)
        try
            clrmap = eval([clrmap,'(numColors)']);
        catch
            disp([clrmap,' is not a valid colormap name']);  
        end
    end
    
    Io = zeros(h,w,3,class(I));
    try
        for c=1:numColors
            for cc = 1:3
                Io(:,:,cc) = Io(:,:,cc) + I(:,:,c)*clrmap(c,cc);
            end
        end
    catch er
        save([scratchPath,'troubleshoot.mat']);
        % load([scratchPath,'troubleshoot.mat']);
        warning(er.getReport);
        warning(['Data saved in:' scratchPath,'troubleshoot.mat']);
        warning(['expected ',num2str(numColors),' found ',num2str(size(Io,3)),' colors.']);
        error('error running Ncolor'); 
    end
end

if nargout == 0
    try
        imagesc(Io);
        colormap(clrmap);
    catch
        imagesc(makeuint(Io,8));
        colormap(clrmap);
    end
end

