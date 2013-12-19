%% Startup Script
% -------------------------------------------------------------------------
% This script initializes the matlab workspace and defines useful paths and
% global variables for STORM analysis
% Call this script from your local startup (My Documents/Matlab/startup.m)
% -------------------------------------------------------------------------
% Jeffrey Moffitt, Alistair Boettiger
% December 18, 2013
% -------------------------------------------------------------------------


%% Define Global Variables

global insightExe; % System executable command for Insight
global daoSTORMexe; % System executable command for 3d DaoSTORM
global defaultXmlFile; % path and name of default DaoSTORM parameters
global defaultIniFile;  % path and name of default insight parameters
global pythonPath; % path to Python 2.7
global matlabStormPath; % path to matlab-storm
global stormAnalysisPath; % path to storm-analysis
global scratchPath; % default scratch path

%% Define matlab-storm Path

addpath(matlabStormPath, '-begin');
disp('Base path set to:')
disp(['     ',matlabStormPath]);
display('------------------------------------------------------------------');

functionpaths = genpath([matlabStormPath,'Functions']); 
display('Adding Function Paths');
addpath(functionpaths);

GUIpaths = genpath([matlabStormPath,'GUIs']);
display('Adding GUI Paths');
addpath(GUIpaths);

display('------------------------------------------------------------------');
cd(matlabStormPath);


%% Define paths for other STORM analysis software 

% Optionally change the default parameter files
defaultIniFile = [matlabStormPath,'Templates\647data_pars.ini'];
defaultXmlFile = [matlabStormPath,'Templates\647_3dmufit_pars.xml'];


% Set all the necessary paths for DaoSTORM to run  % 
newDaoPath = [stormAnalysisPath,filesep,'3d_daostorm\'];
windowsDllPath = [stormAnalysisPath,filesep,'windows_dll\'];
setWindowsPaths = ['path=',pythonPath,';',windowsDllPath,';',' && '];
setPythonPaths =['set PYTHONPATH=%PYTHONPATH%;',stormAnalysisPath,'/; && '];
daoSTORMcmd = ['python.exe ',newDaoPath,'mufit_analysis.py',' '];
daoSTORMexe = [setWindowsPaths,setPythonPaths,daoSTORMcmd];

display('    Created New Global Variables:');
display(['    scratchPath = ' scratchPath]);
display(['    defaultIniFile = ' defaultIniFile]);
display(['    defaultIniFile = ' defaultXmlFile]);
display(['    daoSTORMexe = ' daoSTORMexe]);
display(['    insightExe = ' insightExe]);
display('------------------------------------------------------------------');
%% cleanup 
clear variables;
