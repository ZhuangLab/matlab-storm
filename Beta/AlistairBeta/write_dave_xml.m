

% write bead xml

% to print just the str on a new line: fprintf(fid,str,''); fprintf(fid,'%s\r\n','');
% to print the str preceded by a tab:  fprintf(fid,'\t'); fprintf(fid,str,''); fprintf(fid,'%s\r\n','');

xmlname = 'C:\Users\Alistair\Documents\Projects\General_STORM\STORM_Parameters\beadrun3d_5r_1000.xml';
regions_per_Z = 5;
Zs = [0,-100,100,-200,200,-300,300,-400,400,-500,500]; 
delay = 5000; % ms (2000 or 5000).

fid = fopen(xmlname,'w+');

str = '<?xml version="1.0" encoding="ISO-8859-1"?>';    fprintf(fid,str,''); fprintf(fid,'%s\r\n','');
str = '<sequence>';     fprintf(fid,str,''); fprintf(fid,'%s\r\n','');
x=0; y=0; % starting point; 


for z=1:length(Zs)
   for k=1:regions_per_Z
 
        if mod(k,2) == 0
            x = x+5;
        else
            y=y+5;
        end
        
        if z==1 && k==1
            pause_start = num2str(1);
        else
            pause_start = num2str(0);
        end
        
str ='<movie>';         fprintf(fid,str,''); fprintf(fid,'%s\r\n','');
     str = ['<name>Visbeads','_zpos',sprintf('%02d',z),'_reg',sprintf('%02d',k),'</name>'];     fprintf(fid,'\t'); fprintf(fid,str,''); fprintf(fid,'%s\r\n','');
     str = '<length>10</length>';                               fprintf(fid,'\t'); fprintf(fid,str,''); fprintf(fid,'%s\r\n','');
	 str = '<parameters>2</parameters>';                        fprintf(fid,'\t'); fprintf(fid,str,''); fprintf(fid,'%s\r\n','');
     str = ['<delay>',num2str(delay),'</delay>'];               fprintf(fid,'\t'); fprintf(fid,str,''); fprintf(fid,'%s\r\n','');
     str = ['<lock_target>',num2str(Zs(z)),'</lock_target>'];   fprintf(fid,'\t'); fprintf(fid,str,''); fprintf(fid,'%s\r\n','');
     str = '<progression>';                                     fprintf(fid,'\t'); fprintf(fid,str,''); fprintf(fid,'%s\r\n','');
	 str = '<type>linear</type>';                               fprintf(fid,'\t'); fprintf(fid,str,''); fprintf(fid,'%s\r\n','');
	 str ='<channel start="0.04">4</channel>';                  fprintf(fid,'\t'); fprintf(fid,str,''); fprintf(fid,'%s\r\n','');
	 str = '</progression>';                                    fprintf(fid,'\t'); fprintf(fid,str,''); fprintf(fid,'%s\r\n','');
    str = ['<pause>',pause_start,'</pause><stage_x>',sprintf('%1.1f',x),'</stage_x><stage_y>',sprintf('%1.1f',y),'</stage_y></movie>'];      fprintf(fid,'\t'); fprintf(fid,str,''); fprintf(fid,'%s\r\n','');
str = '<movie>';        fprintf(fid,str,''); fprintf(fid,'%s\r\n','');
     str = ['<name>IRbeads','_zpos',sprintf('%02d',z),'_reg',sprintf('%02d',k),'</name>'];     fprintf(fid,'\t'); fprintf(fid,str,''); fprintf(fid,'%s\r\n','');
     str = '<length>10</length>';                               fprintf(fid,'\t'); fprintf(fid,str,''); fprintf(fid,'%s\r\n','');
	 str = '<parameters>1</parameters>';                        fprintf(fid,'\t'); fprintf(fid,str,''); fprintf(fid,'%s\r\n','');
     str = ['<delay>',num2str(delay),'</delay>'];               fprintf(fid,'\t'); fprintf(fid,str,''); fprintf(fid,'%s\r\n','');
     str = ['<lock_target>',num2str(Zs(z)),'</lock_target>'];   fprintf(fid,'\t'); fprintf(fid,str,''); fprintf(fid,'%s\r\n','');
     str = '<progression>';                                     fprintf(fid,'\t'); fprintf(fid,str,''); fprintf(fid,'%s\r\n','');
	 str = '<type>linear</type>';                               fprintf(fid,'\t'); fprintf(fid,str,''); fprintf(fid,'%s\r\n','');
	 str ='<channel start="0.1">4</channel>';                   fprintf(fid,'\t'); fprintf(fid,str,''); fprintf(fid,'%s\r\n','');
	 str = '</progression>';                                    fprintf(fid,'\t'); fprintf(fid,str,''); fprintf(fid,'%s\r\n','');
    str = ['<pause>0</pause><stage_x>',sprintf('%1.1f',x),'</stage_x><stage_y>',sprintf('%1.1f',y),'</stage_y></movie>'];      fprintf(fid,'\t'); fprintf(fid,str,''); fprintf(fid,'%s\r\n','');
    fprintf(fid,'%s\r\n','');
    end
end
str = '</sequence>';    fprintf(fid,str,''); fprintf(fid,'%s\r\n','');