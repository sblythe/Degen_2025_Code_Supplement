
% load MS2 data
load('path to MS2 summary structures (hb_WT_summaries.mat in ExperimentalData')

% Specify where you'd like your figure saved
savePath = 'placeholder/';


%% Plot MS2 onset time sorted heatmap
close all

cmap1 = [linspace(0.0118,0.0588,120)' linspace(0.0196,0.6549,120)' linspace(0.4314,1,120)'];
cmap2 = [linspace(0.0588,1,120)' linspace(0.6549,1,120)' linspace(1,0,120)'];
cmap3 = [linspace(1,1,120)' linspace(1,0,120)' linspace(0,0,120)'];
cmap = [cmap1; cmap2; cmap3];
close all

mega = combineFiltMS2(hb);
[onsets ordered] = sortByOnTime(mega);

topPixel = max(ordered(:));
ordered(ordered >= 0.9*topPixel) = 0.9*topPixel; % cap pixel values at the 90th percentile

f = figure;
imagesc(ordered)
colormap(cmap)
c = colorbar;
c.FontSize = 6;
c.LineWidth = 0.5;

xlabel('Minutes post anaphase 12','fontsize',8)
ylabel('Nuclei','fontsize',8)
xticks(0:12:96)
xticklabels(0:2:16)
xlim([0 100])

ax=gca;
ax.Box='off';
ax.XAxis.FontSize = 7; % 7 pt font for tick labels
ax.YAxis.FontSize = 7;
ax.LineWidth = 0.5;
set(f,'units','centimeters','position',[50,25,6.75,10]) % dimensions for figure draft 1

% To save the figure: uncomment the line below and specify the file path savePath
% exportgraphics(f,strcat(savePath,'data_heatmap.tif'),'Resolution',300,'BackgroundColor','white')

%%
function [ontimes, sorted] = sortByOnTime(taggedsortedms2)
    
    sortedms2 = taggedsortedms2(:,2:end);
    sortedms2(isnan(sortedms2)) = 0;
    on_point = zeros(size(sortedms2,1),1);
    for j = 1:size(sortedms2,1)
        nonzero = find(sortedms2(j,:),1,'first');
        if nonzero
            on_point(j) = nonzero;
        else
            on_point(j) = nan;
        end
    end

    onpoints_mega = [on_point taggedsortedms2(:,2:end)];
    onpoints_sorted = sortrows(onpoints_mega,1,'ascend');
    sorted = onpoints_sorted(~isnan(onpoints_sorted(:,1)),2:end);
    ontimes = ~isnan(onpoints_sorted(:,1));

end
