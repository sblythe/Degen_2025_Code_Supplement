function [onsets_all, repTimes] = runSSA_sweeps(bcdData, APdata, mirny, framesPerMin, params, Vmax, hillParams, uniform, rep, Km)
    
    % The stochastic algorithm that this function runs is identical to that
    % in runSSA.m, besides slight differences in variable naming and how
    % the algorithm decides which model to simulate. In this function,
    % there is the option for the OFF-ON transition rate (kon) to be
    % determined by a Michaelis-Menten model (when mirny = 0), or a linear
    % model when line 55 is uncommented. If mirny = 1, kon is determined by
    % a single-nucleosome application of Mirny, 2010 (not discussed in
    % Degen et al.). If mirny = 2, kon is determined by a two-nucleosome
    % application of Mirny, 2010 (the nucleosome-dependent model presented
    % in Degen et al.). Additionally, the algorithm can simulate the
    % influence of DNA replication (when rep = 1) or with no replication
    % delays (when rep = 0). If uniform = 1, the algorithm simulates with a
    % uniform Bicoid concentration across the anterior-posterior axis
    % (rather than modeling the Bicoid gradient).

    % Calculate the Bicoid gradient
    a = 1; Bcd0 = 1; D = 3; tau = 50;
    AP_gradient = createBcdGradient(a, Bcd0, D, tau, APdata);

    if uniform == 1
        AP_gradient = [AP_gradient(:,1) 0.135*ones(size(AP_gradient,1),1)]; % in the case of uniform Bicoid
    end

    % Bicoid dynamics
    bcdOverT_norm = bcdDynamics(bcdData, framesPerMin);

    repTimes = zeros(size(AP_gradient, 1), 1); 

    randomReps = (gamrnd(2,1/params.lambda,1,length(APdata))./params.rate + 3.75).*framesPerMin; 
    choices = randperm(length(APdata));
    for i = 1:size(AP_gradient, 1) % loop through AP positions (nuclei)
 
        if rep == 1
            repIndex = randomReps(choices(i));
            repTimes(i) = repIndex/framesPerMin;
        else
            repIndex = 1; % if you don't want DNA replication
        end

        t = 1; % start at the start of anaphase
        ON = 0; onset = 0; % start in the OFF state
        deltaT = 1; % time increment of 1. Units decided by tScale.
        while t <= (15 * framesPerMin) && onset == 0 % loop through time. Cut off if past 15 min (nuclear membrane breakdown).

            % Calculate the bicoid concentration in nM
            bcd = bcdOverT_norm(t) * AP_gradient(i,2) * 140;

            if mirny == 0 % Zero nucleosomes case

                kon = Vmax * (bcd/Km)/(1 + bcd/Km); % prob one site is occupied

                % Linear relationship
%                 kon = Vmax * bcdOverT_norm(t) * AP_gradient(i,2);

            elseif mirny == 1 % One nucleosome case

                % Bcd occupancy calculated with Mirny
                kon = bcdOccupancy(bcd, params.nuc1.KO, params.nuc1.KN, params.nuc1.L, 9);

                kon = Vmax * kon;
                
            elseif mirny == 2 % Two nucleosome case

                % Bcd occupancy at first nucleosome
                Y1 = bcdOccupancy(bcd, params.nuc1.KO, params.nuc1.KN, params.nuc1.L, params.nuc1.n);

                % Bcd occupancy at second nucleosome
                Y2 = bcdOccupancy(bcd, params.nuc2.KO, params.nuc2.KN, params.nuc2.L, params.nuc2.n);

                kon = Vmax * Y1 * Y2; 

            else % Hill equation (cluster of n binding sites)
              
                kon = Vmax * bcd^hillParams.n/(hillParams.KO^hillParams.n + bcd^hillParams.n);

            end

            % Decide which reaction
            if ON == 0

                tau = exprnd(1/(2*kon*(repIndex <= t) + kon*(repIndex > t)));
                t = t + deltaT;

                if tau < deltaT
                    ON = 1;

                    onset = repIndex*(repIndex >= t) + t*(repIndex < t);

                end

            end

        end

        onsets(i)=onset;

    end

    onsets_all = [AP_gradient onsets']; 


    function bcdOverT_norm = bcdDynamics(binned, tScale)

        % Calculate relative Bicoid concentration trace over time
        bcdOverT = movmean(mean(binned,1,'omitnan'),5);
        bcdOverT_norm_1 = bcdOverT./max(bcdOverT);
    
        % Interpolate bcd(t) measurement so frame rate is desired sample rate
        bcdOverT_norm = spline(1:100, bcdOverT_norm_1, linspace(1, 100, 20*tScale)); % 20 min used in paper 
        bcdOverT_norm = bcdOverT_norm - bcdOverT_norm(1);
        bcdOverT_norm(bcdOverT_norm < 0) = 0;

    end

    function Y = bcdOccupancy(bcd, KO, KN, L, n)
    
        Y = (bcd/KO) * (((1 + (bcd/KO))^(n - 1)) + (L * (KO/KN) * (1 + (KO/KN) * (bcd/KO))^(n - 1)))./(((1 + (bcd/KO))^n) +(L * (1 + (KO/KN) * (bcd/KO))^n));
    
    end

end



