function vec = Str2vec(str)
% If 'str' is the output of str = num2str(vec)
% str2vec returns the vector vec that was fed into string
% note str2double returns NaN.  

vec = eval(['[',str,']']);

