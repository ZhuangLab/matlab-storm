# matlab_storm: To Do List #
This is a place for archiving tasks to be completed to bring the core code up to a version suitable for distribution. It also includes a "wish" list of functionality that currently does not exist, but might be nice if it did. 

## To Do List ##
1.  Make matlabstorm_startup a separate startup script which lives in the matlab-storm folder and is called by bas  startup.  
  * This way updates to the matlabstorm that affect startup can still be tracked by the project GitRepo
  * Also if the user has a startup file they just add one line to call the matlab-storm startup and now the toolbox is 'installed'.  
 

## Wish List ##
1. All paths are self referential.  So the user need only specify the location of \matlab-storm\.
a. The goal here is to lower the number dependencies and also the number of paths that must be hardcoded.  
2. Utilize loadlibrary for interfacing with various dlls
3. Develop work around for current GPU code for rendering
a. Write c-code to render quickly (Jeff)
4. Extend molecule list format
5. Create matlab wrapper for daostorm

## Recently Finished
6. Convert all globals in GUIs to be cell arrays indexed by the ID# of the GUI

 
