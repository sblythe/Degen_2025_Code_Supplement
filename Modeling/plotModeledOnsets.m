%% Load datasets
clearvars
close all

% EGFP-Bicoid measurements for modeling
load('path to bcdGFP_norm.mat');
binned = normTrace;

%% Run and plot a simulation

% SPECIFY THE MODEL TO SIMULATE--------------------------------------------
model = 3; % model = 0 (linear), 1 (Michaelis-Menten), 2 (Hill), 3 (nucleosome-dependent)
DNArep = 1; % DNArep = 0 (no replication delays) or 1 (replication delays)


% DEFINE SIMULATION CONDITIONS---------------------------------------------

% General parameters
params = struct;
params.origOrig = 9.7;              % Mean origin-origin distance (kb)
params.lambda = 2/params.origOrig;  % Origins/kb
params.rate = 5.3;                  % Rate of DNA polymerase (kb/min)
params.framesPerMin = 6;            % Frames per minute
params.Vmax = 1;                    % Maximum OFF-ON transition rate (transitions/frame)

% Parameters in the two-nucleosome model
params.nuc1.KO = 9;                 % Dissociation constant of Bicoid associating with open state (nM)
params.nuc1.KN = 2810;              % Dissociation constant of Bicoid associating with nucleosomal state (nM)
params.nuc1.L = 600;                % Nucleosome stability
params.nuc1.n = 5;                  % Number of Bicoid binding sites at nucleosome 1
params.nuc2.KO = params.nuc1.KO; 
params.nuc2.KN = params.nuc1.KN; 
params.nuc2.L = params.nuc1.L; 
params.nuc2.n = 4;                  % Number of Bicoid binding sites at nucleosome 2

% Parameters in the Hill model
params.Hill_n = 9;
params.Hill_EC50 = 16.7;

% Parameter in the Michaelis-Menten model
params.Km = 16.7;

% AP positions to simulate over
xs = 0:0.0005:1; % We want 20 nuclei per 1% AP to match the hb data

% Random seed
rng(507) % 507 used for the figues in Degen et al.

% RUN THE SIMULATION ALGORITHM---------------------------------------------
[AP_grad_onsets, repTimes, steps, setByRep] = runSSA(binned, xs, model, params, DNArep);


% PLOT THE MODELED ONSETS--------------------------------------------------

% For future plotting, set zero onsets to NAN
onsets = AP_grad_onsets(:,3);
onsets(onsets==0) = nan;
AP_all = AP_grad_onsets(:,1);
AP_all(onsets==0) = nan;
onsets_nonzero = onsets(onsets>0);
APs_nonzero = AP_all(onsets>0);

% Determine the 95% CI border AP position to use for future plotting
AP_bins = 0.15:0.01:0.85;
Y = discretize(APs_nonzero,AP_bins);
onsets_bool = onsets_nonzero>0;
spot_positions = [];
for i = 1:length(AP_bins)
    spot_positions = [spot_positions; AP_bins(i).*ones(sum(onsets_bool(Y==i)),1)];
end
borderAP = mean(spot_positions)+1.96*std(spot_positions); 

% Rolling averages for plotting
slideAvg = movmean(onsets_nonzero(APs_nonzero<=borderAP),50)./params.framesPerMin;
slideSD = movstd(onsets_nonzero(APs_nonzero<=borderAP),50)./params.framesPerMin;
plotAP = APs_nonzero(APs_nonzero<=borderAP);

% Plot onsets overlaid with rolling average/SD
f(1) = figure;
p = scatter(APs_nonzero.*100, onsets_nonzero./params.framesPerMin, 5,[0 0 0],'o','filled'); % plot the points
alpha(p,0.1)
hold on;
shadedErrorBar(plotAP*100, slideAvg, slideSD, [0.7 0 0],1,0.4) 
ylabel('Simulated Onset Time (min)','fontsize',8)
xlabel('AP Position (%)','fontsize',8)

% Decide how to title the plot
if model == 0
    title('Open chromatin linear model','fontsize',8)
elseif model == 1
    title('Open chromatin MM model','fontsize',8)
elseif model == 2
    title('Open chromatin Hill model','fontsize',8)
elseif model == 3 || model == 4
    title('KO = '+string(params.nuc1.KO)+', KN = '+string(params.nuc1.KN)+', L = '+string(params.nuc1.L),'fontsize',8)
end

xlim([20 80])
xticks(20:10:80)
xticklabels(20:10:80)
ylim([0 15])
ax = gca;
ax.Box='off';
ax.XAxis.FontSize = 7; % 7 pt font for tick labels
ax.YAxis.FontSize = 7;
ax.LineWidth = 0.5;
set(f(1),'units','centimeters','position',[34.5017 26.1761 5 4.5])

% Plot whether onsets were determined by DNA replication or [Bicoid]
f(2) = figure;
scatter(nan,nan,5,[0 0 1],'o','filled')
hold on
scatter(nan,nan,5,[1 0 0],'o','filled')
p(1) = scatter(AP_all(~isnan(onsets))*100, onsets(~isnan(onsets))./params.framesPerMin, 5, setByRep, 'o', 'filled');
hold on;
p(2) = scatter(nan,nan,5,[0,0,1],'o','filled');
alpha(p,0.5)
ylabel('Onset Time (min)','fontsize',8)
xlabel('AP Position (%)','fontsize',8)
title('Modeled transition dependence','fontsize',8) % CHANGE
xlim([20 80])
xticks(20:10:80)
xticklabels(20:10:80)
ylim([0 15])
l = legend({'Replication-limited','[Bicoid]-limited'});
l.Box = 'off';
l.Position = [0.3447 0.1889 0.6444 0.1535];
l.FontSize = 6;
l.ItemTokenSize(1) = 7;
ax = gca;
ax.Box='off';
ax.XAxis.FontSize = 7; % 7 pt font for tick labels
ax.YAxis.FontSize = 7;
ax.LineWidth = 0.5;
set(f(2),'units','centimeters','position',[40.6400 26.2467 5 4.5])
