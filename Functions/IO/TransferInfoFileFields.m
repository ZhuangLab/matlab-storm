function fileStructs = TransferInfoFileFields(fileStructs, varargin)
% ------------------------------------------------------------------------
% fileStruct = TransferInfoFileFields(fileStruct, varargin)
% This function finds the .inf files associated with each file in
%   fileStructs, loads it, and transfers specified fields to each entry in
%   fileStructs. 
%--------------------------------------------------------------------------
% Necessary Inputs
% fileStructs/A array of structures with the following fields:
%   --filePath: The path to the specific file.
%--------------------------------------------------------------------------
% Outputs
% fileStructs/The same array of structures with additional fields from the
%   corresponding info file structures added. 
% binType/A string that specifies the bin type.  Only required if the
%  default generateDaxName function is used.  
%--------------------------------------------------------------------------
% Variable Inputs (Flag/ data type /(default)):
%--------------------------------------------------------------------------
% Jeffrey Moffitt
% jeffmoffitt@gmail.com
% September 10, 2014
%--------------------------------------------------------------------------
% Creative Commons License CC BY NC SA
%--------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Default variables
% -------------------------------------------------------------------------
defaults = cell(0,3);

% Parameters for parsing file names
defaults(end+1,:) = {'verbose', 'boolean', false};
defaults(end+1,:) = {'infFieldsToAdd', 'cell', {'Stage_X', 'Stage_Y'}};
defaults(end+1,:) = {'generateDaxName', 'function', @(x) [x.filePath(1:(regexp(x.filePath, x.binType, 'once')-2)) '.dax']};

% -------------------------------------------------------------------------
% Parse variable input
% -------------------------------------------------------------------------
parameters = ParseVariableArguments(varargin, defaults, mfilename);

% -------------------------------------------------------------------------
% Parse necessary input
% -------------------------------------------------------------------------
if nargin < 1 || ~isstruct(fileStructs) || ~ismember('filePath', fields(fileStructs))
    error('matlabFunctions:invalidArguments', 'Improper structure provided.');
end

% -------------------------------------------------------------------------
% Printed updates
% -------------------------------------------------------------------------
if parameters.printedUpdates
    display('--------------------------------------------------------------');
    tic;
    display(['Loading and transfering info files']);
end

% -------------------------------------------------------------------------
% Loop over fileStructs
% -------------------------------------------------------------------------
for i=1:length(fileStructs)
    infFileName = parameters.generateDaxName(fileStructs(i));
    infStruct = ReadInfoFile(infFileName, 'verbose', parameters.verbose);
    
    % Add hardcoded fields
    fileStructs(i).infFilePath = [infStruct.localPath infStruct.localName];
    fileStructs(i).imageH = infStruct.frame_dimensions(1);
    fileStructs(i).imageW = infStruct.frame_dimensions(2);
    
    % Add generic fields
    for j=1:length(parameters.infFieldsToAdd)
        fileStructs(i).(parameters.infFieldsToAdd{j}) = infStruct.(parameters.infFieldsToAdd{j});
    end
end

% -------------------------------------------------------------------------
% Printed updates
% -------------------------------------------------------------------------
if parameters.printedUpdates
    display(['...finished in ' num2str(toc) ' s']);
end
    