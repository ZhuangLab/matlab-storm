function [apiSP, hFig] = CreateSizeableImage(varargin)
% ------------------------------------------------------------------------
% [hMagBox, hFig] = CreateSizeableImage();
% This function creates a figure in which the user can plot images via the
% imshow command and which contains a magnification box and a scrollbar.
%
% Options:
% 'title'/string: displays the figure with a given title string
% 'OuterPosition'/4x1 array: Determines the position and size of the window
% 'toolbar'/boolean(false): Determines if a toolbar is present or not
% (FUTURE VERSIONS)

% Jeffrey Moffitt
% jeffmoffitt@gmail.com
% August 18, 2012

% ------------------------------------------------------------------------
% Default variables
% ------------------------------------------------------------------------
name = [];
pos = [];
toolbar = false;
image = [];

% ------------------------------------------------------------------------
% Parse variable arguments
% ------------------------------------------------------------------------
if nargin >= 1
    if (mod(length(varargin), 2) ~= 0 ),
        error(['extra parameters passed to the function ''' mfilename ''' must be passed in pairs.']);
    end
    parametercount = length(varargin)/2;

    for parameterindex = 1:parametercount,
        parameterName = varargin{parameterindex*2 - 1};
        parameterValue = varargin{parameterindex*2};
        switch parameterName
            case 'Name'
                name = parameterValue;
                if ~ischar(parameterValue)
                    error(['Not a valid option for ' parameterName]);
                end
            case 'OuterPosition'
                pos = parameterValue;
                if length(pos) ~= 4
                    error(['Not a valid option for ' parameterName]);
                end
            case 'toolbar'
                toolbar = parameterValue;
                if ~islogical(toolbar)
                    error(['Not a valid option for ' parameterName]);
                end
            case 'image'
                image = CheckParameter(parameterValue, 'array', parameterName);
            otherwise
                error(['the parameter ''' parametername ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end

% ------------------------------------------------------------------------
% Define default values
% ------------------------------------------------------------------------
if isempty(name) && isempty(pos)
    hFig = figure();
elseif ~isempty(name) && isempty(pos)
    hFig = figure('Name', name);
elseif isempty(name) && ~isempty(pos)
    hFig = figure('OuterPosition', pos);
else
    hFig = figure('Name', name, 'OuterPosition', pos);
end
     
hIm = imshow([]); 
hSP = imscrollpanel(hFig,hIm);
set(hSP,'Units','normalized','Position',[0 .1 1 .9])
hMagBox = immagbox(hFig,hIm);
apiSP = iptgetapi(hSP);
set(hFig, 'Toolbar', 'figure');

if ~isempty(image)
    apiSP.replaceImage(image, []);
    apiSP.setMagnification(apiSP.findFitMag());
end

hold on;

