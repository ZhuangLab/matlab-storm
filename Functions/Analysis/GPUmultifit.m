function mlist = GPUmultifit(movie,GPUmultiPars)
% GPUmultifitDax(daxfile,GPUmultiPars)
%-------------------------------------------------------------------------
% A small wrapper that calls the GPUmultifit routine written by Fang. 
%-------------------------------------------------------------------------
% Outputs:
% mlist / structure         -- molecule list
%-------------------------------------------------------------------------
% Additional Outputs:
% SuperRes: 2-D matrix represents super resolution image
% x,y,t   : list of localized particle coordinates and frame number (0 based)
% uncerx,uncery,uncerbh cov: list of localization particle's uncertainty in x y 
%                           background and convariance coefficient
% LLR     : LLR value for each estimates.
% nfit    : number of emitter in the model when obtaining the estimate.
%          ie: for single fit, all nfit is 1. for multi fit N_max=5, nfit
%          will range from 1-5 depend on active density in each frame.
% bb      : background estimate for each localized emitter
% nn      : intensity estimate for each localized emitter
% 
%-------------------------------------------------------------------------
% Inputs:
% daxfile / string          -- full path directory of a daxfile
% GPUmultiPars / structure  -- fitting parameters for GPUmultifit  
%--------------------------------------------------------------------------
% 
% Hint: 
% recommend ~1000 frame used in fitting per batch.  
% Bigger images (ie 512 by 512) would result in a higher memory comsuption
% would then potentially crash matlab (or output 0 matrix for SuperRes)
% because of overflow in host memory or GPU global memory.
%
% Try split frames into chucks and looping through them.
% ie: for 10000 frames, create a loop to fit 1000 each iteration for 10
% iterations and cat(x y intensity) or sum (super resolution image) all result 
% together after the loops.
%
%% Reference:
%Simultaneous multiple-emitter fitting for single molecule 
%super-resolution imaging, Fang Huang, Samantha L. Schwartz, Jason M. Byars, 
%and Keith A. Lidke, Biomedical Optics Express, Vol. 2, Issue 5, pp. 1377-1393 (2011) 
%
%
%Please do not hesitate email me at fang.huang@yale.edu for any questions.
%It is always my pleasure to help!
%
%A matlab-class for multi fitting code (and also the single fitting code,
%Smith2010 NatMeth) is being put together with tutorials and detailed helps 
%for this algorithm. I will keep you updated on the project.


%-------------------------------------------------------------------------
% Default Parameters 
%-------------------------------------------------------------------------
if isempty(GPUmultiPars)
    GPUmultiPars.PSFsigma='1.2';
         % estimated PSF sigma in pixels
    GPUmultiPars.Nave = '800'; 
          % Initial guess for intensity. Intensity is also fitted in 
          % this 103.3 version unlike described in original publication 2011 May.
          % This is still an essential guess that would affect model
          % selection             
    GPUmultiPars.Nmax='5';       
          %Maximum emitter number in fitting model. ie: 1 for single emitter fitting
          %5 for multi emitter fitting.            
    GPUmultiPars.pvalue_threshold='0.001'; 
        % p_value threshold used for test goodness of fitting 
        % using significance test                      
    GPUmultiPars.resolution='30';      
       % in nano meters. Resolution target. Estimates with higher uncertainty value
       % is discarded.                  
    GPUmultiPars.pixelsize='158';        
       % in nano meters. Pixel size of the camera=real_size/magification.
       % ie: 100 nm or 80 nm                    
    GPUmultiPars.boxsz='7';    
       % fitting subregion box size in pixels.
    GPUmultiPars.counts_per_photon = '3';
    % Code is very sensitive to scaling of intensities.
    % GPUmultiPars.startFrame = '1';  % needed only for GPUmultifitDax.m
    % GPUmultiPars.endFrame = '-1'; % needed only for GPUmultifitDax.m
end
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
% Hardcoded
%-------------------------------------------------------------------------
GPUmultiPars.zm='15';   %  zoom factor. Avoid zoom as a variable name. 




%-------------------------------------------------------------------------
% Main Function
%-------------------------------------------------------------------------

% a little translation
counts_per_photon = str2double(GPUmultiPars.counts_per_photon);
PSFsigma = str2double(GPUmultiPars.PSFsigma);
Nave = str2double(GPUmultiPars.Nave);
Nmax = str2double(GPUmultiPars.Nmax);
pvalue_threshold = str2double(GPUmultiPars.pvalue_threshold);
resolution = str2double(GPUmultiPars.resolution);
pixelsize = str2double(GPUmultiPars.pixelsize);
zm = str2double(GPUmultiPars.zm);
boxsz = str2double(GPUmultiPars.boxsz);

imseries = uint16(movie)./(uint16(counts_per_photon)); 
%  figure(2); clf; imagesc(imseries(:,:,1)); colormap gray; colorbar;
 
%% fit with single fitting Nmax=1;

% disp('GPUmultifitPars:');
% disp(GPUmultiPars);
clear GPUmultiMLE40v1033 x y t uncerx uncery uncerbg cov LLR nfit bb nn;

[SuperRes, x, y, t, uncerx, uncery, uncerbg, cov, LLR,  nfit, bb, nn]=GPUmultiMLE40v1033(single(imseries),PSFsigma,Nave,Nmax,pvalue_threshold,resolution,pixelsize,zm,boxsz);

% parameters part of insightM mlist
mlist.x = y;  % x+1 ?   
mlist.y = x; % y+1 ?  
mlist.frame = cast(t,'int32');
mlist.i =nn; 
mlist.a = nn;
mlist.bg = bb;
mlist.z = zeros(size(x),'single');
mlist.c = ones(size(x),'int32');

% insightM parameters not yet populated
% overwritten with additional outputs from GPUmulti
mlist.xc = uncery;
mlist.yc = uncerx;
mlist.w = uncerbg;
mlist.phi = LLR;
mlist.ax = cov;
mlist.link = cast(nfit,'int32'); 

mlist.density = zeros(size(x),'int32'); % int32
mlist.h = zeros(size(x),'single');
mlist.length = zeros(size(x),'int32'); % int32
mlist.zc = zeros(size(x),'single');

disp(['found ',num2str(length(x)) ,' molecules']);

