function [mlist,h,w] = ReZeroROI(binfile,mlist,varargin)
% 
% 

%% Main Function
if isempty(mlist)
    mlist = ReadMasterMoleculeList(binfile);
end

parsfile = ReadListParsFile(binfile);
hasROIinfo = true;  
if   ~isempty(parsfile)
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
        roiInfo = read_parameterfile(parsfile,roiFlags,endmarker);
        roi = cellfun(@str2double,roiInfo);
        w = roi(2) - roi(1);
        h = roi(4) - roi(3); 
        mlist.xc = mlist.xc - roi(1);
        mlist.x = mlist.x - roi(1);
        mlist.yc = mlist.yc - roi(3);
        mlist.y = mlist.y - roi(3);      
    end
else
    if verbose
       disp('No ROI parameters found. using dimensions from .inf file');  
    end
    daxname = regexprep(binfile,{'_list.bin','_mlist.bin','_alist.bin'},'.dax');
    infofile = ReadInfoFile(daxname);
    h = infofile.frame_dimensions(2); % actual size of image
    w = infofile.frame_dimensions(1);
end