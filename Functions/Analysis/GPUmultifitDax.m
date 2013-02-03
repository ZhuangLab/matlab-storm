function mlist = GPUmultifitDax(daxfile,varargin)
% GPUmultifitDax(daxfile,GPUmultiPars)
%-------------------------------------------------------------------------
% A small wrapper that reads in frames from a daxfile and feeds them in
% batches to GPUmultfit for analysis. 
% This file requires the function GPUmultifit.m
%-------------------------------------------------------------------------
% Outputs:
% mlist / structure         -- molecule list
% 
%-------------------------------------------------------------------------
% Inputs:
% daxfile / string          -- full path directory of a daxfile
%-------------------------------------------------------------------------
% Optional Inputs
% input 2: GPUmultiPars / structure  -- fitting parameters for GPUmultifit  
%-------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Parse input
%--------------------------------------------------------------------------
if  nargin == 1 
    GPUmultiPars = ''; % if not passed record as empty. 
    startFrame = 1;
    maxFrame = inf; 
elseif nargin == 2 
    GPUmultiPars = varargin{1}; 
    startFrame = str2double(GPUmultiPars.startFrame); % first frame to analyze
    maxFrame = str2double(GPUmultiPars.endFrame); % last frame to analyze
end

try 
    maxFrames = str2double(GPUmultiPars.batchframes);
catch
    maxFrames = 5000;
end
% max number of frames to process in one bout. 
% A chunk of the movie must be imported into local memory to be passed to
% the fitter.  Too many frames uses up more RAM and may cause the GPU to
% crash.

infoFile = ReadInfoFile(daxfile);
Tframes = infoFile.number_of_frames;
if maxFrame == -1
    maxFrame = inf;
end
Tframes = min(Tframes,maxFrame)-startFrame; 


% initialize a blank mlist
% parameters part of insightM mlist
mlist.x = [];  
mlist.y = [];  
mlist.frame = [];  
mlist.i = [];  
mlist.a = [];
mlist.h = [];
mlist.bg = [];  
mlist.z = [];  
mlist.c = [];  
mlist.xc =[];  
mlist.yc =[];  
mlist.zc = [];
mlist.w = [];  
mlist.phi = [];  
mlist.density = [];  
mlist.length = [];
mlist.link = [];   
mlist.ax = [];

fieldNames = {'x','y','xc','yc','h','a','w','phi','ax','bg','i','c','density',...
    'frame','length','link','z','zc'};

Chunks = ceil(Tframes/maxFrames);
for i=1:Chunks
    sFrame = (i-1)*maxFrames + startFrame;
    endFrame = min(sFrame + maxFrames -1,Tframes+startFrame); 
    disp(['analyzing frames ',num2str(sFrame) ' to ',num2str(endFrame)]);

    movie = ReadDax(daxfile,'startFrame',sFrame,'endFrame',endFrame);
    [h,w,frames] = size(movie);
    if frames <2
        movie = repmat(movie,[1,1,5]);
    end
   mlist_temp = GPUmultifit(movie,GPUmultiPars); % (32:64,32:64,:)
   
   % append to existing mlist
    mlist.x = [mlist.x; mlist_temp.x];  
    mlist.y = [mlist.y; mlist_temp.y];   
    mlist.frame = [mlist.frame; mlist_temp.frame];  
    mlist.i = [mlist.i; mlist_temp.i];   
    mlist.a = [mlist.a; mlist_temp.a];   
    mlist.bg = [mlist.bg; mlist_temp.bg];  
    mlist.z = [mlist.z; mlist_temp.z];    
    mlist.c = [mlist.c; mlist_temp.c];    
    mlist.xc =[mlist.xc; mlist_temp.xc];    
    mlist.yc =[mlist.yc; mlist_temp.yc];   
    mlist.zc = [mlist.zc; mlist_temp.zc];  
    mlist.w = [mlist.w; mlist_temp.w];  
    mlist.phi = [mlist.phi; mlist_temp.phi];   
    mlist.density = [mlist.density; mlist_temp.density];  
    mlist.length = [mlist.length; mlist_temp.length];  
    mlist.link = [mlist.link; mlist_temp.link];    
    mlist.ax = [mlist.ax; mlist_temp.ax];    
    mlist.h = [mlist.h; mlist_temp.h];
end
if Chunks>1
    disp('analysis finished.');
    disp('drift correction skipped...');
end
