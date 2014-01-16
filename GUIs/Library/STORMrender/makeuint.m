%%          makeuint.m
% Alistair Boettiger                                Date Complete: 03/07/11
% Levine Lab                

% Convert to uint

% I is the input image
% n is either 8 for uint8 or 16 for uint16; 
% Io is the output image in the requested format

function Io = makeuint(I,n)

 I = double(I) - min(double(I(:)));
 I = I./max(I(:));   % figure(2); clf; imagesc(I);
 Io = eval(['uint',num2str(n),'(2^n*I)']); 
  


