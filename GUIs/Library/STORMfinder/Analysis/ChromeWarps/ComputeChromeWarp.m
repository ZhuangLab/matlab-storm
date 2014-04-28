function ComputeChromeWarp(folder,varargin)

global matlabStormPath


%%
% folder = 'Q:\2014-03-27_L3C08\Beads\';
 % folder = 'Q:\2014-03-28_Beads\'

% -------------------------------------------------------------------------
% Default variables
% -------------------------------------------------------------------------
defaults = cell(0,3);
defaults(end+1,:) = {'vischns', 'cell',{'647','561','488'} };
defaults(end+1,:) = {'irchns', 'cell',{'750','647'} };
defaults(end+1,:) = {'visDaxRoot', 'string', 'Vis'};
defaults(end+1,:) = {'irDaxRoot', 'string', 'IR'};
defaults(end+1,:) = {'redVisPars', 'string', [matlabStormPath,'Defaults\redVisBead.xml']};
defaults(end+1,:) = {'yellowVisPars', 'string', [matlabStormPath,'Defaults\yellowVisBead.xml']};
defaults(end+1,:) = {'blueVisPars', 'string', [matlabStormPath,'Defaults\blueVisBead.xml']};
defaults(end+1,:) = {'redIrPars', 'string', [matlabStormPath,'Defaults\redIRBead.xml']};
defaults(end+1,:) = {'irIrPars', 'string', [matlabStormPath,'Defaults\irIRBead.xml']};

defaults(end+1,:) = {'batchsize', 'positive', 10};
defaults(end+1,:) = {'batchsize', 'overwrite', 2};
defaults(end+1,:) = {'overwrite', 'nonnegative', 2};
defaults(end+1,:) = {'hideterminal', 'hideterminal', true};

defaults(end+1,:) = {'matchRadius1','positive',2};
defaults(end+1,:) = {'matchRadius','positive',2};
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

%  parameters = ParseVariableArguments([], defaults, mfilename);

%% Step 1: run dot finding on all data
clc
% modify_script(iniFileIn,iniFileOut,{},{}); 
% redROI = [0 256, 0 256];
% yellowROI = [257 512,0 256];
% irROI = [0 256, 257 512];   
% blueROI = [257 512,257 512];


    
visDaxDir = dir([folder,'*',parameters.visDaxRoot,'*.dax']);
visDax = strcat(folder,{visDaxDir.name}');
irDaxDir =  dir([folder,'*',parameters.irDaxRoot,'*.dax']);
irDax =  strcat(folder,{irDaxDir.name}');

m1 = 1;
m2 = 2;
if  ~isempty(visDax) && isempty(irDax)
    m2=1;
end
    
beadmovie(m1).chns = parameters.irchns;  % {'750','647'};       
beadmovie(m1).dax = irDax;
beadmovie(m1).pars = {parameters.irIrPars,parameters.redIrPars}';
beadmovie(m1).refchn = 2;

beadmovie(m2).chns =  parameters.vischns; %  {'647','561'}; %  {'647','561','488'}; %
beadmovie(m2).refchn = 1;
beadmovie(m2).dax = visDax;
beadmovie(m2).pars = {parameters.redVisPars,parameters.yellowVisPars,parameters.blueVisPars}'; 
beadmovie(m2).binname = {};

beadmovie(m2).pars

for m=1:m2
    if ~isempty(beadmovie(m).dax)
        beadmovie(m).binname = cell(length(beadmovie(m).chns),length(beadmovie(m).dax)); %#ok<*AGROW>
        for i=1:length(beadmovie(m).chns)
            RunDotFinder(...
                'daxnames',beadmovie(m).dax,... 
                'parsfile',beadmovie(m).pars{i},...
                'binname',['DAX','_panel',beadmovie(m).chns{i}],...
                'batchsize',parameters.batchsize,...
                'overwrite', parameters.overwrite,...
                'hideterminal',parameters.hideterminal);
            binfiles = cellfun(@(x) regexprep(x,'.dax',...
                ['_panel',beadmovie(m).chns{i},'_alist.bin']),...
                beadmovie(m).dax,'UniformOutput',false);
            beadmovie(m).binname(i,1:length(beadmovie(m).dax)) = binfiles; 
        end
    else
        if parameters.verbose
            disp('no dax movies found');
        end
    end
end
% daxfile = 'Q:\2014-03-27_L3C08\Beads\Visbeads540_560_0_25.dax'
% binfile = 'Q:\2014-03-27_L3C08\Beads\Visbeads540_560_0_25_647_mlist.bin'
% parsfile = 'C:\Users\Alistair\Documents\Research\Projects\matlab-storm\Defaults\redVisBead.xml'
%   system([daoSTORMexe,' "',daxfile,'" "',binfile,'" "',parsfile,'"']);  
%%


data = MatchSampleAndRefFiles(beadmovie); 

dat = MatchSampleAndRefData(data,'matchRadius',parameters.matchRadius1); % match beads 

[tform_1,tform_1_inv,data2,dat2] = ShiftRotateMatch(dat,data,parameters.matchRadius);

[tform,tform2D,tform_inv,tform2D_inv,dat2] = ComputePolyWarp(dat2);

[figH,cdf2D,cdf2D_thresh,thr] = Plot2DWarpResults(data,dat,dat2,figH);

[figH,cdf,cdf_thresh,thr] = Plot3DWarpResults(data,dat,dat2,figH);

 SaveWarpData(folder,data,figH,tform_1,tform,tform2D,...
                        tform_1_inv,tform_inv,tform2D_inv,...
                        cdf,cdf2D,cdf_thresh,cdf2D_thresh,thr);




