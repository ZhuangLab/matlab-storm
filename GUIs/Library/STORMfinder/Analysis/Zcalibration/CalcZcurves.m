function [newFile,wx_fit,wy_fit] = CalcZcurves(daxfile,varargin)
%  CompZcal(daxfile)
%                   -- Computes z calibration from the analyzed daxfile and
%                   saves a new parameters file parsfile_zfit which has the
%                   updated z-fitting parameters.  
%  CompZcal(daxfile,'templateFile',parsfile,'newFile',parsfile)
%                   -- Overwrites existing parsfile z-calibration values
%                   with new ones.  
%--------------------------------------------------------------------------
%% Required Inputs
% daxfile / string
%                   -- name of bead movie with localized beads in x,y,w
% parsfile /string
%                   -- Parameter file to copy all parameters from aside
%                   from the z-fit parameters computed here.  
%--------------------------------------------------------------------------
% Outputs:
% pars_nm / string 
%                  -- name of the parameter file written by the function
%                  which contains the new z-fit parameters
% wx_fit / cfit  
%                  -- Matlab fit object containing the wx(z) equation
% wy_fit / cfit 
%                  -- Matlab fit object containing the wy(z) equation
%--------------------------------------------------------------------------
%% Optional Inputs:
% 'ParameterFlag' / type / default
%
% 'templateFile'/ string '' 
%           - parameter file to use as a template (get all values save
%           z-cal from this file).  Make same as newfile to update just the
%           z-cal parameters.  
% 'newFile' / string / ''
%           - name of parameter file to write with the new values.  
% 'parstype' / string / '.xml' 
%           - parameter type for saved file '.xml' for daoSTORM, '.ini'
%              for insightM
% 'startframe' / double / 1   
%           - frame to use to ID all bead positions
% 'fmin' / double / .8
%           - molecule on for at least this fraction of frames
% 'maxdrift' / double / 1     
%           - max distance in pixels a bead may move and still be linked
% 'maxOutlier' / double / 300
%           - max outlier from preliminary z-fit (nm)
% 'endTrim' / double / .1
%           - fraction of ends of curve to ignore
% 'maxWidth' / double / 1500
%           - max width of beads PSF (nm)
% 'w0Range' / double / 80
%           - max 95% confidence range for w0
% 'zrRange' / double / 300
%           - max 95% confidence range for zr
% 'showPlots' / boolean / true
% 'showExtraPlots' / boolean / false
% 'verbose' / boolean / true
%
%--------------------------------------------------------------------------
%
% Alistair Boettiger
% boettiger@fas.harvard.edu
% December 15, 2013
% Copyright Creative Commons 3.0 CC BY.    
%

%--------------------------------------------------------------------------
%% Global Parameters
%--------------------------------------------------------------------------
global defaultXmlFile defaultIniFile;
   
%--------------------------------------------------------------------------
%% Default Parameters
%--------------------------------------------------------------------------
showExtraPlots = true;
showPlots = true;
verbose = true;
parstype = '.xml';
templateFile = '';
newFile = ''; 
guideMethod = 0;

% for clustering of localizations
startframe = 1; % 290;
maxdrift = 2.5;
fmin = .6;

% For z-curve fitting
maxOutlier = 200;
endTrim = .05;
maxWidth = 1500; 
w0Range = [100,400];
zrRange = [100,700];
gRange = [-600,600];

% daxfile = 'O:\2013-12-01_F08\Beads\647_zcal_0002.dax';




%--------------------------------------------------------------------------
%% Parse mustHave variables
%--------------------------------------------------------------------------
if nargin < 1
   error([mfilename,' expects at least 2 inputs, daxfile and parsfile']);
end

%--------------------------------------------------------------------------
%% Parse Variable Input Arguments
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
            case 'startframe'
                startframe = CheckParameter(parameterValue, 'positive', 'startframe');
            case 'maxdrift'
                maxdrift = CheckParameter(parameterValue, 'positive', 'maxdrift');
            case 'fmin'
                fmin = CheckParameter(parameterValue, 'positive', 'fmin');
            case 'maxOutlier'
                maxOutlier = CheckParameter(parameterValue, 'positive', 'maxOutlier');
            case 'endTrim'
                endTrim = CheckParameter(parameterValue, 'positive', 'endTrim');
            case 'maxWidth'
                maxWidth = CheckParameter(parameterValue, 'positive', 'maxWidth');
            case 'w0Range'
                w0Range = CheckParameter(parameterValue, 'array', 'w0Range');
            case 'zrRange'
                zrRange = CheckParameter(parameterValue, 'array', 'zrRange');
            case 'gRange'
                gRange = CheckParameter(parameterValue, 'array', 'gRange');
            case 'parstype'
                parstype = CheckParameter(parameterValue, 'string', 'parstype');
            case 'templateFile'
                templateFile = CheckParameter(parameterValue, 'string', 'templateFile');
            case 'newFile'
                newFile = CheckParameter(parameterValue, 'string', 'newFile');
            case 'showPlots'
                showPlots = CheckParameter(parameterValue, 'boolean', 'showPlots');
            case 'showExtraPlots'
                showExtraPlots = CheckParameter(parameterValue, 'boolean', 'showExtraPlots');
            case 'verbose'
                verbose = CheckParameter(parameterValue, 'boolean', 'verbose');
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.' '  See help ' mfilename]);
        end
    end
end


if ~isempty(newFile)
    parstype = newFile(4:end);
    if ~strcmp(newfile(4),'.')
        error('parameter file name must contain extension (.ini or .xml)');
    end
end

%% Main Function

% daxfile = 'T:\2015-08-05_beads\561_zcal_0001.dax'

% Load molecule list
[bead_path,daxname] = extractpath(daxfile);
try
    binfile = regexprep(daxfile,'\.dax','_list.bin');
    froot = regexprep(daxname,'\.dax','');
    mlist = ReadMasterMoleculeList(binfile);
catch
    binfile = regexprep(binfile,'_list.bin','_mlist.bin');
    mlist = ReadMasterMoleculeList(binfile);
end

% Some short-hand
x = mlist.x;
y = mlist.y;
frame = mlist.frame;
wx = mlist.w ./ sqrt(mlist.ax);   % /
wy = mlist.w .* sqrt(mlist.ax);  % *
z = mlist.z;

% Get the stage file 
try
    scanzfile = [bead_path,'\',froot,'.off'];
    fid = fopen(scanzfile);
    stage = textscan(fid, '%d\t%f\t%f\t%f','headerlines',1);
    fclose(fid);
catch
    [scanzfileName,filePath] = uigetfile(bead_path,'Locate .off file');
    fid = fopen([filePath,filesep,scanzfileName]);
    stage = textscan(fid, '%d\t%f\t%f\t%f','headerlines',1);
    fclose(fid);
end




zrange = max(stage{4}-stage{4}(1))*1000;
[maxoffset,Zmaxoffset] = max(stage{2});
offset_start = mean(stage{2}(1:Zmaxoffset-5));
nm_per_offsetunit = zrange/(maxoffset - offset_start);

zst = -stage{2}*nm_per_offsetunit; 
zst = zst - zst(1);
if showExtraPlots
    stageplot = figure; plot(zst); 
    set(gcf,'color','w');
    xlabel('frame','FontSize',14); 
    ylabel('stage position','FontSize',14); 
    set(gca,'FontSize',14);
%     saveas(stageplot,[bead_path,'\fig_',SaveRoot,Dao_root,froot,'_stage','.png']);
%     if verbose; 
%         disp(['wrote: ',bead_path,'\fig_',SaveRoot,Dao_root,froot,'_stage','.png']);
%     end
end
[~,fstart] = min(zst);
[~,fend] = max(zst);
if fstart > fend
    zst = -zst;
    [~,fstart] = min(zst);
    [~,fend] = max(zst);
end


% ---------- Match Molecules across frames
if startframe == 1
    startframe = min(mlist.frame);
end
p1s = mlist.frame==startframe;
x1s = mlist.x(p1s);
y1s = mlist.y(p1s);

if showExtraPlots
   figure(2); clf; 
   plot(mlist.x,mlist.y,'k.','MarkerSize',1);
   hold on;
   plot(x1s,y1s,'bo');
   legend('all localizations','startframe localizations'); 
end

% Reject molecules that are too close to other molecules
if length(x1s) > 1
    [~,dist] = knnsearch([x1s,y1s],[x1s,y1s],'K',2);
    nottooclose = dist(:,2)>2*maxdrift;
    x1s = x1s(nottooclose);
    y1s = y1s(nottooclose);
end    

% Feducials must be ID'd in at least fmin fraction of total frames
fb =[x1s-maxdrift, x1s + maxdrift,y1s-maxdrift, y1s + maxdrift];
Tframes = zeros(length(x1s),1);
for i=1:length(x1s)
    inbox = mlist.x > fb(i,1) & mlist.x < fb(i,2) & ...
        mlist.y > fb(i,3) & mlist.y < fb(i,4) & ...
        mlist.frame > startframe;
   Tframes(i) = sum(inbox);
end
feducials = Tframes > fmin*(max(mlist.frame)-startframe); 


if sum(feducials) == 0 
   error('no feducials found. Try changing fmin or startframe');  
end
x1s = x1s(feducials);
y1s = y1s(feducials);
fb = fb(feducials,:);
feducial_boxes = [fb(:,1),fb(:,3),...
    fb(:,2)-fb(:,1),fb(:,4)-fb(:,3)];

if showExtraPlots
    colormap gray;
    figure(2); hold on; 
    plot(x1s,y1s,'r.');
end

%% Record position of feducial in every frame

Nfeducials = length(x1s);
Nframes = double(max(mlist.frame));
numLocs = length(mlist.x);

Cmap = jet(Nfeducials);
Fed_traj = NaN*ones(Nframes,Nfeducials,2);
incirc = false(Nfeducials,numLocs);
inmotion= false(Nfeducials,numLocs);
stagepos = cell(Nfeducials,1); 
Wx = cell(Nfeducials,1);
Wy = cell(Nfeducials,1); 
xpos = cell(Nfeducials,1);
ypos = cell(Nfeducials,1); 
off = zeros(1,Nfeducials);

if showExtraPlots
    figure(3); clf;
    figure(4); clf; 
end

for i=1:Nfeducials
    incirc(i,:) = mlist.x > fb(i,1) & mlist.x <= fb(i,2) & ...
                  mlist.y > fb(i,3) & mlist.y <= fb(i,4);
    inmotion(i,:) = mlist.frame > fstart & mlist.frame < fend; 
    stagepos{i} = zst(mlist.frame(incirc(i,:) & inmotion(i,:)));
    Fed_traj(mlist.frame(incirc(i,:)),i,1) = double(mlist.x(incirc(i,:)));
    Fed_traj(mlist.frame(incirc(i,:)),i,2) = double(mlist.y(incirc(i,:)));
    Wx{i} = double( mlist.w(incirc(i,:) & inmotion(i,:)) ./...
                    mlist.ax(incirc(i,:) & inmotion(i,:)) );
    Wy{i} = double( mlist.w(incirc(i,:) & inmotion(i,:)) .*...
                    mlist.ax(incirc(i,:) & inmotion(i,:)) );
    xpos{i} = mlist.x(incirc(i,:));
    ypos{i} = mlist.y(incirc(i,:));
    if showExtraPlots
        figure(3); hold on; 
        rectangle('Position',feducial_boxes(i,:),'Curvature',[1,1]);
        plot( xpos{i},ypos{i},'.','MarkerSize',5,'color',Cmap(i,:));
        figure(4); hold on; 
        % plot(stagepos{i}+off(i),Wx{i} ,'+','color',Cmap(i,:),'MarkerSize',1);
       %  plot(stagepos{i}+off(i),Wy{i} ,'.','color',Cmap(i,:),'MarkerSize',1);
        
        plot(stagepos{i}+off(i),smooth(Wx{i},.1) ,'LineWidth',1,'color',Cmap(i,:));
        plot(stagepos{i}+off(i),smooth(Wy{i},.1),'-.','LineWidth',1,'color',Cmap(i,:));
        ylim([0,2000]);
        
        figure(2); hold on;
        plot(x1s(i),y1s(i),'o','color',Cmap(i,:),'LineWidth',2);

    end
end


%% align all curves so wx and wy cross at z=0
            


Z = cell(Nfeducials,1); 
ZZ = cell(Nfeducials,1); 
Wxf = cell(Nfeducials,1); 
Wyf = cell(Nfeducials,1); 
wX = cell(Nfeducials,1); 
wY = cell(Nfeducials,1); 
% err = inf*ones(Nfeducials,1); 
if showExtraPlots
    figure(4); clf; figure(5); clf;
end
for  i=1:Nfeducials  
    [m,k] = min(abs( Wx{i} -Wy{i}));
    if m<50
        zz = stagepos{i} - stagepos{i}(k);
        [wx,Wxf{i}] = FitZcurve(zz,Wx{i},'PlotsOn',showExtraPlots,...
            'maxOutlier',maxOutlier,'endTrim',endTrim,'maxWidth',maxWidth,...
            'w0Range',w0Range,'zrRange',zrRange,'gRange',gRange);
        [wy,Wyf{i}] = FitZcurve(zz,Wy{i},'PlotsOn',showExtraPlots,...
            'maxOutlier',maxOutlier,'endTrim',endTrim,'maxWidth',maxWidth,...
            'w0Range',w0Range,'zrRange',zrRange,'gRange',gRange);
    else
        zz = 0; 
        wx = NaN; 
        wy = NaN; 
    end
    
%     if isnan(wx) | isnan(wy) %#ok<OR2>
%         zz = 0; 
%         wx = NaN; 
%         wy = NaN;        
%     end
    off(i) = stagepos{i}(k);
    ZZ{i} = zz;
    Z{i} = zz(zz>-600 & zz<600); 
    wX{i} = wx(zz>-600 & zz<600);
    wY{i} = wy(zz>-600 & zz<600);
    
    % Compute confidence limits
%     if sum(zz) ~= 0
%         cI = confint(Wxf{i});
%         errX = (cI(2,:) - cI(1,:))./coeffvalues(Wxf{i});
%         cI = confint(Wyf{i});
%         errY = (cI(2,:) - cI(1,:))./coeffvalues(Wyf{i});
%         err(i) = nanmean([errX,errY]);
%     end
   
    if showExtraPlots
        figure(4); hold on; 
            plot( zz,wx,'+','color',Cmap(i,:));
            plot( zz,wy,'.','color',Cmap(i,:));
            ylim([0,1300]); xlim([-600,600]);
        figure(5); hold on;
        if sum(zz) ~= 0
            plot(zz,Wx{i} ,'+','color',Cmap(i,:),'MarkerSize',5);
            plot(zz,Wy{i} ,'.','color',Cmap(i,:),'MarkerSize',5);
            ylim([0,1300]); xlim([-600,600]);
        end
    end
end

if showExtraPlots
    figure(4); set(gcf,'color','w'); set(gca,'FontSize',16);
    xlabel('Z-position'), ylabel('dot-width'); legend('wx','wy');
    title('curve fits');
    figure(5); set(gcf,'color','w'); set(gca,'FontSize',16);
    xlabel('Z-position'), ylabel('dot-width'); legend('wx','wy');
    title('raw data');
end

% choose best bead as guidedata.
commonZ = linspace(-600,600,100);
fitWx = zeros(Nfeducials,100);
fitWy = zeros(Nfeducials,100);
for i=1:Nfeducials;
    if ~isempty(Wxf{i}) && ~isempty(Wyf{i})
        fitWx(i,:) = feval(Wxf{i},commonZ);
        fitWy(i,:) = feval(Wyf{i},commonZ);
    end
end
fitDiff = inf*ones(Nfeducials); 
for i=1:Nfeducials
    for j=1:Nfeducials
        if i~=j
           fitDiff(i,j) = norm(fitWx(i,:) - fitWx(j,:)) + norm(fitWy(i,:)-fitWy(j,:));
        end
    end
end
fitDiff(fitDiff==0) = inf; 

if guideMethod == 1
    [~,guide_dot] = max(cellfun(@(x) max(x)-min(x),Z));  % i= 37
else 
    [~,guide_dot] = min(min(fitDiff));
end
    
wx_fit = Wxf{guide_dot};
wy_fit = Wyf{guide_dot};
if verbose
    disp(wx_fit);
    disp(wy_fit);
end

if showPlots
    zcurvePlot = figure(1); clf; 
    plot( ZZ{guide_dot},Wx{guide_dot},'+','color',Cmap(guide_dot,:),'MarkerSize',5); hold on;
    plot( ZZ{guide_dot},Wy{guide_dot},'.','color',Cmap(guide_dot,:),'MarkerSize',5);
    plot( commonZ,fitWx(guide_dot,:),'-','color',Cmap(guide_dot,:),'lineWidth',1); hold on;
    plot( commonZ,fitWy(guide_dot,:),'-','color',Cmap(guide_dot,:),'lineWidth',1);
    for i=1:Nfeducials
        if sum(ZZ{i}) ~= 0
        plot( ZZ{i},Wx{i},'+','color',Cmap(i,:),'MarkerSize',1); hold on;
        plot( ZZ{i},Wy{i},'.','color',Cmap(i,:),'MarkerSize',1);
        end
    end
    ylim([0,1300]); xlim([-600,600]);
    set(gcf,'color','w'); set(gca,'FontSize',16);
    xlabel('Z-position'), ylabel('dot-width'); legend('wx','wy');
    title('curve fits');
    savePlot = regexprep(daxfile,'\.dax','_zfit.png');
    saveas(zcurvePlot,savePlot);
    if verbose; 
        disp(['wrote: ',savePlot]);
    end
end

%% write Data
if isempty(templateFile)
    if strcmp(parstype,'.xml')
        templateFile = defaultXmlFile;
    elseif strcmp(parstype,'.ini')
        templateFile = defaultIniFile;
    end
end

if isempty(newFile)
    newFile = regexprep(daxfile,'\.dax',['_zpars',parstype]);
end
    
writeZfit2ini(templateFile,newFile,wx_fit,wy_fit,'verbose',true,'parstype',parstype)

