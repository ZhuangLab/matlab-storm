function ComputeChromeWarp

global matlabStormPath


%%
folder = 'Q:\2014-03-27_L3C08\Beads\';

% -------------------------------------------------------------------------
% Default variables
% -------------------------------------------------------------------------
defaults = cell(0,3);
defaults(end+1,:) = {'visDaxRoot', 'string', 'Vis'};
defaults(end+1,:) = {'irDaxRoot', 'string', 'IR'};
% defaults(end+1,:) = {'redVisPars', 'string', [matlabStormPath,'Defaults\647VisBead.ini']};
% defaults(end+1,:) = {'yellowVisPars', 'string', [matlabStormPath,'Defaults\561VisBead.ini']};
% defaults(end+1,:) = {'blueVisPars', 'string', [matlabStormPath,'Defaults\488VisBead.ini']};
% 
% defaults(end+1,:) = {'redIrPars', 'string', [matlabStormPath,'Defaults\647IRBead.ini']};
% defaults(end+1,:) = {'irIrPars', 'string', [matlabStormPath,'Defaults\750IRBead.ini']};
defaults(end+1,:) = {'redVisPars', 'string', [matlabStormPath,'Defaults\redVisBead.xml']};
defaults(end+1,:) = {'yellowVisPars', 'string', [matlabStormPath,'Defaults\yellowVisBead.xml']};
defaults(end+1,:) = {'blueVisPars', 'string', [matlabStormPath,'Defaults\blueVisBead.xml']};

defaults(end+1,:) = {'redIrPars', 'string', [matlabStormPath,'Defaults\redIRBead.xml']};
defaults(end+1,:) = {'irIrPars', 'string', [matlabStormPath,'Defaults\irIRBead.xml']};
defaults(end+1,:) = {'batchsize', 'positive', 10};
defaults(end+1,:) = {'overwrite', 'nonnegative', 2};
defaults(end+1,:) = {'hideterminal', 'hideterminal', true};
defaults(end+1,:) = {'verbose', 'boolean', true};

% -------------------------------------------------------------------------
% Parse necessary input
% -------------------------------------------------------------------------
if nargin < 1
    error('matlabSTORM:invalidArguments', 'A MList is required');
end

% -------------------------------------------------------------------------
% Parse variable input
% -------------------------------------------------------------------------
parameters = ParseVariableArguments(varargin, defaults, mfilename);

% parameters = ParseVariableArguments([], defaults, mfilename);

%% Step 1: run dot finding on all data

% modify_script(iniFileIn,iniFileOut,{},{}); 
% redROI = [0 256, 0 256];
% yellowROI = [257 512,0 256];
% irROI = [0 256, 257 512];   
% blueROI = [257 512,257 512];


visDaxDir = dir([folder,'*',parameters.visDaxRoot,'*.dax']);
visDax = strcat(folder,{visDaxDir.name}');
irDaxDir =  dir([folder,'*',parameters.irDaxRoot,'*.dax']);
irDax =  strcat(folder,{irDaxDir.name}');

m1=1;
beadmovie(m1).chns = {'750','647'};       
beadmovie(m1).dax = irDax;

m2=1;
beadmovie(m2).chns = {'647','561','488'};     
beadmovie(m2).dax = visDax;
beadmovie(m2).pars = {parameters.redVisPars,parameters.yellowVisPars,parameters.blueVisPars}'; 
beadmovie(m2).binname = {};

for m=1:2
    if ~isempty(beadmovie(m).dax)
        beadmovie(m).biname = cell(length(visPars),length(beadmovie(m).dax)); %#ok<*AGROW>
        for i=1:length(beadmovie(m).pars)
            RunDotFinder(...
                'daxnames',beadmovie(m).dax,... 
                'parsfile',beadmovie(m).pars{i},...
                'binname',['DAX','_panel',beadmovie(m).chns{i}],...
                'batchsize',parameters.batchsize,...
                'overwrite',0,... parameters.overwrite,...
                'hideterminal',parameters.hideterminal);
            binfiles = cellfun(@(x) regexprep(x,'.dax',...
                ['_panel',beadmovie(m).chns{i},'_mlist.bin']),...
                beadmovie(m).dax,'UniformOutput',false);
            beadmovie(m).binname(i,1:length(beadmovie(m).dax)) = binfiles; 
        end
    end
end
% daxfile = 'Q:\2014-03-27_L3C08\Beads\Visbeads540_560_0_25.dax'
% binfile = 'Q:\2014-03-27_L3C08\Beads\Visbeads540_560_0_25_647_mlist.bin'
% parsfile = 'C:\Users\Alistair\Documents\Research\Projects\matlab-storm\Defaults\redVisBead.xml'
%   system([daoSTORMexe,' "',daxfile,'" "',binfile,'" "',parsfile,'"']);  


data = MatchSampleAndRefFiles(beadmovie)



