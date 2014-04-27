function data = MatchSampleAndRefFiles(beadmovie)

%%
global scratchPath
excludePoorZfit = false;


numMovies = length(beadmovie);
numSamples = length([beadmovie.chns]) - numMovies; 
data(numSamples).sample = [];

sampleset = 0;
refset = 0;
for m=1:numMovies
    
    % Nsamples is number of channels minus 1 reference channel for every movie 
    [~,numFields] = size(beadmovie(m).binname);
    
    data(numSamples).sample(numFields).x = [];
    data(numSamples).sample(numFields).y = [];
    data(numSamples).sample(numFields).z = [];
    data(numSamples).sample(numFields).chn = [];
    data(numSamples).refchn(numFields).x = [];
    data(numSamples).refchn(numFields).y = [];
    data(numSamples).refchn(numFields).z = [];
    data(numSamples).refchn(numFields).chn = [];
    
    
    
    
    for c=1:length(beadmovie(m).chns)  
        if c ~= beadmovie(m).refchn
            sampleset = sampleset + 1; 
            issample = true;
        else
            refset = refset + 1;
            issample = false;
        end
            
          for n = 1:numFields; 
%                try % keep going even if a movie is missing
                    mol_list = ReadMasterMoleculeList( beadmovie(m).binname{c,n},'verbose',false); 
                    mol_list = ReZeroROI(beadmovie(m).binname{c,n},mol_list);
                    % only keep beads that are detected in all frames
                    frames_per_field = max(mol_list.length);
                    mols_on_allframes = mol_list.length >= .9*frames_per_field;
                    if sum(mols_on_allframes) < .1*length(mol_list.x)
                        disp('warning: many molecules not detected or linked for all frames in:');
                        disp(beadmovie(m).binname{c,n});
                       % disp('try rerunning with a larger match radius');  
                    end
                    if excludePoorZfit
                        goodmol = (mol_list.c~=9) & mols_on_allframes; % use only molecules with good z-fit score (class 1)
                    else
                        goodmol = mols_on_allframes;
                    end

                    if issample  % store as sample data
                        data(sampleset).sample(n).x = cast(mol_list.xc(goodmol==1),'double');
                        data(sampleset).sample(n).y = cast(mol_list.yc(goodmol==1),'double');
                        data(sampleset).sample(n).z = cast(mol_list.z(goodmol==1),'double');
                        data(sampleset).sample(n).chn = beadmovie(m).chns{c};       
                        data(sampleset).sample(n).bin = beadmovie(m).binname{c,n};             
                    else % store as reference data for all matching samples
                        for k=refset:refset-1+length(beadmovie(m).chns)-1
                        data(k).refchn(n).x = cast(mol_list.xc(goodmol==1),'double');
                        data(k).refchn(n).y = cast(mol_list.yc(goodmol==1),'double');
                        data(k).refchn(n).z = cast(mol_list.z(goodmol==1),'double');  
                        data(k).refchn(n).chn = beadmovie(m).chns{c};       
                        data(k).refchn(n).bin = beadmovie(m).binname{c,n};   
                        end
                    end
                
%                 catch er
%                     disp(er.message); 
%                      save([scratchPath, filesep, 'troubleshoot.mat']); 
%                      disp(['saved data as, ',scratchPath, filesep, 'troubleshoot.mat']);
%                      % load([scratchPath, filesep, 'troubleshoot.mat']); 
%                     disp(['failed to load ', beadmovie(m).binname{c,n}]);
%                     disp(['skipping field: ',num2str(n)]); 
%                 end 
          end  
    end
end