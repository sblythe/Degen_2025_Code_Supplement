clearvars

% Load MS2 summary structures (in ExperimentalData)
load('path to hb_WT_summaries.mat') % for hbP2-MS2 in WT

%% Generate plots of MS2 features 
close all

% Plot onset time distribution (Figure 2C)
onTimeVsAP_final(hb,'\it{hbP2-MS2}');

% Plot loading rate distribution (Figure 2D)
alignedSlopesVsAP_final(hb,'\it{hbP2-MS2}');

% Plot fraction of active nuclei (Figure 2E)
plotMeanFracActive_final(hb,'\it{hbP2-MS2}');

% Plot mean onset times per movie (Supplemental Figure 1)
plotMeanOnsetsByMov(hb,'Onset time');

% Plot mean loading rates per movie (Supplemental Figure 1)
plotMeanSlopesByMov(hb,'Loading rate');

% Plot mean fraction of active nuclei (Supplemental Figure 1)
plotFracActiveForSupplement(hb,'Active nuclei');

% Plot heatmap of fraction of active nuclei measurements (Supplemental Figure 1)
plotFractionActiveHeatmap(hb,'Active nuclei');

