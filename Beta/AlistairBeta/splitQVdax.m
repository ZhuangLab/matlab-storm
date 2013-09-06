
% SplitDaxFast
function splitQVdax(pathin,varargin)
%--------------------------------------------------------------------------
%% Required Inputs
% pathin / string 
%          folder containing dax files 
% 
%--------------------------------------------------------------------------
%% Optional Inputs
% alldax / structure / []
%           structure output from dirs command containing list of all dax
%       in folder to extract quadview.  If empty code will attempt to
%       process all dax in folder.  This will produce errors if some files
%       are already split.
% chns / cell / {'750','647','561','488'};
%           List of QV quadrants to pull out of the image. The names must
%           match those in QVorder
% QVorder / cell / {'647', '561', '750', '488'}
%           Name of QV channels, left to right, top to bottom.
% savepath / string / ''
%           Location to save the output daxfile 
% step / double / 100
%           Number of frames to load at once
% verbose / boolean / true
%           Print messages to screen
%--------------------------------------------------------------------------
%


%% default parameters
alldax = [];
QVorder = {'647', '561', '750', '488'};
chns = {'750','647','561','488'};    
savepath = '';
maxFrames = 1E10;
step = 1000;
verbose = true; 
% pathin = 'H:\2013-08-21_AbdA\QVdax\';

QVc{1,1} = 1:256;  QVc{1,2} = 1:256;
QVc{2,1} = 1:256;  QVc{2,2} = 257:512;
QVc{3,1} =  257:512;  QVc{3,2} = 1:256;
QVc{4,1} = 257:512;  QVc{4,2} = 257:512;

if nargin > 1
    if (mod(length(varargin), 2) ~= 0 ),
        error(['Extra Parameters passed to the function ''' mfilename ''' must be passed in pairs.']);
    end
    parameterCount = length(varargin)/2;
    for parameterIndex = 1:parameterCount,
        parameterName = varargin{parameterIndex*2 - 1};
        parameterValue = varargin{parameterIndex*2};
        switch parameterName  
            case 'alldax'
                alldax= CheckParameter(parameterValue,'struct','alldax');
            case 'QVorder'
                QVorder= CheckParameter(parameterValue,'cell','QVorder');
            case 'chns'
                chns = CheckParameter(parameterValue,'cell','chns');
            case 'savepath'
                savepath = CheckParameter(parameterValue,'string','savepath');
            case 'step'
                step = CheckParameter(parameterValue,'positive','step'); 
            case 'verbose'
                verbose =  CheckParameter(parameterValue,'boolean','verbose');
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end

% Parse default options
if isempty(alldax)
    alldax = dir([pathin,filesep,'*.dax']); 
end

if isempty(savepath)
    savepath = pathin;
end


%% Main code

D = length(alldax);
if verbose
    disp(['found ',num2str(D),' dax files in folder']);
    disp(pathin);
end

for d=1:D

    try
    dax = [pathin,alldax(d).name];
    [~,infoFile] = ReadDax(dax,'startFrame',1,'endFrame',1,'verbose',verbose);
    catch
        warning(['Unable to open ' dax]);
        disp('skipping this file...'); 
        continue;
    end
    
    C = length(chns); 
    chns_out = zeros(1,C);
    for c=1:C
        chns_out(c) = find(1-cellfun(@isempty,strfind(QVorder,chns{c})));
    end

    name = infoFile.localName;
    Nframes = infoFile.frame_size;
    infoOut = cell(C,1); 
    daxnames = cell(C,1); 
    daxname = regexprep(name,'\.inf','\.dax');
    
    % Write Infofiles for all the quadrants
    for c=chns_out
        infoOut{c} = infoFile;
        infoOut{c}.x_end = 256;
        infoOut{c}.y_end = 256;
        infoOut{c}.frame_dimensions = [256,256];
        infoOut{c}.localName = [QVorder{c},'quad_',name];   
        infoOut{c}.localPath = savepath; 
        daxnames{c} = [QVorder{c},'quad_',daxname];
        WriteInfoFiles(infoOut{c}, 'verbose', true);
    end

    for c=1:C
        % Open dax for writing 
        fid = fopen([infoOut{c}.localPath daxnames{c}], 'w+');
        if fid<0
            warning(['Unable to open ' infoOut{c}.localPath daxnames{c}]);
        elseif verbose
            disp(['Parsing ' infoOut{c}.localPath daxnames{c},'...']);
        end
        
        for n=1:step:Nframes  % n = 3;
            % write movie 2 frames at a time;
            try
                movie = ReadDax(dax,'startFrame',n,'endFrame',n+step-1,'verbose',false);
    %             figure(1); clf; subplot(1,2,1); imagesc( int16(movie(QVc{c,1},QVc{c,2},1)) );
    %             subplot(1,2,2); imagesc( int16(movie(QVc{c,1},QVc{c,2},2)) );
                fwrite(fid, ipermute(int16(movie(QVc{c,1},QVc{c,2},:)), [2 1 3]), 'int16', 'b');
                if verbose
                   disp(['Movie ',num2str(d),' of ',num2str(D),' ',...
                         'Panel', num2str(c),' of ',num2str(C),' ',...
                         num2str(n/Nframes*100,3),'% complete']) 
                end
            catch
                if verbose
                    disp('end of movie reached'); 
                end
                fclose(fid);
                break
            end
        end 
    end
end
fclose('all');

