function  SaveWarpData(savepath,data,figH,tform_1,tform,tform2D,...
                        tform_1_inv,tform_inv,tform2D_inv,...
                        cdf,cdf2D,cdf_thresh,cdf2D_thresh,thr);

%% Default parameters
saveroot = '';
dataIs3D = false;

%% Main function


[~,numFields] = size(data(1).sample);
numSamples = length(data); 

% SAVE transforms
chn_warp_names = cell(numSamples,2);
for s=1:numSamples
    chn_warp_names{s,1} = data(s).sample(1).chn;
    chn_warp_names{s,2} = data(s).refchn(1).chn;
end


save([savepath,filesep,'chromewarps.mat'],'tform_1','tform','tform2D',...
    'cdf','cdf2D','cdf_thresh','cdf2D_thresh','thr','chn_warp_names',...
    'tform_1_inv','tform_inv','tform2D_inv');
disp(['wrote ',savepath,filesep,'chromewarps.mat']);  

saveas(figH.warperr,[savepath,filesep,saveroot,'fig_warperr.png']);
saveas(figH.xyerr,[savepath,filesep,saveroot,'fig_xyerr.png']);
saveas(figH.xyerr_all,[savepath,filesep,saveroot,'fig_xyerr_all.png']);
saveas(figH.warperr_2d,[savepath,filesep,saveroot,'fig_warperr_2d.png']);
if dataIs3D
    saveas(figH.zdist,[savepath,filesep,saveroot,'fig_zdist.png']);
    saveas(figH.xzerr,[savepath,filesep,saveroot,'fig_xyzerr.png']);
end

disp('3D bead fitting complete');

% Cleanup
close(figH.xyerr,figH.xyerr_all);
close(figH.warperr,figH.warperr_2d)
if dataIs3D
 close(figH.zdist, figH.xzerr)
end
