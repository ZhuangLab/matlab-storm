%% Startup Script
% -------------------------------------------------------------------------
% This script initializes the matlab workspace and defines useful paths and
% global variables for STORM analysis
% If you already have a startup script add the following code to this
% script. To be functional, there are specific paths that must be set based
% on the vlocal machine.  
% -------------------------------------------------------------------------
% Jeffrey Moffitt, Alistair Boettinger
% January 18, 2013
% -------------------------------------------------------------------------
%% Clear Existing Workspace
close all;
clear all;
clc;
display('------------------------------------------------------------------');
%% Define matlab-storm Path
basePath = 'C:\Users\Alistair\Dropbox\matlab-storm';  %% MODIFY this path for the local machine
disp('Base path set to:')
disp(['     ',basePath]);
functionPaths = {'Functions\IO', ...
    'Functions\Simulation', ...
    'Functions\Misc', ...
    };
display('Adding Function Paths');
for i=1:length(functionPaths)
    addpath([basePath,filesep,functionPaths{i}], '-end');
    display(['    ' functionPaths{i}]);
end
display('------------------------------------------------------------------');
%% Define Global Variables
global defaultDataPath; %Default Path to Data
global defaultSavePath; % Default Path to Save Files
global defaultInsightPath; % Path to InsightM.exe
global defaultMultiFitPath; % Path to DAOSTORM Executible
global PythonPath;  % location of python.exe (Python 2).7 on computer
global DaoSTORMPathSetup; % .bat file to set paths needed for DaoSTORM.
global defaultIniFile; % path to default .ini file for InsightM parameters
global defaultXmlFile; % path to default .xml file for DaoSTORM parameters

% MODIFY THESE PATHS 
defaultDataPath = 'C:\Users\Alistair\Desktop\GeneralSTORM\Matlab';
defaultSavePath = 'C:\Users\Alistair\Desktop\GeneralSTORM\Matlab';
defaultInsightPath = 'C:\Users\Hazen\Insight3\InsightM.exe';
defaultMultiFitPath = 'C:\Users\Hazen\storm_analysis\trunk\3d_daostorm\mufit_analysis.py';
PythonPath = 'C:\Python27\python.exe'; 
DaoSTORMPathSetup = 'C:\Users\Hazen\setpaths.bat'; 
defaultIniFile = 'C:\Users\Alistair\Dropbox\matlab-storm\Templates\647data_pars.ini';
defaultXmlFile = 'C:\Users\Alistair\Dropbox\matlab-storm\Templates\647_3dmufit_pars.xml';

display(['    Default Data Path Set: ' defaultDataPath]);
display(['    Default Save Path Set: ' defaultSavePath]);
display(['    Default Insight Path Set: ' defaultInsightPath]);
display(['    Default DaoSTORM Path Set: ' defaultMultiFitPath]);
display(['    Default .ini File Set: ' defaultIniFile]);
display(['    Default .xml File Set: ' defaultXmlFile]);
display('------------------------------------------------------------------');
