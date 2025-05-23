function [mean_onsets std_onsets] = plotMeanOnsetsByMov(summaries_all,titleString)
    
    framesPerMin = 6; 

    % Heatmap of fraction active per movie
    binWidth = 0.025;
    xs = 0:binWidth:1;
    binnedOnsets_all = zeros(length(summaries_all),1/binWidth);
    forHeatmap = zeros(length(summaries_all),1/binWidth);
    APRanges = [];
    for i = 1:length(summaries_all)
        filt = filterTracks_v4(summaries_all{i}); % NOTE filt has the AP position tags in the first column
        scaled = bin2D(filt(:,2:end)); % scales matrices by finding the averages in 100 bins
        scaled_tagged = [filt(:,1) scaled];
        
        [meanAP_ontimes_maxms2] = sortOnTimesByAP(scaled_tagged);
        ontimes = meanAP_ontimes_maxms2(:,2);
        ontimes_nonan = ontimes(~isnan(ontimes));
        APs = meanAP_ontimes_maxms2(:,1);
        meanAP_nonan = APs(~isnan(ontimes));

        bins = discretize(meanAP_nonan,xs);
        binnedOnsets = nan(1,1/binWidth);
        for j = 1:max(bins)
            binnedOnsets(j) = mean(ontimes_nonan(bins==j));
        end
        binnedOnsets_all(i,:) = binnedOnsets;

        ant_AP = min(filt(:,1));
        post_AP = max(filt(:,1));

        ant_bin = discretize(ant_AP,xs);
        post_bin = discretize(post_AP,xs);    

        binnedOnsets(isnan(binnedOnsets)) = 0;
        binnedOnsets(1:(ant_bin-1)) = nan;
        binnedOnsets((post_bin+1):end) = nan;

        forHeatmap(i,:) = binnedOnsets;
        APRanges=[APRanges; ant_bin post_bin];

    end
    
    forHeatmap(forHeatmap == 0) = 0.3;
    forHeatmap(isnan(forHeatmap)) = 0;

    tagged=sortrows([APRanges(:,1) forHeatmap],1,'ascend');
    toplot = tagged(:,2:end);

    % create the colormap. Go from white to cyan.
    lowColor = [0 0 0];
    cyan = [2, 231, 247]./256;
    cmap = [[245, 245, 245]./255; linspace(lowColor(1), cyan(1),256)', linspace(lowColor(2),cyan(2),256)', linspace(lowColor(3),cyan(3),256)'];

    % Heatmap
    f = figure; 
    imagesc(toplot./framesPerMin)
    colormap(cmap)
    caxis([0 max(binnedOnsets_all(:))/framesPerMin]);
    c = colorbar;
    c.FontSize = 7;
    c.Title.String = 'Minutes';
    c.Title.FontSize = 7;
    xlim([8 32])
    xticks(8:4:32)
    xticklabels(20:10:80)
    yticks(0:3:18)
    yticklabels(0:3:18)
    xlabel('AP Position (%)','fontsize',8)
    ylabel('Embryo','fontsize',8)
    title(titleString,'fontsize',8)
    ax=gca;
    ax.XAxis.FontSize = 7; % 7 pt font for tick labels
    ax.YAxis.FontSize = 7;
    ax.LineWidth = 0.5;
    set(f,'units','centimeters','position',[50,25,6.5,4.5])

    % To save the figure: uncomment the line below and specify the file path savePath
%     exportgraphics(f,strcat(savePath,'onsetTimeHeatmap.tif'),'Resolution',300,'BackgroundColor','white')


    % Line plot
    mean_onsets = mean(binnedOnsets_all./framesPerMin,1,'omitnan');
    std_onsets = std(binnedOnsets_all./framesPerMin,0,1,'omitnan');

    f = figure; 
    shadedErrorBar(1:length(mean_onsets),mean_onsets,std_onsets,[0 0.8 0.8],1.5,0.2);
    xlim([8 32])
    xticks(8:4:32)
    xticklabels(20:10:80)
    ylim([0 15])
    xlabel('AP Position (%)','fontsize',8)
    ylabel('Minutes post anaphase','fontsize',8)
    title(titleString,'fontsize',8)

    ax = gca;
    ax.Box = 'off';
    ax.XAxis.FontSize = 7; % 7 pt font for tick labels
    ax.YAxis.FontSize = 7;
    ax.LineWidth = 0.5;
    set(f,'units','centimeters','position',[50,25,5,4.5])
    
    % To save the figure: uncomment the line below and specify the file path savePath
%     exportgraphics(f,strcat(savePath,'meanOnsetsAcrossMovs.tif'),'Resolution',300,'BackgroundColor','white')

end

