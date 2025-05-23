function [mean_slopes std_slopes] = plotMeanSlopesByMov(summaries_all,titleString)

    % Heatmap of fraction active per movie
    binWidth = 0.025;
    xs = 0:binWidth:1;
    binnedSlopes_all = zeros(length(summaries_all),1/binWidth);
    forHeatmap = zeros(length(summaries_all),1/binWidth);
    APRanges = [];
    for i = 1:length(summaries_all)
        filt = filterTracks_v4(summaries_all{i}); % NOTE filt has the AP position tags in the first column
        scaled = bin2D(filt(:,2:end)); % scales matrices by finding the averages in 100 bins
        scaled_tagged = [filt(:,1) scaled];
                
        % Remove inactive nuclei (no ms2 signal) and the meanAP column (first column)
        ms2mat = scaled_tagged(sum(scaled_tagged(:,2:end)>0,2)>0,2:end);

        % Remove nans 
        ms2mat(isnan(ms2mat)) = 0; 

        % Create aligned matrix
        alignedMat = zeros(size(ms2mat));
        allstarts = [];
        onsets = [];
        for j = 1:size(ms2mat,1)
    
            startT = find(ms2mat(j,:),1,'first'); % using >0 so don't find the first "nan"
            onsets = [onsets startT];
            stopT = find(ms2mat(j,:),1,'last');
            lengthMS2 = stopT-startT+1;
    
            newTrack = zeros(1,size(ms2mat,2)); % this length will be 100 (unless the bin2D function has been changed)
            newTrack(1,1:lengthMS2) = ms2mat(j,startT:stopT);
            alignedMat(j,:) = newTrack;
    
            allstarts = [allstarts startT]; % keep track of the startT from all movies to determine the delay to add (lowest startT)
        end
    

        timespan = 6; % time interval to find slope over. 6 x 10-second frames 
        AP = scaled_tagged(sum(scaled_tagged(:,2:end)>0,2)>0,1);
        AP_aligned = [AP alignedMat];

        section = alignedMat(:,1:timespan);
        smoothed = movmean(section,5,2); 
        slopes = (smoothed(:,timespan)-smoothed(:,1))./1; % dividing by one minute, the equivalent of timespan = 6

        bins = discretize(AP,xs);
        binnedSlopes = nan(1,1/binWidth);
        for j = 1:max(bins)
            
            binnedSlopes(j) = mean(slopes(bins==j),'omitnan');
        end

        binnedSlopes_all(i,:) = binnedSlopes;

        ant_AP = min(filt(:,1));
        post_AP = max(filt(:,1));

        ant_bin = discretize(ant_AP,xs);
        post_bin = discretize(post_AP,xs);    

        binnedSlopes(isnan(binnedSlopes)) = 0;
        binnedSlopes(1:(ant_bin-1)) = nan;
        binnedSlopes((post_bin+1):end) = nan;

        forHeatmap(i,:) = binnedSlopes;
        APRanges=[APRanges; ant_bin post_bin];

    end

    
    forHeatmap(forHeatmap == 0) = 2;
    forHeatmap(isnan(forHeatmap)) = 0;

    tagged = sortrows([APRanges(:,1) forHeatmap],1,'ascend');
    toplot = tagged(:,2:end);

    % create the colormap. Go from white to cyan.
    lowColor = [0 0 0];
    cyan = [2, 231, 247]./256;
    cmap = [[245, 245, 245]./255; linspace(lowColor(1), cyan(1),256)', linspace(lowColor(2),cyan(2),256)', linspace(lowColor(3),cyan(3),256)'];

    % Heatmap
    f = figure; 
    imagesc(toplot)
    colormap(cmap)
    caxis([0 max(binnedSlopes_all(:))]);
    c=colorbar;
    c.FontSize = 7;
    c.Title.String = 'AU/minute';
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
%     exportgraphics(f,strcat(savePath,'slopesHeatmap.tif'),'Resolution',300,'BackgroundColor','white')


    % Line plot
    mean_slopes = mean(binnedSlopes_all,1,'omitnan');
    std_slopes = std(binnedSlopes_all,0,1,'omitnan');

    f = figure; 
    shadedErrorBar(1:length(mean_slopes),mean_slopes,std_slopes,[0 0.8 0.8],1.5,0.2);

    xlim([8 32])
    xticks(8:4:32)
    xticklabels(20:10:80)
    ylim([-150 450])
    xlabel('AP Position (%)','fontsize',8)
    ylabel('AU (min^{-1})','fontsize',8)
    title(titleString,'fontsize',8)

    ax=gca;
    ax.Box='off';
    ax.XAxis.FontSize = 7; % 7 pt font for tick labels
    ax.YAxis.FontSize = 7;
    ax.LineWidth = 0.5;
    ax.YAxis.Exponent = 2;
    set(f,'units','centimeters','position',[50,25,5,4.5])
    
    % To save the figure: uncomment the line below and specify the file path savePath
%     exportgraphics(f,strcat(savePath,'meanSlopesAcrossMovs.tif'),'Resolution',300,'BackgroundColor','white')


end

