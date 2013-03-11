# matlab_storm #
This collection of matlab, c, and python code is designed to provide a basic interface for STORM data analysis.

Core code was contributed by Alistair Boettinger and Jeffrey Moffitt.  

All code contained here is liscensed under the creative commons CC BY NC.

## Installation Instructions ##
1. Clone this repository via git or copy the contents to your hard drive
2. Copy startup_demo.m and startup_local.m into your default matlab working directory. Typically this directory is "/My Documents/MATLAB"
3. Change the paths within startup_demo.m to paths specific to your computer.
4. Add existing startup commands to startup_local.m
5. Change the name of startup_demo. to startup.m
6. Launch matlab

## Instructions for Contributing to matlab-storm
Everyone is welcome to contribute to matlab-storm, but any code contributed must follow several general 'clean code' standards.
1. New functions should be written in the form described in /Templates/FunctionTemplate.m and placed in an appropriate folder in /Functions
2. Modifications to existing functions should remain backwards compatible as much as possible.

## Additional Software for Analysis
Some aspects of this analysis package depend on the Insight and DAO-STORM software packages written by others. These packages can be found online (DAO-STORM; http://zhuang.harvard.edu/software/3d_daostorm.html) or can be provided by request (Insight; Matt Kilroy kilroy at chem.harvard.edu). For instructions on integrating this software with matlab-storm, contact Alistair or Jeff. 