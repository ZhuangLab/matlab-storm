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
%% Define matlab-storm Path

basePath = 'C:\Users\Documents\Alistair\Github\matlab-storm';  %% MODIFY this path for the local machine
stormAnalysisPath= 'C:\Users\Documents\Alistair\Github\storm-analysis';  %% MODIFY this path for the local machine
% addpath('C:\Users\Documents\Alistair\Matlab');
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

%% Define Global Variables
global InsightExe; % Path to InsightM.exe
global defaultXmlFile; % path and name of default DaoSTORM parameters
global defaultIniFile;  % path and name of default insight parameters
global defaultGPUmFile; % path to default GPUmultifit pars 
global DaoSTORMexe; % System executable command for DaoSTORM
global ScratchPath;
global PythonPath; 

% MODIFY THESE PATHS 
ScratchPath = [General_STORM,'Test_data\']; 
defaultIniFile= [General_STORM,'STORM_Parameters\647zcal_storm2.ini'];
defaultXmlFile = [General_STORM,'STORM_Parameters\647_mufit3d_pars.xml'];
defaultGPUmFile =  [General_STORM,'STORM_Parameters\GPUmultiPars.mat'];


% Add Dlls & Python to the system path anytime DaoSTORM is called.  
PythonPath = 'C:\Python27\'; % 
newDaoPath = [stormAnalysisPath,'3d_daostorm\'];
windowsDllPath = [stormAnalysisPath,'windows_dll\'];

% The necessary file paths
SetPaths = {[PythonPath,';'];
            [windowsDllPath,';']};

% The new DaoSTORM command. 
SetPathCmd = ['path=',SetPaths{:},' && '];
DaoSTORMcmd = ['python.exe ',newDaoPath,'mufit_analysis.py',' '];


DaoSTORMexe = [SetPathCmd, DaoSTORMcmd];
InsightExe = [basePath,filesep,'External', filesep,'Insight3', filesep, 'InsightM.exe'];



display(['    Scratch Path set: ' ScratchPath]);
display(['    Insight Executable set: ' InsightExe]);
display(['    DaoSTORM Executable set: ' DaoSTORMexe]);
display(['    Default .ini File Set: ' defaultIniFile]);
display(['    Default .xml File Set: ' defaultXmlFile]);
display(['    Default gpu parameters: ' defaultGPUmFile]);
display('------------------------------------------------------------------');


%% cleanup 
clear functionPaths BetaPaths MultiFitPath SetPaths SetPathCmd DaoSTORMcmd;
clear newDaoPath windowsdllPath stormAnalysisPath;
