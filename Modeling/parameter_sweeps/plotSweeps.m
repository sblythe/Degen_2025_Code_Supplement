
%% Heatmaps of the good param combinations
close all
clearvars

% load('/Volumes/BlytheLab_Files/Imaging/Ellie/MS2_Analysis_new/modeling/ForPaper/23-Aug-2024 04:38:07_twoNucs/sweepVariables.mat') % For the paper. With rep. Vmax = 1;

% load('/Volumes/BlytheLab_Files/Imaging/Ellie/MS2_Analysis_new/modeling/ForPaper/24-Nov-2024 23:09:01_twoNucs_Vmax1_noRep/sweepVariables.mat') % For the paper. No rep. Vmax = 1

% load('/Volumes/BlytheLab_Files/Imaging/Ellie/MS2_Analysis_new/modeling/ForPaper/04-Nov-2024 14:54:42_twoNucs/sweepVariables.mat') % for nuc stability part of paper. With Rep

% load('/Volumes/BlytheLab_Files/Imaging/Ellie/MS2_Analysis_new/modeling/ForPaper/18-Nov-2024 23:27:50_twoNucs_Vmax0.01/sweepVariables.mat') % For the paper. With rep. Vmax = 0.01;

load('/Volumes/BlytheLab_Files/Imaging/Ellie/MS2_Analysis_new/modeling/ForPaper/21-Nov-2024 06:01:25_twoNucs_Vmax0.5_2.5_4/sweepVariables.mat') % For the paper. With rep. Vmax = 0.5, 2.5, 4


% Split into different Vmax seeps
choice = 1; % decide which Vmax to plot
nMats2 = cell(size(nMats));
EC50Mats2 = cell(size(EC50Mats));
for i = 1:length(nMats)
    nMat = nMats{i};
    nMats2{i} = nMat(:,:,:,choice);
    EC50Mat = EC50Mats{i};
    EC50Mats2{i} = EC50Mat(:,:,:,choice);
end

% Create matrices for plotting

% Find mean of the replicates
nCombo = zeros(size(nMats2{1},1),size(nMats2{1},2),size(nMats2{1},3),length(nMats2));
EC50Combo_nM = zeros(size(EC50Mats2{1},1),size(EC50Mats2{1},2),size(EC50Mats2{1},3),length(EC50Mats2));

for i = 1:4
    nCombo(:,:,:,i) = nMats2{i};
    EC50Combo_nM(:,:,:,i) = EC50Mats2{i};
end

nMat = mean(nCombo,4,'omitnan');
EC50Mat_nM = mean(EC50Combo_nM,4,'omitnan');

% Convert EC50Mat from nM to x/AP
a = 1; Bcd0 = 140; D = 3; tau = 50;
APs = 0:0.01:1;
AP_gradient = createBcdGradient(a, Bcd0, D, tau, APs);

EC50Mat = zeros(size(EC50Mat_nM));
for i = 1:numel(EC50Mat)
   
    [d, ix] = min(abs(AP_gradient(:,2) - EC50Mat_nM(i)));
    EC50Mat(i) = AP_gradient(ix,1);
  
end

% Plot heatmaps of parameter sweep results 

EC50Mat = EC50Mat(:,:,1:10);
nMat = nMat(:,:,1:10);

close all
% params from 5/17/24 sweep
ParamRange1 = KORange; % KO (length 30)
ParamRange2 = KNRange; % KN (length 20)
ParamRange3 = LRange(1:10); % L (length 10)

% Tolerances for plotting
nGoal = 8; 
nTol = 0.05;
nMax = nGoal + nTol * nGoal; 
nMin = nGoal - nTol * nGoal;

EC50Goal = 0.4; 
EC50Tol = 0.05;
EC50Max = EC50Goal + EC50Tol * EC50Goal; 
EC50Min = EC50Goal - EC50Tol * EC50Goal;

LValMat = zeros(size(nMat,1), size(nMat,2), size(nMat,3));
for i = 1:size(nMat,1)
    for j = 1:size(nMat,2)
        for k = 1:size(nMat,3)
            LValMat(i,j,k) = ParamRange3(k);
        end
    end
end

% Custom colormap
colorMap = [[1 1 1];linspace(0,0,length(ParamRange3))' linspace(1, 0.5,length(ParamRange3))' linspace(1, 0.5,length(ParamRange3))'];

% Hill coefficient --------------------------------------------------------

f = figure;

goodNs = nMat < nMax & nMat > nMin;
ind = find(goodNs);
plotMat1 = nan(length(ParamRange1),length(ParamRange2),length(ParamRange3));
plotMat1(ind) = LValMat(ind);

imagesc(mean(plotMat1,3,'omitnan'))
colormap(colorMap)
ylabel('KO (nM)','fontsize',8)
xlabel('KN (nM)','fontsize',8)
ylim([0.5 length(ParamRange1)])
yticks(1:4:length(ParamRange1))
yticklabels(ParamRange1(1:4:end))
xlim([1 length(ParamRange2)])
xticks(1:2:length(ParamRange2))
xticklabels(ParamRange2(1:2:end))
title('Modeled steepness in [' + string(nMin) + ', ' + string(nMax) + ']','fontsize',8)
c = colorbar;
c.Ticks = 0:200:1000;
numLabels = arrayfun(@num2str, 200:200:1000, 'UniformOutput', 0);
c.TickLabels = [{'NAN'} numLabels]';
caxis([0 1000])
c.FontSize = 7;
ax = gca;
ax.Box='off';
ax.XAxis.FontSize = 7; % 7 pt font for tick labels
ax.YAxis.FontSize = 7;
ax.LineWidth = 0.5;
set(f,'units','centimeters','position',[50,25,5.85,4.5])

% Option to save the image (specify file path)
% exportgraphics(f,'path to image','Resolution',300,'BackgroundColor','white')


% EC50 --------------------------------------------------------------------

f = figure;
goodEC50s = EC50Mat<EC50Max & EC50Mat>EC50Min;
ind = find(goodEC50s);
plotMat2 = nan(length(ParamRange1),length(ParamRange2),length(ParamRange3));
plotMat2(ind) = LValMat(ind);

imagesc(mean(plotMat2,3,'omitnan'))
colormap(colorMap)
ylabel('KO (nM)','fontsize',8)
xlabel('KN (nM)','fontsize',8)
ylim([0.5 length(ParamRange1)])
yticks(1:4:length(ParamRange1))
yticklabels(ParamRange1(1:4:end))
xlim([1 length(ParamRange2)])
xticks(1:2:length(ParamRange2))
xticklabels(ParamRange2(1:2:end))
title('Modeled position in [' + string(EC50Min) + ', ' + string(EC50Max) + ']','fontsize',8)
c = colorbar;
c.Ticks = 0:200:1000;
numLabels = arrayfun(@num2str, 200:200:1000, 'UniformOutput', 0);
c.TickLabels = [{'NAN'} numLabels]';
caxis([0 1000])
c.FontSize = 7;
ax = gca;
ax.Box='off';
ax.XAxis.FontSize = 7; % 7 pt font for tick labels
ax.YAxis.FontSize = 7;
ax.LineWidth = 0.5;
set(f,'units','centimeters','position',[50,25,5.85,4.5])

% Option to save the image (specify file path)
% exportgraphics(f,'path to image','Resolution',300,'BackgroundColor','white')

% Combined ----------------------------------------------------------------

% figure
f = figure;

overlap = plotMat1 == plotMat2;
plotMat3 = nan(size(plotMat1));
ind = find(overlap);
plotMat3(ind) = plotMat1(ind);

imagesc(median(plotMat3,3,'omitnan'))
colormap(colorMap)
ylabel('KO (nM)','fontsize',8)
xlabel('KN (nM)','fontsize',8)
ylim([0.5 length(ParamRange1)])
yticks(1:4:length(ParamRange1))
yticklabels(ParamRange1(1:4:end))
xlim([1 length(ParamRange2)])
xticks(1:2:length(ParamRange2))
xticklabels(ParamRange2(1:2:end))
title('Steepness & position in range','fontsize',8)
c = colorbar;
c.Ticks = 0:200:1000;
numLabels = arrayfun(@num2str, 200:200:1000, 'UniformOutput', 0);
c.TickLabels = [{'NAN'} numLabels]';
caxis([0 1000])
c.FontSize = 7;
ax = gca;
ax.Box='off';
ax.XAxis.FontSize = 7; % 7 pt font for tick labels
ax.YAxis.FontSize = 7;
ax.LineWidth = 0.5;
set(f,'units','centimeters','position',[50,25,5.85,4.5])

% Option to save the image (specify file path)
% exportgraphics(f,'path to image','Resolution',300,'BackgroundColor','white')


% What are the winning parameter combinations?
ind = find(~isnan(plotMat3));
[i1, i2, i3] = ind2sub(size(plotMat3), ind);

devCoeff = abs(nMat(ind)-nGoal)/nGoal;
devEC50 = abs(EC50Mat(ind)-EC50Goal)/EC50Goal; 
goodList = [ParamRange1(i1)' ParamRange2(i2)' ParamRange3(i3)' devCoeff devEC50 devCoeff+devEC50];
goodSorted = sortrows(goodList,5,'ascend');

%% What can we show about the good params? Plot histograms of good two nuc

f = figure;
b1 = boxplot(goodSorted(:,1),'Widths',0.3,'Color',[0 0.4470 0.7410]);
set(b1,'linewidth',1.5);
ylabel('KO (nM)','fontsize',8)
title('placeholder','fontsize',8)
ylim([min(KORange) max(KORange)])
% yticks(6:11)
xticks([])
ax = gca;
ax.Box='off';
ax.XAxis.FontSize = 7; % 7 pt font for tick labels
ax.YAxis.FontSize = 7;
ax.LineWidth = 0.5;
set(f,'units','centimeters','position',[50,25,5,4.5])

% Option to save the image (specify file path)
% exportgraphics(f,'path to image','Resolution',300,'BackgroundColor','white')

f = figure;
b2 = boxplot(goodSorted(:,2),'Widths',0.3,'Color',[0.6350 0.0780 0.1840]);
set(b2,'linewidth',1.5);
ylabel('KN (nM)','fontsize',8)
title('placeholder','fontsize',8)
ylim([min(KNRange) max(KNRange)])
% yticks(0:400:1910)
xticks([])
ax = gca;
ax.Box='off';
ax.XAxis.FontSize = 7; % 7 pt font for tick labels
ax.YAxis.FontSize = 7;
ax.LineWidth = 0.5;
set(f,'units','centimeters','position',[50,25,5,4.5]);

% Option to save the image (specify file path)
% exportgraphics(f,'path to image','Resolution',300,'BackgroundColor','white')

f = figure;
ratio = goodSorted(:,1)./goodSorted(:,2);
b3 = boxplot(log10(ratio),'Widths',0.3,'Color',[0.4940 0.1840 0.5560]);
set(b3,'linewidth',1.5);
ylabel('log10( KO/KN )','fontsize',8)
title('placeholder','fontsize',8)
ratioMax = max(KORange)/min(KNRange);
ratioMin = min(KORange)/max(KNRange);
ylim([log10(ratioMin) log10(ratioMax)])
% yticks(-3.2810:-1)
xticks([])
ax = gca;
ax.Box='off';
ax.XAxis.FontSize = 7; % 7 pt font for tick labels
ax.YAxis.FontSize = 7;
ax.LineWidth = 0.5;
set(f,'units','centimeters','position',[50,25,5,4.5])
yline(-1,'--')
yline(-3,'--')

% Option to save the image (specify file path)
% exportgraphics(f,'path to image','Resolution',300,'BackgroundColor','white')

f = figure;
b4 = boxplot(goodSorted(:,3),'Widths',0.3,'Color',[0.4660 0.6740 0.1880]);
set(b4,'linewidth',1.5)
ylabel('L','fontsize',8)
title('placeholder','fontsize',8)
ylim([100 1000])
% yticks(100:200:1000)
xticks([])
ax = gca;
ax.Box='off';
ax.XAxis.FontSize = 7; % 7 pt font for tick labels
ax.YAxis.FontSize = 7;
ax.LineWidth = 0.5;
set(f,'units','centimeters','position',[50,25,5,4.5])

% Option to save the image (specify file path)
% exportgraphics(f,'path to image','Resolution',300,'BackgroundColor','white')


%% How many Ls per good KO/KN combination?
cmap = parula(4);

LCount = sum(~isnan(plotMat1),3);
f = figure;

subplot(1,3,1)
imagesc(LCount)
colormap(cmap) % specify colormap for the subplots
ylabel('KO (nM)')
xlabel('KN (nM)')
ax = gca;
ylim([0.5 length(ParamRange1)])
yticks(1:2:length(ParamRange1))
yticklabels(ParamRange1(1:2:end))
xlim([1 length(ParamRange2)])
xticks(1:2:length(ParamRange2))
xticklabels(ParamRange2(1:2:end))
title('Modeled Hill Coeff in [' + string(nMin) + ', ' + string(nMax) + ']')
ax.FontSize = 14;
c = colorbar;
caxis([0 3])
c.Ticks = 0:3;
c.Title.String = 'L Count';
c.Title.Position = [35,124.41,0];
c.Title.Rotation = -90;
c.Title.FontSize = 14;

subplot(1,3,2)
LCount = sum(~isnan(plotMat2),3);
imagesc(LCount)
ylabel('KO (nM)')
xlabel('KN (nM)')
ax = gca;
ylim([0.5 length(ParamRange1)])
yticks(1:2:length(ParamRange1))
yticklabels(ParamRange1(1:2:end))
xlim([1 length(ParamRange2)])
xticks(1:2:length(ParamRange2))
xticklabels(ParamRange2(1:2:end))
title('Modeled EC50 in [' + string(EC50Min) + ', ' + string(EC50Max) + ']')
ax.FontSize = 14;
c = colorbar;
caxis([0 3])
c.Ticks = 0:3;
c.Title.String = 'L Count';
c.Title.Position = [35,124.41,0];
c.Title.Rotation = -90;
c.Title.FontSize = 14;

subplot(1,3,3)
LCount = sum(overlap,3);
imagesc(LCount)
ylabel('KO (nM)')
xlabel('KN (nM)')
ax = gca;
ylim([0.5 length(ParamRange1)])
yticks(1:2:length(ParamRange1))
yticklabels(ParamRange1(1:2:end))
xlim([1 length(ParamRange2)])
xticks(1:2:length(ParamRange2))
xticklabels(ParamRange2(1:2:end))
title('Hill coefficient & EC50 in range')
ax.FontSize = 14;
c = colorbar;
caxis([0 3])
c.Ticks = 0:3;
c.Title.String = 'L Count';
c.Title.Position = [35,124.41,0];
c.Title.Rotation = -90;
c.Title.FontSize = 14;

f.Position = [500 800 1400 320];

%% Hill function param sweep results
clearvars
close all

load('/Volumes/BlytheLab_Files/Imaging/Ellie/MS2_Analysis_new/modeling/ForPaper/28-Oct-2024 16:38:46_Hill/sweepVariables.mat') % used in paper

% Find mean of the replicates
nCombo = zeros(size(nMats{1},1),size(nMats{1},2),size(nMats{1},3),length(nMats));
EC50Combo_nM = zeros(size(EC50Mats{1},1),size(EC50Mats{1},2),size(EC50Mats{1},3),length(EC50Mats));

for i = 1:length(nMats)
    nCombo(:,:,:,i) = nMats{i};
    EC50Combo_nM(:,:,:,i) = EC50Mats{i};
end

nMat = mean(nCombo,4,'omitnan');
EC50Mat_nM = mean(EC50Combo_nM,4,'omitnan');

% Convert EC50Mat from nM to x/AP
a = 1; Bcd0 = 140; D = 3; tau = 50;
APs = 0:0.01:1;
AP_gradient = createBcdGradient(a, Bcd0, D, tau, APs);

EC50Mat = zeros(size(EC50Mat_nM));
for i = 1:numel(EC50Mat)
   
    [d, ix] = min(abs(AP_gradient(:,2) - EC50Mat_nM(i)));
    EC50Mat(i) = AP_gradient(ix,1);
  
end

ParamRange1 = KORange; % KO (length 11)
ParamRange2 = n_HillRange; % nHill (length 6)
ParamRange3 = VmaxRange; % Vmax (length 10)

f(1) = figure;
positionForPlotting = abs(EC50Mat - 0.4);
imagesc(positionForPlotting(:,:,end))
cmap = flip(colormap(bone),1);
colormap(cmap);
c = colorbar;
c.FontSize = 7;
c.Ticks = [0 0.1 0.2 0.3 0.4 0.5 0.6];
c.TickLabels = [{'0'},{'0.1'},{'0.2'},{'0.3'},{'0.4'},{'0.5'},{'\geq0.6'}];
clim([0 0.6]);
xlabel('Hill coefficient','fontsize',8)
ylabel('EC50 (nM)','fontsize',8)
title('placeholder','fontsize',8)
ylim([1 length(KORange)])
yticks(1:4:length(KORange))
yticklabels(KORange(1:4:end))
xticks(1:10)
xticklabels(n_HillRange)
ylabel(c,'|0.4 - modeled position|','fontsize',8)
ax = gca;
ax.Box='off';
ax.XAxis.FontSize = 7; % 7 pt font for tick labels
ax.YAxis.FontSize = 7;
ax.LineWidth = 0.5;
set(f(1),'units','centimeters','position',[50,25,5.85,4.5])

% Option to save the image (specify file path)
% exportgraphics(f,'path to image','Resolution',300,'BackgroundColor','white')

f(2) = figure;
steepnessForPlotting = abs(nMat - 8);
imagesc(steepnessForPlotting(:,:,end))
cmap = flip(colormap(bone),1);
colormap(cmap);
c = colorbar;
c.FontSize = 7;
c.Ticks = 0:8;
c.TickLabels = [{'0'},{'1'},{'2'},{'3'},{'4'},{'5'},{'6'},{'7'},{'\geq8'}];

clim([0 8]);
xlabel('Hill coefficient','fontsize',8)
ylabel('EC50 (nM)','fontsize',8)
title('placeholder','fontsize',8)
ylim([1 length(KORange)])
yticks(1:4:length(KORange))
yticklabels(KORange(1:4:end))
xticks(1:10)
xticklabels(n_HillRange)
ylabel(c,'|8 - modeled steepness|','fontsize',8)
ax = gca;
ax.Box='off';
ax.XAxis.FontSize = 7; % 7 pt font for tick labels
ax.YAxis.FontSize = 7;
ax.LineWidth = 0.5;
set(f(2),'units','centimeters','position',[50,25,5.85,4.5])

% Option to save the image (specify file path)
% exportgraphics(f,'path to image','Resolution',300,'BackgroundColor','white')

f(3) = figure;
closeToPosition = positionForPlotting<=0.04; % allowing 10% deviation
closeToSteepness = steepnessForPlotting<=0.8; % allowing 10% deviation
bothGood = closeToPosition & closeToSteepness;
imagesc(bothGood)
colormap([[201, 179, 177]./255; 1 1 1])
xlabel('Hill coefficient','fontsize',8)
ylabel('EC50 (nM)','fontsize',8)
title('placeholder','fontsize',8)
ylim([1 length(KORange)])
yticks(1:4:length(KORange))
yticklabels(KORange(1:4:end))
xticks(1:10)
xticklabels(n_HillRange)
ax = gca;
ax.Box='off';
ax.XAxis.FontSize = 7; % 7 pt font for tick labels
ax.YAxis.FontSize = 7;
ax.LineWidth = 0.5;
set(f(3),'units','centimeters','position',[50,25,5,4.5])

% Option to save the image (specify file path)
% exportgraphics(f,'path to image','Resolution',300,'BackgroundColor','white')

f(4) = figure;
closeToPosition = positionForPlotting<=0.02; % allowing 5% deviation
closeToSteepness = steepnessForPlotting<=0.4; % allowing 5% deviation
bothGood = closeToPosition & closeToSteepness;
imagesc(bothGood)
colormap([[201, 179, 177]./255; 1 1 1])
xlabel('Hill coefficient','fontsize',8)
ylabel('EC50 (nM)','fontsize',8)
title('placeholder','fontsize',8)
ylim([1 length(KORange)])
yticks(1:4:length(KORange))
yticklabels(KORange(1:4:end))
xticks(1:10)
xticklabels(n_HillRange)
ax = gca;
ax.Box='off';
ax.XAxis.FontSize = 7; % 7 pt font for tick labels
ax.YAxis.FontSize = 7;
ax.LineWidth = 0.5;
set(f(4),'units','centimeters','position',[50,25,5,4.5])

% Option to save the image (specify file path)
% exportgraphics(f,'path to image','Resolution',300,'BackgroundColor','white')

%% Open chromatin param sweep results - linear
clearvars
close all
load('/Volumes/BlytheLab_Files/Imaging/Ellie/MS2_Analysis_new/modeling/ForPaper/18-Nov-2024 15:17:12_noNucs_linear/sweepVariables.mat')

% Find mean of the replicates
nCombo = zeros(size(nMats{1},1),size(nMats{1},2),size(nMats{1},3),length(nMats));
EC50Combo_nM = zeros(size(EC50Mats{1},1),size(EC50Mats{1},2),size(EC50Mats{1},3),length(EC50Mats));

for i = 1:length(nMats)
    nCombo(:,:,:,i) = nMats{i};
    EC50Combo_nM(:,:,:,i) = EC50Mats{i};
end

nMat = mean(nCombo,4,'omitnan');
EC50Mat_nM = mean(EC50Combo_nM,4,'omitnan');

% Convert EC50Mat from nM to x/AP
a = 1; Bcd0 = 140; D = 3; tau = 50;
APs = 0:0.01:1;
AP_gradient = createBcdGradient(a, Bcd0, D, tau, APs);

EC50Mat = zeros(size(EC50Mat_nM));
for i = 1:numel(EC50Mat)
   
    [d, ix] = min(abs(AP_gradient(:,2) - EC50Mat_nM(i)));
    EC50Mat(i) = AP_gradient(ix,1);
  
end

f = figure;
plot(VmaxRange, EC50Mat,'linewidth',1.5)
% xticks(VmaxRange(1:end))
yline(0.4,'--','linewidth',1.5)
ylim([0 1.05])
xlabel('V_m_a_x')
ylabel('Boundary position (x/L)')
title('Open model (linear)','fontsize',8)
ax = gca;
ax.Box='off';
ax.XAxis.FontSize = 7; % 7 pt font for tick labels
ax.YAxis.FontSize = 7;
ax.LineWidth = 0.5;
set(f,'units','centimeters','position',[50,25,5,4.5])

% Option to save the image (specify file path)
% exportgraphics(f,'path to image','Resolution',300,'BackgroundColor','white')

f = figure;
plot(VmaxRange, nMat, 'linewidth',1.5)
% xticks(VmaxRange(1:end))
yline(8,'--','linewidth',1.5)
ylim([0 9])
xlabel('V_m_a_x')
ylabel('Boundary steepness (AU)')
title('Open model (linear)','fontsize',8)
ax = gca;
ax.Box='off';
ax.XAxis.FontSize = 7; % 7 pt font for tick labels
ax.YAxis.FontSize = 7;
ax.LineWidth = 0.5;
set(f,'units','centimeters','position',[50,25,5,4.5])

% Option to save the image (specify file path)
% exportgraphics(f,'path to image','Resolution',300,'BackgroundColor','white')

%% Open chromatin param sweep results - Michaelis Menten
clearvars
close all
load('/Volumes/BlytheLab_Files/Imaging/Ellie/MS2_Analysis_new/modeling/ForPaper/18-Nov-2024 16:10:17_noNucs_MM/sweepVariables.mat')

% Find mean of the replicates
nCombo = zeros(size(nMats{1},1),size(nMats{1},2),size(nMats{1},3),length(nMats));
EC50Combo_nM = zeros(size(EC50Mats{1},1),size(EC50Mats{1},2),size(EC50Mats{1},3),length(EC50Mats));

for i = 1:length(nMats)
    nCombo(:,:,:,i) = nMats{i};
    EC50Combo_nM(:,:,:,i) = EC50Mats{i};
end

nMat = mean(nCombo,4,'omitnan');
EC50Mat_nM = mean(EC50Combo_nM,4,'omitnan');

% Convert EC50Mat from nM to x/AP
a = 1; Bcd0 = 140; D = 3; tau = 50;
APs = 0:0.01:1;
AP_gradient = createBcdGradient(a, Bcd0, D, tau, APs);

EC50Mat = zeros(size(EC50Mat_nM));
for i = 1:numel(EC50Mat)
   
    [d, ix] = min(abs(AP_gradient(:,2) - EC50Mat_nM(i)));
    EC50Mat(i) = AP_gradient(ix,1);
  
end

f(1) = figure;
positionForPlotting = abs(EC50Mat(1:50,2:end) - 0.4);
imagesc(positionForPlotting(:,:,end))
cmap = flip(colormap(bone),1);
colormap(cmap);
c = colorbar;
c.FontSize = 7;
c.Ticks = [0 0.1 0.2 0.3 0.4 0.5 0.6];
c.TickLabels = [{'0'},{'0.1'},{'0.2'},{'0.3'},{'0.4'},{'0.5'},{'\geq0.6'}];
clim([0 0.6]);
xlabel('K_m (nM)','fontsize',8)
ylabel('V_m_a_x','fontsize',8)
title('placeholder','fontsize',8)
ylim([1 length(VmaxRange(1:30))])
yticks(1:5:length(VmaxRange(1:30)))
yticklabels(VmaxRange(1:5:30))
xticks(1:2:15)
xticklabels(KmRange(2:2:15))
ylabel(c,'|0.4 - modeled position|','fontsize',8)
ax = gca;
ax.Box='off';
ax.XAxis.FontSize = 7; % 7 pt font for tick labels
ax.YAxis.FontSize = 7;
ax.LineWidth = 0.5;
set(f(1),'units','centimeters','position',[50,25,5.85,4.5])

% Option to save the image (specify file path)
% exportgraphics(f,'path to image','Resolution',300,'BackgroundColor','white')

f(2) = figure;
steepnessForPlotting = abs(nMat(1:50,2:end) - 8);
imagesc(steepnessForPlotting(:,:,end))
cmap = flip(colormap(bone),1);
colormap(cmap);
c = colorbar;
c.FontSize = 7;
c.Ticks = 0:8;
c.TickLabels = [{'0'},{'1'},{'2'},{'3'},{'4'},{'5'},{'6'},{'7'},{'\geq8'}];
clim([0 8]);
xlabel('K_m (nM)','fontsize',8)
ylabel('V_m_a_x','fontsize',8)
title('placeholder','fontsize',8)
ylim([1 length(VmaxRange(1:30))])
yticks(1:5:length(VmaxRange(1:30)))
yticklabels(VmaxRange(1:5:30))
xticks(1:2:15)
xticklabels(KmRange(2:2:15))
ylabel(c,'|8 - modeled steepness|','fontsize',8)
ax = gca;
ax.Box='off';
ax.XAxis.FontSize = 7; % 7 pt font for tick labels
ax.YAxis.FontSize = 7;
ax.LineWidth = 0.5;
ax = gca;
ax.Box='off';
ax.XAxis.FontSize = 7; % 7 pt font for tick labels
ax.YAxis.FontSize = 7;
ax.LineWidth = 0.5;
set(f(2),'units','centimeters','position',[50,25,5.85,4.5])

% Option to save the image (specify file path)
% exportgraphics(f,'path to image','Resolution',300,'BackgroundColor','white')

f(3) = figure;
closeToPosition = positionForPlotting<=0.04; % allowing 10% deviation
closeToSteepness = steepnessForPlotting<=0.8; % allowing 10% deviation
bothGood = closeToPosition & closeToSteepness;
imagesc(bothGood)
colormap([[201, 179, 177]./255; 1 1 1])
xlabel('K_m (nM)','fontsize',8)
ylabel('V_m_a_x','fontsize',8)
title('within 10%','fontsize',8)
ylim([1 length(VmaxRange(1:30))])
yticks(1:5:length(VmaxRange(1:30)))
yticklabels(VmaxRange(1:5:30))
xticks(1:2:15)
xticklabels(KmRange(2:2:15))
ylabel(c,'|8 - modeled steepness|','fontsize',8)
ax = gca;
ax.Box='off';
ax.XAxis.FontSize = 7; % 7 pt font for tick labels
ax.YAxis.FontSize = 7;
ax.LineWidth = 0.5;
set(f(3),'units','centimeters','position',[50,25,5,4.5])

% Option to save the image (specify file path)
% exportgraphics(f,'path to image','Resolution',300,'BackgroundColor','white')

