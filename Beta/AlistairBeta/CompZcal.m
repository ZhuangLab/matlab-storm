
function [pars_nm,wx_fit,wy_fit] = CompZcal(daxfile,parsfile,varargin)
%  CompZcal(daxfile,parsfile)
%                   -- Computes z calibration from the analyzed daxfile and
%                   saves a new parameters file parsfile_zfit which has the
%                   updated z-fitting parameters.  
%  CompZcal(daxfile,parsfile,NewParsRoot,'')
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
% 'NewParsRoot' / string / '_zfit'
%                       -- the new parameter file with have this string
%                       appendend at the end.  Leave empty ('') to
%                       overwrite existing parameter file.
% 'zwindow' / double / 100; 
%                       -- (in nm) max deviation of bead from plane to be 
%                       used in refitting the z-plane
% 'PlotsOn' / logical / true 
%                       -- show plots of stage, fits, etc
% 'ShowFit' / logical / true
%                       -- show final fit curves
% 'ConfirmFit' / logical / false
%                       -- refit Z and replot initial fits.  Automatically
%                       sets PlotsOn to true. (otherwise no output)
%--------------------------------------------------------------------------
%
% Alistair Boettiger
% boettiger@fas.harvard.edu
% February 4, 2013
% Copyright Creative Commons 3.0 CC BY.    
%

%--------------------------------------------------------------------------
%% Default paramaters
%------------------------------------------------------------------------
% global daxfile inifile xmlfile; parsfile = inifile;
zwindow = 100; % (in nm) max deviation of bead from plane to be used in refitting the z-plane
NewParsRoot = '_zfit';
PlotsOn = true; 
ConfirmFit = true;
verbose = true;
ShowFit = true; 
flipDaoZ = true; 
%--------------------------------------------------------------------------
%% Parse mustHave variables
%--------------------------------------------------------------------------
if nargin < 2
   error([mfilename,' expects at least 2 inputs, daxfile and parsfile']);
end

%--------------------------------------------------------------------------
%% Parse Variable Input Arguments
%--------------------------------------------------------------------------
if nargin > 2
    if (mod(length(varargin), 2) ~= 0 ),
        error(['Extra Parameters passed to the function ''' mfilename ''' must be passed in pairs.']);
    end
    parameterCount = length(varargin)/2;

    for parameterIndex = 1:parameterCount,
        parameterName = varargin{parameterIndex*2 - 1};
        parameterValue = varargin{parameterIndex*2};
        switch parameterName   
            case 'zwindow'
                zwindow = CheckParameter(parameterValue, 'positive', 'zwindow');
            case 'PlotsOn'
                PlotsOn = CheckParameter(parameterValue, 'boolean', 'PlotsOn');
            case 'ConfirmFit'
                ConfirmFit = CheckParameter(parameterValue, 'boolean', 'ConfirmFit');
            case 'NewParsRoot'
                NewParsRoot = CheckParameter(parameterValue, 'string', 'NewParsRoot');
            case 'verbose'
                verbose  = CheckParameter(parameterValue, 'boolean', 'verbose');
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.' '  See help ' mfilename]);
        end
    end
end
%% Parsing file names, Declaring variables

if ConfirmFit
    PlotsOn = true;
end

if ~isempty(daxfile)
    k = strfind(daxfile,filesep);
    bead_path = daxfile(1:k(end));
    froot = regexprep(daxfile(k(end)+1:end),'.dax','');
end

k = strfind(parsfile,'.');
parstype = parsfile(k:end); 
if strcmp(parstype,'.ini')
    bintype = '_list.bin';
elseif strcmp(parstype,'.xml');
    bintype = '_alist.bin';
end

binfile = [bead_path,'\',froot,bintype];
mlist = ReadMasterMoleculeList(binfile);


% toss any 'bad fits' and switch to shorthand
c = mlist.c(mlist.c==1);
if length(c) < .5*length(mlist.c)
    c = true(length(mlist.c),1);
end
x = mlist.x(c==1);
y = mlist.y(c==1);
frame = mlist.frame(c==1);
wx = mlist.w(c==1) ./ mlist.ax(c==1);  
wy = mlist.w(c==1) .* mlist.ax(c==1);  
z = mlist.z(c==1);


%% Load stage activity

% Notes on structure of .off files:
% stage{2} contains the measured offset values
% stage{4} contains the programed step size in nm

scanzfile = [bead_path,'\',froot,'.off'];
fid = fopen(scanzfile);
stage = textscan(fid, '%d\t%f\t%f\t%f','headerlines',1);
fclose(fid);

% compute conversion factor
Offset2nm = nanmedian((stage{4}-stage{4}(1))./(stage{2}-stage{2}(1)));
zst = stage{2}*Offset2nm*1000;
zst = zst -zst(1);
if PlotsOn
    stageplot = figure; plot(zst); 
    set(gcf,'color','w');
    xlabel('frame','FontSize',14); 
    ylabel('stage position','FontSize',14); 
    set(gca,'FontSize',14);
    saveas(stageplot,[bead_path,'\fig_',froot,'_stage','.png']);
    if verbose; 
        disp(['wrote: ',bead_path,'\fig_',froot,'_stage','.png']);
    end
end
[~,fstart] = min(zst);
[~,fend] = max(zst);

% Only use the molecules which we can still track at zmin.  
Molecule_Positions = [x(frame==1),y(frame==1)];
Nmolecules = sum(frame==1);
if PlotsOn
    mol_stacks = figure; plot(x,y,'k.');hold on;
    set(gcf,'color','w');
    xlabel('x-pos (pixels)','FontSize',14); 
    ylabel('y-pos (pixels)','FontSize',14); 
    plot(Molecule_Positions(:,1),Molecule_Positions(:,2),'ro');
    saveas(mol_stacks,[bead_path,'\fig_',froot,'_mol_stacks','.png']);
    if verbose; 
        disp(['wrote: ',bead_path,'\fig_',froot,'_mol_stacks','.png']);
    end
end


%%  compute z-position of all dots based on stage position + stage tilt
%----------------------------------------------------------------------

% Fit a plane through the data to correct stage tilt.  
x0 = x(frame<fstart-5);
y0 = y(frame<fstart-5);
z0 = z(frame<fstart-5);    % z0 = .1*z0;
p = polyfitn([x0,y0],z0,2); % Fit a plane to the data
ps = p.Coefficients; % coefficients fo the plane
    
% Refit with only the dots near the fitted plane
zfitted = x0.^2*ps(1) + x0.*y0*ps(2) + x0*ps(3) + y0.^2*ps(4) + y0*ps(5) + ps(6);
goodDots = abs(z0-zfitted)<=zwindow;
p = polyfitn([x0(goodDots),y0(goodDots)],z0(goodDots),2); % F
ps = p.Coefficients; 

  % Plot 3D distribution of initial beads (see how level stage is).  
  if PlotsOn 
    ti = 5:5:120;
    [xi,yi] = meshgrid(ti,ti);
    zi = xi.^2*ps(1) + xi.*yi*ps(2) + xi*ps(3) + yi.^2*ps(4) + yi*ps(5) + ps(6);
    xout = x0(logical(1-goodDots)); 
    yout = y0(logical(1-goodDots)); 
    zout = z0(logical(1-goodDots)); 
    stagelevel = figure; clf;
    plot3(x0,y0,z0,'b.',xout,yout,zout,'r.');
    hold on; surf(xi,yi,double(zi)); 
    shading flat; colormap jet;
    xlabel('x');ylabel('y');
    saveas(stagelevel,[bead_path,'\fig_',froot,'_','stagelevel','.png']);
    if verbose; 
        disp(['wrote: ',bead_path,'\fig_',froot,'_','stagelevel','.png']);
    end
  end

  
%% Link molecules across frames

% Now we only want to work with the moving dots
moving_dots = frame > fstart & frame < fend;  % logical index of molecules recorded during stage movement
x = x(moving_dots);
y = y(moving_dots);
wx = wx(moving_dots);
wy = wy(moving_dots); 
stagepos = zst(frame(moving_dots));   
frame = frame(moving_dots);  
z_tilt_corr = x.^2*ps(1) + x.*y*ps(2) + x*ps(3) + y.^2*ps(4) + y*ps(5) + ps(6);
 if strcmp(parstype,'.ini')  && flipDaoZ
zc =  z_tilt_corr - stagepos;  % corrected position of all beads
 else
     zc =  -(z_tilt_corr - stagepos);  % corrected position of all beads
 end
    
Nframes = max(frame) - min(frame) + 1;
ZData = zeros(Nmolecules,Nframes,3);

% THE SLOW WAY 
for n=1:Nmolecules
    xmax = Molecule_Positions(n,1) + 1 ;
    xmin = Molecule_Positions(n,1) - 1 ;
    ymax = Molecule_Positions(n,2) + 1 ;
    ymin= Molecule_Positions(n,2) - 1 ;
    matched = x>xmin & x<xmax & y>ymin & y<ymax;
    for f=1:Nframes
        founddot = matched & frame == f;
        if sum(founddot) < 2
        wxadd = wx(matched & frame == f);
        wyadd = wy(matched & frame == f);
        zcadd = zc(matched & frame == f); 
        else
            wxadd = [];
            wyadd = [];
            zcadd = [];
        end
        if isempty(wxadd); wxadd = NaN; end
        if isempty(wyadd); wyadd = NaN; end
        if isempty(zcadd); zcadd = NaN; end
        ZData(n,f,1) = wxadd;
        ZData(n,f,2) = wyadd;
        ZData(n,f,3) = zcadd;
    end
end

% remove molecules that are missing from 1/2 or more of the frames; 
bad_mols = sum(isnan(ZData(:,:,1)'))>Nframes*1/2;
bad_mols2 = mean(ZData(:,:,2),2) > 1.5*mean(mean(ZData(:,:,2),2));
if iscolumn(bad_mols2)
    bad_mols2 = bad_mols2';
end
bad_mols = bad_mols | bad_mols2;
ZData(bad_mols,:,:) = [];
[Nmolecules,Nframes,~] = size(ZData); 


% Just Plottin' Stuff
%--------------------------------------
if PlotsOn
    before_fit = figure; clf;
    cmap = hsv(Nmolecules);
    for n=1:Nmolecules
        m_wx = reshape(ZData(n,:,1),1,Nframes);
        m_wy = reshape(ZData(n,:,2),1,Nframes);
        m_z = reshape(ZData(n,:,3),1,Nframes);
        plot(m_z,m_wx,'.','color',cmap(n,:),'MarkerSize',1); hold on;
        plot(m_z,m_wy,'+','color',cmap(n,:),'MarkerSize',1); hold on;
    end
    xlabel('corrected stage position','FontSize',14);
    ylabel('width','FontSize',14);
    legend('wx','wy'); set(gca,'FontSize',14);
    set(gcf,'color','w');
    ylim([100,1000]);
     saveas(before_fit,[bead_path,'\fig_',froot,'_','before_fit','.png']);
    if verbose; 
        disp(['wrote: ',bead_path,'\fig_',froot,'_','before_fit','.png']);
    end
end


%% align all curves so wx and wy cross at z=0

Wx = ZData(:,:,1);  % keeping code transparent
Wy = ZData(:,:,2);  % keeping code transparent
Z =  ZData(:,:,3);
for n=1:Nmolecules
     Zn = Z(n,:);
    Wxn = Wx(n,:); 
    Wyn = Wy(n,:);
    [~,i] = min(abs( Wxn - Wyn));
    Z(n,:) = Zn -Zn(i); 
%     [Zn,zi] = sort(Z(n,:));
%     Wxn = Wx(n,zi); 
%     Wyn = Wy(n,zi);
%     [~,i] = min(abs( Wxn - Wyn));
%     Zn = Zn -Zn(i); 

    % figure(1); plot(Zn, Wx(n,:),'g',Zn,Wy(n,:),'b');  hold on;
end

%% Compute curve fits


hasdata =  logical(1-isnan(Wx(:)));
wxf =  Wx(hasdata);
wyf = Wy(hasdata);
zz = Z(hasdata);
[zz,zi] = sort(zz);
wxf = wxf(zi);
wyf = wyf(zi);


% figure(3); clf; 
% plot(zz,wxf,'g.',zz,wyf,'b.','MarkerSize',1);

% Coarse fit, no higher order correction terms 
ftype = fittype('w0*sqrt( ((z-g)/zr)^2 + 1 ) ','coeff', {'w0','zr','g'},'ind','z'); 
wx_fit0 = fit(zz,wxf,ftype,'StartPoint',[ 300  450  -240 ],'Lower',[150 -1000 -1000],'Upper',[450,1000,1000]); % Expect curve to be near w0=300, zr=400 gx=-240;
try
    ftype = fittype('w0*sqrt( B*((z-g)/zr)^4 + A*((z-g)/zr)^3 + ((z-g)/zr)^2 + 1 )','coeff', {'w0','zr','g','A','B'},'ind','z');
    wx_fit = fit(zz,wxf,ftype,'StartPoint',[ wx_fit0.w0  wx_fit0.zr  wx_fit0.g  0 0],'Lower',[150 -1000 -1000 -20 -20],'Upper',[450,1000,1000,20,20]); % ADDED use options
catch er
    disp(er.message); 
    disp('wx_fit tightening bounds on A and B and exlcuding data edges...');
    wx_fit = fit(zz(end/10:end-end/10),wxf(end/10:end-end/10),ftype,'StartPoint',[ wx_fit0.w0  wx_fit0.zr  wx_fit0.g  0 0],'Lower',[150 -1000 -1000 -1 -1],'Upper',[450,1000,1000,1,1]); % ADDED use options
end

% Full model fit, seeded off of course fit; 
ftype = fittype('w0*sqrt( ((z-g)/zr)^2 + 1 ) ','coeff', {'w0','zr','g'},'ind','z');
wy_fit0 = fit(zz,wyf,ftype,'StartPoint',[ 250  450  240 ],'Lower',[150 -1000 -1000],'Upper',[450,1000,1000]); % Expect curve to be near w0=300, zr=400 gy=240;
try
ftype = fittype('w0*sqrt( B*((z-g)/zr)^4 + A*((z-g)/zr)^3 + ((z-g)/zr)^2 + 1 )','coeff', {'w0','zr','g','A','B'},'ind','z');
wy_fit = fit(zz,wyf,ftype,'start',[ wy_fit0.w0  wy_fit0.zr  wy_fit0.g  0 0]); % ADDED use options
catch er
    disp(er.message);
      disp('wy_fit tightening bounds on A and B and exlcuding data edges...');
  wy_fit = fit(zz(end/10:end-end/10),wyf(end/10:end-end/10),ftype,'StartPoint',[ wy_fit0.w0  wy_fit0.zr  wy_fit0.g  0 0],'Lower',[150 -1000 -1000 -.5 -.5],'Upper',[450,1000,1000,1,1]); % ADDED use options); % ADDED use options
end
swx = feval(wx_fit,zz);
swy = feval(wy_fit,zz);

% Refit, using only data near the curve
gooddots = logical(1- (abs(wyf - swy)>zwindow | abs(wxf - swx)>zwindow) );
zz = zz(gooddots);
wyf = wyf(gooddots);
wxf =wxf(gooddots);
ftype = fittype('w0*sqrt( B*((z-g)/zr)^4 + A*((z-g)/zr)^3 + ((z-g)/zr)^2 + 1 )','coeff', {'w0','zr','g','A','B'},'ind','z');
wx_fit = fit(zz,wxf,ftype,'StartPoint',[ wx_fit.w0  wx_fit.zr  wx_fit.g wx_fit.A wx_fit.B],'Lower',[150 -1000 -1000 -20 -20],'Upper',[450,1000,1000,20,20]); % ADDED use options
ftype = fittype('w0*sqrt( B*((z-g)/zr)^4 + A*((z-g)/zr)^3 + ((z-g)/zr)^2 + 1 )','coeff', {'w0','zr','g','A','B'},'ind','z');
wy_fit = fit(zz,wyf,ftype,'start',[ wy_fit.w0  wy_fit.zr  wy_fit.g  wy_fit.A wy_fit.B]); % ADDED use options
swx = feval(wx_fit,zz);
swy = feval(wy_fit,zz);


if PlotsOn || ShowFit
    zcal_curves = figure; clf;
    plot(zz,wxf,'b.',zz,wyf,'g+','MarkerSize',1);
    hold on; 
    plot(zz,swx,'c-',zz,swy,'k-');
    axis([-600 600 0 1100])
    xlabel('z (nm)');
    ylabel('width (nm)');
    legend('wx','wy');
    saveas(zcal_curves,[bead_path,'\fig_',froot,'_','zcal_curves','.png']);
    if verbose; 
        disp(['wrote: ',bead_path,'\fig_',froot,'_','zcal_curves','.png']);
    end
end

disp(wx_fit);
disp(wy_fit);



%% write to disk

zexpr = sprintf('wx0=%.2f;zrx=%.2f;gx=%.2f;  Cx=0.00000;Bx=%.4f;Ax=%.4f;  wy0=%.2f;zry=%.2f;gy=%.2f;  Cy=0.0000;By=%.4f;Ay=%.4f;  X=(z-gx)/zrx;  wx=sqrt(wx0*sqrt(Cx*X^5+Bx*X^4+Ax*X^3+X^2+1));  Y=(z-gy)/zry;  wy=sqrt(wy0*sqrt(Cy*Y^5+By*Y^4+Ay*Y^3+Y^2+1))\n',...
    wx_fit.w0,wx_fit.zr,wx_fit.g,wx_fit.B,wx_fit.A,wy_fit.w0,wy_fit.zr,wy_fit.g,wy_fit.B,wy_fit.A);
if verbose
    disp(zexpr);
end

pars_nm = [bead_path,'\',froot,NewParsRoot,parstype];

if strcmp(parstype,'.ini')
modify_script(parsfile,pars_nm,{'z calibration expression='},{zexpr},'');
elseif strcmp(parstype,'.xml');
zpars_names = {
        '<wx_wo type="float">',...  wx0
        '<wx_c type="float">',...  gx
        '<wx_d type="float">',...  zrx
        '<wxA type="float">',...  Ax
        '<wxB type="float">',... Bx
        '<wy_wo type="float">',...  wy0
        '<wy_c type="float">',...  gy
        '<wy_d type="float">',...  zry
        '<wyA type="float">',...  Ay
        '<wyB type="float">',... By
        } ; 
zpars_values = {
        wx_fit.w0,...
        wx_fit.g,...
        wx_fit.zr,...
        wx_fit.A,...
        wx_fit.B,...
        wy_fit.w0,...
        wy_fit.g,...
        wy_fit.zr,...
        wy_fit.A,...
        wy_fit.B,...
        };
zpars_values = cellfun(@num2str, zpars_values,'UniformOutput',false);
modify_script(parsfile,pars_nm,zpars_names,zpars_values,'<');
end








%%  
% flipDaoZ =1
if ConfirmFit 
    % confirm z_offset is zero.  
    [~,zi] = min(abs(swx-swy));
    z_offset = zz(zi);
    disp(z_offset);

    % There's no need to run a dotfinder again, we don't need to recompute the
    % beads x,y, wx wy, those don't change.  

    % Iterate
    % toss any 'bad fits' and switch to shorthand
    c = mlist.c(mlist.c==1);
    if length(c) < .5*length(mlist.c)
        c = true(length(mlist.c),1);
    end
    x = mlist.x(c==1);
    y = mlist.y(c==1);
    frame = mlist.frame(c==1);
    wx = mlist.w(c==1) ./ mlist.ax(c==1);
    wy = mlist.w(c==1) .* mlist.ax(c==1);  
    z = mlist.z(c==1);

    % Compute new z positions
    N = length(x);
    new_z = zeros(N,1);
    for n=1:N
     [~,i] = min( (wx(n).^.5 - swx.^.5).^2 + (wy(n).^.5 - swy.^.5).^2 );
     new_z(n) = zz(i); 
    end

    if PlotsOn
        ZvZ = figure; plot(new_z,z,'k.');
        xlabel('z-new (nm)','FontSize',14);
        ylabel('z-old (nm)','FontSize',14);
        set(gcf,'color','w');
        saveas(ZvZ,[bead_path,'\fig_',froot,'_','ZvZ','.png']);
        if verbose; 
            disp(['wrote: ',bead_path,'\fig_',froot,'_','ZvZ','.png']);
        end
    end

    z=new_z;
    zwindow = .5*zwindow; % we should be doing substantially better by now.

    %  compute z-position of all dots based on stage position + stage tilt
    %----------------------------------------------------------------------
    % Fit a plane through the data to correct stage tilt.  
    x0 = x(frame<fstart-5);
    y0 = y(frame<fstart-5);
    z0 = z(frame<fstart-5);    % z0 = .1*z0;
    p = polyfitn([x0,y0],z0,2); % Fit a plane to the data
    ps = p.Coefficients; % coefficients fo the plane

    % Refit with only the dots near the fitted plane
    zfitted = x0.^2*ps(1) + x0.*y0*ps(2) + x0*ps(3) + y0.^2*ps(4) + y0*ps(5) + ps(6);
    goodDots = abs(z0-zfitted)<=zwindow;
    p = polyfitn([x0(goodDots),y0(goodDots)],z0(goodDots),2); % F
    ps = p.Coefficients; 

      % Plot 3D distribution of initial beads (see how level stage is).  
      if PlotsOn 
        ti = 5:5:120;
        [xi,yi] = meshgrid(ti,ti);
        zi = xi.^2*ps(1) + xi.*yi*ps(2) + xi*ps(3) + yi.^2*ps(4) + yi*ps(5) + ps(6);
        xout = x0(logical(1-goodDots)); 
        yout = y0(logical(1-goodDots)); 
        zout = z0(logical(1-goodDots)); 
        stagelevel_fit = figure; clf;
        plot3(x0,y0,z0,'b.',xout,yout,zout,'r.');
        hold on; surf(xi,yi,double(zi)); 
        shading flat; colormap jet;
        xlabel('x');ylabel('y');
        saveas(stagelevel_fit,[bead_path,'\fig_',froot,'_','stagelevel_fit','.png']);
        if verbose; 
            disp(['wrote: ',bead_path,'\fig_',froot,'_','stagelevel_fit','.png']);
        end
      end


    % Link molecules across frames

    % Now we only want to work with the moving dots
    moving_dots = frame > fstart & frame < fend;  % logical index of molecules recorded during stage movement
    x = x(moving_dots);
    y = y(moving_dots);
    wx = wx(moving_dots);
    wy = wy(moving_dots); 
    stagepos = zst(frame(moving_dots));   
    frame = frame(moving_dots);  
    z_tilt_corr = x.^2*ps(1) + x.*y*ps(2) + x*ps(3) + y.^2*ps(4) + y*ps(5) + ps(6);
 if strcmp(parstype,'.ini') && flipDaoZ
zc =  z_tilt_corr - stagepos;  % corrected position of all beads
 else
     zc =  -(z_tilt_corr - stagepos);  % corrected position of all beads
 end

    Nframes = max(frame) - min(frame) + 1;
    ZData = zeros(Nmolecules,Nframes,3);

    % THE SLOW WAY 
    for n=1:Nmolecules
        xmax = Molecule_Positions(n,1) + 1 ;
        xmin = Molecule_Positions(n,1) - 1 ;
        ymax = Molecule_Positions(n,2) + 1 ;
        ymin= Molecule_Positions(n,2) - 1 ;
        matched = x>xmin & x<xmax & y>ymin & y<ymax;
        for f=1:Nframes
            founddot = matched & frame == f;
            if sum(founddot) < 2
            wxadd = wx(matched & frame == f);
            wyadd = wy(matched & frame == f);
            zcadd = zc(matched & frame == f); 
            else
                wxadd = [];
                wyadd = [];
                zcadd = [];
            end
            if isempty(wxadd); wxadd = NaN; end
            if isempty(wyadd); wyadd = NaN; end
            if isempty(zcadd); zcadd = NaN; end
            ZData(n,f,1) = wxadd;
            ZData(n,f,2) = wyadd;
            ZData(n,f,3) = zcadd;
        end
    end

% remove molecules that are missing from 1/2 or more of the frames; 
bad_mols = sum(isnan(ZData(:,:,1)'))>Nframes*1/2;
bad_mols2 = mean(ZData(:,:,2),2) > 1.5*mean(mean(ZData(:,:,2),2));
if iscolumn(bad_mols2)
    bad_mols2 = bad_mols2';
end
bad_mols = bad_mols | bad_mols2;
ZData(bad_mols,:,:) = [];
[Nmolecules,Nframes,~] = size(ZData); 
    
    
    % Just Plottin' Stuff
    %--------------------------------------
    if PlotsOn
        after_fit = figure; clf;
        cmap = hsv(Nmolecules);
        plot(zz,swx,'b-',zz,swy,'k-','linewidth',2); hold on; 
        for n=1:Nmolecules
            m_wx = reshape(ZData(n,:,1),1,Nframes);
            m_wy = reshape(ZData(n,:,2),1,Nframes);
            m_z = reshape(ZData(n,:,3),1,Nframes);
            plot(m_z,m_wx,'.','color',cmap(n,:),'MarkerSize',1); hold on;
            plot(m_z,m_wy,'+','color',cmap(n,:),'MarkerSize',1); hold on;
        end
        xlabel('corrected stage position','FontSize',14);
        ylabel('width','FontSize',14);
        legend('wx','wy'); set(gca,'FontSize',14);
        set(gcf,'color','w');
        ylim([100,1000]);
         saveas(after_fit,[bead_path,'\fig_',froot,'_','after_fit','.png']);
        if verbose; 
            disp(['wrote: ',bead_path,'\fig_',froot,'_','after_fit','.png']);
        end
    end
    %--------------------------------------
end
