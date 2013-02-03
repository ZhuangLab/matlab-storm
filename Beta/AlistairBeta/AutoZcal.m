function [xerr,yerr] = AutoZcal(daxfile,varargin)
%--------------------------------------------------------------------------
% [xerr,yerr] = AutoZcal(bead_path,varargin)
% 
% [xerr,yerr] = fxn_autoZcal(bead_path,'default ini dir',value,...
%        'ini root', value, 'bead name', value,'max iterations',value,...
%       'max_uncert',value,'insight',value,'print2terminal',value,...
%       'QuadView512',value,'chns',value);
%
% uses predfined insight ini parameters for each color channel and computes
%       a 3D astigmatism warping function for each color channel.  This is
%       saved along with the default values as a .ini file.  
%-------------------------------------------------------------------------
% Inputs:
% bead_path / string / 'C:/data/Beads/'
%                -- location of bead data for z-calibration and chromatic
%                calibration
%--------------------------------------------------------------------------
% Outputs:
% xerr / yerr  / vector 
%               -- uncertainity for each of the 5 fit parameters. 
%  _list.bin files for zcalibration bead movies.  
%  .ini files for all chns provided
%
% Notes: this fxn requires the fxn write_minimal_dax_ini_file.m
%        and the folder Zcalibration, with fxn fxnZcal.m and dependents 
%--------------------------------------------------------------------------
% Optional Inputs
% 'default ini dir' / string / 'C:\Matlab_STORM\Parameters'
%                -- contains initial .ini files for each channel to use 
%                for the first run only.  
% 'ini root' / string / '_zcal_storm4.ini'
%               -- specify which ini files to initialize on.  name must
%               include the .ini and start with the channel (e.g. 561z.ini)
%               or a default using [647 ini_root] will be used.  
% 'bead name' / string / 'zcal'
%               -- string contained in filenames of z-calibration files
%                   if not 647, name must begin with channel (e.g. 561). 
% 'max iterations' / integer / 8
%               -- maximum number of iterations to try to make confidence
%                 intervals in fit obtain desired bound
% 'max uncert' / vector / [.01 .1 .2 .5 .5]
%               -- maximum uncertainty tolerated in fit parameters 
% 'insight' /string / 
%               -- string location and version of InsightM for analysis
% 'print2terminal' / logical / false
%               -- should progress log from insight be printed to the
%                   matlab terminal or saved as a text file.
% 'Quadview512' / logical / false
%               -- are z-calibration movies taken in 512x512_Quadview? 
% 'chns' / cell of strings / {'750','647','561','488'}; 
%               -- list of the channel roots for which to perform
%               z-calibration.  
%--------------------------------------------------------------------------
%
% Alistair Boettiger
% boettiger@fas.harvard.edu
% September 18, 2012
% Copyright Creative Commons 3.0 CC BY.    
%
% Version 1.1
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Global Variables
%--------------------------------------------------------------------------
global defaultInsightPath defaultIniFile


%--------------------------------------------------------------------------
% Hardcoded Variables
%--------------------------------------------------------------------------
% addpath('C:\Users\Alistair\Documents\Projects\General_STORM\Matlab_STORM\lib\Zcalibration');

%--------------------------------------------------------------------------
% Define default parameters
%--------------------------------------------------------------------------
insight = defaultInsightPath;
inifile = defaultIniFile;
max_iterations = 8;
max_uncert = [.01 .1 .2 .5 .5];
print2terminal = true;

%--------------------------------------------------------------------------
%% Parse mustHave variables
%--------------------------------------------------------------------------
if nargin < 1
   error([mfilename,' expects 1 inputs, folder, bead_folder and binnames']);
end


%--------------------------------------------------------------------------
%% Parse Variable Input Arguments
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
            case 'max iterations'
                max_iterations  = CheckParameter(parameterValue, 'positive', 'max iterations');
            case 'print2terminal'
                print2terminal = CheckParameter(parameterValue, 'boolean', 'print2terminal');
            case 'chns'
                chns = parameterValue;
            case 'inifile'
                inifile = CheckParameter(parameterValue, 'string', 'inifile');
            case 'max uncert'
                max_uncert = parameterValue;
                if length(max_uncert) ~= 5; 
                     error(['Not a valid option for ' parameterName]);
                end 
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.' '  See help ' mfilename]);
        end
    end
end

%%

% arrays to record final uncertainty   
x_below_bnd = [0,0,0,0,0];
y_below_bnd = [0,0,0,0,0];
iters = 0;

k = strfind(daxfile,filesep);
bead_path = daxfile(1:k(end));


   nooverwrite  = false;
    while sum([x_below_bnd,y_below_bnd]) < 10  && iters < max_iterations
        iters = iters + 1;  % cap on max iterations to converge
        disp(['iteration ',num2str(iters)]);
        if ~print2terminal
            ccall = ['!',insight,' ',daxfile,' ',inifile,' >' bead_path,'\newlog',num2str(k),'.txt'];
        else
            ccall = ['!',insight,' ',daxfile,' ',inifile];
        end
        disp(['!',insight]);
        disp(daxfile);
        disp(inifile); % print command to screen
        eval(ccall);  % Run insightM to get positions

        % Need to wait until _list.bin file appears before calling fxn_Zcal to compute  
        done = length(dir([daxfile(1:end-4),'_list.bin']));
        twait = 0; tic
        while done == 0 && twait < 20;
            done = length(dir([daxfile(1:end-4),'_list.bin']));
            pause(1); 
            twait = toc; 
        end
        disp('bead-fitting complete. Fitting calibration curves...');
 %----------------------------------------------------------------
  % run z-calibration, get updated ini file
 %----------------------------------------------------------------
        
[ini_nm, fresx2, fresy2] = ComputeZCalibration('daxfile',daxfile,'inifile',inifile,'nooverwrite',nooverwrite);
 % note, this changes the ini being used to the recent one. 
        nooverwrite = true; % this causes the function to save separate versions of the z-calibration output images for each iteration. 
inifile = ini_nm; % change inifile to current file.  

%------------------------------------------------------------------
% Compute uncertainty bounds. 
%------------------------------------------------------------------
% Will stop when these converge to within the indicated tolerances
        c95 = confint(fresx2);
         x_uncert = abs( ( c95(2,:) - c95(1,:) ) ./ [fresx2.w0, fresx2.zr, fresx2.g fresx2.A fresx2.B]);
         x_below_bnd = x_uncert < max_uncert;
         disp(['x uncertainty = ',num2str(x_uncert)]);

         c95 = confint(fresy2);
         y_uncert = abs( ( c95(2,:) - c95(1,:) ) ./ [fresx2.w0, fresx2.zr, fresx2.g fresx2.A fresx2.B]);
         y_below_bnd = y_uncert < max_uncert;
         disp(['y uncertainty = ',num2str(y_uncert)]);
    end % loop back and iterate with new ini file.  

    if iters < max_iterations || sum([x_below_bnd,y_below_bnd]) == 10 % abs(old_w0x - new_w0x) < 1
        disp('Z-calibration converged');
    else
        disp('Z-calibration did not converge ');
        disp(c95);
        disp(['fit uncertainty: x= ',num2str( x_uncert ), '   y=',num2str( y_uncert ) ]);
    end

        xerr = x_uncert;
        yerr = y_uncert;

disp('Z-calibration finished'); 