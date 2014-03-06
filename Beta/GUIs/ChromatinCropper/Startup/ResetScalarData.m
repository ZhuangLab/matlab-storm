function ResetScalarData(handles,maxDots,numChns)

global CC

CC{handles.gui_number}.data.mainArea = NaN*zeros(maxDots,numChns);
CC{handles.gui_number}.data.mI = NaN*zeros(maxDots,numChns);
CC{handles.gui_number}.data.mainLocs = NaN*zeros(maxDots,numChns);
CC{handles.gui_number}.data.allArea = NaN*zeros(maxDots,numChns);
CC{handles.gui_number}.data.allLocs = NaN*zeros(maxDots,numChns);
CC{handles.gui_number}.data.cvDensity = NaN*zeros(maxDots,numChns); 
CC{handles.gui_number}.data.driftError = NaN*zeros(maxDots,numChns);
CC{handles.gui_number}.data.mI3 = NaN*zeros(maxDots,numChns);
CC{handles.gui_number}.data.mainVolume = NaN*zeros(maxDots,numChns);


if numChns > 1
    CC{handles.gui_number}.data.area1only = NaN*zeros(maxDots,1);
    CC{handles.gui_number}.data.area2only = NaN*zeros(maxDots,1);
    CC{handles.gui_number}.data.area1or2 = NaN*zeros(maxDots,1);
    CC{handles.gui_number}.data.area1and2 = NaN*zeros(maxDots,1);
    CC{handles.gui_number}.data.overlapMap = cell(maxDots,1);
end