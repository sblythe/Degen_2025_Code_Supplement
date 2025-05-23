
% load hbP2-MS2 data
load('/Volumes/BlytheLab_Files/Imaging/Ellie/MS2_Analysis_new/summaryStructures/hb_240624.mat')


%% Amplitude, duration, cumulative analysis
% Filter and combine datasets
mega = combineFiltMS2(hb); % AP position tags in column one
APs = mega(:,1);

% Find maximums (95th percentile) across the AP axis
recordTimes = zeros(size(mega(:,2:end)));
maxes = zeros(size(mega,1),1);
durations = zeros(size(mega,1),1);
timeToMax = zeros(size(mega,1),1);
onsets = zeros(size(mega,1),1);
latencyOfMax = zeros(size(mega,1),1);
globals = zeros(size(mega,1),1);
totals = zeros(size(mega,1),1);

tracks = mega(:,2:end);
int_global = prctile(tracks(tracks>0),90);
for i = 1:size(mega,1)
    nuc = mega(i,2:end);
    onset = find(nuc>0,1);
    nonzeroInt = nuc(nuc>0);
    int_90 = prctile(nonzeroInt,90);

    if isempty(onset)

        timePt = NaN;
        maxes(i) = NaN;
        timeToMax(i) = NaN;
        onset = NaN;
        latencyOfMax(i) = NaN;

    else

        timePt = find(nuc>=int_90,1);
        maxes(i) = nuc(timePt);
        recordTimes(i,timePt) = 1;
        timeToMax(i) = timePt;
        latencyOfMax(i) = timePt-onset;

    end

    timeGlobal = find(nuc>=int_global,1);
    if isempty(timeGlobal)

        globals(i) = NaN;

    else

        globals(i) = timeGlobal;

    end

    durations(i) = sum(nuc>0);
    onsets(i) = onset;
    totals(i) = sum(nuc,'omitnan');
end

maxes(maxes==0) = nan;
maxes_nonan = maxes(~isnan(maxes));
AP_nonan = APs(~isnan(maxes));
dur_nonan = durations(~isnan(maxes));
times_nonan = timeToMax(~isnan(maxes));
onsets_nonan = onsets(~isnan(maxes));
latencies_nonan = latencyOfMax(~isnan(maxes));
totals_nonan = totals(~isnan(maxes));


% Find the 95% confidence interval to plot rolling averages over
AP_bins = 0.2:0.01:0.8;
Y = discretize(AP_nonan,AP_bins);
maxes_bool = maxes_nonan > 0;
spot_positions = [];
for i = 1:length(AP_bins)
    spot_positions = [spot_positions; AP_bins(i).*ones(sum(maxes_bool(Y==i)),1)];
end

borderAP = mean(spot_positions)+1.96*std(spot_positions); % border position to use for future plotting. Use 1.96 for paper!!


%% Plot the amplitudes
close all

f = figure;
p = scatter(AP_nonan*100,maxes_nonan,5,'k','o','filled'); % plot the point

% Calculate rolling average and plot
rollAvg = movmean(maxes_nonan(AP_nonan<=borderAP),100);
rollSD = movstd(maxes_nonan(AP_nonan<=borderAP),100);
plotAP = AP_nonan(AP_nonan<=borderAP)*100;

hold on;
shadedErrorBar(plotAP,rollAvg,rollSD,[100,149,237]./255,1,0.4) % corn flower blue: 100,149,237

alpha(p,0.06)
ylabel('Intensity (AU)','fontsize',8)
xlabel('AP Position (%)','fontsize',8)
title('Amplitude','fontsize',8)

xlim([20 80])
xticks(20:20:80)
xticklabels(20:20:80)
ax=gca;
ax.Box='off';
ax.XAxis.FontSize = 7; % 7 pt font for tick labels
ax.YAxis.FontSize = 7;
ax.LineWidth = 0.5;
ax.YAxis.Exponent = 3;
set(f,'units','centimeters','position',[50,25,5,4.5])

% To save the figure: uncomment the line below and specify the file path savePath
% exportgraphics(f,strcat(savePath,'amplitudeVsAP.tif'),'Resolution',300,'BackgroundColor','white')

%% Plot the amplitudes, filtered by onsets
framesPerMin = 6;

minOnset = 0;
maxOnset = 20;
onsets_min = onsets_nonan./framesPerMin;
maxes_range = maxes_nonan(onsets_min>minOnset & onsets_min<=maxOnset);
APs_range = AP_nonan(onsets_min>minOnset & onsets_min<=maxOnset);

% Calculate rolling average and plot
rollAvg = movmean(maxes_range(APs_range<=borderAP),100);
rollSD = movstd(maxes_range(APs_range<=borderAP),100);
plotAP = APs_range(APs_range<=borderAP)*100;


f = figure;
p = scatter(APs_range*100,maxes_range,5,'k','o','filled'); % plot the point
hold on;
shadedErrorBar(plotAP,rollAvg,rollSD,[100,149,237]./255,1,0.4) % corn flower blue: 100,149,237
alpha(p,0.06)
ylabel('Intensity (AU)','fontsize',8)
xlabel('AP Position (%)','fontsize',8)
title('Amplitude','fontsize',8)

xlim([20 80])
xticks(20:20:80)
xticklabels(20:20:80)
ylim([0 2000])
ax=gca;
ax.Box='off';
ax.XAxis.FontSize = 7; % 7 pt font for tick labels
ax.YAxis.FontSize = 7;
ax.LineWidth = 0.5;
set(f,'units','centimeters','position',[50,25,5,4.5])


%% Plot the durations
framesPerMin = 6;
close all

f = figure;
p = scatter(AP_nonan*100,dur_nonan./framesPerMin,5,'k','o','filled'); % plot the point

% Calculate rolling average and plot
rollAvg = movmean(dur_nonan(AP_nonan<=borderAP),100)./framesPerMin;
rollSD = movstd(dur_nonan(AP_nonan<=borderAP),100)./framesPerMin;
plotAP = AP_nonan(AP_nonan<=borderAP)*100;

hold on;
shadedErrorBar(plotAP,rollAvg,rollSD,[100,149,237]./255,1,0.4) % corn flower blue: 100,149,237

alpha(p,0.06)
ylabel('Minutes','fontsize',8)
xlabel('AP Position (%)','fontsize',8)
title('Duration','fontsize',8)

xlim([20 80])
xticks(20:20:80)
xticklabels(20:20:80)
ylim([0 15])
ax=gca;
ax.Box='off';
ax.XAxis.FontSize = 7; % 7 pt font for tick labels
ax.YAxis.FontSize = 7;
ax.LineWidth = 0.5;
set(f,'units','centimeters','position',[50,25,5,4.5])

% To save the figure: uncomment the line below and specify the file path savePath
% exportgraphics(f,strcat(savePath,'durationVsAP.tif'),'Resolution',300,'BackgroundColor','white')

%% Scatter plot of amplitude vs. duration
f = figure;
p = scatter(dur_nonan(AP_nonan<=borderAP)./framesPerMin,maxes_nonan(AP_nonan<=borderAP),5,'k','o','filled'); % plot the point
alpha(p,0.1)
xlabel('Duration (min)','fontsize',8)
ylabel('Amplitude (AU)','fontsize',8)
title('title','fontsize',8)
ax=gca;
ax.Box='off';
ax.XAxis.FontSize = 7; % 7 pt font for tick labels
ax.YAxis.FontSize = 7;
ax.LineWidth = 0.5;
ax.YAxis.Exponent = 3;
set(f,'units','centimeters','position',[50,25,5,4.5])

l = lsline(ax);
l.Color = [1 0 0];
l.LineWidth = 1.5;

figure
test = [maxes_nonan(AP_nonan<=borderAP) dur_nonan(AP_nonan<=borderAP)./framesPerMin];
R = corrplot(test);

% To save the figure: uncomment the line below and specify the file path savePath
% exportgraphics(f,strcat(savePath,'dur_amp_scatter.tif'),'Resolution',300,'BackgroundColor','white')

%% Scatter plot of onset vs. duration
framesPerMin = 6;

close all
f = figure;
p = scatter(onsets_nonan(AP_nonan<=borderAP)./framesPerMin,dur_nonan(AP_nonan<=borderAP)./framesPerMin,5,'k','o','filled'); % plot the point
alpha(p,0.1)
xlabel('Onset time (min)','fontsize',8)
ylabel('Duration (min)','fontsize',8)
title('title','fontsize',8)
ax=gca;
ax.Box='off';
ax.XAxis.FontSize = 7; % 7 pt font for tick labels
ax.YAxis.FontSize = 7;
ax.LineWidth = 0.5;
set(f,'units','centimeters','position',[50,25,5,4.5])

l = lsline(ax);
l.Color = [1 0 0];
l.LineWidth = 1.5;

figure
test = [onsets_nonan(AP_nonan<=borderAP)./framesPerMin dur_nonan(AP_nonan<=borderAP)./framesPerMin];
R = corrplot(test);

% To save the figure: uncomment the line below and specify the file path savePath
% exportgraphics(f,strcat(savePath,'onset_dur_scatter.tif'),'Resolution',300,'BackgroundColor','white')

%% Scatter plot of onset vs. amplitude
f = figure;
p = scatter(onsets_nonan(AP_nonan<=borderAP)./framesPerMin,maxes_nonan(AP_nonan<=borderAP),5,'k','o','filled'); % plot the point
alpha(p,0.1)
xlabel('Onset time (min)','fontsize',8)
ylabel('Amplitude (AU)','fontsize',8)
title('title','fontsize',8)
ax=gca;
ax.Box='off';
ax.XAxis.FontSize = 7; % 7 pt font for tick labels
ax.YAxis.FontSize = 7;
ax.LineWidth = 0.5;
set(f,'units','centimeters','position',[50,25,5,4.5])
ax.YAxis.Exponent = 3;

l = lsline(ax);
l.Color = [1 0 0];
l.LineWidth = 1.5;

figure
test = [onsets_nonan(AP_nonan<=borderAP)./framesPerMin maxes_nonan(AP_nonan<=borderAP)];
R = corrplot(test);

% To save the figure: uncomment the line below and specify the file path savePath
% exportgraphics(f,strcat(savePath,'onset_amp_scatter.tif'),'Resolution',300,'BackgroundColor','white')

%% Plot the times to amplitude (starting at t = 0)
close all

figure;
imagesc(recordTimes)

framesPerMin = 6;

f = figure;
p = scatter(AP_nonan*100,times_nonan./framesPerMin,5,'k','o','filled'); % plot the point

% Calculate rolling average and plot
rollAvg = movmean(times_nonan(AP_nonan<=borderAP),100)./framesPerMin;
rollSD = movstd(times_nonan(AP_nonan<=borderAP),100)./framesPerMin;
plotAP = AP_nonan(AP_nonan<=borderAP)*100;

hold on;
shadedErrorBar(plotAP,rollAvg,rollSD,[100,149,237]./255,1,0.4) % corn flower blue: 100,149,237

alpha(p,0.06)
ylabel('Minutes','fontsize',8)
xlabel('AP Position (%)','fontsize',8)
title('Time to max','fontsize',8)

xlim([20 80])
xticks(20:20:80)
xticklabels(20:20:80)
ax=gca;
ax.Box='off';
ax.XAxis.FontSize = 7; % 7 pt font for tick labels
ax.YAxis.FontSize = 7;
ax.LineWidth = 0.5;
set(f,'units','centimeters','position',[50,25,5,4.5])

%% Plot the times to amplitude (starting at t = onset)
close all
framesPerMin = 6;

f = figure;
p = scatter(AP_nonan*100,latencies_nonan./framesPerMin,5,'k','o','filled'); % plot the point

% Calculate rolling average and plot
rollAvg = movmean(latencies_nonan(AP_nonan<=borderAP),100)./framesPerMin;
rollSD = movstd(latencies_nonan(AP_nonan<=borderAP),100)./framesPerMin;
plotAP = AP_nonan(AP_nonan<=borderAP)*100;

hold on;
shadedErrorBar(plotAP,rollAvg,rollSD,[100,149,237]./255,1,0.4) % corn flower blue: 100,149,237

alpha(p,0.06)
ylabel('Minutes','fontsize',8)
xlabel('AP Position (%)','fontsize',8)
title('Latency of max','fontsize',8)

xlim([20 80])
xticks(20:20:80)
xticklabels(20:20:80)
ylim([0 10])
ax=gca;
ax.Box='off';
ax.XAxis.FontSize = 7; % 7 pt font for tick labels
ax.YAxis.FontSize = 7;
ax.LineWidth = 0.5;
set(f,'units','centimeters','position',[50,25,5,4.5])

%% Plot time to global maximum
close all
framesPerMin = 6;

globals_nonan = globals(~isnan(globals));
APs_globals = APs(~isnan(globals));

f = figure;
p = scatter(APs_globals*100,globals_nonan./framesPerMin,5,'k','o','filled'); % plot the point

% Calculate rolling average and plot
rollAvg = movmean(globals_nonan(APs_globals<=borderAP),100)./framesPerMin;
rollSD = movstd(globals_nonan(APs_globals<=borderAP),100)./framesPerMin;
plotAP = APs_globals(APs_globals<=borderAP)*100;

hold on;
shadedErrorBar(plotAP,rollAvg,rollSD,[100,149,237]./255,1,0.4) % corn flower blue: 100,149,237

alpha(p,0.06)
ylabel('Minutes','fontsize',8)
xlabel('AP Position (%)','fontsize',8)
title('Time to global max','fontsize',8)

xlim([20 80])
xticks(20:20:80)
xticklabels(20:20:80)
% ylim([0 10])
ax=gca;
ax.Box='off';
ax.XAxis.FontSize = 7; % 7 pt font for tick labels
ax.YAxis.FontSize = 7;
ax.LineWidth = 0.5;
set(f,'units','centimeters','position',[50,25,5,4.5])

%% Summed output
close all
framesPerMin = 6;


f = figure;
p = scatter(AP_nonan*100,totals_nonan,5,'k','o','filled'); % plot the point
alpha(p,0.06)

% Calculate rolling average and plot
rollAvg = movmean(totals_nonan(AP_nonan<=borderAP),100);
rollSD = movstd(totals_nonan(AP_nonan<=borderAP),100);
plotAP = AP_nonan(AP_nonan<=borderAP)*100;

hold on;
shadedErrorBar(plotAP,rollAvg,rollSD,[100,149,237]./255,1,0.4) % corn flower blue: 100,149,237

ylabel('Intensity (AU)','fontsize',8)
xlabel('AP Position (%)','fontsize',8)
title('Total output','fontsize',8)

xlim([20 80])
xticks(20:20:80)
xticklabels(20:20:80)
ylim([0 8e+4])
ax=gca;
ax.Box='off';
ax.XAxis.FontSize = 7; % 7 pt font for tick labels
ax.YAxis.FontSize = 7;
ax.LineWidth = 0.5;
set(f,'units','centimeters','position',[50,25,5,4.5])

exportgraphics(f,strcat(savePath,'sumVsAP.tif'),'Resolution',300,'BackgroundColor','white')

%% Scatter plot of duration vs. summed output
f = figure;
p = scatter(dur_nonan(AP_nonan<=borderAP)./framesPerMin,totals_nonan(AP_nonan<=borderAP),5,'k','o','filled'); % plot the point
alpha(p,0.1)
xlabel('Duration (min)','fontsize',8)
ylabel('Total output (AU)','fontsize',8)
title('title','fontsize',8)
ax=gca;
ax.Box='off';
ax.XAxis.FontSize = 7; % 7 pt font for tick labels
ax.YAxis.FontSize = 7;
ax.LineWidth = 0.5;
set(f,'units','centimeters','position',[50,25,5,4.5])

l = lsline(ax);
l.Color = [1 0 0];
l.LineWidth = 1.5;

figure
test = [dur_nonan(AP_nonan<=borderAP)./framesPerMin totals_nonan(AP_nonan<=borderAP)];
R = corrplot(test);

% To save the figure: uncomment the line below and specify the file path savePath
% exportgraphics(f,strcat(savePath,'dur_total_scatter.tif'),'Resolution',300,'BackgroundColor','white')

%% Scatter plot of amplitude vs. summed output
f = figure;
p = scatter(totals_nonan(AP_nonan<=borderAP),maxes_nonan(AP_nonan<=borderAP),5,'k','o','filled'); % plot the point
alpha(p,0.1)
xlabel('Total output (AU)','fontsize',8)
ylabel('Amplitude (AU)','fontsize',8)
title('title','fontsize',8)
ax=gca;
ax.Box='off';
ax.XAxis.FontSize = 7; % 7 pt font for tick labels
ax.YAxis.FontSize = 7;
ax.LineWidth = 0.5;
ax.YAxis.Exponent = 3;
set(f,'units','centimeters','position',[50,25,5,4.5])

l = lsline(ax);
l.Color = [1 0 0];
l.LineWidth = 1.5;

figure
test = [maxes_nonan(AP_nonan<=borderAP) totals_nonan(AP_nonan<=borderAP)];
R = corrplot(test);

% To save the figure: uncomment the line below and specify the file path savePath
% exportgraphics(f,strcat(savePath,'total_amp_scatter.tif'),'Resolution',300,'BackgroundColor','white')

