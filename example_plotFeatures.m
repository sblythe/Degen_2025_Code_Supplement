
clearvars

% Load MS2 summary structures
load('/Users/eleanordegen/Documents/MATLAB/P2_paper_code/ExperimentalData/hb_WT_summaries.mat')

%% Generate plots of MS2 features (Figure 2)
close all

% Calculate and plot onset time distribution (full)
onTimeVsAP_final(hb,'hbP2 MS2');

% Calculate and plot loading rate distribution (full)
alignedSlopesVsAP_final(hb,'hbP2 MS2');

% Calculate and plot fraction of active nuclei
plotMeanFracActive_final(hb,'hbP2 MS2');

% Plot mean onset times per movie
plotMeanOnsetsByMov(hb,'hbP2 MS2');