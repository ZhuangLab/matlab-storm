

%% imreadfast.m
%
%  Alistair Boettiger                                  Date Begun: 06/06/11
% Levine Lab                                        Last Modified: 06/07/11
%
% Fast reading for single-frame tifs



function I = imreadfast(filename)

tf = imformats('tif');
I = feval(tf.read, filename, 1);
 
end

