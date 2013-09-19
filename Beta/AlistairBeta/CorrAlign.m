

function [xshift,yshift] = CorrAlign(Im1,Im2)

 [H,W] = size(Im1);
 corrM = xcorr2(single(Im1),single(Im2)); % The correlation map
   Hc = 50;    Wc = 50; 
 % Just the center of the correlation map  
   corrMmini = corrM(H-Hc/2+1:H+Hc/2,W-Wc/2+1:W+Wc/2);
   [~,indmax] =  max(corrMmini(:));
   [cy,cx] = ind2sub([Hc,Wc],indmax );
   xshift = (cx-Wc/2);
   yshift = (cy-Hc/2);