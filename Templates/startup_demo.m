%% Startup Script
% -------------------------------------------------------------------------
% This script initializes the matlab workspace and defines useful paths and
% global variables for STORM analysis
% If you already have a startup script add the following code to this
% script. To be functional, there are specific paths that must be set based
% on the local machine.  
% -------------------------------------------------------------------------
% Jeffrey Moffitt, Alistair Boettiger
% October 16, 2013
% -------------------------------------------------------------------------
%% Clear Existing Workspace
close all;
clear all;
clc;
display('------------------------------------------------------------------');
warning off all
restoredefaultpath; % Clear previous paths
warning on all



%% Define Global Variables
global InsightExe; % System executable command for InsightM
global DaoSTORMexe; % System executable command for DaoSTORM
global defaultInsightPath; % Alternate Name for System executable command for InsightM
global defaultMultiFitPath;  % Alternate Name for  System executable command for DaoSTORM
global defaultXmlFile; % path and name of default DaoSTORM parameters
global defaultIniFile;  % path and name of default insight parameters
global defaultGPUmFile; % path to default GPUmultifit pars 
global ScratchPath; % place for matlab-storm to save temporary files

%% Define matlab-storm Path

% MODIFY THESE PATHS 

basePath = 'C:\Users\Alistair\Documents\Github\matlab-storm\';  
stormAnalysisPath= 'C:\Users\Alistair\Documents\Github\storm-analysis\';  
ScratchPath = 'C:\Users\Alistair\Documents\Scratch\'; 

addpath(basePath, '-begin');
disp('Base path set to:')
disp(['     ',basePath]);
display('------------------------------------------------------------------');

functionpaths = genpath([basePath,filesep,'Functions']); 
display('Adding Function Paths');
addpath(functionpaths);

GUIpaths = genpath([basePath,filesep,'GUIs']);
display('Adding GUI Paths');
addpath(GUIpaths);

BetaPaths = genpath([basePath,filesep,'Beta']);
display('Adding Beta Paths');
addpath(BetaPaths); 
display('------------------------------------------------------------------');
cd(basePath);


%% Define paths for other STORM analysis software 

% Optionally change the default parameter files
defaultIniFile = [basePath,'Templates\647zcal_storm2.ini'];
defaultXmlFile = [basePath,'Templates\647_3dmufit_pars.xml'];
defaultGPUmFile = [basePath,'Templates\GPUmultiPars.mat'];

% Insight3 Path (modify if necessary)
InsightPath = [basePath,filesep,'External', filesep,'Insight3'];

% Set all the necessary paths for DaoSTORM to run  
PythonPath = 'C:\Python27\'; % 
newDaoPath = [stormAnalysisPath,filesep,'3d_daostorm\'];
windowsDllPath = [stormAnalysisPath,filesep,'windows_dll\'];
SetWindowsPaths = ['path=',PythonPath,';',windowsDllPath,';',' && '];
SetPythonPaths =['set PYTHONPATH=%PYTHONPATH%;',stormAnalysisPath,'/; && '];
DaoSTORMcmd = ['python.exe ',newDaoPath,'mufit_analysis.py',' '];


DaoSTORMexe = [SetWindowsPaths,SetPythonPaths,DaoSTORMcmd];
InsightExe = [InsightPath, filesep, 'InsightM.exe'];
 % Alternate Name for System executable command for InsightM
defaultInsightPath = DaoSTORMexe;
defaultMultiFitPath = InsightExe;

demoDaoSTORMcall = ['[DaoSTORMexe,daxfile,',''' '',','defaultXmlFile]'];
demoInsightMcall = ['[InsightExe,daxfile,',''' '',','defaultIniFile]'];


display('    Created New Global Variables:');
display(['    ScratchPath = ' ScratchPath]);
display(['    defaultIniFile = ' defaultIniFile]);
display(['    defaultIniFile = ' defaultXmlFile]);
display(['    defaultGPUmFile = ' defaultGPUmFile]);
display(['    InsightExe = ' InsightExe]);
display(['       To run, use "system(',demoInsightMcall,')"'   ]);
display(['    DaoSTORMexe = ' DaoSTORMexe]);
display(['       To run, use "system(',demoDaoSTORMcall,')"'   ]);
display('------------------------------------------------------------------');
%% cleanup 
clear variables;
