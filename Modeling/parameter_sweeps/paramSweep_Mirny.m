function [nMat, EC50Mat, fMaxMat] = paramSweep_Mirny(KORange, KNRange, LRange, VmaxRange, bcdData, tScale, mirny, seed, rep)

    tic % record the run time

    % General parameters
    params = struct;
    params.origOrig = 9.7;              % mean origin-origin distance (kb)
    params.lambda = 2/params.origOrig;  % origins/kb
    params.rate = 5.3;                  % rate of DNA polymerase (kb/min)
    params.nuc1.n = 5;
    params.nuc2.n = 4;
    
%     f = waitbar(0);
    
    nMat = zeros(length(KORange),length(KNRange),length(LRange),length(VmaxRange));
    EC50Mat = zeros(length(KORange),length(KNRange),length(LRange),length(VmaxRange));
    fMaxMat = zeros(length(KORange),length(KNRange),length(LRange),length(VmaxRange));
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
                    xs = 0:0.0002:1;
                    [AP_grad_ON, ~] = runSSA_sweeps(bcdData, xs, mirny, tScale, params, Vmax, [],[],rep,[]);
                    
                    % Fraction of active nuclei of simulations
                    AP_axis = 0:0.01:1;
                    bins = discretize(AP_grad_ON(:,1),AP_axis); % try with 1% EL bins
                    
                    fracActive = zeros(max(bins),1);
                    for m = 1:max(bins) 
                        onsetsInBin = AP_grad_ON(bins==m,3);
                        fracActive(m) = sum(onsetsInBin>0)/length(onsetsInBin);
                    end
            
                    % Fit a hill equation to the fraction of active nuclei
                    a = 1; Bcd0 = 140; D = 3; tau = 50;
                    AP_gradient = createBcdGradient(a, Bcd0, D, tau, AP_axis(1:end-1));
                    bcd = AP_gradient(:,2);

                    % MAPPING: n = b(1),  EC50 = b(2), fMax = B(3)
                    hill_fit = @(b,x)  (b(3)*(bcd.^b(1)))./(bcd.^b(1)+b(2)^b(1));
                    b0 = [20, 40, 1];  
                    options = optimoptions(@lsqcurvefit,'StepTolerance',1e-10,'MaxFunctionEvaluations',1e6,'MaxIterations', 1e6,'Display','off');
                    B = lsqcurvefit(hill_fit, b0, bcd, fracActive,[0, 0, 0],[100, 140, 1],options);
                    nMat(i,j,k,l) = B(1);
                    EC50Mat(i,j,k,l) = B(2);
                    fMaxMat(i,j,k,l) = B(3);
    
                end
            end
        end
    
%         waitbar(i/length(KORange),f)
    end
%     close(f)
    
    toc % record the run time

end
