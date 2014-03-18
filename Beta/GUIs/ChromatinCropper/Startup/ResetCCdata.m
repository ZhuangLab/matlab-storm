function ResetCCdata(handles)
%% Data structure -- All the stuff we're going to save and export
global CC;

maxDots = 200; 

% General information about spot
CC{handles.gui_number}.data.locusname = '';
CC{handles.gui_number}.data.chromeError = NaN;

% Summary statistics about blobs
numChns = 1; 
ResetScalarData(handles,maxDots,numChns);
CC{handles.gui_number}.data.props2D = cell(maxDots,1);

% Raw data about blobs
CC{handles.gui_number}.data.flists = cell(maxDots,1);
CC{handles.gui_number}.data.vlists = cell(maxDots,1);
CC{handles.gui_number}.data.imaxes = cell(maxDots,1);
CC{handles.gui_number}.data.binnames = cell(maxDots,1);
CC{handles.gui_number}.data.parData = cell(maxDots,1);

% Images of our work
CC{handles.gui_number}.data.convImages = cell(maxDots,1);
CC{handles.gui_number}.data.cellImages = cell(maxDots,1);   
CC{handles.gui_number}.data.stormImages = cell(maxDots,1);   
CC{handles.gui_number}.data.timeMaps = cell(maxDots,1);   
CC{handles.gui_number}.data.stormImagesXZ = cell(maxDots,1);   
CC{handles.gui_number}.data.stormImagesYZ = cell(maxDots,1);   
CC{handles.gui_number}.data.stormImagesX  = cell(maxDots,1);   
CC{handles.gui_number}.data.stormImagesXZfilt = cell(maxDots,1);   
CC{handles.gui_number}.tempData.stormImagesYZfilt = cell(maxDots,1);   
CC{handles.gui_number}.tempData.stormImagesXYfilt = cell(maxDots,1);   
CC{handles.gui_number}.data.areaMaps = cell(maxDots,1);   
CC{handles.gui_number}.data.densityMaps = cell(maxDots,1);  

