
Updated 06/11/13

## Bug list

## Fixed bugs
* `STORMfinderBeta.m` InsightM call gives cannot save configuration file error: **Fixed: 05/23/13**.  May have fixed  2D mode creates incomplete bin as well. 
* `STORMfinderBeta.m` in 2D mode creates incomplete bin files when using InsightM: **Fixed: 05/23/13**, missing `"` in filepath. 
* `ReadDaxBeta.m` gets wrong bits from bypass 256x256 camera.  `ReadDax.m` does this right so we should be able to figure out the proper extension.  **Fixed: 06/11/13**, Returned incorrect frames or incorrect mixed frames when given different start frame.  Error resulting from missing factor of 2 for 16 bit not 8 bit images.
