function cellstring = parseCSL( stringlist )
%cellstring =  parseCSL(string_of_comma_separated_list)
%----------------------------------------------------------------------
% Takes a string which contains a list of items separated by commas
% parses each comma separated value into a unique element of a cell array
% of strings.  
% spaces before or after commas are ignored.  
%
% Alistair Boettiger
% boettiger.alistair@gmail.com
% February 12th, 2012

items = strfind(stringlist,',');
if ~isempty(items)
    items = [0,items,length(stringlist)+1];
    Nitems = length(items) -1;
    cellstring = cell(1,Nitems);
    for i=1:Nitems
        cellstring{i} = strtrim(stringlist(items(i)+1:items(i+1)-1));
    end
else
    cellstring = {stringlist};
end
