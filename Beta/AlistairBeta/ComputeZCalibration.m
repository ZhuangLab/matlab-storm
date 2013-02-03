

 function [ini_nm, fresx2, fresy2] = ComputeZCalibration(varargin) % (bead_path,froot,ini,nooverwrite)
%--------------------------------------------------------------------------
% Inputs:
% bead_path / string / 'C:/data/Beads/'
%                -- location of bead data for z-calibration and chromatic
%                calibration
% froot / string / '750_zcal'
%               -- string that contains the root of the data movie used for
%               the dax/bin/off files.
% chn / string / '750'
%               -- string containing the channel being analyzed.  Used in
%               output filename to keep track of things.  Also important to
%               get quadrant in Quadview512 mode
% inifile / string / 'C:/data/Beads/750_zcal.ini'
%               -- full path and name of ini file to use as a stem. All
%               features of this file will be reproduced in the output file
%               ini_nm except the 'z calibration expression=...'
% nooverwrite /logical / true
%               -- prevents script from overwriting existing output images.
%               new images will instead be saved as v1 v2 etc...
%--------------------------------------------------------------------------
% Outputs
% ini_nm / string / 'C:/data/pars.ini'
%               -- name of ini file written by analysis script
% fresx2 / fit-structure
%               -- fit expression and uncertainty for x
% fresy2 / fit-structure
%               -- fit expression and uncertainty for y
%--------------------------------------------------------------------------
% 
%
%
%--------------------------------------------------------------------------
%
% Alistair Boettiger
% boettiger@fas.harvard.edu
% September 18, 2012
% Copyright Creative Commons CC BY.    
%
% Version 1.0
%--------------------------------------------------------------------------



%-------------------------------------------------------------------------
%% Default parameters
%-------------------------------------------------------------------------

bead_path = '';
daxfile = '';
froot = '';
inifile = '';
nooverwrite = false;

%--------------------------------------------------------------------------
%% Parse Variable Input Arguments
%--------------------------------------------------------------------------
if nargin > 0
    if (mod(length(varargin), 2) ~= 0 ),
        error(['Extra Parameters passed to the function ''' mfilename ''' must be passed in pairs.']);
    end
    parameterCount = length(varargin)/2;

    for parameterIndex = 1:parameterCount,
        parameterName = varargin{parameterIndex*2 - 1};
        parameterValue = varargin{parameterIndex*2};
        switch parameterName
            case 'BeadPath'
                bead_path = CheckParameter(parameterValue, 'string', 'BeadPath');
            case 'froot'
                froot = CheckParameter(parameterValue, 'string', 'froot');
            case 'daxfile'
                daxfile = CheckParameter(parameterValue, 'string', 'daxfile');
            case 'inifile'
                inifile = CheckParameter(parameterValue, 'string', 'inifile');
            case 'nooverwrite'
                nooverwrite = CheckParameter(parameterValue, 'boolean', 'nooverwrite');
            case 'chn'
                chn =  CheckParameter(parameterValue, 'string', 'chn');
            otherwise
                error(['The parameter ''', parameterName,...
                    ''' is not recognized by the function, ''',...
                    mfilename '''.' '  See help ' mfilename]);
        end
    end
end

%--------------------------------------------------------------------------
%% Hardcoded Variables
%--------------------------------------------------------------------------
chn = ''; 

corrtilt = true;  % correct tilt? 
zwin_in = 60; % nm max deviation from 
zwin = zwin_in;
new_zmax = 700; % 
zmin = -600; %nm
zmax = 600; %nm
stageneutralposition = 0; %um
zfitmin = -500;
zfitmax = 500;
zcor = 0; % adjust to make the two curves cross at zero. 
% currently not used.  Should work back into code?  Seemed to be creating
% artificats at one point.  



%--------------------------------------------------------------------------
%% Main Function
%--------------------------------------------------------------------------

if ~isempty(daxfile)
        k = strfind(daxfile,filesep);
        bead_path = daxfile(1:k(end));
        froot = regexprep(daxfile(k(end)+1:end),'.dax','');
end

scanfile = [bead_path,'\',froot,'_list.bin'];
scanzfile = [bead_path,'\',froot,'.off'];
ini_nm = [bead_path,'\',froot,'_zpars.ini'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load scan file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


disp(['loading ',scanfile,'...']);
% scan = readbinfile(scanfile);  % call's Sang He's version of readbin
scan = ReadMasterMoleculeList(scanfile); 

%in = find(scan.cat==1 & scan.x>=minx & scan.x<=maxx & scan.y>=miny & scan.y<=maxy); % within expected frames
% find is not necessary and is slow.  Logical indexing works.  

in = scan.c==1;   
x = scan.x(in);
y = scan.y(in); 
z = scan.z(in);
cat = scan.c(in);
frame = scan.frame(in);
Ax = scan.ax(in);
width = scan.w(in);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load stage scan file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fid = fopen(scanzfile);
stage = textscan(fid, '%d\t%f\t%f\t%f','headerlines',1);
fclose(fid);

if (stageneutralposition==0)
    stageneutralposition = stage{4}(1);
end
zst = (stage{4}-stageneutralposition)*1000-zcor;
[~,fststart] = min(zst);
[~,fstend] = max(zst);
fstart = find(zst(fststart:fstend)>zmin, 1 ) + fststart;
fend = find(zst(fststart:fstend)<zmax, 1, 'last' ) + fststart;

figure(2)
plot(zst); xlabel('frame'); ylabel('z');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Use molecular lists when the stage did not
% to calculate how well the stage is leveled
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
in0 = find(frame<fststart-1 & cat==1);
x0 = x(in0);
y0 = y(in0);
z0 = z(in0);

% ps = (y,z,1);
% zy1 = polyval(ps,1:130);
p = polyfitn([x0,y0],z0,2);
ps = p.Coefficients;
ti = 5:5:250;
[xi,yi] = meshgrid(ti,ti);
% zi = xi*ps(1) + yi*ps(2) + ps(3);
zi = xi.^2*ps(1) + xi.*yi*ps(2) + xi*ps(3) + yi.^2*ps(4) + yi*ps(5) + ps(6);

% filter out beads that are too far away from the fitted plane
% zf = x0*ps(1) + y0*ps(2) + ps(3);
zf = x0.^2*ps(1) + x0.*y0*ps(2) + x0*ps(3) + y0.^2*ps(4) + y0*ps(5) + ps(6);
ino = find(abs(z0-zf)>=zwin);
xout = x0(ino);
yout = y0(ino);
zout = z0(ino);

figure(1); clf;
plot3(x0,y0,z0,'b.',xout,yout,zout,'r.'); hold on; surf(ti,ti,zi); hold off;
xlabel('x');ylabel('y');

% %
%zcor = -median(zout);
% if ( ~input('May I proceed? (Yes:1, No:0) ') )
%     break;
% end

%% fit again with filtered beads
in1 = find(abs(z0-zf)<zwin);  % The GOOD beads localizations.  
i=1;


% Any bead that has an out of frame localization in the beginning is going
% to get rejected.  The bead is identified by overlap of 1 pixel.  
    in2 = zeros(1,length(x0)); % pre-allocation ADDED 08/05/12
    for n=in1' % for all good beads
        if ( isempty(find(abs(x0(n)-xout)<1 & abs(y0(n)-yout)<1, 1)) ); 
            in2(i) = n;
            i = i+1;
        end
    end
    in2(in2==0) = []; %  added 
    
x1 = x0(in2);
y1 = y0(in2);
z1 = z0(in2);
p = polyfitn([x1,y1],z1,2);
ps = p.Coefficients;

%--------------------------------------------------------------------------
% Get subset of data during scanning
%--------------------------------------------------------------------------
in = find( frame>fstart & frame<fend);
i=1;
for n=in' % for all n between fstart and fend
    if ( isempty(find(abs(x(n)-xout)<1 & abs(y(n)-yout)<1, 1)) )
        in1(i) = n;
        i = i+1;
    end
end

%--------------------------------------------------------------------------
% correct stage tilt
%--------------------------------------------------------------------------
if (corrtilt)
    zc = x(in1).^2*ps(1) + x(in1).*y(in1)*ps(2) + x(in1)*ps(3) + y(in1).^2*ps(4) + y(in1)*ps(5) + ps(6);
    zact0 = - zst(frame(in1)) + zc ;
    [zact,in11] = sort(zact0);
    in111 = in1(in11);

    xx = x(in111);
    yy = y(in111);
    wx = width(in111)./sqrt(Ax(in111));
    wy = width(in111).*sqrt(Ax(in111));
else
    xx = x(in1);
    yy = y(in1);
    wx = width(in1)./sqrt(Ax(in1));
    wy = width(in1).*sqrt(Ax(in1));
    zact = -zst(frame(in1));
end
in3 = find(abs(zact)<new_zmax);
px = polyfit(zact(in3),wx(in3),2);
py = polyfit(zact(in3),wy(in3),2);
swx = polyval(px,zact);
swy = polyval(py,zact);

inex = find( abs(wx-swx)>zwin );
iney = find( abs(wy-swy)>zwin );

fig_wxy  = figure(3);
plot(zact,wx,'.',zact,wy,'.',zact(inex),wx(inex),'x',zact(iney),wy(iney),'x',zact,swy,'.',zact,swx,'.');
axis([-600 600 0 1500])
xlabel('z (nm)');
ylabel('width (nm)');
legend('wx','wy')

% Plot current fit
if nooverwrite == 1
    ver = dir([bead_path,'\fig_',chn,'wxy*.png']);
    ver = length(ver)+1;
else
    ver = '';
end
saveas(fig_wxy,[bead_path,'\fig_',chn,'wxy',num2str(ver),'.png']);
disp(['wrote ', bead_path,'\fig_',chn,'wxy',num2str(ver),'.png']);
figure(4); clf; plot(zact,swy,'.',zact,swx,'.')

%%
zwin = zwin_in; % input('Enter window size of excluding data in nm: ');


%-------------------------------------------------------------------------
% fit wx
%-------------------------------------------------------------------------

% ~~~~~~~~~~~~~~~ filter out beads outside the window ~~~~~~~~~~~~~~~~~~~~
% i.e. beads too far from the polynomial fit curve will exluded from the
% actual fit to the astigmitism equation.  
indx = find( abs(wx-swx)<zwin & (zact<=zfitmax & zact>zfitmin) );
indx2 = zeros(size(z)); % ADDED
i=1;
inex = find( abs(wx-swx)>zwin & zact<=zfitmax & zact>zfitmin );
xout = xx(inex);
yout = yy(inex);
for n=indx'
    if ( isempty(find(abs(xx(n)-xout)<1 & abs(yy(n)-yout)<1, 1)) )
        indx2(i) = n;
        i = i+1;
    end
end
indx2(indx2==0) = []; % ADDED
z = zact(indx2);
w = wx(indx2);


%~~~~~~~~~~~~~~~~Now compute fit on just the 'good' beads ~~~~~~~~~~~~~%
ftype = fittype('w0*sqrt( ((z-g)/zr)^2 + 1 ) ','coeff', {'w0','zr','g'},'ind','z');
fresx1 = fit(z,w,ftype,'StartPoint',[ 300  450  -240 ]); 
ftype = fittype('w0*sqrt( B*((z-g)/zr)^4 + A*((z-g)/zr)^3 + ((z-g)/zr)^2 + 1 )','coeff', {'w0','zr','g','A','B'},'ind','z');
fresx2 = fit(z,w,ftype,'start',[ fresx1.w0  fresx1.zr  fresx1.g  0 0]); % ADDED use options
fcur2 = zcal(zact,fresx2.w0,fresx2.zr,fresx2.g,fresx2.A,fresx2.B);

%-------------------------------------------------------------------------
% Plot and export results
%-------------------------------------------------------------------------
fig_wxfit = figure(41);
plot(zact,wx,'b.',z,w,'r.',zact,swx,'g-','linewidth',2);
legend('raw data','filtered data','polyfit');
hold on; plot(zact,fcur2,'c-','linewidth',2); hold off;
legend('raw data','filtered data','polyfit','actual fit');
axis([zmin-50 zmax+50 min(wx)-50 max(wx)+50]);

if nooverwrite == 1
    ver = dir([bead_path,'\fig_',chn,'wxfit*.png']);
    ver = length(ver)+1;
else
    ver = '';
end
saveas(fig_wxfit,[bead_path,'\fig_',chn,'wxfit',num2str(ver),'.png']);
disp(['wrote ', bead_path,'\fig_',chn,'wxfit',num2str(ver),'.png']);


%-------------------------------------------------------------------------
% fit wy
%-------------------------------------------------------------------------

% ~~~~~~~~~~~~~~~ filter out beads outside the window ~~~~~~~~~~~~~~~~~~~~
% i.e. beads too far from the polynomial fit curve will exluded from the
% actual fit to the astigmitism equation.  
zwin = zwin*1.2;
indy = find( abs(wy-swy)<zwin & (zact<=zfitmax & zact>zfitmin) );
i=1;
iney = find( abs(wy-swy)>zwin & zact<=zfitmax & zact>zfitmin );
xout = xx(iney);
yout = yy(iney);
indy2 = zeros(size(z)); % ADDED
for n=indy'
    if ( isempty(find(abs(xx(n)-xout)<1 & abs(yy(n)-yout)<1, 1)) )
        indy2(i) = n;
        i = i+1;
    end
end
indy2(indy2==0) = []; % ADDED
z = zact(indy2);
w = wy(indy2);



ftype = fittype('w0*sqrt( ((z-g)/zr)^2 + 1 ) ','coeff', {'w0','zr','g'},'ind','z');
fresy1 = fit(z,w,ftype,'start',[ 300  450  -240 ]); % ADDED fopt to end   % Original default start
ftype = fittype('w0*sqrt( B*((z-g)/zr)^4 + A*((z-g)/zr)^3 + ((z-g)/zr)^2 + 1 )','coeff', {'w0','zr','g','A','B'},'ind','z');
fresy2 = fit(z,w,ftype,'start',[ fresy1.w0  fresy1.zr  fresy1.g  0 0]); % 
fcur2 = zcal(zact,fresy2.w0,fresy2.zr,fresy2.g,fresy2.A,fresy2.B);

%-------------------------------------------------------------------------
% Plot and export results
%-------------------------------------------------------------------------
fig_wyfit =figure(42);
plot(zact,wy,'b.',z,w,'r.',zact,swy,'g-','linewidth',2);
legend('raw data','filtered data','polyfit');
hold on; plot(zact,fcur2,'c-','linewidth',2); hold off;
legend('raw data','filtered data','polyfit','actual fit');
axis([zmin-50 zmax+50 min(wy)-50 max(wy)+50]);
if nooverwrite == 1
    ver = dir([bead_path,'\fig_',chn,'wyfit*.png']);
    ver = length(ver)+1; 
else
    ver = '';
end
saveas(fig_wyfit,[bead_path,'\fig_',chn,'wyfit',num2str(ver),'.png']);
disp(['wrote ', bead_path,'\fig_',chn,'wyfit',num2str(ver),'.png']);

% print to screen
zexpr = sprintf('wx0=%.2f;zrx=%.2f;gx=%.2f;  Cx=0.00000;Bx=%.4f;Ax=%.4f;  wy0=%.2f;zry=%.2f;gy=%.2f;  Cy=0.0000;By=%.4f;Ay=%.4f;  X=(z-gx)/zrx;  wx=sqrt(wx0*sqrt(Cx*X^5+Bx*X^4+Ax*X^3+X^2+1));  Y=(z-gy)/zry;  wy=sqrt(wy0*sqrt(Cy*Y^5+By*Y^4+Ay*Y^3+Y^2+1))\n',fresx2.w0,fresx2.zr,fresx2.g,fresx2.B,fresx2.A,fresy2.w0,fresy2.zr,fresy2.g,fresy2.B,fresy2.A);
disp(zexpr);
% print for ini file
ztxt = [bead_path,'\',froot,'_zcal.txt'];
fid2 = fopen(ztxt,'w+'); 
fprintf(fid2,'z calibration expression=wx0=%.2f;zrx=%.2f;gx=%.2f;  Cx=0.00000;Bx=%.4f;Ax=%.4f;  wy0=%.2f;zry=%.2f;gy=%.2f;  Cy=0.0000;By=%.4f;Ay=%.4f;  X=(z-gx)/zrx;  wx=sqrt(wx0*sqrt(Cx*X^5+Bx*X^4+Ax*X^3+X^2+1));  Y=(z-gy)/zry;  wy=sqrt(wy0*sqrt(Cy*Y^5+By*Y^4+Ay*Y^3+Y^2+1))\n',fresx2.w0,fresx2.zr,fresx2.g,fresx2.B,fresx2.A,fresy2.w0,fresy2.zr,fresy2.g,fresy2.B,fresy2.A);
fclose(fid2);
%%
% fname_in, fname_out
modify_script(inifile,ini_nm,{'z calibration expression='},{zexpr});




