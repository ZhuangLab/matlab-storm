 function [za,ps] = LevelData(fit,apply)
 % fit is [x,y,z] dataset on which to compute the fit of a plane in 3D
 % apply is [x,y] data for which to report the new z
 % 
    x = fit(:,1); y = fit(:,2); z=fit(:,3);
    p = polyfitn([x,y],z,2);
    ps = p.Coefficients;
    xa = apply(:,1); ya = apply(:,2);
    za = xa.^2*ps(1) + xa.*ya*ps(2) + xa*ps(3) + ya.^2*ps(4) + ya*ps(5) + ps(6);