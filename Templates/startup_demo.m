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
global defaultInsightPath; % Path to InsightM.exe
global defaultDaoSTORM; % .bat file to set paths needed for DaoSTORM.
global defaultIniFile; % path to default .ini file for InsightM parameters
global defaultXmlFile; % path to default .xml file for DaoSTORM parameters
global ScratchPath;

% THESE YOU MAY WISH TO MODIFY
ScratchPath = [basePath,filesep,'ScratchFolder',filesep];
defaultIniFile = [basePath, filesep, 'Defaults',filesep,'647data_pars.ini'];
defaultXmlFile = [basePath, filesep, 'Defaults',filesep,'647_3dmufit_pars.xml'];

% THESE SHOULD NOT NEED TO BE CHANGED
% Add Dlls & Python to the system path anytime DaoSTORM is called.  
PythonPath = 'C:\Python27\'; % 
DllPath =  [basePath,filesep,'External', filesep,'DaoSTORM', filesep, 'dlls',filesep];
DaoSTORMPath = [basePath,filesep,'External', filesep,'DaoSTORM', filesep, 'mufit_analysis.py'];
setpath = ['PATH=',PythonPath,';',DllPath,';%PATH%',' & ',PythonPath,'python.exe '];
defaultDaoSTORM = [setpath, DaoSTORMPath];
defaultInsightPath = [basePath,filesep,'External', filesep,'Insight3', filesep, 'InsightM.exe'];

display(['    Scratch Path Set: ' ScratchPath]);
display(['    Default Insight Path Set: ' defaultInsightPath]);
display(['    Default DaoSTORM Path Set: ' defaultDaoSTORM]);
display(['    Default .ini File Set: ' defaultIniFile]);
display(['    Default .xml File Set: ' defaultXmlFile]);
display('------------------------------------------------------------------');


