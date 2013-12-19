# STORMfinder

This GUI is designed to display and analyze raw STORM data (`*.dax` files).  

## View a Dax File and Select Parameters

### Opening a dax file 
To open a dax file in the GUI you can drag and drop a `.dax` file into the matlab command window.  Matlab will prompt if you want to open the file in STORMfinder.  Simply respond yes and it will open.

Alternatively, you can launch the GUI directly (type STORMfinder into the command window), and select "Load Dax File" from the "File" menu.

### Choosing fitting parameters
At the bottom of the GUI you will see a drop down menu called "Fit Method".  The default method is InsightM.  

> Note: To use InsightM, you must have "Insight3" installed and the filepath to InsightM recorded in your `matlab_startup.m` file.  To use DaoSTORM you must have the "storm-analysis" repository installed and its location recorded in your `matlab_startup.m`.  

Below the file menu are a string of icons.  Hover your mouse over these icons for an explanation of what they do.  

The first icon is calls the selected spot-finding algorithm specified by "Fit Method" with the currently selected parameters.  If no parameter file is loaded, STORMfinder will use the default parameters for the selected method.  

To change parameters, Click the "Fit Parameters" button at the bottom of the window.  This will bring up a new window allowing you to edit the fitting parameters.  The window will be different depending on the method selected.  

### Advanced Options
In the upper right, after the "Data File" name, you will a small "inst id#".  matlab-storm supports multiple instances of STORMfinder to run simultaneously and each is assigned a unique id#.  All data for this instance can also be accessed in the command line through the global variable SF.  This is a cell array of size the number of instances of STORMfinder you have opened.  Each cell entry contains a structure with all the parameter selections and filepaths corresponding to that instance.   

## Computing Z-Calibration from Astigmatism Imaging 
If you recorded a z-calibration movie of fluorescent beads using the Hal4000 microscope software, you can load the corresponding dax file into STORMfinder and run "Compute Z-Calibration" from the "Analysis" menu to generate updated parameter files.

> Note 1: Compute Z-Calibration assumes the movie is of diffraction-limited beads, some of which are visible in all frames of the Z-scan.  If your movie is of blinking single molecules on a solid coverslip, this function will not work.
> 
> Note 2:  Compute Z-Calibration does not assume the beads are located in a common plane, and can successfully handle beads distributed in 3D space.   
  

## Computing Chromatic Warp Maps

To compute a chromatic warp map to correct for chromatic aberrations between different color channels, you will need a a series of `.dax` movies of the same beads visible in each channel (either use multi-color beads or use high laser excitation and use the fluorescent blead-through).  

Run "Analysis", Compute Chromatic Warp.   