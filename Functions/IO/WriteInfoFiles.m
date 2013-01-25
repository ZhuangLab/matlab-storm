function WriteInfoFiles(infoFiles, varargin)
%--------------------------------------------------------------------------
% WriteInfoFiles(infoFiles, varargin);
% This function writes the contents of the structure array, infoFiles, into
% .ini files
%--------------------------------------------------------------------------
% Inputs:
%
% infoFiles/array of info structures: The array of structures written to
% disk
%--------------------------------------------------------------------------
% Outputs:
%
%--------------------------------------------------------------------------
% Variable Inputs:
% 'verbose'/bool/(true): Determine if progress is printed or not.  
%
%--------------------------------------------------------------------------
% Jeffrey Moffitt
% October 3, 2012
% jeffmoffitt@gmail.com
%
% Version 1.0
%--------------------------------------------------------------------------
% Updates
% 01/20/13 Alistair Boettiger (boettiger.alistair@gmail.com)
% fixed vend hend bug that causes files not to display in Insight3
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Hardcoded Variables
%--------------------------------------------------------------------------
quiet = 0;
%--------------------------------------------------------------------------
% Global Variables
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Default Variables
%--------------------------------------------------------------------------
verbose = true;

%--------------------------------------------------------------------------
% Parse Required Input
%--------------------------------------------------------------------------
if nargin < 1
    error('Info file structures must be provided');
elseif ~isstruct(infoFiles)
    error('Info file structures must be provided');    
end

%--------------------------------------------------------------------------
% Parse Variable Input
%--------------------------------------------------------------------------
if nargin > 1
    if (mod(length(varargin), 2) ~= 0 ),
        error(['Extra Parameters passed to the function ''' mfilename ''' must be passed in pairs.']);
    end
    parameterCount = length(varargin)/2;

    for parameterIndex = 1:parameterCount,
        parameterName = varargin{parameterIndex*2 - 1};
        parameterValue = varargin{parameterIndex*2};
        switch parameterName
            case 'verbose'
                verbose = parameterValue;
                if ~islogical(verbose) 
                    error(['Not a valid value for ' parameterName]);
                end
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end

%--------------------------------------------------------------------------
% Write .ini files
%--------------------------------------------------------------------------
for i=1:length(infoFiles)
    dirContents = dir(infoFiles(i).localPath);
    if isempty(dirContents)
        mkdir(infoFiles(i).localPath);
    end
    fid = fopen([infoFiles(i).localPath infoFiles(i).localName], 'w');
    if fid < 0
        error(['Error opening ' infoFiles(i).localPath infoFiles(i).localName]);
    end
    
    fprintf(fid,'%s\r\n','information file for');
    fprintf(fid,'%s\r\n', infoFiles(i).file);
    fprintf(fid,'machine name = %s\r\n', infoFiles(i).machine_name);
    fprintf(fid,'parameters file = %s\r\n', infoFiles(i).parameters_file);
    fprintf(fid,'shutters file = %s\r\n', infoFiles(i).shutters_file);
    fprintf(fid,'CCD mode = %s\r\n', infoFiles(i).CCD_mode);
    fprintf(fid,'data_type = %s\r\n', infoFiles(i).data_type);
    fprintf(fid,'frame dimensions = %d x %d\r\n', ... 
        infoFiles(i).frame_dimensions(1), infoFiles(i).frame_dimensions(2));
    fprintf(fid,'binning = %d x %d\r\n', ... 
        infoFiles(i).binning(1), infoFiles(i).binning(2));
    fprintf(fid,'frame size = %d\r\n', infoFiles(i).frame_size);
    fprintf(fid,'horizontal shift speed = %f\r\n', infoFiles(i).horizontal_shift_speed);
    fprintf(fid,'vertical shift speed = %f\r\n', infoFiles(i).vertical_shift_speed);
    fprintf(fid,'EMCCD Gain = %d\r\n', infoFiles(i).EMCCD_Gain);
    fprintf(fid,'Preamp Gain = %f\r\n', infoFiles(i).Preamp_Gain);
    fprintf(fid,'Exposure Time = %f\r\n', infoFiles(i).Exposure_Time);
    fprintf(fid,'Frames Per Second = %f\r\n', infoFiles(i).Frames_Per_Second);
    fprintf(fid,'camera temperature (deg. C) = %d\r\n', infoFiles(i).camera_temperature);
    fprintf(fid,'number of frames = %d\r\n', infoFiles(i).number_of_frames);
    fprintf(fid,'camera head = %s\r\n', infoFiles(i).camera_head);
    fprintf(fid,'hstart=%d\r\n', infoFiles(i).hstart);
    fprintf(fid,'hend=%d\r\n', infoFiles(i).frame_dimensions(1));  % hend is end of horizontal display for Insight
    fprintf(fid,'vstart=%d\r\n', infoFiles(i).vstart);
    fprintf(fid,'vend=%d\r\n', infoFiles(i).frame_dimensions(2)); %  vend is end of vertical display for Insight
    fprintf(fid,'ADChannel = %d\r\n', infoFiles(i).ADChannel);
    fprintf(fid,'Stage X = %f\r\n', infoFiles(i).Stage_X);
    fprintf(fid,'Stage Y = %f\r\n', infoFiles(i).Stage_Y);
    fprintf(fid,'Stage Z = %f\r\n', infoFiles(i).Stage_Z);
    fprintf(fid,'Lock Target = %f\r\n', infoFiles(i).Lock_Target);
    fprintf(fid,'scalemax = %d\r\n', infoFiles(i).scalemax);
    fprintf(fid,'scalemin = %d\r\n', infoFiles(i).scalemin);
    fprintf(fid,'notes = %s\r\n', infoFiles(i).notes);
    
    if verbose
        display(['Completed info file: ' infoFiles(i).localPath infoFiles(i).localName]);
    end
    fclose(fid);
end