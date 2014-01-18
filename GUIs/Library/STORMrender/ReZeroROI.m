function [mlist,h,w] = ReZeroROI(binfile,mlist,varargin)
%  [mlist,h,w] = ReZeroROI(binfile,mlist,varargin)
% 

%--------------------------------------------------------------------------
% Default optional parameters
%--------------------------------------------------------------------------
verbose = true;

%--------------------------------------------------------------------------
% Parse Variable Input Parameters
%--------------------------------------------------------------------------
if nargin < 1
   error([mfilename,' expects inputs: cell of binnames, cell of channels, and string to a chromewarps.mat warp file']);
end
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
                verbose = CheckParameter(parameterValue,'boolean','verbose');                
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end


%% Main Function
if isempty(mlist)
    mlist = ReadMasterMoleculeList(binfile);
end

parsfile = ReadListParsFile(binfile);
hasROIinfo = true;  
hasParsFile = ~isempty(parsfile);
if  hasParsFile
    parsflag = parsfile(end-3:end);
    if strcmp(parsflag,'.xml');
    roiFlags = {'<x_start type="int">',...
                '<x_stop type="int">',...
                '<y_start type="int">',...
                '<y_stop type="int">'};
    endmarker = '<';
    elseif strcmp(parsflag,'.ini');
    roiFlags = {'ROI_x0=',...
                'ROI_x1=',...
                'ROI_y0=',...
                'ROI_y1='};
    endmarker = '';
    else
       hasROIinfo = false;  
    end
    if hasROIinfo
        try
         roiInfo = read_parameterfile(parsfile,roiFlags,endmarker);
        catch
            try
                binPath = extractpath(binfile);
                [~, parsName] = extractpath(parsfile);
                roiInfo = read_parameterfile([binPath,parsName],roiFlags,endmarker);
            catch
                hasROIinfo = false;
                hasParsFile = false;
            end
        end
    end
    if hasROIinfo
        roi = cellfun(@str2double,roiInfo);
        w = roi(2) - roi(1);
        h = roi(4) - roi(3); 
        mlist.xc = mlist.xc - roi(1);
        mlist.x = mlist.x - roi(1);
        mlist.yc = mlist.yc - roi(3);
        mlist.y = mlist.y - roi(3);      
    end
end
if ~hasParsFile
    if verbose
       disp('No ROI parameters found. using dimensions from .inf file');  
    end
    daxname = regexprep(binfile,{'_list.bin','_mlist.bin','_alist.bin'},'.dax');
    try
        infofile = ReadInfoFile(daxname);
        h = infofile.frame_dimensions(2); % actual size of image
        w = infofile.frame_dimensions(1);
    catch er
        warning(['Unable to read infofile',infofileName]);
        disp(er.message); 
        disp(er.getReport);
        warning('Unable to determine file size: assuming 256x256');
        h = 256;
        w = 256;
    end
end