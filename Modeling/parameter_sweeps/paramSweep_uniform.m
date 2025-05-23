function fracMat = paramSweep_uniform(KORange, KNRange, LRange, VmaxRange, bcdData, tScale, mirny, seed, rep)

    tic % record the run time

    % General parameters
    params = struct;
    params.origOrig = 9.7;              % mean origin-origin distance (kb)
    params.lambda = 2/params.origOrig;  % origins/kb
    params.rate = 5.3;                  % rate of DNA polymerase (kb/min)
    params.nuc1.n = 5;
    params.nuc2.n = 4;
    
%     f = waitbar(0);
   
    fracMat = zeros(length(KORange),length(KNRange),length(LRange),length(VmaxRange));
    for i = 1:length(KORange)
        params.nuc1.KO = KORange(i);
        params.nuc2.KO = KORange(i);
    
        for j = 1:length(KNRange)
            params.nuc1.KN = KNRange(j);
            params.nuc2.KN = KNRange(j);
    
            for k = 1:length(LRange)
                params.nuc1.L = LRange(k);
                params.nuc2.L = LRange(k);
    
                for l = 1:length(VmaxRange)
                    Vmax = VmaxRange(l);
                    
                    % Run simulation
                    rng(seed)
                    xs = 0:0.0005:1;
                    uniform = 1;
                    [AP_grad_ON, ~] = runSSA_sweeps(bcdData, xs, mirny, tScale, params, Vmax,[],uniform,rep,[]);
                    
                    % Fraction of active nuclei of simulations
                    AP_axis = 0:0.01:1;
                    bins = discretize(AP_grad_ON(:,1),AP_axis); % try with 1% EL bins
                    
                    fracActive = zeros(max(bins),1);
                    for m = 1:max(bins) 
                        onsetsInBin = AP_grad_ON(bins==m,3);
                        fracActive(m) = sum(onsetsInBin>0)/length(onsetsInBin);
                    end
            
                    fracMat(i,j,k,l) = mean(fracActive,'omitnan');
    
                end
            end
        end
    
%         waitbar(i/length(KORange),f)
    end
%     close(f)
    
    toc % record the run time

end