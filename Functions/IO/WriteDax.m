function infoFile = WriteDax(dax,varargin)
% Writes the matrix "dax" to a .dax file
% automatically completes necessary information in the .inf file
% 
% 
global scratchPath

defaults = cell(0,3);
defaults(end+1,:) = {'folder', 'string', scratchPath}; % 
defaults(end+1,:) = {'daxName', 'string', 'temp'}; % 
defaults(end+1,:) = {'verbose', 'boolean', true}; % 
parameters = ParseVariableArguments(varargin, defaults, mfilename);

[yDim,xDim,nFrames] = size(dax); 

                 infoFile.localName= [parameters.daxName,'.inf'];
                 infoFile.localPath= parameters.folder;
                  infoFile.uniqueID= 7.3616e+05;
                      infoFile.file= '';
              infoFile.machine_name= 'matlab-storm';
           infoFile.parameters_file= '';
             infoFile.shutters_file= '';
                  infoFile.CCD_mode= 'frame-transfer';
                 infoFile.data_type= '16 bit integers (binary, big endian)';
          infoFile.frame_dimensions= [yDim xDim];
                   infoFile.binning= [1 1];
                infoFile.frame_size= xDim*yDim;
    infoFile.horizontal_shift_speed= 10;
      infoFile.vertical_shift_speed= 3.3000;
                infoFile.EMCCD_Gain= 30;
               infoFile.Preamp_Gain= 5.1000;
             infoFile.Exposure_Time= 0.5000;
         infoFile.Frames_Per_Second= 1.9930;
        infoFile.camera_temperature= -68;
          infoFile.number_of_frames= nFrames;
               infoFile.camera_head= 'DU897_BV';
                    infoFile.hstart= 1;
                      infoFile.hend= xDim;
                    infoFile.vstart= 1;
                      infoFile.vend= yDim;
                 infoFile.ADChannel= 0;
                   infoFile.Stage_X= 0;
                   infoFile.Stage_Y= 0;
                   infoFile.Stage_Z= 0;
               infoFile.Lock_Target= 0;
                  infoFile.scalemax= 1844;
                  infoFile.scalemin= 100;
                     infoFile.notes= '';
                     
 WriteDAXFiles(dax,infoFile,'verbose',parameters.verbose);
 