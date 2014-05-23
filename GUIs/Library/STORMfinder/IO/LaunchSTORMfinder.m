function LaunchSTORMfinder(filename)
% opens filename in STORMfinder
% This is a wrapper function for windows DDE launch

disp(['opening ',filename ,' in STORMfinder']); 

% STORMfinder('OpeningFcn',filename)