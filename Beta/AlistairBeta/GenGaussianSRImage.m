
  function SR_GaussianImage=GenGaussianSRImage(xsize,ysize,x,y,std,varargin)
  
%--------------------------------------------------------------------------
% SR_GaussianImage=GenGaussianSRImage(xsize,ysize,x,y,std)
%
%  SR_GaussianImage=GenGaussianSRImage(xsize,ysize,x,y,std,'zoom',zm,...
%    'MaxBlobs',1E5,'intensities',mints,'eccentricity',ecc)
%
% This function calls the mex file GPUgenerateGaussianBlobs 
%--------------------------------------------------------------------------
% Required Inputs:
% xsize / scalar / 256  -- original image x-dimension
% ysize / scalar / 256  -- original image y dimension
% x / vector            -- x positions of all molecules
% y  / vector           -- y positions of all molecules
% std                   -- width of of all molecules 
%--------------------------------------------------------------------------
% Outputs:
% image matrix (uint16) with all molecules as Gaussian Blobs
%--------------------------------------------------------------------------
% Optional Inputs:
% 'zoom' / double / 16 
%                      -- zoom scale factor for pixel size.  16 produces
%                       10 nm pixels for standard ~160 nm per pixel camera.
% 'MaxBlobs' / double / 1E5
%                      -- Max number of localizations to send to rendering
%                      code at once.  If this number is too large the
%                      memory on Graphics card will be exceeded, causing
%                      CUDA to crash until the computer system is rebooted.
%                      Big dots (large sigma's) take longer to render
% 'intensities' / vector length n molecules / ones(N,1)
%                     -- Each molecule can be given a different intensity.
%                     It is recommended that the default parameters are
%                     used for most STORM imaging.
% 'eccentricity' / vector length n molecules / zeros(N,1)
%                     -- Each molecule may have a 
%--------------------------------------------------------------------------
%
% Alistair Boettiger
% boettiger@fas.harvard.edu
% Built on Code from Fang Huang (September 17, 2012)
% Copyright Creative Commons CC BY.    
%
% Version 1.1
% Note, this version of code requires GPUgenerateBlobs0507122.mex 
% NOT FOR DISTRIBUTION WITHOUT PERMISSION OF FANG HUANG
% (squallbob@gmail.com)  
% 
% Version 1.0
% Alternatively, use previous version GPUgenerateBlobs.mex for SR_demo
%  addpath(genpath('C:\Users\Alistair\Documents\Projects\GPU_Coding'));
%--------------------------------------------------------------------------



%--------------------------------------------------------------------------
% Hardcoded Variables
%--------------------------------------------------------------------------



%--------------------------------------------------------------------------
% Define default parameters
%--------------------------------------------------------------------------
zm = 16;
MaxBlobs = 1E5; % code will crash if trying to fit more than 1 million molecules.  
cov=single(0*x);
mints =single(cov+1);


%--------------------------------------------------------------------------
% Parse Variable Input Arguments
%--------------------------------------------------------------------------
if nargin > 5
    if (mod(length(varargin), 2) ~= 0 ),
        error(['Extra Parameters passed to the function ''' mfilename ''' must be passed in pairs.']);
    end
    parameterCount = length(varargin)/2;

    for parameterIndex = 1:parameterCount,
        parameterName = varargin{parameterIndex*2 - 1};
        parameterValue = varargin{parameterIndex*2};
        switch parameterName
            case 'zoom'
                zm = parameterValue;
                if length(zm)~=1
                    error(['Not a valid option for ' parameterName]);
                end
            case 'MaxBlobs'
                MaxBlobs = parameterValue;
                if length(MaxBlobs)~=1
                    error(['Not a valid option for ' parameterName]);
                end      
            case 'intensities'
                mints = single(parameterValue);
                if size(mints) ~= size(x) 
                    error('size of intensities must equal size of x-data');
                end
            case 'eccentricity'
                mints = single(parameterValue);
                if size(mints) ~= size(x) 
                    rror('size of eccentricity data must equal size of x-data');
                end                
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.' '  See help ' mfilename]);
        end
    end
end

%--------------------------------------------------------------------------
% Main Function
%--------------------------------------------------------------------------

% Fix inputs for GPUgaussblobs
x = single(zm*x);
y = single(zm*y); 
xsize = single(zm*xsize);
ysize = single(zm*ysize);
x_std = single(zm*std);
y_std = single(zm*std); 
% In general, 2D gaussian fits need not be symmetric blobs.  Hence the
% rendering code will accept different x and y standard deviations, and a
% skew factor determined by cov.  
N=size(x,1);


% Parse call to GPUgenerate blobs into smaller chunks to avoid memory crash
if N>MaxBlobs
    Nloops=ceil(N/MaxBlobs);
    SR_GaussianImage=0;
    for nn=1:Nloops
        st=(nn-1)*MaxBlobs+1;
        en=min(nn*MaxBlobs,N);      
        temp=GPUgenerateBlobs0507122(xsize,ysize, ...
            x(st:en),y(st:en),mints(st:en),x_std(st:en),y_std(st:en),cov(st:en),1);           
        SR_GaussianImage=SR_GaussianImage+temp;    
    end
else
    SR_GaussianImage=GPUgenerateBlobs0507122(xsize,ysize,x,y,mints,x_std,y_std,cov,1);
end
            
SR_GaussianImage = makeuint(SR_GaussianImage,16); % convert to uint16


function Io = makeuint(I,n)
 I = double(I) - min(double(I(:)));
 I = I./max(I(:));   % figure(2); clf; imagesc(I);
 Io = eval(['uint',num2str(n),'(2^n*I)']); 
  

        