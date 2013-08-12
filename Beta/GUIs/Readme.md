# Beta GUIs 

Welcome to Beta GUIs.  This folder will generally house some of the latest tools for processing STORM data with Matlab.
This code may still have bugs and some functions may not yet be fully implimented.  
Updates in this repository may introduce bugs that didnt exist before (it is a Beta / development repo). 

- Alistair Boettiger

# Current Projects

## STORMfinderBeta
This GUI is the development version of the STORMfinder GUI available in the main GUI programs.

### Getting Started with STORMfinderBeta
#### Opening a file
* drag and drop a `.dax` file into the main Matlab command window and press 1 when prompted to "open with STORMfinderBeta".  
* Alternatively, launch STORMfinderBeta (run the m-file, run the GUI, or type STORMfinderBeta into the command window). Then select File > Open Dax file.  
#### Chormatic Bead Alignment
* 

### New Features
* automated, iterative computation of z-calibration curves from bead data.
* automated computation of 2D and 3D chromatic field correction.  
* chromatic correction accepts arbitrary number of sample movies, with and without quadview
* Multi-instance support within the same Matlab instance?  -- requires changing all globals to a structure element passed around
* uiopen globals (filenames) should just create new elements in cell arrays.  Other globals should become locals.  

### In Development
* Add dualView support to CalcChromeWarp 
* split CalcChromeWarp into subfunctions?


## STORMrenderBeta
This GUI displays navigates and explores bin files in multi color with a collection of 3D viewers. 

### New Features
* Select multiple binfiles to load through GUI menu
* Integrated new form of chromatic warping

### In Development / To Do
* Change contrast control to default to log and make log-based steps using slider. 
* Rewrite automatic paring of files (part of rewrite of load commands)
* Add option to render mlist channels as different colors
* Add overlay dax files
* Add Fiji 3D viewer option (use matlab embedded fiji?) 
* Multi-instance support within the same Matlab instance?  -- requires changing all globals to a structure element passed around
* uiopen globals (filenames) should just create new elements in cell arrays.  Other globals should become locals.  


## Tifviewer
Simple matlab GUI for playing with TIF files 

### Features
* change contrast settings
* flip channels on and off
