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
![](https://github.com/ZhuangLab/matlab-storm/blob/Alistair/Beta/GUIs/ChromeWarpParameters.PNG)

* Number of sets -- how many different bead movies you have. For example, there may be one series of movies of IR beads where you want to align the 750 channel to the 647 channel, and another series of movies which have visible beads, where you want to align the 488 and 561 channels to the 647 channel. 
* Parameters for Set -- which set of movies are you providing data for
* Channel Names -- these will be used to match parameter files with movies.  They should be a comma separated list.  The channel name should be used as the root of the corresponding parameter file.  (e.g. if the parameter file for the '647' channel data is called '647_parameters', the channel name should be '647' and the Parameter file name roots should be 'parameters'.
* daxfile name roots -- the part of the file name which distinguishes the dax movies which are part of set 1 from all other dax files in the folder. If these are the only dax files in the folder you can leave this parameter blank.
* Parameter file name roots -- the part of the parameter file name after the channel name.  This is needed only to distinguish reference channel parameters which may be different for different movie sets (e.g. 647_IRBead_pars and 647_VisBead_pars).  Only enough of the name to make it unique need be entered.  If there is just one set you can leave it blank.  Note there should still be multiple parameter files in the folder with the bead movies.    
* Reference channel -- one of the channel names should be listed here. 


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
