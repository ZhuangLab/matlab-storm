%% Startup Script
% -------------------------------------------------------------------------
% This script initializes the matlab workspace and defines useful paths and
% global variables for STORM analysis
% If you already have a startup script add the following code to this
% script. To be functional, there are specific paths that must be set based
% on the vlocal machine.  
% -------------------------------------------------------------------------
% Jeffrey Moffitt, Alistair Boettiger
% January 18, 2013
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
basePath = 'D:\Users\JeffMoffitt\Dropbox\ZhuangLab\Coding\Matlab\matlab-storm';  %% MODIFY this path for the local machine
addpath(basePath, '-begin');

disp('Base path set to:')
disp(['     ',basePath]);
display('------------------------------------------------------------------');

functionPaths = {'Functions', ...
    'Functions\Analysis', ...
    'Functions\File Conversion', ...
    'Functions\IO', ...
    'Functions\Plotting and Display', ...
    'Functions\Simulation', ...
    'Functions\Misc', ...
    };
display('Adding Function Paths');
for i=1:length(functionPaths)
    addpath([basePath,filesep,functionPaths{i}], '-begin');
    display(['    ' functionPaths{i}]);
end

display('------------------------------------------------------------------');
GUIpaths = {'GUIs', ...
    'GUIs\library', ...
    };
display('Adding GUI Paths');
for i=1:length(GUIpaths)
    addpath([basePath,filesep,GUIpaths{i}], '-begin');
    display(['    ' GUIpaths{i}]);
end

display('------------------------------------------------------------------');
defaultPaths = {'Defaults', ...   
    };
display('Adding Default Settings Paths');
for i=1:length(defaultPaths)
    addpath([basePath,filesep,defaultPaths{i}], '-begin');
    display(['    ' defaultPaths{i}]);
end
display('------------------------------------------------------------------');
cd(basePath);
%% Define Global Variables
global defaultDataPath; %Default Path to Data
global defaultSavePath; % Default Path to Save Files
global defaultInsightPath; % Path to InsightM.exe
global defaultDaoSTORM; % .bat file to set paths needed for DaoSTORM.
global defaultIniFile; % path to default .ini file for InsightM parameters
global defaultXmlFile; % path to default .xml file for DaoSTORM parameters
global defaultGPUmFile; % path to default .mat file for GPU parameters


% MODIFY THESE PATHS 
defaultDataPath = 'N:\';
defaultSavePath = 'D:\Users\JeffMoffitt\Dropbox\ZhuangLab\Coding\Matlab\Data';
defaultIniFile = [basePath, filesep, 'Defaults\647data_pars.ini'];
defaultXmlFile = [basePath, filesep, 'Defaults\647_3dmufit_pars.xml'];
defaultGPUmFile = [basePath, filesep, 'Defaults\GPUmultiPars.mat'];

% THESE SHOULD NOT NEED TO BE CHANGED
% Add Dlls & Python to the system path anytime DaoSTORM is called.  
PythonPath = 'C:\Python27\'; % 
DllPath =  [basePath,filesep,'External', filesep,'DaoSTORM', filesep, 'dlls',filesep];
DaoSTORMPath = [basePath,filesep,'External', filesep,'DaoSTORM', filesep, 'mufit_analysis.py'];
setpath = ['PATH=',PythonPath,';',DllPath,';%PATH%',' & ',PythonPath,'python.exe '];
defaultDaoSTORM = [setpath, DaoSTORMPath];
defaultInsightPath = [basePath,filesep,'External', filesep,'Insight3', filesep, 'InsightM.exe'];

display(['    Default Data Path Set: ' defaultDataPath]);
display(['    Default Save Path Set: ' defaultSavePath]);
display(['    Default Insight Path Set: ' defaultInsightPath]);
display(['    Default DaoSTORM Path Set: ' DaoSTORMPath]);
display(['    Default .ini File Set: ' defaultIniFile]);
display(['    Default .xml File Set: ' defaultXmlFile]);
display(['    Default gpu parameters: ' defaultGPUmFile]);
display('------------------------------------------------------------------');

%% Run local startup
startup_local

