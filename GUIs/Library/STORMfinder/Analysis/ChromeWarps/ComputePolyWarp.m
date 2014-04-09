function [tform,tform2D,tform_inv,tform2D_inv,dat2] = ComputePolyWarp(dat2)
% returns tform tform2D and the inverse functions tform_inv and tform2D_inv

numSamples = length(dat2.sample);

poly_order = 2;
poly_order2 = 2;
tform = cell(numSamples,1);
tform2D = cell(numSamples,1); 
tform_inv = cell(numSamples,1);
tform2D_inv = cell(numSamples,1); 
for s=1:numSamples
    refchn = [dat2(s).refchn.x dat2(s).refchn.y dat2(s).refchn.z]; 
    sample = [dat2(s).sample.x dat2(s).sample.y dat2(s).sample.z]; 
    tform{s} = cp2tform3D(refchn,sample,'polynomial',poly_order); % compute warp
    tform_inv{s} = cp2tform3D(sample,refchn,'polynomial',poly_order); % compute warp
    [dat2(s).sample.tx,dat2(s).sample.ty,dat2(s).sample.tz] = ...
        tforminv(tform{s}, dat2(s).sample.x, dat2(s).sample.y, dat2(s).sample.z); % apply warp
    % 2D transform 
    tform2D{s} = cp2tform( [dat2(s).refchn.x dat2(s).refchn.y],...
        [dat2(s).sample.x dat2(s).sample.y],'polynomial',poly_order2); % compute warp
    tform2D_inv{s} = cp2tform([dat2(s).sample.x dat2(s).sample.y],...
        [dat2(s).refchn.x dat2(s).refchn.y],'polynomial',poly_order2); % compute warp
    [dat2(s).sample.tx2D,dat2(s).sample.ty2D,] = tforminv(tform2D{s},...
        dat2(s).sample.x, dat2(s).sample.y); % apply warp
end

% DONE!
% the rest of this code is just graphing and computing the accuracy of the
% warp in different ways.  tforms are exported at the end along with the
% percision of fit data.  Plots are automatically saved in the source
% folder to better document warp percision. 