function ChromeWarpParsDefaults

disp('defaults reset');

global chromeWarpPars

% Set defaults:
if isfield(chromeWarpPars,'OK');  % only update on load, not on exit
    init = 0;
    if ~chromeWarpPars.OK
        init = 1;
    end
else
    init = 1;
end  

if init
    chromeWarpPars.ChannelNames{1} = '750,647';
    chromeWarpPars.DaxfileRoots{1} = 'IRbeads';
    chromeWarpPars.ParameterRoots{1} = 'Ir';
    chromeWarpPars.ReferenceChannel{1} = '647';
    chromeWarpPars.Quadview{1} = 1;

    chromeWarpPars.ChannelNames{2} = '647,561,488';
    chromeWarpPars.DaxfileRoots{2} = 'Visbeads';
    chromeWarpPars.ParameterRoots{2} = 'Vis';
    chromeWarpPars.ReferenceChannel{2} = '647';
    chromeWarpPars.Quadview{2} = 1;
    chromeWarpPars.ListQVorder = '647,561,750,488';
    
    disp('reset default values');
end

