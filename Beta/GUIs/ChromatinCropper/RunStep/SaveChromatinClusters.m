function handles = SaveChromatinClusters(handles)

global CC

 % Load variables
    Icell = CC{handles.gui_number}.Icell;
    R = CC{handles.gui_number}.R;
    data = CC{handles.gui_number}.data;
    saveroot = CC{handles.gui_number}.pars7.saveroot;
    
    % save parameters
    imnum = CC{handles.gui_number}.imnum;
    saveNs = CC{handles.gui_number}.saveNs; 
    savefolder = get(handles.SaveFolder,'String');
    if isempty(saveroot)
        s1 = strfind(daxname,'quad_'); 
        s2 = strfind(daxname,'_storm');
        saveroot = daxname(s1+5:s2);
        if isempty(s1)
            s1 = 1;
            saveroot = daxname(s1:s2);
        end
        
        CC{handles.gui_number}.pars7.saveroot = saveroot;
    end
    
    if isempty(savefolder)
        error('error, no save location specified'); 
    end
    % Test if savefolder exists
    if exist(savefolder,'dir') == 0
        mk = input(['Folder ',savefolder,...
            ' does not exist.  Create it? y/n '],'s');
        if strcmp(mk,'y')
            mkdir(savefolder);
        end
    end
    
    disp(['saving data in: ',savefolder])
   
    Iout2 = figure(2); clf;
    imagesc(CC{handles.gui_number}.convI);
    colormap hot; hold on;
    
    for n=saveNs
        % summary data to print ot image
        TCounts = sum(R(n).PixelValues);
        DotSize = length(R(n).PixelValues);
        MaxD = max(R(n).PixelValues);

        % Run through figures, print out to fig 1 and save. 
        Iout = figure(1); clf; 
        ShowConv(handles,n);
        set(gca,'color','k'); 
        saveas(Iout,[savefolder,filesep,saveroot,...
            'Iconv_',num2str(imnum),'_d',num2str(n),'.png']);
        pause(.01);

        Iout = figure(1); clf;
        ShowSTORM(handles,n);
        set(gca,'color','w'); 
        title(... 
            ['dot',num2str(n),' counts=',num2str(TCounts),' size=',...
                 num2str(DotSize),' maxD=',num2str(MaxD)],...
                 'color','k');
        saveas(Iout,[savefolder,filesep,saveroot,...
            'Istorm_',num2str(imnum),'_d',num2str(n),'.png']);
        pause(.01);

        if CC{handles.gui_number}.pars7.saveColorTime
            Iout = figure(1); clf;
            ShowDotTime(handles,n);
            set(gca,'color','k'); set(gcf,'color','w'); 
            xlabel('nm');     ylabel('nm'); 
            saveas(Iout,[savefolder,filesep,saveroot,...
                'Itime_',num2str(imnum),'_d',num2str(n),'.png']);
            pause(.01);
        end
% 

        imwrite(makeuint(Icell{n},8),hot(256),[savefolder,filesep,saveroot,...
            'Icell_',num2str(imnum),'_d',num2str(n),'.png']);
        pause(.01);

        Iout = figure(1); clf;
        ShowHist(handles,n);
        set(gca,'color','k');
        saveas(Iout,[savefolder,filesep,saveroot,...
            'Ihist_',num2str(imnum),'_d',num2str(n),'.png']);
%         imwrite(Ihist{n},[savefolder,filesep,saveroot,...
%             'Ihist_',num2str(imnum),'_d',num2str(n),'.png']);
        
        imaxes = CC{handles.gui_number}.imaxes{n};
        vlist = CC{handles.gui_number}.vlists{n}; %#ok<NASGU>
        parData{1} = CC{handles.gui_number}.pars1;
        parData{2} = CC{handles.gui_number}.pars2;
        parData{3} = CC{handles.gui_number}.pars3;
        parData{4} = CC{handles.gui_number}.pars4;
        parData{5} = CC{handles.gui_number}.pars5;
        parData{6} = CC{handles.gui_number}.pars6;
        parData{7} = CC{handles.gui_number}.pars7;
        parData{8} = CC{handles.gui_number}.pars0;
        parData{9} = CC{handles.gui_number}.parsX;
        
        Imdata.Istorm = CC{handles.gui_number}.Istorm{n};
        Imdata.Iconv = CC{handles.gui_number}.Iconv{n};
        Imdata.Itime = CC{handles.gui_number}.Itime{n};
        Imdata.Ihist = CC{handles.gui_number}.Ihist{n};
        Imdata.name = CC{handles.gui_number}.binfiles(imnum).name;
        
        save([savefolder,filesep,saveroot,'DotData_',num2str(imnum),...
            '_d',num2str(n),'.mat'],'imaxes','vlist','parData','Imdata');
        
        Iout2 = figure(2); 
        text(imaxes.cx+6,imaxes.cy,...
         ['dot ',num2str(n)],'color','w'); 
     
         disp(['saving data for dot',num2str(n),'...']);  
         disp(['wrote ',savefolder,filesep,saveroot,'DotData_',...
             num2str(imnum),'_d',num2str(n),'.mat']);
         pause(.5); 
    end
    
    saveas(Iout2,[savefolder,filesep,saveroot,...
        'Overview_',num2str(imnum),'.png']);
        
    
    figure(1); clf;
    subplot(3,2,1); hist( [data.MainArea{:}] ); title('Area');
    subplot(3,2,2); hist( [data.Dvar{:}] ); title('Intensity Variation')
    subplot(3,2,3); hist( [data.MainDots{:}]./[data.MainArea{:}] ); title('localization density');
    subplot(3,2,4); hist( [data.Tregions{:}] ); title('number of regions'); 
    subplot(3,2,5); hist( [data.TregionsW{:}] ); title('Weighted number of regions')
    subplot(3,2,6); hist( [data.mI{:}] ); title('moment of Inertia'); 
    % hist( [data.MainEccent{:}] ); title('eccentricity'); 
    
    CCguiData = CC{handles.gui_number};  %#ok<NASGU>
    save([savefolder,filesep,saveroot,'data.mat'],'data','CCguiData');
    
    save([ScratchPath,'test.mat']);
    % load([ScratchPath,'test.mat']);