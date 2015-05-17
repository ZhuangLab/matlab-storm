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
%         case 'yellow'
%         clrmap = hot(pts);
%         clrmap = [clrmap(:,1),clrmap(:,1),clrmap(:,2)];
%         clrmap(clrmap<0) = 0;

        case 'yellow' % red
        clrmap = hot(pts);
        clrmap = [clrmap(:,1),clrmap(:,2),clrmap(:,3)];
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
        
        case 'black'
        clrmap = gray(pts);
        
        case 'cyan'
        clrmap = hot(pts);
        clrmap = [clrmap(:,3),clrmap(:,1),clrmap(:,1)];
        clrmap(clrmap<0) = 0;

      case 'whiteOrangeRed'
        nPts = pts;
        whiteToYellow = zeros(nPts,3);
        yellowToRed  = zeros(nPts,3);
        redToBlack  = zeros(nPts,3);
        redToWhite = zeros(nPts,3); 
        redToYellow= zeros(nPts,3); 
        for n=1:nPts
            yellowToRed(n,:) = [1,(nPts-n+1)/nPts,0];
            redToBlack(n,:) =  [(nPts-n+1)/nPts,0,0];
            redToWhite(n,:) = [1,n/nPts,n/nPts];
            whiteToYellow(n,:) = [1, (nPts-n*.3+.3)/nPts, (nPts-n+1)/nPts];
            redToYellow(n,:)= [1,.7*n/nPts,0];
        end
        clrmap = flipud([redToYellow;flipud(whiteToYellow)]);

      case 'blackCyanOrange'
        nPts = pts;
        blackToCyan = zeros(nPts,3);
        CyanToOrange  = zeros(nPts,3);
        for n=1:nPts;
            blackToCyan(n,:) = [0 n/nPts n/nPts];
            CyanToOrange(n,:) = [ n/nPts, (nPts-(n/2))/nPts, (nPts-n)/nPts];
        end
        clrmap = ([blackToCyan; (CyanToOrange)]);
          
        
        otherwise
        if verbose
            disp(['colormap ',clr,' not recognized']);
        end
  end
end

if nargout == 0;
        colormap(clrmap); 
end