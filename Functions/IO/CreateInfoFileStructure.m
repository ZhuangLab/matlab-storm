function infoFile = CreateInfoFileStructure()
%--------------------------------------------------------------------------
% infoFile = CreateInfoFileStructure()
% This function creates an empty infoFile structure.
%--------------------------------------------------------------------------
% Inputs:
% 
%--------------------------------------------------------------------------
% Outputs:
% infoFile: An empty structure with all of the field elements appropriate
% for an info file
%--------------------------------------------------------------------------
% Variable Inputs:
% 
%--------------------------------------------------------------------------
% Jeffrey Moffitt
% October 3, 2012
% jeffmoffitt@gmail.com
%
% Version 1.0
%--------------------------------------------------------------------------
% Updates 
% 01/20/12
% hend and vend determine the window size in insight (i.e. 256 x 256)
% Insight3 opens only a single pixel if these are each 1.  
% Alistair Boettiger (boettiger.alistair@gmail.com)
%--------------------------------------------------------------------------


infoFile.localName = '';
infoFile.localPath = '';
infoFile.uniqueID = now;
infoFile.file = '';
infoFile.machine_name = '';
infoFile.parameters_file = '';
infoFile.shutters_file = '';
infoFile.CCD_mode = '';
infoFile.data_type = '16 bit integers (binary, big endian)';
infoFile.frame_dimensions = [0 0];
infoFile.binning = [1 1];
infoFile.frame_size = 0;
infoFile.horizontal_shift_speed = 0;
infoFile.vertical_shift_speed = 0;
infoFile.EMCCD_Gain = 1;
infoFile.Preamp_Gain = 1;
infoFile.Exposure_Time = 1;
infoFile.Frames_Per_Second = 1;
infoFile.camera_temperature = 1;
infoFile.number_of_frames = 1;
infoFile.camera_head = '';
infoFile.hstart = 1;
infoFile.hend = 256;
infoFile.vstart = 1;
infoFile.vend = 256;
infoFile.ADChannel = 0;
infoFile.Stage_X = 0;
infoFile.Stage_Y = 0;
infoFile.Stage_Z = 0;
infoFile.Lock_Target = 0;
infoFile.scalemax = 0;
infoFile.scalemin = 0;
infoFile.notes = '';
