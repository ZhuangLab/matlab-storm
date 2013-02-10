function CalcChromeWarp(pathin,varargin)
%--------------------------------------------------------------------------
%% CalcChromeWarp(pathin)
% BeadWarp3D(pathin,'insight',value, 'refitZ',value, 'Rerun Insight',value...
% 'run external',value, 'batch',value, 'ini root',value, 'max frames',value,... 
% 'saveroot',value, 'match radius', value, 'remove crosstalk', value,...
% 'IRroot',value,'Visroot',value)
%
% Computes and saves tforms3D.mat and tforms2D.mat, which contain
% polynomial warps to map 750, 561 and 488 bead data to 647.  Currently
% bead data in all 4 channels is required. 
%
% Beads may be taken in 2D or 3D (i.e. multiple zplanes).  
%--------------------------------------------------------------------------
%% Necessary Inputs
% pathin / string
%           -- folder containing bead movies as .dax files
%--------------------------------------------------------------------------
%% Outputs
% saves in the path folder tforms_3D.mat and tforms_2D.mat containing warp
% information
% 
%--------------------------------------------------------------------------
%% Optional Inuputs
% 'refitZ' / logical 2-vector / [1,1]
%                       -- rerun beadfitting or search for existing
%                       VisBeadPos.mat and IRBeadPos.mat
% 'overwrite' / double / 2
%                       -- 0 skip, 1 = overwrite, 2 = ask me.
% 'batchsize' / double / 3
%                       -- maximum number of external versions of InsightM
%                       to run at once. 
% 'parsroot' / string / 'Bead'
%                       -- ini files for analysis contain this string after
%                       the channel number.  channel number must be
%                       '750','647','561', or '488';
% 'max frames' / double
%                       -- maximum number of bead frames to include in the
%                       analysis.  Typically 5-7 z-sections of 36 positions.
% 'saveroot' / string / ''
%                       -- string to be incorporated into exported files
% 'match radius' / double / 6
%                       -- maximum distance between beads in different
%                       color channels to still be considered same bead.
%                       measured in pixels.  STORM4 quadview requires large
%                       offset (~6-8).
% 'remove crosstalk' / logical / true
%                       -- Vis beads sometimes show up in IR channels.
%                       This will attempt to remove these beads to improve
%                       fits and estimate of fit errors
% 'IRroot' / string / 'IRbeads'
%                       -- the IR bead images contain this string in the
%                       filename.
% 'Visroot' / string /'Visbeads'
%                       -- the Vis bead images contain this string in the
%                       filename
% 'method' /string / 'insight'
%                       -- 'insight' or 'DaoSTORM' for dotfitting
% class1only / logical / true
%                       -- use only class1 molecules only (good z fit).
%--------------------------------------------------------------------------
% Alistair Boettiger
% boettiger.alistair@gmail.com
% February 7th, 2013
%
% Version 3.0
%--------------------------------------------------------------------------
% Creative Commons License 3.0 CC BY  
%--------------------------------------------------------------------------
%% updates
% Version update information
% Version 3.0 Rewritten to use ReadMasterMoleculeList format, clean up code
% a little bit by subfunctionalization.  
% Version 2.2 computes a coarse affine warp to followed by a fine
% polynomial warp; 
% Version 2.1 change defaults so that if list.bin files exist insight 
% will not rerun.
% Version 2.0 fxn_BeadWarp3D
% Version 1.0 Adapted from MapBeadWarp3D from Sang-Hee Shim 05/11/12.  
%--------------------------------------------------------------------------
%% To update
% make it so that all 4 channels are not required 
% use readMasterMoleculeList instead of bin2matfast    
%--------------------------------------------------------------------------
%% required functions
% bin2matfast.m launch_a_bat_file.m corr_mols.m cp2tform3D.m
%--------------------------------------------------------------------------




%--------------------------------------------------------------------------
%% Hardcoded Variables
%--------------------------------------------------------------------------
% addpath('C:\Users\Alistair\Documents\Projects\General_STORM\Matlab_STORM\lib\Warp');
% avoids freeze ups if data file is missing.  
% keep this as 4 vector or the code will freeze.  
 chns = {'750','647','561','488'};
match_radius1 = 8;
overwrite = 1;  % needs to overwrite files to apply different parameters

%--------------------------------------------------------------------------
%% Default Parameters
%--------------------------------------------------------------------------
refitZ = [0,0]; % for IR and Vis.  Run insight using 3D beads and compute new positions?  
max_frames = 36*7; % 36*3; %  36*3; % 
IRparsroot = 'Bead';
Visparsroot = 'Bead';
saveroot = ''; 
remove_crosstalk = 1;
match_radius =  6; %6.5  7 4
fpZ = 36; % frames per z


method ='insight'; %  'DaoSTORM';
hideterminal = true;
IRroot = 'IRbeads';
Visroot = 'Visbeads';
batchsize = 10;
class1only = false;

verbose = true;
  %  pathin = 'I:\2013-02-02_BXCemb\Beads';  IRroot = 'IRbeads'; max_frames = 1000;

%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%% Parse mustHave variables
%--------------------------------------------------------------------------
if nargin < 1
   error([mfilename,' expects at least 1 input: bead_folder']);
end


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
            case 'method'
                method = checkList(parametervalue,{'insight','DaoSTORM'},'method');
            case 'refitZ'
                refitZ = parameterValue;  
            case 'overwrite'
                overwrite = parameterValue;
            case 'ini root'
                ini_root = checkParameter(parameterValue,'string','ini root');
            case 'max frames'
                max_frames =checkParameter(parameterValue,'positive','max frames');
            case 'save root'
                saveroot = checkParameter(parameterValue,'string','save root');
            case 'match radius'
                match_radius = checkParameter(parameterValue,'positive','match radius');
            case 'remove crosstalk'
                remove_crosstalk = checkParameter(parameterValue,'boolean','remove crosstalk');
            case 'batchsize'
                 batchsize = checkParameter(parameterValue,'positive','batchsize');
            case 'IRroot'
                IRroot = checkParameter(parameterValue,'string','IRroot');
            case 'Visroot'
                Visroot = checkParameter(parameterValue,'string','Visroot');
            case 'class1only'
                class1only = checkParameter(parameterValue,'boolean','class1only');
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end

%--------------------------------------------------------------------------
%% Main code
%--------------------------------------------------------------------------
 




if strcmp(method,'insight')
    parstype = '.ini';
   datatype = '_list.bin';
elseif strcmp(method,'DaoSTORM');
    parstype = '.xml';
   datatype = '_alist.bin'; 
   class1only = false; % DaoSTORM puts everything in class 0.  
end

ir_already_run = dir([pathin,'/','IRBeadPos3D',saveroot,'.mat']);
if isempty(ir_already_run)
    refitZ(1) = true;
end
vis_already_run = dir([pathin,'/','VisBeadPos3D',saveroot,'.mat']);
if isempty(vis_already_run)
    refitZ(2) = true;
end
%%  Need to re-run bead data with each of the z-parameters.  
if refitZ(1) == 1 


  % Run insight on IR beads with 3D fitting
    alldax = dir([pathin,filesep,IRroot,'*.dax']);

     if isempty(alldax)
         warning('MATLAB:DirNotFound',['no ', 'IRbeads*.dax files found in ',pathin]);
         disp(pathin);
     end
 
    Nframes = length(alldax);
    disp(['found ',num2str(Nframes)]);
    Nframes = min(max_frames,Nframes); 
    
 %----------------------------------------------------------------------   
 % Get a parameter file for each IR channel 
 % If a match to the input IRparsroot is succesful, use that
 % otherwise, prompt the reader to chose a file from the load GUI
 parsfile = cell(length(chns),1);    
 for c=1:length(chns)
        parsroot = [chns{c},'*',IRparsroot];
    if isempty(parsfile{c})
        parsname = dir([pathin,filesep,'*',parsroot, '*',parstype]);
        if length(parsname) > 1 || isempty(parsname)
            disp(['Too many or no ',parstype,...
                ' files in directory.  Please chose a parameters file for']);
           getfileprompt = {['*',parstype],[method,' pars (*',parstype,')']};
           [filename, filepath] = uigetfile(getfileprompt,...
               'Select Parameter File',pathin);
           parsfile{c} = [filepath, filename];
        else
            parsfile{c} = [pathin, filesep, parsname.name];
        end
    end     
    if isempty(strfind(parsfile,parstype))
        error([parsfile{c}, ' is not a valid ', parstype, ' parameter file for ',method]);
    end
 end
    
     
    for n=1:Nframes
        [movies,info] = ReadDaxBeta(daxfile,'subregion',subregion);
        for c=1:length(chns)
        binname{c,n} = WriteDax(movies{c},info,chns{c},method,parsfile{c},hideterminal,overwrite);
        end
    end
    
  
        
        
        

    IR647(Nframes).x = [];  % needs different name than vis chn 647 beads
    IR647(Nframes).y = [];
    IR647(Nframes).z = [];

    IR750(Nframes).x = [];
    IR750(Nframes).y = [];
    IR750(Nframes).z = [];
  
  for c = 1:length(chns)
      if strcmp(chns{c},'750') || strcmp(chns{c},'647')
          disp(['fitting ',IRroot,' beads in channel ',chns{c},'...']);
           RunDotFinder('method',method,'parsroot',[chns{c},'*',ini_root],...
               'daxroot',IRroot,'path',pathin,'hideterminal',hideterminal,...
               'batchsize',batchsize,'overwrite',overwrite,'verbose',verbose); 
      else
          break % only do '750' and '647' here.  
      end   
     
  % load bin files and save position data for each channel. 
      for k = 1:Nframes; % k = 14;
            bin_nm = [alldax(k,1).name(1:end-4),datatype]; % load bin file
            try
                mol_list = ReadMasterMoleculeList([pathin,filesep,bin_nm],...
                    'verbose',verbose); 
            catch er
                disp(er.message); 
                warning(['failed to load ',pathin,filesep,bin_nm]);
            end
            frames_per_field = max(mol_list.length);
            mols_on_allframes = mol_list.length == frames_per_field;
            if sum(mols_on_allframes) < .3*length(mol_list.x)
                disp('warning: many molecules not well linked between frames');
                disp('reduced quality of fit may result');
                mols_on_allframes = true(length(mol_list.x),1); % avoid tossing too many molecules with this filter
            end
            if class1only
                goodmol = mol_list.c &  mols_on_allframes; % use only molecules with good z-fit score (class 1)
            else
                goodmol =  mols_on_allframes;
            end
            x = cast(mol_list.x(goodmol==1),'double');
            y = cast(mol_list.y(goodmol==1),'double');
            z = cast(mol_list.z(goodmol==1),'double');
            % split up channels based on their positions in the quadview
            if strcmp(chns{c},'750')
                   IR750(k).x = x(x>0 & x<256 & y>258 & y<512);  % throw out a top row of points
                   IR750(k).y = y(x>0 & x<256 & y>258 & y<512)-256;
                   IR750(k).z = z(x>0 & x<256 & y>258 & y<512); 
            elseif strcmp(chns{c},'647')
                   IR647(k).x = x(x>0 & x<256 & y>0 & y<256);
                   IR647(k).y = y(x>0 & x<256 & y>0 & y<256);
                   IR647(k).z = z(x>0 & x<256 & y>0 & y<256);
            else
                break
            end
      end       
  end
 
save([pathin,'/','IRBeadPos3D',saveroot,'.mat'],'IR750','IR647','Nframes');  
disp(['wrote ',  pathin,'/','IRBeadPos3D',saveroot,'.mat']);
else
    load([pathin,'/','IRBeadPos3D',saveroot,'.mat'],'IR750','IR647','Nframes');  
end


%%  Run insight on Vis beads with 3D fitting
if refitZ(2) == 1
alldax = dir([pathin,'\','Visbeads','*.dax']);

     if isempty(alldax)
         warning('MATLAB:DirNotFound',['no ', 'Visbeads*.dax files found in ',pathin,'\']);
     end

Nframes = length(alldax);
Nframes = min(max_frames,Nframes); 

pos647(Nframes).x = [];
pos647(Nframes).y = [];
pos647(Nframes).z = [];
 
pos561(Nframes).x = [];
pos561(Nframes).y = [];
pos561(Nframes).z = [];
 
pos488(Nframes).x = [];
pos488(Nframes).y = [];
pos488(Nframes).z = [];
 
for c=1:length(chns)    
     if strcmp(chns{c},'647') || strcmp(chns{c},'561') || strcmp(chns{c},'488')
         disp(['fitting ',Visroot,' beads in channel ',chns{c},'...']);
           RunDotFinder('method',method,'parsroot',[chns{c},'*',ini_root],...
               'daxroot',Visroot,'path',pathin,'hideterminal',hideterminal,...
               'batchsize',batchsize,'overwrite',overwrite,'verbose',verbose); 
      else
          break % only do '750' and '647' here.  
      end  
     
      for k = 1:Nframes; % k = 14;
            bin_nm = [alldax(k,1).name(1:end-4),datatype]; % load bin file
            try
                mol_list = ReadMasterMoleculeList([pathin,filesep,bin_nm],...
                    'verbose',verbose); 
            catch er
                disp(er.message); 
                warning(['failed to load ',pathin,filesep,bin_nm]);
            end
            frames_per_field = max(mol_list.length);
            mols_on_allframes = mol_list.length == frames_per_field;
            if sum(mols_on_allframes) < .3*length(mol_list.x)
                disp('warning: many molecules not well linked between frames');
                disp('reduced quality of fit may result');
                mols_on_allframes = true(length(mol_list.x),1); % avoid tossing too many molecules with this filter
            end
            if class1only
                goodmol = mol_list.c & mols_on_allframes; % use only molecules with good z-fit score (class 1)
            else
                goodmol = mols_on_allframes;
            end
            
            x = cast(mol_list.xc(goodmol==1),'double');
            y = cast(mol_list.yc(goodmol==1),'double');
            z = cast(mol_list.zc(goodmol==1),'double');
            % split up channels based on their positions in the quadview
            if strcmp(chns{c},'647')
                pos647(k).x = x(x>0 & x<256 & y>0 & y<256);
                pos647(k).y = y(x>0 & x<256 & y>0 & y<256);
                pos647(k).z = z(x>0 & x<256 & y>0 & y<256);
            elseif strcmp(chns{c},'561')
                pos561(k).x = x(x>257 & x<512 & y>0 & y<256)-256;
                pos561(k).y = y(x>257 & x<512 & y>0 & y<256);
                pos561(k).z = z(x>257 & x<512 & y>0 & y<256);
            elseif strcmp(chns{c},'488')
                pos488(k).x = x(x>257 & x<512 & y>257 & y<512)-256;
                pos488(k).y = y(x>257 & x<512 & y>257 & y<512)-256;
                pos488(k).z = z(x>257 & x<512 & y>257 & y<512);
            else
                break
            end
      end  
end
% save position data
save([pathin,'/','VisBeadPos3D',saveroot,'.mat'],'pos647','pos561','pos488','Nframes'); 
else
    load([pathin,'/','VisBeadPos3D',saveroot,'.mat'],'pos647','pos561','pos488'); 
end





%% match molecules in each section
% (much less ambiguious than matching superimposed selection list). 

k = 1; 
cx_radius = 4;
verbose = true;
       
% % plots for troubleshooting
% figure(1); clf;  
% plot(pos488(k).x,pos488(k).y,'g.',pos561(k).x,pos561(k).y,'r.',...
%    pos647(k).x,pos647(k).y,'b.'); 
% hold on;
% plot(IR647(k).x,IR647(k).y,'b+',IR750(k).x,IR750(k).y,'m+');

tform_start = maketform('affine',[1 0 0; 0 1 0; 0 0 1]);
for k = 1:Nframes   
    % Match each channel to 647, split out x,y,z
    [set1_750,set2_750] = matchmols(IR647(k),IR750(k),tform_start, match_radius1,verbose,'750',k);
    [set1_561,set2_561] = matchmols(pos647(k), pos561(k),tform_start, match_radius1,verbose,'561',k);
    [set1_488,set2_488] = matchmols(pos647(k), pos488(k),tform_start, match_radius1,verbose,'488',k);      
end      
 
    % combine into large sets
    all750x = cell2mat(set2_750.x');
    all750x_ref = cell2mat(set1_750.x');
    all750y = cell2mat(set2_750.y');
    all750y_ref = cell2mat(set1_750.y');
   
    all561x = cell2mat(set2_561.x');
    all561x_ref = cell2mat(set1_561.x');
    all561y = cell2mat(set2_561.y');
    all561y_ref = cell2mat(set1_561.y');

    all488x = cell2mat(set2_488.x');
    all488x_ref = cell2mat(set1_488.x');
    all488y = cell2mat(set2_488.y');
    all488y_ref = cell2mat(set1_488.y');

% % For troubleshooting:    
%         % save original merged files for later comparison.  
%     all750xo = cell2mat(set2_750.x);
%     all750xo_ref = cell2mat(set1_750.x);
%     all750yo = cell2mat(set2_750.y);
%     all750yo_ref = cell2mat(set1_750.y);
%    
%     all561xo = cell2mat(set2_561.x);
%     all561xo_ref = cell2mat(set1_561.x);
%     all561yo = cell2mat(set2_561.y);
%     all561yo_ref = cell2mat(set1_561.y);
% 
%     all488xo = cell2mat(set2_488.x);
%     all488xo_ref = cell2mat(set1_488.x);
%     all488yo = cell2mat(set2_488.y);
%     all488yo_ref = cell2mat(set1_488.y);

 
    % test plot
      fig_xyerr_all =  figure(5); clf; subplot(1,2,1);
    plot(all750x,all750y,'mo',all750x_ref,all750y_ref,'m+',...
        all561x,all561y,'r*',all561x_ref,all561y_ref,'b+',...
        all488x,all488y,'go');
    title('before warp');
    legend('750','647IR','561','647vis','488');
 
%% Compute and apply warp 

tform750_1 = maketform('affine',[1 0 0; 0 1 0; 0 0 1]);
tform561_1 = maketform('affine',[1 0 0; 0 1 0; 0 0 1]);
tform488_1 = maketform('affine',[1 0 0; 0 1 0; 0 0 1]);

% method = 'affine';
method = 'nonreflective similarity';
if sum(strcmp(chns,'750')) && ~isempty(all750x)
tform750_1 = cp2tform([all750x_ref all750y_ref], [all750x all750y ],method); % compute warp
end
if sum(strcmp(chns,'561')) && ~isempty(all561x)
tform561_1 = cp2tform([all561x_ref all561y_ref],[ all561x all561y],method);
end
if sum(strcmp(chns,'488')) && ~isempty(all488x)
tform488_1 = cp2tform([all488x_ref all488y_ref] ,[all488x all488y],method);
end
%% REMATCH, then Polywarp 3

%------------------------------------

pos488b = pos488;
pos561b = pos561;
IR750b = IR750;
for k=1:Nframes
    [xt,yt] = tforminv(tform488_1, pos488(k).x,pos488(k).y);
    pos488b(k).x = xt; 
    pos488b(k).y = yt;
    [xt,yt] = tforminv(tform561_1, pos561(k).x,pos561(k).y);
    pos561b(k).x=xt; 
    pos561b(k).y=yt;
    try
    [xt,yt] = tforminv(tform750_1, IR750(k).x,IR750(k).y);
    IR750b(k).x=xt; 
    IR750b(k).y=yt;
    catch er
        disp(er.message)
    end
end;

figure(1); clf; k =1;
plot(pos488(k).x,pos488(k).y,'go',pos488b(k).x,pos488b(k).y,'g*'); hold on;
plot(pos561(k).x,pos561(k).y,'ro',pos561b(k).x,pos561b(k).y,'r+');
plot(IR750(k).x,IR750(k).y,'mo',IR750b(k).x,IR750b(k).y,'m+');

pos488 = pos488b;
pos561 = pos561b;
IR750 = IR750b;


%% match molecules in each section
% (much less ambiguious than matching superimposed selection list). 


tform_start = maketform('affine',[1 0 0; 0 1 0; 0 0 1]);
for k = 1:Nframes
  
     if remove_crosstalk  % Remove 750 crosstalk
       % Remove cross-talk values: Match 750 to vis647, subtract these from 647 lists.
       pos647(k) = remove_bleadthrough(pos647(k),IR750(k),tform_start, cx_radius,verbose,'Vis647',k);
       pos561(k) = remove_bleadthrough(pos561(k),IR750(k),tform_start, cx_radius,verbose,'Vis561',k);
       pos488(k) = remove_bleadthrough(pos488(k),IR750(k),tform_start, cx_radius,verbose,'Vis488',k);   
    end
    
     % Match each channel to 647, split out x,y,z
    [set1_750,set2_750] = matchmols(IR647(k),IR750(k),tform_start, match_radius,verbose,'750',k);
    [set1_561,set2_561] = matchmols(pos647(k), pos561(k),tform_start, match_radius,verbose,'561',k);
    [set1_488,set2_488] = matchmols(pos647(k), pos488(k),tform_start, match_radius,verbose,'488',k);         
end      
 
    % combine into large sets
    all750x = cell2mat(set2_750.x');
    all750x_ref = cell2mat(set1_750.x');
    all750y = cell2mat(set2_750.y');
    all750y_ref = cell2mat(set1_750.y');
    all750z = cell2mat(set2_750.z');
    all750z_ref = cell2mat(set1_750.z');
   
    all561x = cell2mat(set2_561.x');
    all561x_ref = cell2mat(set1_561.x');
    all561y = cell2mat(set2_561.y');
    all561y_ref = cell2mat(set1_561.y');
    all561z = cell2mat(set2_561.z');
    all561z_ref = cell2mat(set1_561.z');
 
    all488x = cell2mat(set2_488.x');
    all488x_ref = cell2mat(set1_488.x');
    all488y = cell2mat(set2_488.y');
    all488y_ref = cell2mat(set1_488.y');
    all488z = cell2mat(set2_488.z');
    all488z_ref = cell2mat(set1_488.z');
    
    % test plot
      fig_xyerr_all =  figure(5); clf; subplot(1,2,1);
    plot(all750x,all750y,'mo',all750x_ref,all750y_ref,'m+',...
        all561x,all561y,'r*',all561x_ref,all561y_ref,'b+',...
        all488x,all488y,'go');
    title('before warp');
    legend('750','647IR','561','647vis','488');
% 
% %-------------------------------------------------------------------
%% Compute and apply warp 

poly_order = 3;
poly_order2 = 3;

try % may not have 750 beads
    base = [ all750x_ref all750y_ref all750z_ref]; % reference / target chn 
    input = [ all750x all750y all750z ];  % matched data to warp
    tform750 = cp2tform3D(base,input,'polynomial',poly_order); % compute warp
    [tx750,ty750,tz750] = tforminv(tform750, all750x, all750y, all750z); % apply warp
    % 2D transform (for troubleshooting)
    tform750_2D = cp2tform( [ all750x_ref all750y_ref ], [ all750x all750y ],'polynomial',poly_order2); % compute warp
    [tx750_2d,ty750_2d] = tforminv(tform750_2D, all750x, all750y); % apply warp
catch er
    disp(er.message)
    tx750 =0; ty750=0; tz750=0; tx750_2d=0; ty750_2d=0;
    tform750 = []; tform750_2D = []; 
    
end
    
try 
    base = [ all561x_ref all561y_ref all561z_ref]; % reference / target chn
    input = [ all561x all561y all561z ];  % matched data to warp
    tform561 = cp2tform3D(base,input,'polynomial',poly_order);
    [tx561,ty561,tz561] = tforminv(tform561, all561x, all561y, all561z);
    % 2D transform (for troubleshooting)
    tform561_2D = cp2tform([all561x_ref all561y_ref],[ all561x all561y],'polynomial',poly_order2);
    [tx561_2d,ty561_2d] = tforminv(tform561_2D, all561x, all561y);
catch er
    disp(er.message)
    tx561 =0; ty561=0; tz561=0; tx561_2d=0; ty561_2d=0;
    tform561 = []; tform561_2D = []; 
end

try  % may not have 488 beads
    base = [ all488x_ref all488y_ref all488z_ref]; % reference / target chn 
    input = [ all488x all488y all488z ];  % matched data to warp
    tform488 = cp2tform3D(base, input,'polynomial',poly_order);
    [tx488,ty488,tz488] = tforminv(tform488, all488x, all488y, all488z);
    % 2D transforms (for troubleshooting)
    tform488_2D = cp2tform([all488x_ref all488y_ref] ,[all488x all488y],'polynomial',poly_order2);
    [tx488_2d,ty488_2d] = tforminv(tform488_2D, all488x, all488y);
catch er
    disp(er.message);
    tx488 =0; ty488=0; tz488=0; tx488_2d=0; ty488_2d=0;
    tform488 = []; tform488_2D = []; 
end

% DONE!
% the rest of this code is just graphing and computing the accuracy of the
% warp in different ways.  tforms are exported at the end along with the
% percision of fit data.  Plots are automatically saved in the source
% folder to better document warp percision. 


%% level the data and plot z-distribution

zmin = -650; zmax = 650; % for plotting only
% level unwarped zdata
lzo750 = all750z-level_data(all750x,all750y,all750z);
lzo561 = all561z-level_data(all561x,all561y,all561z);
lzo488 = all488z-level_data(all488x,all488y,all488z);

% level warped z data
try
lz750 = tz750-level_data(tx750,ty750,tz750);
lz647IR = all750z_ref-level_data(all750x_ref,all750y_ref,all750z_ref);
catch er
    disp(er.message);
    disp('error leveling 750 beads.  Ignore if no 750 beads in data');
    lz750 = 0;
    lz647IR = 0;
end
    

try
    lz561 = tz561-level_data(tx561,ty561,tz561);
catch er
    disp(er.message);
    disp('error leveling 561 beads.  Ignore if no 561 beads in data');
    lz561=0;
    all561x_ref=0;
    all561y_ref=0 ;
    all561z_ref=0;
end

try % don't always use 488 beads.  This is to avoid an error
    lz488 = tz488-level_data(tx488,ty488,tz488);
catch er
    disp(er.message);
    disp('error leveling 488 beads.  Ignore if no 488 beads in data');
    lz488=0;
    all488x_ref =0;
    all488y_ref=0 ;
    all488z_ref=0;
end

try
    lz647Vis = all561z_ref-level_data(all561x_ref,all561y_ref,all561z_ref);
catch er
    disp(er.message);
    lz647Vis = 0;
end

% Color coded histograms of the leveled z-distributions of beads in each
% color.  The bar color indicates the actual cluster.  This assumes 36
% images at each z positoin! (could easily be generalized).  
fig_zdist = figure(7); clf;
     passes = length(set2_488.z)/fpZ ;
     col = hsv(passes+1);
     all488_clust = zeros(1,passes+1); all561_clust = zeros(1,passes+1);  all647vis_clust = zeros(1,passes+1);
     all647ir_clust = zeros(1,passes+1); all750_clust = zeros(1,passes+1);
    for j=1:passes % separate molecules into z clusters
        all488_clust(j+1) = all488_clust(j) + sum(cellfun(@length,set2_488.z(1+(j-1)*fpZ:j*fpZ)));
        all561_clust(j+1) = all561_clust(j)+ sum(cellfun(@length,set2_561.z(1+(j-1)*fpZ:j*fpZ)));
        all647vis_clust(j+1) =  all647vis_clust(j)+ sum(cellfun(@length,set1_561.z(1+(j-1)*fpZ:j*fpZ)));
        all647ir_clust(j+1) = all647ir_clust(j)+ sum(cellfun(@length,set1_750.z(1+(j-1)*fpZ:j*fpZ)));
        all750_clust(j+1) =  all750_clust(j) + sum(cellfun(@length,set2_750.z(1+(j-1)*fpZ:j*fpZ)));
    end
    hx = linspace(zmin,zmax,50);  
    % histogram each z cluster as a different color.  Do for each of the
    % channels (including reference channels) 
    for j=2:passes+1 % j=3;
    subplot(3,2,1); hist(lz750( all750_clust(j-1)+1: all750_clust(j) ),hx); title('750'); xlim([zmin,zmax]); hold on;
      h1  = findobj(gca,'Type','Patch'); set(h1(1),'FaceColor',col(j-1,:),'EdgeColor',col(j-1,:)); alpha .7;
    subplot(3,2,2); hist(lz647IR( all647ir_clust(j-1)+1: all647ir_clust(j) ),hx); title('IR 647');   xlim([zmin,zmax]); hold on;
      h1  = findobj(gca,'Type','Patch'); set(h1(1),'FaceColor',col(j-1,:),'EdgeColor',col(j-1,:)); alpha .7;
    subplot(3,2,3); hist(lz561( all561_clust(j-1)+1: all561_clust(j) ),hx); title('561');   xlim([zmin,zmax]); hold on;
      h1  = findobj(gca,'Type','Patch'); set(h1(1),'FaceColor',col(j-1,:),'EdgeColor',col(j-1,:)); alpha .7;
    subplot(3,2,4); hist(lz488( all488_clust(j-1)+1: all488_clust(j) ),hx); title('488');   xlim([zmin,zmax]); hold on;
      h1  = findobj(gca,'Type','Patch'); set(h1(1),'FaceColor',col(j-1,:),'EdgeColor',col(j-1,:)); alpha .7;
    subplot(3,2,5); hist(lz647Vis( all647vis_clust(j-1)+1: all647vis_clust(j) ),hx); title('Vis 647');  xlim([zmin,zmax]); hold on;
      h1  = findobj(gca,'Type','Patch'); set(h1(1),'FaceColor',col(j-1,:),'EdgeColor',col(j-1,:)); alpha .7;
    end
    subplot(3,2,6); colormap(col(1:passes,:)); colorbar;
    set(gcf,'color','w');



fig_xzerr = figure(2); clf; 
  subplot(1,2,1);
    scatter(all561x_ref,lz647Vis,'bo'); hold on; 
    scatter(all488x,lzo488,'g.'); 
    scatter(all561x,lzo561,'r.');
    scatter(all750x,lzo750,'m.');
    scatter(all750x_ref,lz647IR,'co'); 
    title('unwarped');
    ylim([zmin,zmax]); xlim([100,110]);
  subplot(1,2,2);
    scatter(all561x_ref,lz647Vis,'bo'); hold on;
    scatter(tx488,lz488,'g.'); 
    scatter(tx561,lz561,'r.');
    scatter(tx750,lz750,'m.');
    scatter(all750x_ref,lz647IR,'co'); 
    title('warped');
    ylim([zmin,zmax]); xlim([100,110]);
    
% figure(2); clf;
% scatter3(all488x_ref,all488y_ref,all488z_ref,'b.'); hold on; 
% scatter3(all488x,all488y,all488z,'g.'); 
% scatter3(all561x,all561y,all561z,'r.');
% scatter3(all750x,all750y,all750z,'m.');
% scatter3(all750x_ref,all750y_ref,all750z_ref,'c.'); 
% title('unwarped');
% view(90,0) % view(50,20)
% 
% figure(3); clf;
% scatter3(all488x_ref,all488y_ref,all488z_ref,'b.'); hold on;
% scatter3(tx488,ty488,tz488,'g.'); 
% scatter3(tx561,ty561,tz561,'r.');
% scatter3(tx750,ty750,tz750,'m.');
% scatter3(all750x_ref,all750y_ref,all750z_ref,'c.'); 
% title('warped');


%% XY average warp error
  fig_xyerr =  figure(4); clf; subplot(1,2,1);
    plot(all750x,all750y,'mo',all750x_ref,all750y_ref,'m+',...
        all561x,all561y,'r*',all561x_ref,all561y_ref,'b+',...
        all488x,all488y,'go',all488x_ref,all488y_ref,'b+');
    title('before warp');
    legend('750','647IR','561','647vis','488');
    xlim([90,160]); ylim([90,120]);

    subplot(1,2,2); 
    plot(tx750_2d,ty750_2d,'mo',all750x_ref,all750y_ref,'m+',...
        tx561_2d,ty561_2d,'r*',all561x_ref,all561y_ref,'b+',...
        tx488_2d,ty488_2d,'go',all488x_ref,all488y_ref,'b+');
    title('after warp');
    legend('750','647IR','561','647vis','488');
    xlim([90,160]); ylim([90,120]);


      fig_xyerr_all =  figure(5); clf; subplot(1,2,1);
    plot(all750x,all750y,'mo',all750x_ref,all750y_ref,'m+',...
        all561x,all561y,'r*',all561x_ref,all561y_ref,'b+',...
        all488x,all488y,'go',all488x_ref,all488y_ref,'b+');
    title('before warp');
    legend('750','647IR','561','647vis','488');
    subplot(1,2,2); plot(tx750_2d,ty750_2d,'mo',all750x_ref,all750y_ref,'m+',...
        tx561_2d,ty561_2d,'r*',all561x_ref,all561y_ref,'b+',...
        tx488_2d,ty488_2d,'go',all488x_ref,all488y_ref,'b+');
    title('after warp');
    legend('750','647IR','561','647vis','488');
%% 3D average warp error
nm_per_pix = 158; 
xys = (nm_per_pix)^2;

% pre-warp error
do750 = sqrt( xys*(all750x - all750x_ref).^2 + xys*(all750y - all750y_ref).^2 + (all750z - all750z_ref).^2 );
do561 = sqrt( xys*(all561x - all561x_ref).^2 + xys*(all561y - all561y_ref).^2 + (all561z - all561z_ref).^2 );
do488 = sqrt( xys*(all488x - all488x_ref).^2 + xys*(all488y - all488y_ref).^2 + (all488z - all488z_ref).^2 );

% post-warp error
d750 = sqrt( xys*(tx750 - all750x_ref).^2 + xys*(ty750 - all750y_ref).^2 + (tz750 - all750z_ref).^2 );
d561 = sqrt( xys*(tx561 - all561x_ref).^2 + xys*(ty561 - all561y_ref).^2 + (tz561 - all561z_ref).^2 );
d488 = sqrt( xys*(tx488 - all488x_ref).^2 + xys*(ty488 - all488y_ref).^2 + (tz488 - all488z_ref).^2 );

% compute warp accuracy
thr = .75;
[cdf750.y, cdf750.x] = ecdf(d750);
[cdf561.y, cdf561.x] = ecdf(d561);
[cdf488.y, cdf488.x] = ecdf(d488);
cdf90_750 = (cdf750.x(find(cdf750.y>thr,1,'first')));
cdf90_561 = (cdf561.x(find(cdf561.y>thr,1,'first')));
cdf90_488 = (cdf488.x(find(cdf488.y>thr,1,'first')));
disp([num2str(100*thr,2),'% of 750 beads aligned to ', num2str(cdf90_750),'nm']);
disp([num2str(100*thr,2),'% of 561 beads aligned to ', num2str(cdf90_561),'nm']);
disp([num2str(100*thr,2),'% of 488 beads aligned to ', num2str(cdf90_488),'nm']);

% Histogram warp error
fig_warperr = figure(1); clf; 
subplot(3,2,1); hist(do750,100); title(['unwarped 750, mean error: ',num2str(mean(do750),3),'nm']);
subplot(3,2,2); hist(d750,100);  title(['3D warped 750: ' num2str(100*thr,2),'% aligned to ', num2str(cdf90_750),'nm']);
subplot(3,2,3); hist(do561,100);  title(['unwarped 561, mean error: ',num2str(mean(do561),3),'nm']);
subplot(3,2,4); hist(d561,100);   title(['3D warped 561: ',num2str(100*thr,2),'% aligned to ', num2str(cdf90_561),'nm']);
subplot(3,2,5); hist(do488,100);  title(['unwarped 488, mean error: ',num2str(mean(do488),3),'nm']);
subplot(3,2,6); hist(d488,100);   title(['3D warped 488: ',num2str(100*thr,2),'% aligned to ', num2str(cdf90_488),'nm']);



% XY average warp error

d2o750 =  nm_per_pix*sqrt( (all750x - all750x_ref).^2 + (all750y - all750y_ref).^2  );
d2o561 =  nm_per_pix*sqrt( (all561x - all561x_ref).^2 + (all561y - all561y_ref).^2 );
d2o488 =  nm_per_pix*sqrt( (all488x - all488x_ref).^2 + (all488y - all488y_ref).^2  );

d2_750 =  nm_per_pix*sqrt( (tx750' - all750x_ref).^2 + (ty750' - all750y_ref).^2  );
d2_561 =  nm_per_pix*sqrt( (tx561' - all561x_ref).^2 + (ty561' - all561y_ref).^2  );
d2_488 =  nm_per_pix*sqrt( (tx488' - all488x_ref).^2 + (ty488' - all488y_ref).^2 );

[cdf2_750.y, cdf2_750.x] = ecdf(d2_750);
[cdf2_561.y, cdf2_561.x] = ecdf(d2_561);
[cdf2_488.y, cdf2_488.x] = ecdf(d2_488);
cdf2_750 = (cdf2_750.x(find(cdf2_750.y>thr,1,'first')));
cdf2_561 = (cdf2_561.x(find(cdf2_561.y>thr,1,'first')));
cdf2_488 = (cdf2_488.x(find(cdf2_488.y>thr,1,'first')));

fig_warperr_2d = figure(3); clf; 
subplot(3,2,1); hist(d2o750,100); title(['unwarped 750, mean error: ',num2str(mean(d2o750),3),'nm']);
subplot(3,2,2); hist(d2_750,100);  title(['2D warped 750: ' num2str(100*thr,2),'% aligned to ', num2str(cdf2_750),'nm']);
subplot(3,2,3); hist(d2o561,100);  title(['unwarped 561, mean error: ',num2str(mean(d2o561),3),'nm']);
subplot(3,2,4); hist(d2_561,100);   title(['2D warped 561: ',num2str(100*thr,2),'% aligned to ', num2str(cdf2_561),'nm']);
subplot(3,2,5); hist(d2o488,100);  title(['unwarped 488, mean error: ',num2str(mean(d2o488),3),'nm']);
subplot(3,2,6); hist(d2_488,100);   title(['2D warped 488: ',num2str(100*thr,2),'% aligned to ', num2str(cdf2_488),'nm']);


saveas(fig_warperr,[pathin,'/',saveroot,'fig_warperr.png']);
saveas(fig_xyerr,[pathin,'/',saveroot,'fig_xyerr.png']);  
saveas(fig_zdist,[pathin,'/',saveroot,'fig_zdist.png']);
saveas(fig_xzerr,[pathin,'/',saveroot,'fig_xyzerr.png']);
saveas(fig_xyerr_all,[pathin,saveroot,'/','fig_xyerr_all.png']);
saveas(fig_warperr_2d,[pathin,'/','fig_warperr_2d.png']);


% SAVE transforms
save([pathin,'/','tforms3D.mat'],'tform488','tform561','tform750',...
    'tform488_1','tform561_1','tform750_1',...
    'cdf750','cdf561','cdf488','cdf90_750','cdf90_561','cdf90_488','thr');
disp(['wrote ',pathin,'/','tforms3D.mat']);    


save([pathin,'/','tforms2D.mat'],'tform488_2D','tform561_2D','tform750_2D',...
    'tform488_1','tform561_1','tform750_1',...    
    'cdf2_750','cdf2_561','cdf2_488','thr');
disp(['wrote ',pathin,'/','tforms2D.mat']);
disp('3D bead fitting complete');


%% test z-calibration by refitting calibration movie
% zroot = 'Zcal'; 
% chns = {'750','647','561','488'};
% 
% for c=1:length(chns);
%     % find dax files 
%     chn = chns{c}; 
%      alldax = dir([pathin,'\',chn,'*.dax']);
%      inidata = dir([pathin,'\',chn,'*.ini']); 
%      ini = [pathin,'\',inidata.name];%   
%      if QVZ == 1
%          if strcmp(chn,'750')==1 || strcmp(chn,'647')==1
%              alldax = dir([pathin,'\','IR','*',zroot,'*.dax']);
%          elseif  strcmp(chn,'561')==1 || strcmp(chn,'488')==1
%              alldax = dir([pathin,'\','Vis','*',zroot,'*.dax']);
%          end
%      end
%      
%      Nframes = length(alldax);  % unnecessary really as we only take z-calibration movie.   
%         for k=1:Nframes             
%                 dax = [pathin,'\',alldax(k,1).name];   
%                 ccall = ['!',insight,' ',dax,' ',iniVis, '&& exit &'];
%                 disp(ccall); % print command to screen
%                 eval(ccall);  % Run insightM to get positions                       
%         end
% end
% 
%     allbin = dir([workdir,'\' Bead_folder,'\', '*',zroot,'*_list.bin']);
%     Nframes = length(allbin);
%     disp(['found ',num2str(Nframes), ' _list.bin files']); 
% 
%
  
function signalchn = remove_bleadthrough(signalchn,bkdchn,tform_start,cx_radius,verbose,sname,k)
       
     [matched, ~] = corr_mols(signalchn,bkdchn,tform_start, cx_radius); 
     if ~isempty(matched.set1_inds)
        % figure(2); clf; plot(signalchn.x, signalchn.y,'k.',signalchn.x( matched.set1_inds ),signalchn.y( matched.set1_inds ),'ro');
         signalchn.x( matched.set1_inds )=[];
         signalchn.y( matched.set1_inds )=[];
         signalchn.z( matched.set1_inds )=[];
       %  figure(2); hold on; plot(signalchn.x, signalchn.y,'g+');
     end
     if verbose
       disp(['frame ',num2str(k),':  ', num2str(length(matched.set1_inds)), '/',...
       num2str(length(signalchn.x)),...
       ' IR blead-through molecules removed from', sname])
     end        

       
function [set1,set2] = matchmols(ref,sample,tform, match_radius1,verbose,sname,k)
       [matched, unmatched] = corr_mols(ref, sample,tform, match_radius1);                   
         set1.x{k} = ref.x( matched.set1_inds ); % points in ref channel
         set1.y{k} = ref.y( matched.set1_inds );
         set1.z{k} = ref.z( matched.set1_inds );
         set2.x{k} = sample.x( matched.set2_inds ); % points in 750 channel
         set2.y{k} = sample.y( matched.set2_inds );
         set2.z{k} = sample.z( matched.set2_inds );   
         if verbose
         disp(['frame ',num2str(k),':  ', num2str(length(matched.set2_inds)), '/'...
           num2str( length(matched.set2_inds) + length(unmatched.set2_inds) ),...
           sname ,' molecules matched'])   
         end

         
 function [zf,ps] = level_data(x,y,z)
    % zf = level_data(x,y,z) 
    % Returns vector zf of length(z) such that 
    % z_leveled = z - level_data(x,y,z);
    % will remove any systematic tilt in the dataset z.  
    try
    p = polyfitn([x',y'],z',2);
    catch
        p = polyfitn([x,y],z,2);
    end
    ps = p.Coefficients;
    zf = x.^2*ps(1) + x.*y*ps(2) + x*ps(3) + y.^2*ps(4) + y*ps(5) + ps(6);
    % % For plotting only
    % ti = 5:5:120;
    % [xi,yi] = meshgrid(ti,ti);
    % zi = xi.^2*ps(1) + xi.*yi*ps(2) + xi*ps(3) + yi.^2*ps(4) + yi*ps(5) + ps(6);
    
    
  function binname = WriteDax(movie,info,tag,method,parsfile,hideterminal,overwrite)
    info.hend = subregion(2)-subregion(1)+1;
    info.vend = subregion(4)-subregion(3)+1;
    info.frame_dimensions = [info.hend,info.vend];
    info.localName = [tag,'_',info.localName];
    WriteDAXFiles(movie647,info);   
    newdaxfile = [pathin,filesep,info.localName(1:end-4),'.dax'];
    RunDotFinder('method',method,'parsfile',parsfile,...
           'daxfile',newdaxfile,'hideterminal',hideterminal,...
           'overwrite',overwrite,'verbose',verbose); 

