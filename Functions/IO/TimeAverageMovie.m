function TimeAverageMovie(daxfile,varargin)
%--------------------------------------------------------------------------
% TimeAverageMovie(daxfile)
% 
%--------------------------------------------------------------------------
% Inputs:
% daxfile
%--------------------------------------------------------------------------
% Outputs:
% writes a daxfile to disk. Default is to have the same name as existing
% daxfile with _ds# appended to the end.  
% 
%--------------------------------------------------------------------------
% Optional inputs:
% 'downsize' / integer / 60 
%                   - number of frames to average together
% 'blocksize' / integer / 10 
%                   - number of blocks to load at once.  Affects speed and
%                   memory usage.  blocksize*downsize = number of frames in
%                   memory at once.  1000 - 2000 is generally fast.
% 'newDaxName' / string / ''
%                   - full filepath for new daxfile
% overwrite / boolean / true
%                   - if the target file exists, overwrite it? 
%--------------------------------------------------------------------------
% Alistair Boettiger
% boettiger.alistair@gmail.com
% February 12th, 2014
%
% Version 1.0
%--------------------------------------------------------------------------
% Creative Commons License 3.0 CC BY  
%--------------------------------------------------------------------------


%-------------------------------------------------------------------------
%% default inputs
%-------------------------------------------------------------------------

% global daxfile;
% daxfile =  '\\Tuck\tstorm\Data\020614_Hao_L4\E1E3\splitdax\561quad_E1_B0_0004.dax';
blocksize = 10;
downsize = 60;
overwrite = true; 
newDaxName = '';
subregion = [];
gain = 1; 
%--------------------------------------------------------------------------
%% Parse variable input
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
            case 'newDaxName'
                newDaxName = CheckParameter(parameterValue,'string','newDaxName');                   
            case 'downsize'
                downsize = CheckParameter(parameterValue,'positive','downsize');                   
            case 'blocksize'
                blocksize = CheckParameter(parameterValue,'positive','blocksize');                   
            case 'overwrite'
                overwrite = CheckParameter(parameterValue,'boolean','overwrite'); 
            case 'subregion'
                subregion = parameterValue;          
            case 'gain'
                gain  = CheckParameter(parameterValue,'positive','gain');                   
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end

%% Main Function
stepsize = blocksize*downsize;  



% Read info file, setup new savenames
infoFile = ReadInfoFile(daxfile);
if isempty(newDaxName)
    ds = ['_ds',num2str(downsize)]; % default append
    newDaxName = regexprep(infoFile.localName,'\.inf',[ds,'\.dax']);
end

% Write new info-file based on existing infofile
T = infoFile.number_of_frames;
H = infoFile.frame_dimensions(1); 
W = infoFile.frame_dimensions(2); 
T2 = floor(T/downsize); 
infoFile2 = infoFile;
infoFile2.number_of_frames = T2;
infoFile2.localName = regexprep(newDaxName,'\.dax','\.inf');
infoFile2.file = newDaxName;

% % Only if cropping out of a larger movie.  
% infoFile2.hend = H;
% infoFile2.frame_dimensions = [H,W];
% infoFile2.frame_size = H*W;

WriteInfoFiles(infoFile2);

newDaxFile = [infoFile2.localPath,newDaxName];
if exist(newDaxFile,'file') == 0
    fid = fopen(newDaxFile,'w+'); 
else
    if overwrite
        fid = fopen(newDaxFile,'w+'); 
    else
        error([newDaxFile ' already exists']);
    end
end


averagedMovie = zeros(H,W,T2,'uint16'); 
v=0;
for t=1:ceil(T/stepsize)  % t = 3
    s1 = (t-1)*stepsize + 1;
    e1 = min(t*stepsize,T); 

    if isempty(subregion)
        movie = ReadDax(daxfile,...
        'startFrame',s1,'endFrame',e1,'verbose',false); 
    else
        movie = ReadDax(daxfile,'subregion',subregion,...
            'startFrame',s1,'endFrame',e1,'verbose',false); 
    end
    
    for u=1:blocksize
        s2 = (u-1)*downsize + 1;
        e2 = min(u*downsize,e1-s1+1); 
        v=v+1;
        averagedMovie(:,:,v) = mean(gain*movie(:,:,s2:e2),3);
    end
    s = (t-1)*blocksize + 1;
    e = min(t*blocksize,T2); 
    fwrite(fid, ipermute(averagedMovie(:,:,s:e), [2 1 3]), 'int16', 'b');
    if rem(t,2) == 0
        disp([ num2str(100*t/ceil(T/stepsize),4),'% complete'] );
    end
end
fclose(fid); 
