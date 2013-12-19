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

#### InsightM Fit Parameters
The InsightM parameter selection window should look like this:

![](https://raw.github.com/ZhuangLab/matlab-storm/master/GUIs/Tutorials/figs/InsightMpars.PNG)
The parameter names should be self-explanatory.

#### DaoSTORM Fit Parameters
The DaoSTORM parameter selection window should look like this:
![](https://raw.github.com/ZhuangLab/matlab-storm/master/GUIs/Tutorials/figs/DaoSTORMpars.PNG)

The parameters are similar to the those for insightM.
**Method** is one of "2dfixed, 2d, 3d, or Z"

* 2dfixed - fixed sigma 2d gaussian fitting.
* 2d - variable sigma 2d gaussian fitting.
* 3d - x, y sigma are independently variable, z will be fit after peak fitting.
* Z - x, y sigma depend on z, z is fit as part of peak fitting.

**Threshold** is the same as min height in InsightM.  One notable exception is that if "max iterations" is set to 4 or less, than threshold should be 1/4 the corresponding value used with Insight.  (During the DaoSTORMs first 4 iterations it looks only for very bright molecules, 4 times the minimum threshold).

**Max iterations** is the number of iterations of subtraction performed by the DaoSTORM routine.  See the original DaoSTORM publication for more description.  

**Descriptor** allows for different frame definitions for multi-Activator STORM.

* 0 - activation frame
* 1 - non-specific frame
* 2 - channel1 frame
* 3 - channel2 frame
* 4 - etc..

**max displacement** molecules that are on in consecutive frames with centroids within this distance in pixels will be linked together in the resulting `_alist.bin` file.  Their photons will be averaged together to determine the centroid.

### Advanced Options
In the upper right, after the "Data File" name, you will a small "inst id#".  matlab-storm supports multiple instances of STORMfinder to run simultaneously and each is assigned a unique id#.  All data for this instance can also be accessed in the command line through the global variable SF.  This is a cell array of size the number of instances of STORMfinder you have opened.  Each cell entry contains a structure with all the parameter selections and filepaths corresponding to that instance.   

## Computing Z-Calibration from Astigmatism Imaging 
If you recorded a z-calibration movie of fluorescent beads using the Hal4000 microscope software, you can load the corresponding dax file into STORMfinder and run "Compute Z-Calibration" from the "Analysis" menu to generate updated parameter files.

You have several options that can be modified.  

![](https://raw.github.com/ZhuangLab/matlab-storm/master/GUIs/Tutorials/figs/STORMfinder_zcal1.PNG)

**New Parameter File Name** If you want a particular file name for the new parameter file that will be written (e.g. "myPars.xml") you can write that here.  Otherwise the file will have the same name as the original daxfile with "_zpars" appended on the end (and be of type `.xml` or `.ini` depending on the template you specify).

**Template Parameter file name** The coefficients for the z-calibration curve will be computed from your movie.  The rest of the parameters in the generated parameters file will come from a template.  This will be the system default parameters unless you specify another file.  To open a the windows-browser to find the file, type "open". 

**Run in Matlab**
Setting this to false will cause the script to run externally rather than in the command window.  

**Run silently**
Determines whether a new window opens to display fitting progress (if Run in Matlab is false) or whether progress is printed to Matlab command line (if Run in Matlab is true). 

**Overwrite**
If bin files already exist for this dax-file, should STORMfinder overwrite them, skip the analysis and use the existing files, or prompt the user for a decision at the time.  

**Show plots?**
Display the fitted curves in figure(1)?

**Show extra plots?**
Good for troubleshooting.  More plots illustrating the progress of the fitting routine in identifying feducials and fitting curves will be shown.

**Edit calibration parameters?**
Opens a new parameter window where you can modify the calibration parameters if your data is giving poor fits or no fits.  



> Note 1: Compute Z-Calibration assumes the movie is of diffraction-limited beads, some of which are visible in all frames of the Z-scan.  If your movie is of blinking single molecules on a solid coverslip, this function will not work.
> 
> Note 2:  Compute Z-Calibration does not assume the beads are located in a common plane, and can successfully handle beads distributed in 3D space.   

A successful execution should produce a set of calibration curves that look like this:

![](https://raw.github.com/ZhuangLab/matlab-storm/master/GUIs/Tutorials/figs/STORMfinder_zcal2.PNG)

The curve coefficients are also printed to the matlab command window.  As we can see in the command window, a new parameter file (in this case a DaoSTORM parameter file called `647zcal_0001_zpars.xml`) has also been written to disk.  

![](https://raw.github.com/ZhuangLab/matlab-storm/master/GUIs/Tutorials/figs/STORMfinder_zcal3.PNG)  

## Computing Chromatic Warp Maps

To compute a chromatic warp map to correct for chromatic aberrations between different color channels, you will need a a series of `.dax` movies of the same beads visible in each channel (either use multi-color beads or use high laser excitation and use the fluorescent blead-through).  

Run "Analysis", Compute Chromatic Warp.   