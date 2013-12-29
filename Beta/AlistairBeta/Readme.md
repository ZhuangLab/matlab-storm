AlistairBeta Readme

(c) CC BY Alistair Boettiger.   February 2013

Welcome to my Beta development!  This is my active coding repository for all STORM related functions (including some general purpose functions that I use for my STORM analysis).
Feel free to Fork this part of the repository or copy an code here in, just kindly attribute me in your new code.

In this readme I have tried to provide some explanation of the code contained in this folder.
It is organized as one big repo / toolbox, which makes it easy for multiple different codes to share the same functions found here.
The sub-directory lib contains a few programs that other people have written (e.g. from the Matlab Fileserver and Zhuang lab), but I still find useful to call.  

Many of these functions are written to perform all the image rendering and analysis routines which are wrapped by my projects in the GUIs folder
To use those GUIs you will need these functions.  You can also see the help file for any of these functions for information on how to call them directly from your own scripts or functions to write new batch processes.


## Required for STORMfinderBeta GUI

filename 		   | 		description   
-------------------|---------------------
CompZcal.m  	   | for z-calibration
AutoZcal.m  	   | for z-calibration
CalcChromeWarp.m   | for chromatic calibration
lib\polyfitn.m     | for z-calibration
lib\corr_mols.m    | for chromatic correction calibration
lib\cp2tform3D.m   | for chromatic correction calibration
zcal_ini2xml.m 	   | port the zcalibration from an ini file into an xmlfile


## Required for STORMrenderBeta GUI

---------------------------------------------------------------------
- automatch_files.m 			matches names based on common file root and common number
- findfile.m  					goes looking for specified file (e.g. warpmap) in nearby folders
- applyfilter.m   				filter on molecule list properties or custom combos
- MultiChnDriftCorrect.m  		Load binfiles, apply global drift correction
- MosaicViewer.m    			load N tiles around this position from the Steve Mosaic
- chromewarp.m 					apply chromatic warp												(Needs update to new chromewarp format)
- fxn_AddOverlay.m 				add an overlay image 												(Needs update or new fxn to add dax files)
- plotSTORM.m 					OBSOLETE															(now obsolete 02/16/13).  schedule to delete.
- plotSTORM_colorZ.m 			takes x,y,z,i and imaxes-structure and plots as gaussian blurs
- GenGaussianSRImage.m 			matlab wrapper for GPUgenerateblobs (called by plotSTORM family)
- GPUgenerateBlobs0507122.mex 	 compiled mex to GPU from Fang Huang
- Im3D.m     					3D iso-surface plot
- Im3Dslices.m   				transparent 3D density map slices
- msublist.m  					return mlist for just a local image



## General Analysis Beta
------------------------------------------------------------------------------
- findclusters.m  				basic 2D dot clustering algorithm (distance based)
- findclusters3D.m				In progress: 3D clustering algorithm (distance based)
- fit2Dgauss.m    				fit x,y data to an elliptical gaussian
- fit3Dgauss.m 					fit x,y,z data to a non-isotropic 3D gaussian sphere
- hist4.m 						extends hist3 2-dimensional sample binning to 3-dimensions
- rectangle3d.m					extends rectangle to 3d boxes
- align_by_simulated_annealing.m  Align N curves stored in an NxM matrix by simulated annealing of left right shifts.  (see help file)

## General Plotting functions
---------------------------------------------------------------------------------------
- normhistall.m 					plots multiple normalized transparent histograms on common axes
- cdfplotall.m 					plot multiple cdfs of data on a common set of axes
