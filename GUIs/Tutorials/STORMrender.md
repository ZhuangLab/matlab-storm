# STORMrender

## Loading a file
### Basic Loading
To load a file, simply drag and drop a molecule list bin file into the Matlab command window (\*\_list.bin, \*\_mlist.bin, or \*\_alist.bin produced by DaoSTORM3D, InsightM, or STORMfinder).  Matlab will prompt if you want to open the file in STORMrender or just read it into the global variable `binfile`.

Alternatively, you may launch STORMrender and select "File" > "Open bin file".  

### Loading multiple binfiles from a multi-color data set
STORMrender facilitates viewing mutlicolor STORM data, specializing in multi-reporter data.  To load multiple bin files, select "File" > "Open multiple bin files".  Hold down the `ctrl` key to select multiple files.  
STORMrender will then ask you in what order the images were taken.  This is important so that the drift correction can be successfully extrapolated through the movies.  
STORMrender will also ask you for a `chromewarps.mat` file, which tells it the polynomial transform needed to correct for chromatic aberrations.  This transform is not required, but it is highly recommend.  See the STORMfinder tutorial on "Computing chromatic warp maps" for more information on how to generate a `chromewarps.mat` file.   

> Note on multi-color data: STORMrender does not currently treat the molecule class  field (e.g. `molist.c`) field as a separate channel.  
> This could be easily added by programming STORMrender to recognize of the multiple classes (1-8) are present in the `mlist` data.  In this case the data should be split into separate molecule-list structures in different elements of the `mlist`.  New STORMlayers should be added for each channel.

#### Automatic matching of multi-color data
Alternatively, STORMrender can try to automatically match all the files in your working directory based on their file names.  Then you need only increase the counter and it will automatically load all the corresponding bin files and apply the appropriate chromatic alignment and drift correction.  

For this to work your file names will have to adhere to the following structure:

[Explanation of filename structure for automatic multi-color matching] 



## Explore your image
### Toolbar
Hover your mouse of the icons to get a tool tip.

**Open File** - select a new bin file to load.

**Save Image** - saves a tiff file of the current field of view

**Save Image Data** - saves a png of the current field of view and `.mat` file with the a molecule list (`vlist`) which contains molecule data for just the field of view.

**Center Image** - centers STORM image at position indicated by the cursor

**Zoom Enhance** - select a region to zoom in

**Standard Zoom in** - select region of image to zoom in on.  Note this zoom does not increase the STORM resolution (use Zoom Enhance for that).

**Standard Zoom out** - zoom out (reverses standard zoom in)

**Standard pan** - pan around image after standard zoom in. 

**Data cursor** - returns the location and intensity of the pixel beneath the mouse.

**3D surface view** - Generates a 3D surface at given intensity threshold.  Requires plot Z as color turned on in "Options" > "Display Options".

**3D transparent slices** - Generates a 3D image of transparent stack of heat maps. Requires plot Z as color turned on in "Options" > "Display Options".

**3D scatter plot** - plots localizations as a 3D scatter plot
 
**2D scatter plot** - plots localizations as a 2D scatter plot

**color dots by frame number** - plots localizations as a 2D scatter plot, colored blue to red to indicate first to last frame.  Useful in testing for image drift.

**Manual Contrast** - Enter a max and min intensity to improve image contrast. Better to use the min and max boxes in the Levels panel (see Adjust image contrast below).  

**Auto Contrast** - autocontrasts all STORM image channels.


### Zoom tool
Just above the upper right edge of the image you will find a small zoom box.  Here you can easily zoom in or out, or jump to a fixed magnification.  The current magnification (relative to the field of view size) is shown in the box.  If you edit this number and press enter STORMrender will jump to the indicated zoom.  
[Image zoom-tool]

### Navigator Panel
At the upper left of the main viewing panel, STORMrender displays a small version of the image at 1x zoom / full field (see image below).  If you zoom in, a small white box on the Navigator image shows where you are so you can keep your bearing.  
The Navigator Panel refreshes whenever your return to zoom 1. 


### Adjust image contrast
In the "Levels" panel at the right of the image, select the drop-down menu and choose the layer you want to adjust.  
![](https://raw.github.com/ZhuangLab/matlab-storm/master/GUIs/Tutorials/figs/STORMrender_ContrastDemo.PNG)


## Additional Analysis
Now that you can view your binfile data in STORMrender, you may notice that the automatic drift correction in the previous analysis seems not to have worked well (your images are smeary), or that perhaps no drift correction was yet performed.  

In this example substantial drift during the movies was reasonably corrected during the analysis, but has lead to a clear offset in the position of the two color channels:  

![](https://raw.github.com/ZhuangLab/matlab-storm/master/GUIs/Tutorials/figs/STORMrender_load2color.PNG)

You can zoom in on a dense feature in your image and select the color dots by time option to see if there appears to be a systematic shift.  

[Image colortime]


You can try to correct this drift better by selecting the "Analysis" menu and choosing either "Correlation Drift Correction" or "Feducial Drift Correction".  

### Correlation Drift Correction
Correlation Drift Correction will let you reanalyze the whole movie (as Insight and DaoSTORM do) and allow you to change the integration parameters.  Alternatively if a particular structure has lots of localizations that appear to clearly be stretched out as a function of time, you can zoom in on this part of the image and use only these more informative pixels for the correlation based drift correction.    

### Feducial Drift Correction
If you have some feducials (such as beads that remain visible in most frames) in your movie or in a separate bin file that you would like to use to correct drift, STORMrender can extract the frame-by-frame drift from these molecule positions and use that to correct drift in your image data.  

Selecting "Feducial Drift Correction" brings up the options box.

![](https://raw.github.com/ZhuangLab/matlab-storm/master/GUIs/Tutorials/figs/STORMrender_FeducialDriftOptions.PNG)

If successful you should see a plot that shows the drift trajectory

![](https://raw.github.com/ZhuangLab/matlab-storm/master/GUIs/Tutorials/figs/STORMrender_FeducialDriftTraj.PNG)

The command window defaults to print out the details of the bin file and daxfile loaded for feducial drift correction.  If there are multiple beads that fit your feducial criteria, it will also compute a residual error (standard deviation between beads). If there is only one bead this number will be zero.  

![](https://raw.github.com/ZhuangLab/matlab-storm/master/GUIs/Tutorials/figs/STORMrender_FeducialDriftMultiColor.PNG)

Alignment:
![](https://raw.github.com/ZhuangLab/matlab-storm/master/GUIs/Tutorials/figs/STORMrender_FeducialDriftFixed1.PNG)

![](https://raw.github.com/ZhuangLab/matlab-storm/master/GUIs/Tutorials/figs/STORMrender_FeducialDriftFixed2.PNG)

## Adding Overlays
You may wish to overlay your STORM image on some other images (e.g. conventional images taken in the same and or other channels). Simply select "Options" "Add Overlay", select Okay, and navigate to the image you wish to overlay.  STORMrender assumes this image has the same maximum dimensions as the STORM data, so if your binfile is just a cropped ROI, you will need to crop the overlay image to the same dimensions first.  

![](https://raw.github.com/ZhuangLab/matlab-storm/master/GUIs/Tutorials/figs/STORMrender_OverlayDemo.PNG)
