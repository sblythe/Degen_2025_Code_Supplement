function [onsets_all, repTimes, steps, setByRep] = runSSA(bcdData, APdata, model, params, rep)

    % This function runs the stochastic simulation described in the
    % Modeling Supplement of Degen et al. It generates a list of onset
    % times (second column of onsets_all) for specified AP positions 
    % (APdata and first column of onsets_all) given measurements of Bicoid 
    % concentration dynamics (bcdData). You can specify whether kon will be 
    % defined according to the open chromatin linear model (model = 0), the 
    % open chromatin Michaelis Menten model (model = 1), the open chromatin 
    % Hill model (model = 2), or the nucleosome-dependent model (model = 3). 
    % Additionally, you can choose whether to incorporate the influence of 
    % DNA replication into the simulation (rep = 1 for replication delays, 
    % rep = 0 for no replication delays).

    % Calculate the Bicoid gradient
    a = 1; Bcd0 = 1; D = 3; tau = 50;
    AP_gradient = createBcdGradient(a, Bcd0, D, tau, APdata);

    % Bicoid dynamics
    bcdOverT_norm = bcdDynamics(bcdData, params.framesPerMin);

    % Variable to record the replication delays
    repTimes = zeros(size(AP_gradient, 1), 1); steps = []; setByRep = [];

    % Determine the replication delay for each nucleus (draw from gamma)
    randomReps = (gamrnd(2,1/params.lambda,1,length(APdata))./params.rate + 3.75).*params.framesPerMin;
    choices = randperm(length(APdata));

    % Simulate each nucleus over time
    for i = 1:size(AP_gradient, 1) % Loop through AP positions (nuclei)
 
        % Choose the replication delay for the nucleus
        repIndex = randomReps(choices(i));
        repTimes(i) = repIndex/params.framesPerMin;

        % If you don't want DNA replication, specify replication has occured at the first time step
        if rep == 0
            repIndex = 1; 
        end

        t = 1; % Start at the start of anaphase
        ON = 0; onset = 0; % Start in the OFF state
        deltaT = 1; % Time increment in frames
        while t <= (15 * params.framesPerMin) && onset == 0 % Loop through time prior to nuclear membrane breakdown

            % Calculate the bicoid concentration in nM
            bcd = bcdOverT_norm(t) * AP_gradient(i,2) * 140;

            % Calculate the OFF-ON transition rate kon
            if model == 0 % Zero nucleosomes, linear model

                kon = params.Vmax * bcdOverT_norm(t) * AP_gradient(i,2);

            elseif model == 1 % Zero nucleosomes, Michaelis-Menten model

                kon = params.Vmax * (bcd/params.Km)/(1 + bcd/params.Km); 

            elseif model == 2 % Zero nucleosomes, Hill model

                kon = params.Vmax * bcd^params.Hill_n/(params.Hill_EC50^params.Hill_n + bcd^params.Hill_n);
                
            elseif model == 3 % Two-nucleosome application of Mirny

                % Bcd occupancy at first nucleosome
                Y1 = bcdOccupancy(bcd, params.nuc1.KO, params.nuc1.KN, params.nuc1.L, params.nuc1.n);

                % Bcd occupancy at second nucleosome
                Y2 = bcdOccupancy(bcd, params.nuc2.KO, params.nuc2.KN, params.nuc2.L, params.nuc2.n);

                kon = params.Vmax * Y1 * Y2; 

            end

            % Decide which reaction
            if ON == 0

                tau = exprnd(1/(2*kon*(repIndex<=t) +  kon*(repIndex>t))); % Waiting time until transition to ON

                t = t + deltaT; % Increment time

                % Did the transition happen within the time step?
                if tau < deltaT

                    ON = 1; % Transition to the ON state

                    % Rrecord what set the timing of the transition
                    if repIndex >= t 

                        onset = repIndex; 
                        setByRep = [setByRep; [0 0 1]]; % Blue: onset set by replication delay
                        
                    else

                        onset = t;
                        setByRep = [setByRep; [1 0 0]]; % Red: onset set by Bicoid

                    end
                    
                end

            end

        end

        onsets(i) = onset; % Record the onset time

    end

    onsets_all = [AP_gradient onsets']; 

    % Supporting function: create vector of Bicoid concentrations for modeling
    function bcdOverT_norm = bcdDynamics(binned, tScale)

        % Calculate relative Bicoid concentration trace over time
        bcdOverT = movmean(mean(binned,1),5,'omitnan');
        bcdOverT_norm_1 = bcdOverT./max(bcdOverT);
    
        % Interpolate bcd(t) measurement so frame rate is desired sample rate
        bcdOverT_norm = spline(1:100, bcdOverT_norm_1, linspace(1, 100, 20*tScale)); % using a 20-min nuclear cycle
        bcdOverT_norm = bcdOverT_norm - bcdOverT_norm(1);
        bcdOverT_norm(bcdOverT_norm < 0) = 0;

    end

    % Supporting function: calculate fractional Bicoid occupancy according to Mirny, 2010
    function Y = bcdOccupancy(bcd, KO, KN, L, n)

        Y = (bcd/KO) * (((1 + (bcd/KO))^(n - 1)) + (L * (KO/KN) * (1 + (KO/KN) * (bcd/KO))^(n - 1)))./(((1 + (bcd/KO))^n) +(L * (1 + (KO/KN) * (bcd/KO))^n));

    end

end