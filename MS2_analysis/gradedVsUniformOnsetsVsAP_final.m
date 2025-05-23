
load('path to uniform Bcd MS2 summary structures')
load('path to WT MS2 summary structures')

% Specify where you'd like your figure saved
savePath = 'placeholder/';

%% NOTE: check that when you run the functions below you aren't saving new images (comment out the save command)
[graded_AP_avg_SD, APs, ontimes] = onsetVsAP_sampled_final(hb,'HbP2 MS2 in graded Bicoid');
[uniform_AP_avg_SD, APs_uniform, ontimes_uniform] = onsetVsAP_sampled_final(uBcd_HbP2_summaries,'HbP2 MS2 in uniform Bicoid');

%%
close all
framesPerMin = 6;

f = figure;

% Bin different genotypes so can compare across the axis
APs = 0:1:100;

mean_wt = graded_AP_avg_SD(:,1);
binned_wt = discretize(mean_wt,APs);

mean_uni = uniform_AP_avg_SD(:,1);
binned_uni = discretize(mean_uni,APs);

onset_binned_wt = zeros(length(APs),1);
onset_binned_uni = zeros(length(APs),1);
for i = 1:length(APs)

    if sum(binned_wt == i) > 0
        onset_binned_wt(i) = mean(graded_AP_avg_SD(binned_wt == i,2));
    else
        onset_binned_wt(i) = nan;
    end

    if sum(binned_uni == i)
        onset_binned_uni(i) = mean(uniform_AP_avg_SD(binned_uni == i,2));
    else
        onset_binned_uni(i) = nan;
    end
end

diffs = onset_binned_wt - onset_binned_uni;
% [~, ix] = min(abs(diffs),[],'omitnan')
% xline(ix,'--');
ix = find(diffs<0.001 & diffs>-0.001);

% rec=rectangle('position',[ix(1) 0 ix(2)-ix(1) 18],'FaceColor',[0.9 0.9 0.9],'EdgeColor',[250, 245, 227]./256); 
% hold on;

p = scatter(APs_uniform*100,ontimes_uniform./framesPerMin,5,'k','o','filled'); % plot the point
alpha(p,0.1)
line(nan, nan, 'Linestyle', 'none', 'Marker', 'none', 'Color', 'none');
line(nan, nan, 'Linestyle', 'none', 'Marker', 'none', 'Color', 'none');
shadedErrorBar(graded_AP_avg_SD(:,1), graded_AP_avg_SD(:,2), graded_AP_avg_SD(:,3),[227, 85, 14]./255, 1, 0.4)
hold on
shadedErrorBar(uniform_AP_avg_SD(:,1), uniform_AP_avg_SD(:,2), uniform_AP_avg_SD(:,3), [100,149,237]./255, 1, 0.4)

hold on
xline(sum(ix)/2,'--','linewidth',0.5)

ylabel('Onset Time (min)','fontsize',8)
xlabel('AP Position (%)','fontsize',8)
title('Merge','fontsize',8)

xlim([20 80])
xticks(20:10:80)
xticklabels(20:10:80)
ylim([0 15]) 
ax = gca;
set(ax,'layer','top')
set(gcf,'color','w');
ax.Box = 'off';
ax.XAxis.FontSize = 7; % 7 pt font for tick labels
ax.YAxis.FontSize = 7;
ax.LineWidth = 0.5;

l = legend('','Graded Bicoid','Uniform Bicoid');
l.FontSize = 6;
l.Box = 'off';
l.Location = 'southeast';
set(f,'units','centimeters','position',[50,25,5,4.5])

% To save the figure: uncomment the line below and specify the file path savePath
% exportgraphics(f,strcat(savePath,'graded_uniform_overlay.tif'),'Resolution',300,'BackgroundColor','white')