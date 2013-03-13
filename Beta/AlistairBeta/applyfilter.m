

function [infilter,filts] = applyfilter(mlist, infilter, filts, channels, par, myfilt)
% Routine from the STORMrender GUI
%
%--------------------------------------------------------------------------
% Inputs
% mlist / cell array
%                molecule list
% infilter / cell array      
%                cell array of logical vectors of equal length as the
%                corresponding mlist, indicating which localizations
%                are to be rendered
% filts / structure
%               contains a field for each filter and specifies parameter
%               values of filter
% channels / vector
%               lists channels (e.g. [1,2,4]) on which to apply filter
% par / string 
%               one of the components of the the mlist to histogram and
%               filter on, or a custom filter, 'custom'.  
% myfilt / string 
%               custom filter to be used if par is custom.  
% imaxes / global structure
%               only required for input filter on 'region'.  
% 

% Global variables

global imaxes ScratchPath

%% Main Function

for c = channels     
    %--------------------------------------------------------------------
    % convert a user defined string into a filter (see examples)
    if strcmp(par,'custom') % apply custom filter
          disp({'custom filter: f = logical function of m.*';
              'examples';
              '"f = [m.a] > 100" % returns molecules with parameter a > 100';
              ' "f =  ([m.i] ./ [m.a]) > .5 & ([m.i] ./ [m.a]) <5 ; | [m.i] > 1000" returns  ';       
           ' "[idx,dist] = knnsearch(transpose([[m.xc];[m.yc]]),transpose([m.xc,m.yc]),"k",4); f = (max(dist,[],2) < 5);  %  this returns molecules with more than k=4 neighbors in a radius of dmax=5. note: need to change double " to single to eval.'});                        

        m = mlist{c}; % allow for shorthand entry (see above)
        eval(myfilt); 
     
        
        infilter{c} = infilter{c} & logical(f);
        filts.custom = myfilt;
        
    %--------------------------------------------------------------------
    % only render localization which are inside a user defined box
    elseif strcmp(par,'region');
            figure(1); 
            [x,y] = ginput(2);  % These are relative to the current axis
            disp('x,y grabbed');
            disp([x,y]);
            xim = imaxes.xmin + x/imaxes.scale/imaxes.zm;
            yim = imaxes.ymin + y/imaxes.scale/imaxes.zm;
            disp('x,y converted');
            disp([xim,yim]);

            % plot box
            figure(1); hold on;
            rectangle('Position',[min(x),min(y),abs(x(2)-x(1)),abs(y(2)-y(1))],'EdgeColor','w'); hold off;
            inregion = [mlist{c}.xc] > xim(1) & [mlist{c}.xc] < xim(2) & [mlist{c}.yc] > yim(1) & [mlist{c}.yc] < yim(2);
            infilter{c} = infilter{c} & inregion'; 
            disp([num2str(sum(inregion)/length([mlist{c}.xc])*100),'% of localizations kept']);
            
%             figure(3); clf; plot([mlist{c}.xc],[mlist{c}.yc],'k.');
%             xlim([xim(1),xim(2)]); ylim([yim(1),yim(2)]);
    %--------------------------------------------------------------------        
    else % apply data cut on histogram of molecule properties
        N = length([mlist{c}.xc]);
        disp(['mlist{',num2str(c),'}.',par]);
        datarange = eval(['[mlist{',num2str(c),'}.',par,']',]);

        % select data range from a histogram
        figure(2); clf; hist(datarange,N/20); xlabel(par); 
        [v,~] = ginput(2); % gets mouse click positions
        disp(v);
        infilter{c} = infilter{c} & (datarange > v(1) & datarange < v(2));

        disp(['keeping ', num2str(sum( (datarange > v(1) & datarange < v(2)) )/N*100,4),'% of values']);
        disp(['Now showing ',num2str(sum(infilter{c})/N*100,4),'% of localizations']); 
        
        % save and display filter bounds
      % filts = setfield(filts,par,v); % old (functional/tested cmd)
        filts.(par) = v;  % using 'dynamic fieldnames' 
        xs = linspace(min(datarange),max(datarange),N/20); 
        figure(2); clf; 
        hist(datarange,xs); 
        xlabel(par); 
        xlim([min(datarange),max(datarange)]);
        h = findobj('type','patch'); 
        hold on;
        hist(datarange( datarange > v(1) & datarange < v(2) ),xs);
        h2 = findobj('type','patch'); 
        set(h2,'FaceColor','b','EdgeColor','b');
        set(h,'FaceColor','m','EdgeColor','m');
    end
end