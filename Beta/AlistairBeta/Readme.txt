AlistairBeta Readme

(c) CC BY Alistair Boettiger.   February 2013

Welcome to my Beta development!  This is my active coding repository for all STORM related functions (including some general purpose functions that I use for my STORM analysis).
Feel free to Fork this part of the repository or copy an code here in, just kindly attribute me in your new code.

In this readme I have tried to provide some explanation of the code contained in this folder.
It is organized as one big repo / toolbox, which makes it easy for multiple different codes to share the same functions found here.
The sub-directory lib contains a few programs that other people have written (e.g. from the Matlab Fileserver and Zhuang lab), but I still find useful to call.  


Many of these functions are written to perform all the image rendering and analysis routines which are wrapped by my projects in the GUIs folder
To use those GUIs you will need these functions.  You can also see the help file for any of these functions for information on how to call them directly from your own scripts or functions to write new batch processes.


Beta Files in here required for STORMfinderBeta GUI
----
CompZcal.m  (for z-calibration)
AutoZcal.m  (for z-calibration)
CompChromeWarp.m (for chromatic calibration)
lib\polyfitn.m  (for z-calibration)
lib\corr_mols.m  (for chromatic correction calibration)
lib\cp2tform3D.m (for chromatic correction calibration)

Beta Files in here required for STORMrenderBeta GUI
----
automatch_files.m (matches names based on common file root and common number)
findfile.m  (goes looking for chromatic warp maps)
applyfilter.m   
MultiChnDriftCorrect.m
chromewarp.m
plotSTORM.m
plotSTORM_colorZ.m
GenGaussianSRImage.m
GPUgenerateBlobs0507122.mex % compiled mex to GPU from Fang Huang
Im3D.m
Im3Dslices.m
fxn_rebuild_mosaic.m


Maybe useful
align_by_simulated_annealing.m -- Align N curves stored in an NxM matrix by simulated annealing of left right shifts.  (see help file)