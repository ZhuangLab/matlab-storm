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
% 'beadsets' / structure nx1
%           required fields if passed: 
%               'chns' / cell of strings / {'647','750'}
%               'refchn' / string / '647'
%           Optional fileds
%               'quadview' / logical / true
%               'daxroot' / string / 'IRbeads' - part of daxfile filename
%               'parsroot' / string / 'Visbeads' - part of .ini or .xml
%                       filename
% 'QVorder' / cell / {'647','561','750',488'}
%               Only relevant if using quadview.  with the same labels as
%               in beadsets.chns, the order, right to left and top to
%               bottom, that the channels are arranged in quadview. 
% 'overwrite' / double / 0
%                       -- 0 skip, 1 = overwrite, 2 = ask me.
% 'saveroot' / string / ''
%                       -- string to be incorporated into exported files
% 'affine match radius' / double / 6
%                       -- maximum distance between beads in different
%                       color channels to still be considered same bead.
%                       measured in pixels.  used in affine transformation
%                       only, which is robust to larger values.  
% 'polyfit match radius' / double / 2
%                       -- maximum distance between beads in different
%                       color channels to still be considered same bead.
%                       measured in pixels.  STORM4 quadview requires large
%                       offset (~6-8).
% 'remove crosstalk' / logical / true
%                       -- Vis beads sometimes show up in IR channels.
%                       This will attempt to remove these beads to improve
%                       fits and estimate of fit errors
% 'method' /string / 'insight'
%                       -- 'insight' or 'DaoSTORM' for dotfitting
% 'noclass9' / logical / false
%                       -- exclude class9 molecules? (failed z-fit error
%                       tolerance in insight).  
% 'verobse' / logical / true
%                       -- print progress updates to screen
%--------------------------------------------------------------------------
% Alistair Boettiger
% boettiger.alistair@gmail.com
% February 12th, 2013
%
% Version 4.1
%--------------------------------------------------------------------------
% Creative Commons License 3.0 CC BY  
%--------------------------------------------------------------------------
%% updates
% Version 4.1 Updated for integration into STORMfinderBeta, complete with
%   its own GUI for choosing parameters.  
% Version 4.0  02/10/13 -- Rewritten to accomidate arbitrary number of 
%    movies and arbitrary combinations of reference and sample channels. 
%    Works in with successive movies or quadview split.
% Version 3.0 02/08/13 -- Rewritten to use ReadMasterMoleculeList format,
%    clean up code a little bit by subfunctionalization.  
% Version 2.2 12/2012 computes a coarse affine warp to followed by a fine
%   polynomial warp; 
% Version 2.1 06/2012 change defaults so that if list.bin files exist
%   insight will not rerun.
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
% Global Variables
%--------------------------------------------------------------------------
global ScratchPath


%--------------------------------------------------------------------------
%% Hardcoded Variables
%-------------------------------------------------------------------------- 
% These can all become user inputs later: 


% beadmovie(1).daxroot = 'IRbeads';
% beadmovie(1).parsroot = 'IRBead';
% beadmovie(1).quadview = true;
% beadmovie(2).daxroot = 'Visbeads';
% beadmovie(2).parsroot = 'VisBead';
% beadmovie(2).quadview = true;

%--------------------------------------------------------------------------
%% Default Parameters
%--------------------------------------------------------------------------
match_radius1 = 10;
saveroot = ''; 
match_radius =  2; %
fpZ = 5; % frames per z
overwrite = 0;  % needs to overwrite files to apply different parameters
method ='insight'; %  'DaoSTORM';
hideterminal = true;
Noclass9 = true;
verbose = true;

% Defaults for beadmovie:
    beadmovie(1).chns = {'750','647'};
    beadmovie(1).refchn = '647';
    beadmovie(2).chns = {'647','561','488'};
    beadmovie(2).refchn = '647';
    optional_fields = {'daxroot','parsroot','quadview'};
    default_values = {'','',true};
    
QVorder = {'647','561','750','488'}; % topleft, topright,bottomleft, bottomright.

% might be removed in future: 
remove_crosstalk = false;
max_frames = inf; % May be removed soon

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
                method = CheckList(parameterValue,{'insight','DaoSTORM'},'method');
            case 'overwrite'
                overwrite= CheckParameter(parameterValue,'nonnegative','overwrite');
            case 'frames per Z'
                fpZ = CheckParameter(parameterValue,'positive','fpZ');
            case 'max frames'
                max_frames = CheckParameter(parameterValue,'positive','max frames');
            case 'save root'
                saveroot = CheckParameter(parameterValue,'string','save root');
            case 'affine match radius'
                match_radius1 = CheckParameter(parameterValue,'positive','affine match radius');
            case 'polyfit match radius'
                match_radius = CheckParameter(parameterValue,'positive','polyfit match radius');
            case 'remove crosstalk'
                remove_crosstalk = CheckParameter(parameterValue,'boolean','remove crosstalk');
            case 'beadset'
                beadmovie = CheckParameter(parameterValue,'struct','beadset');
            case 'Noclass9'
                Noclass9 = CheckParameter(parameterValue,'boolean','Noclass9');
            case 'QVorder'
                QVorder = CheckParameter(parameterValue,'array','QVorder'); 
            case 'hideterminal'
                hideterminal = CheckParameter(parameterValue,'boolean','hideterminal');
            case 'verbose'
                verbose =  CheckParameter(parameterValue,'boolean','verbose');
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end


% parsing optional fields of beadmovie
    Nmovies = length(beadmovie);

    for n=1:length(optional_fields)
        if ~isfield(beadmovie(1),optional_fields(n))
            beadmovie(1).(optional_fields(n)) = default_values{n};
        end
    end

    % fields that CalcChromeWarp will add to the 
    beadmovie(Nmovies).binname = [];
    beadmovie(Nmovies).parsfile = [];
    beadmovie(Nmovies).Nfields = [];
    beadmovie(Nmovies).refchni = [];

%--------------------------------------------------------------------------
%% Main code
%--------------------------------------------------------------------------
 
% parse method specific parameters 
if strcmp(method,'insight')
    parstype = '.ini';
   datatype = '_list.bin';
elseif strcmp(method,'DaoSTORM');
    parstype = '.xml';
   datatype = '_alist.bin';  
end


%%  Run beadfitting
% match each region of the movie to the appropriate bead parameters 


for m=1:Nmovies

    % find all dax files (different bead fields) from each movie
    alldax = dir([pathin,'\', beadmovie(m).daxroot,'*.dax']);
     if isempty(alldax)
         warning('MATLAB:DirNotFound',['no ', beadmovie(m).daxroot ,'*.dax files found in ',pathin,filesep]);
     end
    Nfields = length(alldax);
    Nfields = min(max_frames,Nfields); 
    Nchns = length(beadmovie(m).chns);
    beadmovie(m).Nfields = Nfields; 
    
    % convert reference channel to index
    refchni = find(strcmp(beadmovie(m).chns,beadmovie(m).refchn));
    if isempty(refchni)
        disp(['reference channel: ',beadmovie(m).refchn, ' does not exist among movie channels ']);
        disp(beadmovie(m).chns);  
        error('Reference channel must be one of the movie channels');
    end
    beadmovie(m).refchni = refchni;
    
    %----------------------------------------------------------------------   
     % Get a parameter file for each channel 
     % If a match to the input parsroot is succesful, use that
     % otherwise, prompt the reader to chose a file from the load GUI
     beadmovie(m).parsfile = cell(Nchns,1);    
     for c=1:length(beadmovie(m).chns)
            parsroot = [beadmovie(m).chns{c},'*',beadmovie(m).parsroot];
            
            disp([pathin,filesep,'*',parsroot, '*',parstype]);
            
        if isempty(beadmovie(m).parsfile{c})
            parsname = dir([pathin,filesep,'*',parsroot, '*',parstype]);
            if length(parsname) > 1 || isempty(parsname)
                disp(['Too many or no ',parstype,...
                    ' files in directory.  Please chose a parameters file for']);
               getfileprompt = {['*',parstype],[method,' pars (*',parstype,')']};
               [filename, filepath] = uigetfile(getfileprompt,...
                   ['Select Parameter File for ',beadmovie(m).parsroot,...
                   ' ',beadmovie(m).chns{c}],pathin);
               beadmovie(m).parsfile{c} = [filepath, filename];
            else
                beadmovie(m).parsfile{c} = [pathin, filesep, parsname.name];
            end
        end     
        if isempty(strfind(beadmovie(m).parsfile{c},parstype))
            error([beadmovie(m).parsfile{c}, ' is not a valid ', parstype, ' parameter file for ',method]);
        end
     end
    %----------------------------------------------------------------------

    
 % Read and run 
 %--------------------------------------------------------------------
 
 % currently written for quadview of singleview
 % for Dualview just need to add a dualview parser into ReadDaxBeta (or
 % could call ReadDaxBeta twice with different 'subregion',[xmin,xmax,ymin
 % ymax]).  
 % For single channel we have n movies Nchns =1;
 
 % Create new folder to save split-off movies
 if beadmovie(m).quadview
    splitdax_folder = 'splitdax';
    newpath = [pathin,filesep,splitdax_folder,filesep];  
    if ~isdir(newpath)
        mkdir(newpath);
    end
 else
     newpath = [pathin,filesep];
 end
    
    beadmovie(m).binname = cell(Nchns,Nfields);
 % Loop through all split off movies and run appropriate parameters on them   
    for n=1:Nfields
        % Check to see if split dax movies already exist in target folder
        % if not found for all channels, load original dax and split again.
        try
            splitdax = dir([newpath,'*',alldax(n).name]); 
            notsplit = length(splitdax) < Nchns;
            if   notsplit
                daxfile = [pathin,filesep,alldax(n).name];
                [movies,info] = ReadDaxBeta(daxfile,'Quadviewsplit',true);
            end
            for c=1:Nchns
                if notsplit
                    QVframe = strcmp(QVorder,beadmovie(m).chns{c});
                    WriteDax(movies{QVframe},info,beadmovie(m).chns{c},newpath);     
                end
                if beadmovie(m).quadview
                daxfile = [newpath,filesep,beadmovie(m).chns{c},'_',alldax(n).name];
                else
                daxfile = [newpath,filesep,alldax(n).name];
                end
                beadmovie(m).binname{c,n} = [daxfile(1:end-4),datatype]; 
                RunDotFinder('method',method,'parsfile',beadmovie(m).parsfile{c},...
                   'daxfile',daxfile,'hideterminal',hideterminal,...
                   'overwrite',overwrite,'batchsize',2); 
               % batchsize 2 implies RunDotFinder will return control to
               % CalcChromeWarp without waiting for analysis to finish
            end
        catch er
            disp(er.message); 
            disp(['skipping field: ',num2str(n)]);
        end
    end
end

% Wait until all movies have finished being analyzed before proceeding
for m=1:Nmovies
    max_wait = 100; 
    waitT = 0;
    Nbinfiles_complete = length(dir([newpath,'*', beadmovie(m).daxroot,'*',datatype]));
    Nbinfiles_started = length(beadmovie(m).chns)*beadmovie(m).Nfields;
    while Nbinfiles_complete < Nbinfiles_started && waitT < max_wait
       Nbinfiles_complete = length(dir([newpath,'*', beadmovie(m).daxroot,'*',datatype]));
       Nbinfiles_started = length(beadmovie(m).chns)*beadmovie(m).Nfields; 
       pause(1);
       waitT = waitT+1; 
    end
end



% split data into reference channels and samples 

% Nsamples is number of channels minus 1 reference channel for every movie 
Nsamples = length([beadmovie.chns]) - Nmovies; 



data(Nsamples).sample(Nfields).x = [];
data(Nsamples).sample(Nfields).y = [];
data(Nsamples).sample(Nfields).z = [];
data(Nsamples).sample(Nfields).chn = [];
data(Nsamples).refchn(Nfields).x = [];
data(Nsamples).refchn(Nfields).y = [];
data(Nsamples).refchn(Nfields).z = [];
data(Nsamples).refchn(Nfields).chn = [];


sampleset = 0;
refset = 0;
for m=1:Nmovies
    for c=1:length(beadmovie(m).chns)  
        if c ~= beadmovie(m).refchni
            sampleset = sampleset + 1; 
            issample = true;
        else
            refset = refset + 1;
            issample = false;
        end
            
          for n = 1:Nfields; 
                try % keep going even if a movie is missing
                    mol_list = ReadMasterMoleculeList( beadmovie(m).binname{c,n},'verbose',false); 

                    % only keep beads that are detected in all frames
                    frames_per_field = max(mol_list.length);
                    mols_on_allframes = mol_list.length >= .9*frames_per_field;
                    if sum(mols_on_allframes) < .1*length(mol_list.x)
                        disp('warning: many molecules not detected or linked for all frames in:');
                        disp(beadmovie(m).binname{c,n});
                       % disp('try rerunning with a larger match radius');  
                    end
                    if Noclass9
                        goodmol = (mol_list.c~=9) & mols_on_allframes; % use only molecules with good z-fit score (class 1)
                    else
                        goodmol = mols_on_allframes;
                    end

                    if issample  % store as sample data
                        data(sampleset).sample(n).x = cast(mol_list.xc(goodmol==1),'double');
                        data(sampleset).sample(n).y = cast(mol_list.yc(goodmol==1),'double');
                        data(sampleset).sample(n).z = cast(mol_list.z(goodmol==1),'double');
                        data(sampleset).sample(n).chn = beadmovie(m).chns{c};       
                        data(sampleset).sample(n).bin = beadmovie(m).binname{c,n};             
                    else % store as reference data for all matching samples
                        for k=refset:refset-1+length(beadmovie(m).chns)-1
                        data(k).refchn(n).x = cast(mol_list.xc(goodmol==1),'double');
                        data(k).refchn(n).y = cast(mol_list.yc(goodmol==1),'double');
                        data(k).refchn(n).z = cast(mol_list.z(goodmol==1),'double');  
                        data(k).refchn(n).chn = beadmovie(m).chns{c};       
                        data(k).refchn(n).bin = beadmovie(m).binname{c,n};   
                        end
                    end
                
                catch er
                    disp(er.message); 
                    warning(['failed to load ',pathin,filesep, beadmovie(m).binname{c,n}]);
                    disp(['skipping field: ',num2str(n)]); 
                end 
          end  
    end
end

  
 %% match molecules in each section
% (much less ambiguious than matching superimposed selection list). 

cx_radius = match_radius;

% for plotting
cmap = hsv(Nsamples);
mark = {'o','o','.'};
      
% % plots for troubleshooting
% k = 1; 
% figure(1); clf; 
% for s=1:Nsamples
%     plot(data(s).refchn(k).x,data(s).refchn(k).y,mark{s},'color',cmap(s,:)); hold on;
%       plot(data(s).sample(k).x,data(s).sample(k).y,'+','color',cmap(s,:)); hold on;
% end

tform_start = maketform('affine',[1 0 0; 0 1 0; 0 0 1]);
dat(Nsamples).refchn.x = [];

set1 = cell(Nsamples,1);
set2 = cell(Nsamples,1);
% set1{s}.x{k} provides the set1 matches for sample s in frame k.  
for s=1:Nsamples
    for k = 1:Nfields   
    [set1{s},set2{s}] = matchmols(data(s).refchn(k),data(s).sample(k),...
        tform_start, match_radius1,verbose,data(s).sample(k).chn,k,...
        set1{s},set2{s},Nfields);
    end   
    dat(s).refchn.x = cat(1,set1{s}.x{:}); % cell2mat(set1{s}.x);
    dat(s).refchn.y = cat(1,set1{s}.y{:}); % cell2mat(set1{s}.y);
    dat(s).refchn.z =cat(1,set1{s}.z{:}); %  cell2mat(set1{s}.z);
    dat(s).sample.x =cat(1,set2{s}.x{:}); %  cell2mat(set2{s}.x);
    dat(s).sample.y =cat(1,set2{s}.y{:}); %  cell2mat(set2{s}.y);
    dat(s).sample.z =cat(1,set2{s}.z{:}); %  cell2mat(set2{s}.z);
end




% % test plot
%   figure; clf; 
%   for s=1:Nsamples
%   plot(dat(s).refchn.x,dat(s).refchn.y,mark{s},'color',cmap(s,:)); hold on;
%   plot(dat(s).sample.x,dat(s).sample.y,'+','color',cmap(s,:)); hold on;
%   end
      
 
%% Compute and apply x-y translation warp (transform 1) 
 tform_1 = cell(1,Nsamples); % cell to contain tform_1 for each chn. 
 
for s=1:Nsamples
% maybe important for handling missing data:
    method = 'nonreflective similarity';
    tform_1{s} = maketform('affine',[1 0 0; 0 1 0; 0 0 1]); % 
    if  ~isempty(dat(s).refchn.x)
        tform_1{s} = cp2tform([dat(s).refchn.x dat(s).refchn.y], [dat(s).sample.x dat(s).sample.y ],method); % compute warp
    end 
end

%% REMATCH, then Polywarp 3

%------------------------------------
data2 = data;
for s=1:Nsamples
    for k=1:Nfields
        [xt,yt] = tforminv(tform_1{s}, data(s).sample(k).x,  data(s).sample(k).y);
        data2(s).sample(k).x = xt; 
        data2(s).sample(k).y = yt;
    end
end
% Maybe these points should just go in new field of data?
% need to watch corr mols, it wants to operate on .x .y not .x1, .y2
% also there are different numbers of molecules in each list due to
% different matching, which could get confusing if it's 1 var


% %  A plot just for troubleshooting
% k = 1; % just beads in this field
% figure(1); clf; 
% for s=1:Nsamples
%     plot(data2(s).refchn(k).x,data2(s).refchn(k).y,mark{s},'color',cmap(s,:)); hold on;
%      plot(data2(s).sample(k).x,data2(s).sample(k).y,'+','color',cmap(s,:)); hold on;
% end


%% match molecules in each section
% (much less ambiguious than matching superimposed selection list). 


tform_start = maketform('affine',[1 0 0; 0 1 0; 0 0 1]);
set1 = cell(Nsamples,1);
set2 = cell(Nsamples,1);
dat2(Nsamples).refchn.x = [];
for s = 1:Nsamples
    for k = 1:Nfields          
        % Hard-coded, remove 750 blead through on Quadview
        % With good parameter choices should not be necessary.  
         if remove_crosstalk  && beadmovie(m).quadview % Remove 750 crosstalk 
           data2(2).refchn(k) = remove_bleadthrough(data2(2).refchn(k),data2(1).sample(k),tform_start, cx_radius,verbose,'Vis647',k);
           data2(3).refchn(k) = remove_bleadthrough(data2(3).refchn(k),data2(1).sample(k),tform_start, cx_radius,verbose,'Vis647',k);
           data2(2).sample(k) = remove_bleadthrough(data2(2).sample(k),data2(1).sample(k),tform_start, cx_radius,verbose,'Vis561',k);
           data2(3).sample(k) = remove_bleadthrough(data2(3).sample(k),data2(1).sample(k),tform_start, cx_radius,verbose,'Vis488',k);
        end

         % Match beads from each sample channel to counterpart in target reference channel 
         % set1{s}.x{k} provides the set1 matches for sample s in frame k.  
        [set1{s},set2{s}] = matchmols(data2(s).refchn(k),data2(s).sample(k),...
            tform_start, match_radius,verbose,data2(s).sample(k).chn,k,set1{s},set2{s},Nfields);     
    end      
 % combine into single vectors
    dat2(s).refchn.x = cell2mat(set1{s}.x);
    dat2(s).refchn.y = cell2mat(set1{s}.y);
    dat2(s).refchn.z = cell2mat(set1{s}.z);
    dat2(s).sample.x = cell2mat(set2{s}.x);
    dat2(s).sample.y = cell2mat(set2{s}.y);
    dat2(s).sample.z = cell2mat(set2{s}.z);
end
    
%   % test plot
%       fig_xyerr_all =  figure; clf; subplot(1,2,1);
%       for s=1:Nsamples
%       plot(dat(s).refchn.x,dat(s).refchn.y,mark{s},'color',cmap(s,:)); hold on;
%       plot(dat(s).sample.x,dat(s).sample.y,'+','color',cmap(s,:)); hold on;
%       end
%       title('after warp1'); 
% 
% %-------------------------------------------------------------------
%% Compute and apply warp 

poly_order = 2;
poly_order2 = 2;
tform = cell(Nsamples,1);
tform2D = cell(Nsamples,1); 

for s=1:Nsamples
    refchn = [dat2(s).refchn.x dat2(s).refchn.y dat2(s).refchn.z]; 
    sample = [dat2(s).sample.x dat2(s).sample.y dat2(s).sample.z]; 
    tform{s} = cp2tform3D(refchn,sample,'polynomial',poly_order); % compute warp
    [dat2(s).sample.tx,dat2(s).sample.ty,dat2(s).sample.tz] = ...
        tforminv(tform{s}, dat2(s).sample.x, dat2(s).sample.y, dat2(s).sample.z); % apply warp
    % 2D transform (for troubleshooting)
    tform2D{s} = cp2tform( [dat2(s).refchn.x dat2(s).refchn.y],...
        [dat2(s).sample.x dat2(s).sample.y],'polynomial',poly_order2); % compute warp
    [dat2(s).sample.tx2D,dat2(s).sample.ty2D,] = tforminv(tform2D{s},...
        dat2(s).sample.x, dat2(s).sample.y); % apply warp
end

% DONE!
% the rest of this code is just graphing and computing the accuracy of the
% warp in different ways.  tforms are exported at the end along with the
% percision of fit data.  Plots are automatically saved in the source
% folder to better document warp percision. 




%% level the data and plot z-distribution



% level unwarped zdata based on flatness of field in frame1
% syntax 
 % zlevel = z_apply - level_data([x_fit,y_fit,z_fit],[x_apply,y_apply])  (x,y,z to compute tilt)
for s=1:Nsamples
%    % Level just using tilt from frame 0.  
%      zc_ref  = level_data([data2(s).refchn(1).x, data2(s).refchn(1).y, data2(s).refchn(1).z],[dat2(s).refchn.x, dat2(s).refchn.y]); % unwarped ref data
%      dat2(s).refchn.zo  = dat2(s).refchn.z - zc_ref;
%      zc_sample  = level_data([data2(s).sample(1).x, data2(s).sample(1).y, data2(s).sample(1).z],[dat2(s).sample.x, dat2(s).sample.y]); % unwarped sample data
%     dat2(s).sample.zo = dat2(s).sample.z- zc_sample;
%  
% Level using best global filt of a plane to all data
   % zlevel = z_apply - level_data([x_fit,y_fit,z_fit],[x_apply,y_apply])  (x,y,z to compute tilt)
     zc_ref  = level_data([dat2(s).refchn.x, dat2(s).refchn.y, dat2(s).refchn.z],[dat2(s).refchn.x, dat2(s).refchn.y]); % unwarped ref data
     dat2(s).refchn.zo  = dat2(s).refchn.z - zc_ref;
     zc_sample  = level_data([dat2(s).sample.x, dat2(s).sample.y, dat2(s).sample.z],[dat2(s).sample.x, dat2(s).sample.y]); % unwarped sample data
    dat2(s).sample.zo = dat2(s).sample.z- zc_sample;  
end


%% 
% Color coded histograms of the leveled z-distributions of beads in each
% color.  The bar color indicates the actual cluster. 
zmin = -650; zmax = 650; % for plotting only

try
    passes = Nfields/fpZ ;
    col = hsv(passes+1);
    sample_clust = zeros(Nsamples,passes+1);
    ref_clust = zeros(Nsamples,passes+1);
    for n=1:Nsamples    
        for j=1:passes % separate molecules into z clusters
            ks = (1+(j-1)*fpZ:j*fpZ); % subset of frames at specific z-height
            sample_clust(n,j+1) = sample_clust(n,j) + sum(cellfun(@length,set2{n}.z(ks)));
            ref_clust(n,j+1) = ref_clust(n,j) + sum(cellfun(@length,set1{n}.z(ks)));
        end
    end

    % histogram each z cluster as a different color.  Do for each of the
        % channels (including reference channels) 
    fig_zdist = figure; clf;
    
    hx = linspace(zmin,zmax,50);    
    for n=1:Nsamples    
        for j=2:passes+1 % j=3;
        % for sample beads
        subplot(Nsamples,Nmovies,(2*n)-1); 
        hist(dat2(n).sample.zo(sample_clust(n,j-1)+1: sample_clust(n,j) ),hx);
        title(['plot: ',num2str((2*n)-1),' ', data(n).sample(1).chn]); 
        xlim([zmin,zmax]); hold on;
        h1  = findobj(gca,'Type','Patch'); 
        set(h1(1),'FaceColor',col(j-1,:),'EdgeColor',col(j-1,:)); alpha .7;

        % For reference beads
        subplot(Nsamples,Nmovies,(2*n)); 
        hist(dat2(n).refchn.zo(ref_clust(n,j-1)+1: ref_clust(n,j) ),hx);
        title(['plot: ',num2str((2*n)),' ', data(n).refchn(1).chn]); 
        xlim([zmin,zmax]); hold on;
        h1  = findobj(gca,'Type','Patch'); 
        set(h1(1),'FaceColor',col(j-1,:),'EdgeColor',col(j-1,:)); alpha .7; 
        end
    end
     colormap(col(1:passes,:));
     colorbar; caxis([1,passes]);
     set(gcf,'color','w');
catch er
    disp(er.message)
    disp(['error in computing histogram of z-positions.  ',...
        'Perhaps the wrong number of frames per z positions is entered']);
    disp(['should the frames per z be: ',num2str(fpZ)]);
end
%%  XZ error
  fig_xzerr =  figure; clf;
  subplot(1,2,1);
  for s=1:Nsamples
  plot(dat(s).refchn.x,dat(s).refchn.z,mark{s},'color',cmap(s,:)); hold on;
  plot(dat(s).sample.x,dat(s).sample.z,'+','color',cmap(s,:)); hold on;
  end
 title('unwarped xz scatter');     ylim([zmin,zmax]); % xlim([100,110]);    

   subplot(1,2,2);
  for s=1:Nsamples
  plot(dat2(s).refchn.x,dat2(s).refchn.z,mark{s},'color',cmap(s,:)); hold on;
  plot(dat2(s).sample.tx,dat2(s).sample.tz,'+','color',cmap(s,:)); hold on;
  end
 title('warped xz scatter');     ylim([zmin,zmax]); % xlim([100,110]);    

 

%% XY average warp error
% xy error
  fig_xyerr_all =  figure; clf; subplot(1,2,1);
  for s=1:Nsamples
  plot(dat(s).refchn.x,dat(s).refchn.y,mark{s},'color',cmap(s,:)); hold on;
  plot(dat(s).sample.x,dat(s).sample.y,'+','color',cmap(s,:)); hold on;
  end
 title('unwarped');  

 subplot(1,2,2);
  for s=1:Nsamples
  plot(dat2(s).refchn.x,dat2(s).refchn.y,mark{s},'color',cmap(s,:)); hold on;
  plot(dat2(s).sample.tx,dat2(s).sample.ty,'+','color',cmap(s,:)); hold on;
  end
 title('warped');  
 
 
fig_xyerr =  figure; clf; subplot(1,2,1);
xmin = 100; xmax = 130; ymin = 100; ymax = 130; 
  for s=1:Nsamples
  plot(dat(s).refchn.x,dat(s).refchn.y,mark{s},'color',cmap(s,:)); hold on;
  plot(dat(s).sample.x,dat(s).sample.y,'+','color',cmap(s,:)); hold on;
  end
 title('unwarped');   
 xlim([xmin,xmax]); 
 ylim([ymin,ymax]); 

 subplot(1,2,2);
  for s=1:Nsamples
  plot(dat2(s).refchn.x,dat2(s).refchn.y,mark{s},'color',cmap(s,:)); hold on;
  plot(dat2(s).sample.tx,dat2(s).sample.ty,'+','color',cmap(s,:)); hold on;
  end
 title('warped');
 xlim([xmin,xmax]);
 ylim([ymin,ymax]);  

%% 3D Total warp error
nm_per_pix = 158; 
xys = (nm_per_pix)^2;
thr = .75;

% pre-warp error (3D)
prewarperror = cell(Nsamples,1); 
for s=1:Nsamples
prewarperror{s} = sqrt( xys*(dat(s).sample.x - dat(s).refchn.x).^2 +...
                 xys*(dat(s).sample.y - dat(s).refchn.y).^2 +...
                (dat(s).sample.z - dat(s).refchn.z).^2 );
end

% post-warp1 error (3D)
warp1error = cell(Nsamples,1); 
for s=1:Nsamples
warp1error{s} = sqrt( xys*(dat2(s).sample.x - dat2(s).refchn.x).^2 +...
                 xys*(dat2(s).sample.y - dat2(s).refchn.y).^2 +...
                (dat2(s).sample.z - dat2(s).refchn.z).^2 );
end

% post warp error (3D), 
postwarperror = cell(Nsamples,1); 
cdf(Nsamples).x = []; 
cdf_thresh = zeros(Nsamples,1); 
for s=1:Nsamples
postwarperror{s} = sqrt( xys*(dat2(s).sample.tx - dat2(s).refchn.x).^2 +...
                     xys*(dat2(s).sample.ty - dat2(s).refchn.y).^2 +...
                    (dat2(s).sample.tz - dat2(s).refchn.z).^2 );
[cdf(s).y, cdf(s).x] = ecdf(postwarperror{s});
cdf_thresh(s)  = (cdf(s).x(find(cdf(s).y>thr,1,'first')));
disp([num2str(100*thr,2),'% of ',data(s).sample(1).chn,...
    ' 3D beads aligned to ', num2str(cdf_thresh(s)),'nm']);
end

% Histogram warp error
fig_warperr = figure; clf; 
k=0;
for s=1:Nsamples
    k=k+1;
    subplot(Nsamples,3,k); hist(prewarperror{s},100);
    title(['unwarped ',data(s).sample(1).chn,' <error>: ',...
        num2str(mean(prewarperror{s}),3),'nm'],'FontSize',7);
    k=k+1;
    subplot(Nsamples,3,k); hist(warp1error{s},100);
    title(['After affine : ',data(s).sample(1).chn,' <error>: ',...
        num2str(mean(warp1error{s}),3),'nm'],'FontSize',7);
    k=k+1;
    subplot(Nsamples,3,k); hist(postwarperror{s},100);  
    title(['3D warped ',data(s).sample(1).chn,': ' num2str(100*thr,2),...
        '% aligned to ', num2str(cdf_thresh(s),4),'nm'],'FontSize',7);
end
set(gcf,'color','w');





%% 2D XY average warp error


% pre-warp error (3D)
prewarperror2D = cell(Nsamples,1); 
for s=1:Nsamples
prewarperror2D{s} = sqrt( xys*(dat(s).sample.x - dat(s).refchn.x).^2 +...
                    xys*(dat(s).sample.y - dat(s).refchn.y).^2  );
end

% pre-warp error (3D)
warp1error2D = cell(Nsamples,1); 
for s=1:Nsamples
warp1error2D{s} = sqrt( xys*(dat2(s).sample.x - dat2(s).refchn.x).^2 +...
                    xys*(dat2(s).sample.y - dat2(s).refchn.y).^2  );
end

% post warp error (3D), 
postwarperror2D = cell(Nsamples,1); 
cdf2D(Nsamples).x = []; 
cdf2D_thresh = zeros(Nsamples,1); 
for s=1:Nsamples
postwarperror2D{s} = sqrt( xys*(dat2(s).sample.tx2D - dat2(s).refchn.x).^2 +...
                     xys*(dat2(s).sample.ty2D - dat2(s).refchn.y).^2 );
[cdf2D(s).y, cdf2D(s).x] = ecdf(postwarperror2D{s});
cdf2D_thresh(s)  = (cdf2D(s).x(find(cdf2D(s).y>thr,1,'first')));
disp([num2str(100*thr,2),'% of ',data(s).sample(1).chn,...
    ' 2D beads aligned to ', num2str(cdf2D_thresh(s)),'nm']);
end


% Histogram warp error
fig_warperr_2d = figure; clf; 
k=0;
for s=1:Nsamples
    k=k+1;
    subplot(Nsamples,3,k); hist(prewarperror2D{s},100);
    title(['unwarped ',data(s).sample(1).chn,' <error>: ',...
        num2str(mean(prewarperror{s}),3),'nm'],'FontSize',7);
    k=k+1;
    subplot(Nsamples,3,k); hist(warp1error2D{s},100);
    title(['After affine ',data(s).sample(1).chn,' <error>: ',...
        num2str(mean(warp1error{s}),3),'nm'],'FontSize',7);
    k=k+1;
    subplot(Nsamples,3,k); hist(postwarperror2D{s},100);  
    title(['2D warped ',data(s).sample(1).chn,': ' num2str(100*thr,2),...
        '% aligned to ', num2str(cdf2D_thresh(s),4),'nm'],'FontSize',7);
end
set(gcf,'color','w');

saveas(fig_warperr,[pathin,filesep,saveroot,'fig_warperr.png']);
saveas(fig_xyerr,[pathin,filesep,saveroot,'fig_xyerr.png']);  
saveas(fig_zdist,[pathin,filesep,saveroot,'fig_zdist.png']);
saveas(fig_xzerr,[pathin,filesep,saveroot,'fig_xyzerr.png']);
saveas(fig_xyerr_all,[pathin,filesep,saveroot,'fig_xyerr_all.png']);
saveas(fig_warperr_2d,[pathin,filesep,saveroot,'fig_warperr_2d.png']);

chn_warp_names = cell(Nsamples,2);
for s=1:Nsamples
    chn_warp_names{s,1} = data(s).sample(1).chn;
    chn_warp_names{s,1} = data(s).refchn(1).chn;
end


% SAVE transforms
save([pathin,filesep,'chromewarps.mat'],'tform_1','tform','tform2D',...
    'cdf','cdf2D','cdf_thresh','cdf2D_thresh','thr','chn_warp_names');
disp(['wrote ',pathin,filesep,'chromewarps.mat']);    

disp('3D bead fitting complete');



close(fig_xyerr, fig_zdist, fig_xzerr, fig_xyerr_all);
 close(fig_warperr,fig_warperr_2d)
% 
% Internal functions 
  
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
       disp(['frame ',num2str(k),':  ', num2str(length(matched.set1_inds)), filesep,...
       num2str(length(signalchn.x)),...
       ' IR blead-through molecules removed from', sname])
     end        

       
function [set1,set2] = matchmols(ref,sample,tform, match_radius,verbose,sname,k,set1,set2,Nfields)
    
if isempty(set1); % initialize on the first time through; 
    set1.x = cell(Nfields,1); set1.y = cell(Nfields,1); set1.z = cell(Nfields,1);
    set2.x = cell(Nfields,1); set2.y = cell(Nfields,1); set2.z = cell(Nfields,1);
end
    
       [matched, unmatched] = corr_mols(ref, sample,tform, match_radius);  
         set1.x{k} = ref.x( matched.set1_inds ); % points in ref channel
         set1.y{k} = ref.y( matched.set1_inds );
         set1.z{k} = ref.z( matched.set1_inds );
         set2.x{k} = sample.x( matched.set2_inds ); % points in 750 channel
         set2.y{k} = sample.y( matched.set2_inds );
         set2.z{k} = sample.z( matched.set2_inds );   
         if verbose
         disp(['frame ',num2str(k),':  ', num2str(length(matched.set2_inds)), filesep...
           num2str( length(matched.set2_inds) + length(unmatched.set2_inds) ),...
           ' ', sname ,' molecules matched'])   
         end
        if isempty(set1.x{k})
            set1.x{k} = []; % handling  Empty [0x1] not concat with Empty 1x0 matrix errors  
            set1.y{k} = [];
            set1.z{k} = [];
        end
        if isempty(set2.x{k})
            set2.x{k} = []; % handling  Empty [0x1] not concat with Empty 1x0 matrix errors  
            set2.y{k} = [];
            set2.z{k} = [];
        end
         
         
 function [za,ps] = level_data(fit,apply)
    x = fit(:,1); y = fit(:,2); z=fit(:,3);
    p = polyfitn([x,y],z,2);
    ps = p.Coefficients;
    xa = apply(:,1); ya = apply(:,2);
    za = xa.^2*ps(1) + xa.*ya*ps(2) + xa*ps(3) + ya.^2*ps(4) + ya*ps(5) + ps(6);
    
    
  function  WriteDax(movie,info,tag,newpath)
    info.hend = info.frame_dimensions(2)/2;
    info.vend = info.frame_dimensions(1)/2;
    info.frame_dimensions = [info.hend,info.vend];
    info.localName = [tag,'_',info.localName];
    info.localPath = newpath;
    info.file = [info.localPath,info.localName(1:end-4),'.dax'];
    WriteDAXFiles(movie,info);


