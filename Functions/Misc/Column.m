function x = Column(x)

[i,j] = size(x);
if i > 1 && j > 1
    error('input is not a vector');
elseif i == 1
    x = x';
elseif j== 1
    x = x;
end

    