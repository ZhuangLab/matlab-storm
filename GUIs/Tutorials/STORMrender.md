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

## Additional Analysis
Now that you can view your binfile data in STORMrender, you may notice that the automatic drift correction in the previous analysis seems not to have worked well (your images are smeary), or that perhaps no drift correction was yet performed.  

You can zoom in on a dense feature in your image and select the color dots by time option to see if there appears to be a systematic shift.  

[Image colortime]

You can try to correct this drift better by selecting the "Analysis" menu and choosing either "Correlation Drift Correction" or "Feducial Drift Correction".  Correlation Drift Correction will let you reanalyze the whole movie (as Insight and DaoSTORM do) and allow you to change the integration parameters.  Alternatively if a particular structure has lots of localizations that appear to clearly be stretched out as a function of time, you can zoom in on this part of the image and use only these more informative pixels for the correlation based drift correction.    

If you have some feducials in your movie or in a separate bin file that you would like to use to correct drift, STORMrender can extract the frame-by-frame drift from these molecule positions and use that to correct drift in your image data.  


## Adding Overlays
You may wish to overlay your STORM image on some other images (e.g. conventional images taken in the same and or other channels). Simply select "Options" "Add Overlay", select Okay, and navigate to the image you wish to overlay.  STORMrender assumes this image has the same maximum dimensions as the STORM data, so if your binfile is just a cropped ROI, you will need to crop the overlay image to the same dimensions first.  