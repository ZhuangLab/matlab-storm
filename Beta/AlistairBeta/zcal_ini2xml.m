
function  zcal_ini2xml(inifile,xmlfile_in,xmlfile_out)

% xmlin = 'C:\Users\Alistair\Documents\Projects\General_STORM\STORM_Parameters';
% inipath = 'I:\2013-02-08_multiplex\Beads';
% datapath = 'I:\2013-02-08_multiplex\STORM';
% 
% inifile = [inipath,filesep,'750_IRBead_pars.ini'];
% xmlfile_in = [xmlin,filesep,'750_mufit3d_pars.xml'];
% xmlfile_out = [datapath,filesep,'750_dao_pars.xml'];

zexpr = read_parameterfile(inifile,{'z calibration expression='},'');
zexpr = zexpr{1};

% % stupid regular expression approach not working
% expr = '=.\d+\.?\d*'; % get all numbers that start with an equal sign
% str = regexp(zexpr,expr,'match');
% char(str)


starts = strfind(zexpr,'=');
ends = strfind(zexpr,';');
Ks = min(length(starts),length(ends));
pars = cell(Ks,1);
for k=1:Ks;
    pars{k} = zexpr(starts(k)+1:ends(k)-1);
end


% sadly Insight and DaoSTORM don't list the parameters in the same order...
% And we have some = signs to get rid of:
% wx0=235.08;zrx=539.26;gx=401.08;  Cx=0.00000;Bx=1.8281;Ax=-1.0652;  wy0=282.25;zry=903.63;gy=-332.57;  Cy=0.0000;By=-7.1569;Ay=14.6075;  X=(z-gx)/zrx;  wx=sqrt(wx0*sqrt(Cx*X^5+Bx*X^4+Ax*X^3+X^2+1));  Y=(z-gy)/zry;  wy=sqrt(wy0*sqrt(Cy*Y^5+By*Y^4+Ay*Y^3+Y^2+1))

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
        pars{1},...  % wx_fit.w0,...
        pars{3},...  %wx_fit.g,...
        pars{2},...  %wx_fit.zr,...
        pars{6},...  %wx_fit.A,...
        pars{5},...  %wx_fit.B,...
        pars{7},...  %wy_fit.w0,...
        pars{9},...  %wy_fit.g,...
        pars{8},...  %wy_fit.zr,...
        pars{12},...  %wy_fit.A,...
        pars{11},...
        };
modify_script(xmlfile_in,xmlfile_out,zpars_names,zpars_values,'<');


