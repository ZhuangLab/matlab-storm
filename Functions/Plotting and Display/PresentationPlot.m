function fig_handle = PresentationPlot(varargin)
%--------------------------------------------------------------------------
% fig_handle = PresentationPlot(varargin)
% This function takes the current (or specified) figure and adjusts it for
% presentation
%--------------------------------------------------------------------------
% Outputs:
%
%--------------------------------------------------------------------------
% Variable Inputs:
% 
%--------------------------------------------------------------------------
% Jeffrey Moffitt
% October 9, 2012
% jeffmoffitt@gmail.com
%
% Version 1.0
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Default Values
%--------------------------------------------------------------------------
fontSize = 16;
lineWidth = 3;
markerWidth = 12;
figHandle = gcf;
%--------------------------------------------------------------------------
% Parse Variable Input 
%--------------------------------------------------------------------------
if nargin >= 2
    if (mod(length(varargin), 2) ~= 0 ),
        error(['Extra Parameters passed to the function ''' mfilename ''' must be passed in pairs.']);
    end
    parameterCount = length(varargin)/2;

    for parameterIndex = 1:parameterCount,
        parameterName = varargin{parameterIndex*2 - 1};
        parameterValue = varargin{parameterIndex*2};
        switch parameterName
            case 'FontSize'
                fontSize = CheckParameter(parameterValue, 'positive', parameterName);
            case 'LineWidth'
                lineWidth = CheckParameter(parameterValue, 'positive', parameterName);
            case 'MarkerWidth'
                markerWidth = CheckParameter(parameterValue, 'positive', parameterName);
            case 'FigureHandle'
                figHandle = CheckParameter(parameterValue, 'positive', parameterName);
            otherwise
                error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
        end
    end
end

figure(figHandle);
ax = get(gcf, 'Children');

for i=1:length(ax)
    
    axis_handles = get(ax(i));
    axis_fields = fieldnames(axis_handles);
    
    if ismember('FontSize', axis_fields)
        set(ax(i), 'FontSize', fontSize);
    end
    
    if ismember('XLabel', axis_fields)
        x_handle = get(ax(i), 'XLabel');
        if ismember('FontSize', fieldnames(get(x_handle)))
            set(x_handle, 'FontSize', fontSize);
        end
    end

    if ismember('YLabel', axis_fields)
        y_handle = get(ax(i), 'YLabel');
        if ismember('FontSize', fieldnames(get(y_handle)))
            set(y_handle, 'FontSize', fontSize);
        end
    end

    if ismember('Title', axis_fields)
        t_handle = get(ax(i), 'Title');
        if ismember('FontSize', fieldnames(get(t_handle)))
            set(t_handle, 'FontSize', fontSize);
        end
    end
    
    if ismember('Children', axis_fields)
        line_handles = get(ax(i), 'Children');
        
        for j=1:length(line_handles)
            if ismember('LineWidth', fieldnames(get(line_handles(j))))
                set(line_handles(j), 'LineWidth', lineWidth);
            end
            if ismember('MarkerSize', fieldnames(get(line_handles(j))))
                set(line_handles(j), 'MarkerSize', markerWidth);
            end
        end
    end
    
    if ismember('LineWidth', axis_fields)
        set(ax(i), 'LineWidth', lineWidth);
    end
end
