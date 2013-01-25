Functions Folder Readme 
===============================

Folder Organization
--------------------------------
All functions in this folder are organized in common directories.  
Functions without an obvious common theme may go in Misc. folder.

On Writing New Functions 
---------------------------------
Functions are written to following 'Clean Code' Standards
* has help file -- lists all inputs and outputs with descriptors
* functions have small number of mandatory inputs (typically 1-4)
* additional inputs are passed as 'Flag',value pairs.  (see examples)
* functions remain backward compatible (see Editing functions below)
* see /function template/ for format of help file and input parsing.  

Additional Recommendations
* long code is written in demarcated code blocks 
* As general a structure as possible --(shouldn't be hard-coded based on the unique configuration of a single microscope setup)
	computer independent (no hard coded directories)
	
	
On Editing Functions
-------------------------------
This is a repository contains version managed 'living' code which is meant to be edited an improved.  
However, since these functions in this folder are in a finalized form it is important to remain backwards compatibility in your upgrades.
Additional features can be added to functions by modifying the function input list appropriately:

	flags = {'OriginalFlag', 'NewFlag'};

	for parameterIndex = 1:parameterCount,
		parameterName = varargin{parameterIndex*2 - 1};
		parameterValue = varargin{parameterIndex*2};
		switch parameterName
			case 'OriginalFlag'
				OriginalFlag = CheckParameter(parameterValue, 'string', 'OriginalFlag');
			case 'NewFlag'
				NewFlag = CheckParameter(parameterValue, 'boolean', 'NewFlag');
			otherwise
				error(['The parameter ''' parameterName ''' is not recognized by the function ''' mfilename '''.']);
		end
	end
	
Old flags should remain in place and there inputs reassiagned to preserve functionality.  
If this is not possible but the update represents a substantial improvement have the system through an error which tells the user clearly how to change their input flags.