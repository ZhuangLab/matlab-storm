
Updated 09/06/13

## Bug list
* `RunDotFinder.m` calling InsightM finds a random subset of the molecules picked out by the same parameters when used in frame by frame analysis.  (maybe only happens when drift correction is off? or 2D?)
* `CalcChromeWarp.m` errors when looking for 2 sets of movies and finds only 1 (e.g. looks for IRBeads and VisBeads but finds only VisBeads).  Splitdax and analysis work fine, but system does not continue with beadmapping.  Nfields element of beadmovie remains empty.  


## Fixed bugs
* `STORMfinderBeta.m` can't load 512x256 images. (I think just the dimensions are swapped, Hal/dax lists WxH not HxW).  **Fixed: 09/06/13**
* `CalcChromeWarp.m` Currently assumes both sets of movies have the same number of fields when checking if fitting analysis has already been run:  
**Fixed: 09/06/13  Needs testing.**
* `ReadDaxBeta.m` gets wrong bits from bypass 256x256 camera.  `ReadDax.m` does this right so we should be able to figure out the proper extension.  
**Fixed: 06/11/13**, Returned incorrect frames or incorrect mixed frames when given different start frame.  Error resulting from missing factor of 2 for 16 bit not 8 bit images.
* `STORMfinderBeta.m` InsightM call gives cannot save configuration file error: 
**Fixed: 05/23/13**.  May have fixed  2D mode creates incomplete bin as well. 
* `STORMfinderBeta.m` in 2D mode creates incomplete bin files when using InsightM. 
**Fixed: 05/23/13**, missing `"` in filepath. 
