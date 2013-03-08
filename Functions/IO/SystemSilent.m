function proc = SystemSilent(system_command)
%--------------------------------------------------------------------------
% SystemSilent(system_command)
%               -- launches a system command to run in a hidden terminal
% proc = SystemSilent(system_command)
%               -- launches  a system command to run in a hidden terminal
%               and returns the structure proc with process details.  
%               proc.HasExited will let you know if the process is finished
% Note:  Only runs on WINDOWS
%-------------------------------------------------------------------------
% Inputs 
% system_command / string 
%               -- same text you would send to system() or dos()
%-------------------------------------------------------------------------
% Outputs (optional)
% proc / structure -- contains details about the process just launched,
%                   including whether or not it is still running 
%------------------------------------------------------------------------- 
% Examples
% SystemSilent('c:\temp\example.bat') 
%               runs example.bat silently in background
% proc = SystemSilent('c:\temp\example.bat') 
% while true
%     if proc.HasExited
%         fprintf('\nProcess exited with status %d\n', proc.ExitCode);
%         break
%     end
%     fprintf('.');
%     pause(.1);
% end
%               runs example.bat silently in background, prints ..... to
%               screen every .1 seconds while process is running, and
%               prints text to screen declaring that the process has
%               exited when it is complete.  
% SystemSilent([insight.exe daxfile inifile && exit &]) 
%               runs insight.exe on daxfile silently in background.  The &&
%               exit & part might not be necessary.  (exit when done and
%               run externally).  
%-------------------------------------------------------------------------
% Alistair Boettiger        boettiger.alistair@gmail.com
% February 3, 2013
% 
% Developed based on suggestions from Andrew Janke on StackOverflow Jan 19
% 2012. http://stackoverflow.com/questions/8931000/how-to-execute-a-dos-command-from-matlab-and-return-control-immediately-to-matla
%--------------------------------------------------------------------------
% Creative Commons License 3.0 CC BY  
%--------------------------------------------------------------------------

% Main Code 

startInfo = System.Diagnostics.ProcessStartInfo('cmd.exe', sprintf('/c "%s"', system_command));
startInfo.WindowStyle = System.Diagnostics.ProcessWindowStyle.Hidden;  %// if you want it invisible
proc = System.Diagnostics.Process.Start(startInfo);
if isempty(proc)
    error('Failed to launch process');
end


