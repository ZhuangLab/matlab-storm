function writeZfit2ini(template_file,new_file,wx_fit,wy_fit,varargin)

%% Default Parameters
global ScratchPath

parstype = '.ini';
verbose = true;

%--------------------------------------------------------------------------
%% Parse mustHave variables
%--------------------------------------------------------------------------
if nargin < 4
   error([mfilename,' expects at least 2 inputs, daxfile and parsfile']);
end

%--------------------------------------------------------------------------
%% Parse Variable Input Arguments
%--------------------------------------------------------------------------
if nargin > 4
    if (mod(length(varargin), 2) ~= 0 ),
        error(['Extra Parameters passed to the function ''' mfilename ''' must be passed in pairs.']);
    end
    parameterCount = length(varargin)/2;

    for parameterIndex = 1:parameterCount,
        parameterName = varargin{parameterIndex*2 - 1};
        parameterValue = varargin{parameterIndex*2};
        switch parameterName   
            case 'parstype'
                parstype = CheckList(parameterValue, {'.ini','.xml'}, 'parstype');
            case 'verbose'
                verbose = CheckParameter(parameterValue, 'boolean', 'verbose');
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.' '  See help ' mfilename]);
        end
    end
end

%% Main Function

zexpr = sprintf('wx0=%.2f;zrx=%.2f;gx=%.2f;  Cx=0.00000;Bx=%.4f;Ax=%.4f;  wy0=%.2f;zry=%.2f;gy=%.2f;  Cy=0.0000;By=%.4f;Ay=%.4f;  X=(z-gx)/zrx;  wx=sqrt(wx0*sqrt(Cx*X^5+Bx*X^4+Ax*X^3+X^2+1));  Y=(z-gy)/zry;  wy=sqrt(wy0*sqrt(Cy*Y^5+By*Y^4+Ay*Y^3+Y^2+1))\n',...
    wx_fit.w0,wx_fit.zr,wx_fit.g,wx_fit.B,wx_fit.A,wy_fit.w0,wy_fit.zr,wy_fit.g,wy_fit.B,wy_fit.A);
if verbose
    disp(zexpr);
end

if strcmp(parstype,'.ini')
    modify_script(template_file,new_file,{'z calibration expression='},{zexpr},'');
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
modify_script(template_file,new_file,zpars_names,zpars_values,'<');
end


