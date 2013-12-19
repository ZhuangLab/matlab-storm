%% Startup Script
% -------------------------------------------------------------------------
% This script initializes the matlab workspace and defines useful paths and
% global variables for STORM analysis
% If you already have a startup script add the following code to this
% script. To be functional, there are specific paths that must be set based
% on the local machine.  
% -------------------------------------------------------------------------
% Jeffrey Moffitt, Alistair Boettiger
% December 19, 2013
% -------------------------------------------------------------------------

% Copy the code below into your startup.m file 

%% Define Global Variables

global insightExe; % System executable command for InsightM
global scratchPath; % place for matlab-storm to save temporary files
global pythonPath; % path to Python 2.7
global matlabStormPath; % path to matlab-storm
global stormAnalysisPath; % path to storm-analysis


%% Define Local Paths

% MODIFY THESE PATHS 
scratchPath = 'C:\Users\Alistair\Documents\ScratchPath\'; 
pythonPath = 'C:\Python27\'; 
matlabStormPath = 'C:\Users\Alistair\Documents\Github\matlab-storm\';  
stormAnalysisPath= 'C:\Users\Alistair\Documents\Github\storm-analysis\';  
insightExe = 'C:\Insight3\InsightM.exe';

% Call the matlab-storm startup script
addpath([matlabStormPath,'Startup\']);
matlabstorm_startup;

