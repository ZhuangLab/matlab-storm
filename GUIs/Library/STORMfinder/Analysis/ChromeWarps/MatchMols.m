function [set1,set2] = MatchMols(ref,sample,tform, match_radius,verbose,sname,k,set1,set2,Nfields)
    if isempty(set1); % initialize on the first time through; 
        set1.x = cell(Nfields,1); set1.y = cell(Nfields,1); set1.z = cell(Nfields,1);
        set2.x = cell(Nfields,1); set2.y = cell(Nfields,1); set2.z = cell(Nfields,1);
    end

    [matched, unmatched] = corr_mols(ref, sample,tform, match_radius);  
     set1.x{k} = ref.x( matched.set1_inds ); % points in ref channel
     set1.y{k} = ref.y( matched.set1_inds );
     set1.z{k} = ref.z( matched.set1_inds );
     set2.x{k} = sample.x( matched.set2_inds ); % points in 750 channel
     set2.y{k} = sample.y( matched.set2_inds );
     set2.z{k} = sample.z( matched.set2_inds );   
    if verbose
     disp(['frame ',num2str(k),':  ', num2str(length(matched.set2_inds)), filesep...
       num2str( length(matched.set2_inds) + length(unmatched.set2_inds) ),...
       ' ', sname ,' molecules matched'])   
    end
    if isempty(set1.x{k})
        set1.x{k} = []; % handling  Empty [0x1] not concat with Empty 1x0 matrix errors  
        set1.y{k} = [];
        set1.z{k} = [];
    else
        set1.x{k} = set1.x{k}(:);
        set1.y{k} = set1.y{k}(:);
        set1.z{k} = set1.z{k}(:);
    end
    if isempty(set2.x{k})
        set2.x{k} = []; % handling  Empty [0x1] not concat with Empty 1x0 matrix errors  
        set2.y{k} = [];
        set2.z{k} = [];
    else
        set2.x{k} = set2.x{k}(:);
        set2.y{k} = set2.y{k}(:);
        set2.z{k} = set2.z{k}(:);
    end
 
 
         