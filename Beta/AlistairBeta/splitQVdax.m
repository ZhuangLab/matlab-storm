
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
%--------------------------------------------------------------------------
%


%% default parameters
alldax = [];
QVorder = {'647', '561', '750', '488'};
chns = {'750','647','561','488'};    
savepath = '';

% pathin = 'F:\080813\F9gN DL755 tile 4nM 20for\Left';

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
            case 'alldax'
                alldax= CheckParameter(parameterValue,'struct','alldax');
            case 'QVorder'
                QVorder= CheckParameter(parameterValue,'cell','QVorder');
            case 'chns'
                chns = CheckParameter(parameterValue,'cell','chns');
            case 'savepath'
                savepath = CheckParameter(parameterValue,'string','savepath');
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


%% Main Code

Nchns = length(chns);
Nmovies = length(alldax); 

for n=1:Nmovies
    daxfile = [pathin,filesep,alldax(n).name];
    [movies,info] = ReadDaxBeta(daxfile,'Quadviewsplit',true);
    for c=1:Nchns
        QVframe = strcmp(QVorder,chns{c});
        tag = [chns{c},'quadrant_'];   
        info.localName = [tag,info.localName];
        info.localPath = [savepath,filesep];
        info.file = [info.localPath,info.localName(1:end-4),'.dax'];
        WriteDAXFiles(movies{QVframe},info);   
    end
end
                


