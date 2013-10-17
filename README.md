# matlab_storm #
This collection of matlab, c, python, and GPU code is designed to provide a basic interface for STORM data analysis.  The Graphical User Interfaces (GUIs) should be usable to those with little programming experience.  Many additional STORM related data processing functions are available to the experience matlab user.  

Core code was contributed by Alistair Boettiger and Jeffrey Moffitt.  
All core code contained here is licensed under the creative commons CC BY NC.  See individual help files for more information.
GPU code was contributed by Fang Huang and Keith Lidke.   Please see `Code Attribution` below for information on citing this code. 

## Installation Instructions ##
1. Clone this repository (see below) via git or copy the contents to your hard drive
    * New to Git? Recommended: Sign up for an account at Github.com and `fork` the matlab-storm project.
    * Install Windows Github on your local machine (or GitK).
    * Sign into to Windows Github on your local machine and clone the github project.
2. Copy startup\_demo.m and startup_local.m into your default matlab working directory. Typically this directory is "/My Documents/MATLAB"
3. Change the paths within startup_demo.m to paths specific to your computer.
4. Change the name of startup_demo.m to startup.m
5. Launch matlab

## Instructions for Contributing to matlab-storm
Everyone is welcome to contribute to matlab-storm but any code contributed must follow several general 'clean code' standards.

1. New functions should be written in the form described in /Templates/FunctionTemplate.m and placed in an appropriate folder in /Functions
2. Modifications to existing functions should remain backwards compatible as much as possible.

## Code Attribution
1. Code repository
 
     `title = {https://github.com/ZhuangLab/matlab-storm}`

     `version = {git commit ce8094b603}`  

	`authors = {Alistair Boettiger and Jeff Moffitt}`


2. GPU code for rapid rendering of STORM images from molecule lists was written by Fang Huang in collaboration with Keith Lidke.  See the Lidke lab [software page](http://panda3.phys.unm.edu/~klidke/software.html) for additional details.  Please cite:
>  Huang, F., Schwartz, S. L., Byars, J. M. & Lidke, K. a Simultaneous multiple-emitter fitting for single molecule super-resolution imaging. Biomedical optics express 2, 1377–93 (2011).

=======
## Additional Software for Analysis
Some aspects of this analysis package depend on the Insight and DAO-STORM software packages written by others. These packages can be found online (DAO-STORM; http://zhuang.harvard.edu/software/3d_daostorm.html) or can be provided by request (Insight; Matt Kilroy kilroy at chem.harvard.edu). For instructions on integrating this software with matlab-storm, contact Alistair or Jeff. 
