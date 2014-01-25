function clrmap = GetColorMap(clrmapName,varargin)

verbose = true; 
pts = 256;

if nargin > 1
    pts = varargin{1};
end

try 
    clrmap = eval([clrmapName, '(',num2str(pts),')']);
catch

    % Black to white colormaps via the indicated color name;
  switch clrmapName
        case 'yellow'
        clrmap = hot(pts);
        clrmap = [clrmap(:,1),clrmap(:,1),clrmap(:,2)];
        clrmap(clrmap<0) = 0;

        case 'red'
        clrmap = hot(pts);
        clrmap = [clrmap(:,1),clrmap(:,2),clrmap(:,3)];
        clrmap(clrmap<0) = 0;
        
        case 'blue'
        clrmap = hot(pts);
        clrmap = [clrmap(:,3),clrmap(:,2),clrmap(:,1)];
        clrmap(clrmap<0) = 0;

        case 'green'
        clrmap = hot(pts);
        clrmap = [clrmap(:,3),clrmap(:,1),clrmap(:,2)];
        clrmap(clrmap<0) = 0;

        case 'purple'
        clrmap = hot(pts);
        clrmap = [clrmap(:,1),clrmap(:,3),clrmap(:,1)];
        clrmap(clrmap<0) = 0; 
        
        case 'cyan'
        clrmap = hot(pts);
        clrmap = [clrmap(:,3),clrmap(:,1),clrmap(:,1)];
        clrmap(clrmap<0) = 0;

        otherwise
        if verbose
            disp(['colormap ',clr,' not recognized']);
        end
  end
end

if nargout == 0;
        colormap(clrmap); 
end